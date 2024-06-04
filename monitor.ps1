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
    Get-ComputerInfo | Select-Object -Property TotalPhysicalMemory, FreePhysicalMemory

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    $report = @()
    for ($i = 0; $i -lt 3000; $i++) {
        $memoryUsage = Get-Process -Id $processId | Select-Object -ExpandProperty WorkingSet
        $report += [PSCustomObject]@{ Timestamp = (Get-Date); MemoryUsage = $memoryUsage }
        Start-Sleep -Milliseconds 100
    }
    $report | Export-Csv -Path "MemoryUsageReport.csv" -NoTypeInformation
}

function Monitor-Disks {
    # Listado de top 10 de archivos más grandes en el sistema
    Get-ChildItem -Path C:\ -Recurse | Sort-Object -Property Length -Descending | Select-Object -First 10

    # Estado general de los discos por partición
    Get-PSDrive -PSProvider FileSystem

    # Monitorear una ruta específica
    $path = Read-Host "Ingrese la ruta para monitorear"
    $report = @()
    for ($i = 0; $i -lt 3000; $i++) {
        $fileUsage = Get-ChildItem -Path $path -Recurse | Sort-Object -Property LastAccessTime -Descending | Select-Object -First 3
        $report += [PSCustomObject]@{ Timestamp = (Get-Date); FileUsage = $fileUsage }
        Start-Sleep -Milliseconds 100
    }
    $report | Export-Csv -Path "DiskUsageReport.csv" -NoTypeInformation
}

function Monitor-CPU {
    # Listado de top 10 de procesos con mayor uso de CPU
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10

    # Estado general de la CPU
    Get-WmiObject -Class Win32_Processor | Select-Object -Property LoadPercentage

    # Monitorear un proceso específico
    $processId = Read-Host "Ingrese el ID del proceso para monitorear"
    $report = @()
    for ($i = 0; $i -lt 3000; $i++) {
        $cpuUsage = Get-Process -Id $processId | Select-Object -ExpandProperty CPU
        $report += [PSCustomObject]@{ Timestamp = (Get-Date); CPUUsage = $cpuUsage }
        Start-Sleep -Milliseconds 100
    }
    $report | Export-Csv -Path "CPUUsageReport.csv" -NoTypeInformation
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

