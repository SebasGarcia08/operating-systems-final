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
    $memInfo = free -m | Select-String "Mem:"
    $memParts = $memInfo -replace '\s+', ' ' -split ' '
    $totalMemory = $memParts[1]
    $usedMemory = $memParts[2]
    $freeMemory = $memParts[3]
    Write-Output "Total Physical Memory: $totalMemory MB"
    Write-Output "Used Physical Memory: $usedMemory MB"
    Write-Output "Free Physical Memory: $freeMemory MB"

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    Start-Job -ScriptBlock {
        $processId = $using:processId
        $report = @()
        for ($i = 0; $i -lt 3000; $i++) {
            $memoryUsage = ps -p $processId -o %mem --no-headers
            $report += [PSCustomObject]@{ Timestamp = (Get-Date); MemoryUsage = $memoryUsage }
            Start-Sleep -Milliseconds 100
        }
        $report | Export-Csv -Path "MemoryUsageReport.csv" -NoTypeInformation
    }
    Write-Host "Monitoreo de memoria iniciado en background"
}

function Monitor-Disks {
    # Listado de top 10 de archivos más grandes en el sistema
    Write-Output "========================== START - Top 10 de archivos más grandes en el sistema =========================="
    Get-ChildItem -Path C:\ -Recurse | Sort-Object -Property Length -Descending | Select-Object -First 10
    Write-Output "========================== END - Top 10 de archivos más grandes en el sistema =========================="

    # Estado general de los discos por partición
    Write-Output "========================== START - Estado general de los discos por partición =========================="
    df -h
    Write-Output "========================== END - Estado general de los discos por partición =========================="

    # Monitorear una ruta específica
    $path = Read-Host "Ingrese la ruta para monitorear"
    Start-Job -ScriptBlock {
        $path = $using:path
        $report = @()
        for ($i = 0; $i -lt 3000; $i++) {
            $fileUsage = ls -lt $path | Select-String -First 3
            $report += [PSCustomObject]@{ Timestamp = (Get-Date); FileUsage = $fileUsage }
            Start-Sleep -Milliseconds 100
        }
        $report | Export-Csv -Path "DiskUsageReport.csv" -NoTypeInformation
    }
    Write-Host "Monitoreo de discos iniciado en background"
}

function Monitor-CPU {
    # Listado de top 10 de procesos con mayor uso de CPU
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10

    # Estado general de la CPU
    Write-Output "========================== START - Estado general de la CPU =========================="
    $cpuInfo = top -b -n1 | Select-String "Cpu(s)"
    Write-Output $cpuInfo
    Write-Output "========================== END - Estado general de la CPU =========================="

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    Start-Job -ScriptBlock {
        $processId = $using:processId
        $report = @()
        for ($i = 0; $i -lt 3000; $i++) {
            $cpuUsage = ps -p $processId -o %cpu --no-headers
            $report += [PSCustomObject]@{ Timestamp = (Get-Date); CPUUsage = $cpuUsage }
            Start-Sleep -Milliseconds 100
        }
        $report | Export-Csv -Path "CPUUsageReport.csv" -NoTypeInformation
    }
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
