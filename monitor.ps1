# Script en PowerShell
function Show-Menu {
    param (
        [string]$title = 'Menu'
    )
    Write-Host "================ $title ================"
    Write-Host "1. Monitorear estado de la memoria"
    Write-Host "2. Monitorear estado de los discos"
    Write-Host "3. Monitorear estado de los procesos / CPU"
    Write-Host "0. Salir"
}

function Monitor-Memory {
    # Listado de top 10 de uso de memoria por proceso
    Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 10

    # Estado general de memoria
    $memInfo = Get-WmiObject -Class Win32_OperatingSystem
    $totalMemory = [math]::round($memInfo.TotalVisibleMemorySize / 1KB, 2)
    $freeMemory = [math]::round($memInfo.FreePhysicalMemory / 1KB, 2)
    $usedMemory = $totalMemory - $freeMemory
    Write-Output "Total Physical Memory: $totalMemory MB"
    Write-Output "Used Physical Memory: $usedMemory MB"
    Write-Output "Free Physical Memory: $freeMemory MB"

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    $outputPath = Join-Path -Path $PWD -ChildPath "MemoryUsageReport.csv"
    Start-Job -ScriptBlock {
        param($processId, $outputPath)
        for ($i = 0; $i -lt 3000; $i++) {
            $memoryUsage = (Get-Process -Id $processId).WorkingSet / 1KB
            [PSCustomObject]@{ Timestamp = (Get-Date); MemoryUsage = $memoryUsage } | Export-Csv -Path $outputPath -Append -NoTypeInformation
            Start-Sleep -Milliseconds 100
        }
    } -ArgumentList $processId, $outputPath | Out-Null
    Write-Host "Monitoreo de memoria iniciado en background"
}

function Monitor-Disks {
    # Listado de top 10 de archivos más grandes en el sistema
    Write-Output "========================== START - Top 10 de archivos más grandes en el sistema =========================="
    Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property Length -Descending | Select-Object -First 10
    Write-Output "========================== END - Top 10 de archivos más grandes en el sistema =========================="

    # Estado general de los discos por partición
    Write-Output "========================== START - Estado general de los discos por partición =========================="
    Get-PSDrive -PSProvider FileSystem
    Write-Output "========================== END - Estado general de los discos por partición =========================="

    # Monitorear una ruta específica
    $path = Read-Host "Ingrese la ruta para monitorear"
    $outputPath = Join-Path -Path $PWD -ChildPath "DiskUsageReport.csv"
    Start-Job -ScriptBlock {
        param($path, $outputPath)
        for ($i = 0; $i -lt 3000; $i++) {
            $fileUsage = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property LastAccessTime -Descending | Select-Object -First 3
            [PSCustomObject]@{ Timestamp = (Get-Date); FileUsage = $fileUsage } | Export-Csv -Path $outputPath -Append -NoTypeInformation
            Start-Sleep -Milliseconds 100
        }
    } -ArgumentList $path, $outputPath | Out-Null
    Write-Host "Monitoreo de discos iniciado en background"
}

function Monitor-CPU {
    # Listado de top 10 de procesos con mayor uso de CPU
    Write-Output "========================== START - top 10 de procesos con mayor uso de CPU =========================="
    Write-Output "ProcessName, ID, CPU, WorkingSet, VirtualMemorySize, TotalProcessorTime, UserProcessorTime, PrivilegedProcessorTime"
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10 | Format-Table -Property ProcessName, Id, CPU, WorkingSet, VirtualMemorySize, TotalProcessorTime, UserProcessorTime, PrivilegedProcessorTime
    Write-Output "========================== END - top 10 de procesos con mayor uso de CPU =========================="

    # Estado general de la CPU
    Write-Output "========================== START - Estado general de la CPU =========================="
    $cpuInfo = Get-WmiObject -Class Win32_Processor | Select-Object -Property LoadPercentage
    Write-Output $cpuInfo
    Write-Output "========================== END - Estado general de la CPU =========================="

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    $outputPath = Join-Path -Path $PWD -ChildPath "CPUUsageReport.csv"
    Start-Job -ScriptBlock {
        param($processId, $outputPath)
        for ($i = 0; $i -lt 3000; $i++) {
            $cpuUsage = (Get-Process -Id $processId).CPU
            [PSCustomObject]@{ Timestamp = (Get-Date); CPUUsage = $cpuUsage } | Export-Csv -Path $outputPath -Append -NoTypeInformation
            Start-Sleep -Milliseconds 100
        }
    } -ArgumentList $processId, $outputPath | Out-Null
    Write-Host "Monitoreo de CPU iniciado en background"
}

while ($true) {
    Show-Menu
    $option = Read-Host "Seleccione una opción"
    switch ($option) {
        1 { Monitor-Memory }
        2 { Monitor-Disks }
        3 { Monitor-CPU }
        0 { break }
        default { Write-Host "Opción no válida, intente nuevamente" }
    }
}
