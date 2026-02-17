#!/bin/bash

# Extract and sanitize the CPU model name for the filename 
# This removes spaces and special characters to ensure a valid filename
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs | tr -d ' ' | tr '/' '-')
OUTPUT_FILE="${CPU_MODEL}_specs.txt"

{
    echo "========================================================="
    echo "   SYSTEM SPECIFICATION REPORT FOR ABAQUS INSTALLATION"
    echo "   Generated on: $(date)"
    echo "========================================================="
    echo ""

    echo "--- 1. OPERATING SYSTEM & SHELL ---"
    if [ -f /etc/os-release ]; then
        grep "PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"'
    fi
    echo "Kernel Version:   $(uname -r)" 
    echo "CPU Architecture: $(uname -m)" 
    echo "Current Shell:    $SHELL" 
    echo ""

    echo "--- 2. CPU (PROCESSOR) ---"
    lscpu | grep -E "Model name|Socket\(s\)|Core\(s\) per socket|Thread\(s\) per core|CPU\(s\):" 
    
    echo "Critical Instruction Sets (AVX/AVX2):"
    if lscpu | grep -qi "avx2"; then
        echo "   [FOUND] AVX2 supported."
    elif lscpu | grep -qi "avx"; then
        echo "   [FOUND] AVX (standard) supported, but NOT AVX2."
    else
        echo "   [WARNING] Neither AVX nor AVX2 detected."
    fi

    echo "Raw CPU Flags (First 10): $(lscpu | grep -i "Flags" | cut -d':' -f2 | xargs | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, "..."}')" 
    echo ""

    echo "--- 3. MEMORY (RAM) ---"
    echo "Motherboard Max Capacity: $(sudo dmidecode -t 16 | grep 'Maximum Capacity' | cut -d':' -f2 | xargs || echo 'Requires sudo')" 
    echo "Total Installed RAM:      $(awk '/^MemTotal:/ {printf "%.2f GB", $2/1024/1024}' /proc/meminfo)" 
    echo "Number of Memory Sticks:  $(sudo dmidecode -t 17 | grep -c 'Size: [0-9]' || echo 'Requires sudo')" 
    echo "RAM Speed:                $(sudo dmidecode -t 17 | grep 'Configured Memory Speed' | head -n 1 | cut -d':' -f2 | xargs || echo 'Requires sudo')" 
    echo ""

    echo "--- 4. GRAPHICS / GPU ---"
    lspci | grep -i vga | cut -d':' -f3 
    echo ""

    echo "--- 5. STORAGE & PARTITIONS ---"
    echo "Storage Devices and Types (0=SSD, 1=HDD):"
    lsblk -d -o NAME,ROTA,SIZE,TYPE | grep 'disk' 
    
    echo ""
    echo "Partition Details:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep 'part' 
    echo ""

    echo "========================================================="
} > "$OUTPUT_FILE"

echo "Report successfully generated: $OUTPUT_FILE"
