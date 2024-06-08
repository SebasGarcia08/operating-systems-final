# Script en PowerShell para Linux
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
    Write-Output "========================== START - top 10 de uso de memoria por proceso =========================="
    ps -eo pid,pmem,comm --sort=-pmem | head -n 11
    Write-Output "========================== END - top 10 de uso de memoria por proceso =========================="

    # Estado general de memoria
    Write-Output "========================== START - Estado general de memoria =========================="
    free -h
    Write-Output "========================== END - Estado general de memoria =========================="

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    $outputPath = Join-Path -Path $PWD -ChildPath "MemoryUsageReport.csv"
    Start-Job -ScriptBlock {
        param($processId, $outputPath)
        $header = "Timestamp,Process ID,Memory Usage (KB)"
        $header | Out-File -FilePath $outputPath -Encoding UTF8
        for ($i = 0; $i -lt 3000; $i++) {
            $memoryUsage = (ps -p $processId -o pmem=)
            [PSCustomObject]@{ Timestamp = (Get-Date); ProcessId = $processId; MemoryUsage = $memoryUsage } | ConvertTo-Csv -NoTypeInformation -Append | Out-File -FilePath $outputPath -Append -Encoding UTF8
            Start-Sleep -Milliseconds 100
        }
    } -ArgumentList $processId, $outputPath | Out-Null
    Write-Host "Monitoreo de memoria iniciado en background"
}

function Monitor-Disks {
    # Listado de top 10 de archivos más grandes en el sistema
    Write-Output "========================== START - Top 10 de archivos más grandes en el sistema =========================="
    $largestFiles = & find / -type f -exec du -h {} + | sort -rh | head -n 10
    Write-Output $largestFiles
    Write-Output "========================== END - Top 10 de archivos más grandes en el sistema =========================="

    # Estado general de los discos por partición
    Write-Output "========================== START - Estado general de los discos por partición =========================="
    $diskInfo = df -h
    Write-Output $diskInfo
    Write-Output "========================== END - Estado general de los discos por partición =========================="

    # Monitorear una ruta específica
    $path = Read-Host "Ingrese la ruta para monitorear"
    $outputPath = Join-Path -Path $PWD -ChildPath "DiskUsageReport.csv"
    Start-Job -ScriptBlock {
        param($path, $outputPath)
        for ($i = 0; $i -lt 3000; $i++) {
            $fileUsage = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property LastAccessTime -Descending | Select-Object -First 3
            foreach ($file in $fileUsage) {
                [PSCustomObject]@{ Timestamp = (Get-Date); FilePath = $file.FullName; LastAccessTime = $file.LastAccessTime } | ConvertTo-Csv -NoTypeInformation -Append | Out-File -FilePath $outputPath -Append -Encoding UTF8
            }
            Start-Sleep -Milliseconds 100
        }
    } -ArgumentList $path, $outputPath | Out-Null
    Write-Host "Monitoreo de discos iniciado en background"
}

function Monitor-CPU {
    # Listado de top 10 de procesos con mayor uso de CPU
    Write-Output "========================== START - top 10 de procesos con mayor uso de CPU =========================="
    Write-Output "ProcessName, ID, CPU, RSS, VSZ, TIME+"
    ps -eo pid,pcpu,comm --sort=-pcpu | head -n 11
    Write-Output "========================== END - top 10 de procesos con mayor uso de CPU =========================="

    # Estado general de la CPU
    Write-Output "========================== START - Estado general de la CPU =========================="
    top -b -n1 | grep "Cpu(s)"
    Write-Output "========================== END - Estado general de la CPU =========================="

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    $outputPath = Join-Path -Path $PWD -ChildPath "CPUUsageReport.csv"
    Start-Job -ScriptBlock {
        param($processId, $outputPath)
        for ($i = 0; $i -lt 3000; $i++) {
            $cpuUsage = (ps -p $processId -o pcpu=)
            [PSCustomObject]@{ Timestamp = (Get-Date); ProcessId = $processId; CPUUsage = $cpuUsage } | ConvertTo-Csv -NoTypeInformation -Append | Out-File -FilePath $outputPath -Append -Encoding UTF8
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
