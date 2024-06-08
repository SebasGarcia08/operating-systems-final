#!/bin/bash

show_menu() {
    echo "================ Menu ================"
    echo "1. Monitorear estado de la memoria"
    echo "2. Monitorear estado de los discos"
    echo "3. Monitorear estado de los procesos / CPU"
    echo "0. Salir"
}

monitor_memory() {
    # Listado de top 10 de uso de memoria por proceso
    ps aux --sort=-%mem | head -n 11

    # Estado general de memoria
    free -h

    # Monitorear un proceso específico
    read -p "Ingrese el ID del proceso para monitorear: " process_id
    (
        for i in {1..3000}; do
            memory_usage=$(ps -p $process_id -o %mem --no-headers 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "$(date): $memory_usage" >> MemoryUsageReport.txt
            else
                echo "$(date): Error fetching memory usage for PID $process_id" >> MemoryUsageReport.txt
            fi
            sleep 0.1
        done
    ) &
}

monitor_disks() {
    # Listado de top 10 de archivos más grandes en el sistema
    find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 10

    # Estado general de los discos por partición
    df -h

    # Monitorear una ruta específica
    read -p "Ingrese la ruta para monitorear: " path
    (
        for i in {1..3000}; do
            file_usage=$(ls -lt $path 2>/dev/null | head -n 4)
            if [ $? -eq 0 ]; then
                echo "$(date): $file_usage" >> DiskUsageReport.txt
            else
                echo "$(date): Error accessing path $path" >> DiskUsageReport.txt
            fi
            sleep 0.1
        done
    ) &
}

monitor_cpu() {
    # Listado de top 10 de procesos con mayor uso de CPU
    ps aux --sort=-%cpu | head -n 11

    # Estado general de la CPU
    top -b -n1 | grep "Cpu(s)" | awk '{print "CPU Usage: " $2 + $4 "%"}'

    # Monitorear un proceso específico
    read -p "Ingrese el ID del proceso para monitorear: " process_id
    (
        for i in {1..3000}; do
            cpu_usage=$(ps -p $process_id -o %cpu --no-headers 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "$(date): $cpu_usage" >> CPUUsageReport.txt
            else
                echo "$(date): Error fetching CPU usage for PID $process_id" >> CPUUsageReport.txt
            fi
            sleep 0.1
        done
    ) &
}

while true; do
    show_menu
    read -p "Seleccione una opción: " option
    case $option in
        1) monitor_memory ;;
        2) monitor_disks ;;
        3) monitor_cpu ;;
        0) exit 0 ;;
        *) echo "Opción no válida, intente nuevamente" ;;
    esac
done
