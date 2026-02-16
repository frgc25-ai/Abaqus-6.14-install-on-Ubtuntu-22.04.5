#!/bin/bash

# Define the output file
OUTPUT_FILE="system_reference_specs.txt"

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
    echo "Kernel Version: $(uname -r)"
    echo "Architecture:   $(uname -m)"
    # Added Shell type
    echo "Current Shell:  $SHELL"
    echo ""

    echo "--- 2. CPU (PROCESSOR) ---"
    lscpu | grep -E "Model name|Socket\(s\)|Core\(s\) per socket|Thread\(s\) per core|CPU\(s\):"
    echo ""

    echo "--- 3. MEMORY (RAM) ---"
    # Modified to show both Total and Available RAM
    free -h | awk '/^Mem:/ {print "Total RAM: "$2", Available: "$7}'
    echo ""

    echo "--- 4. GRAPHICS / GPU ---"
    lspci | grep -i vga | cut -d':' -f3
    echo ""

    echo "--- 5. STORAGE (SCRATCH DRIVE) ---"
    df -h . | awk 'NR==2 {print "Total Space: "$2", Available: "$4}'
    echo ""

    echo "========================================================="
} > "$OUTPUT_FILE"

echo "Report successfully generated: $OUTPUT_FILE"
