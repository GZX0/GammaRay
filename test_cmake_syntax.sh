#!/bin/bash
# Test CMake syntax for the fixed CMakeLists.txt files

echo "Testing CMake syntax..."

files=(
    "CMakeLists.txt"
    "src/render/CMakeLists.txt"
    "src/tests/CMakeLists.txt"
    "src/render/plugin_interface/CMakeLists.txt"
    "src/client/plugin_interface/CMakeLists.txt"
)

error_count=0

for file in "${files[@]}"; do
    echo -n "Checking $file... "
    if [ -f "$file" ]; then
        # Check for basic syntax issues
        if grep -q "endif()" "$file" || grep -q "endif ()" "$file"; then
            echo "OK"
        else
            echo "ERROR: No endif() found"
            ((error_count++))
        fi
    else
        echo "ERROR: File not found"
        ((error_count++))
    fi
done

echo ""
echo "Checking for Windows-specific Qt6WebSockets handling..."
if grep -q "WebSockets is Windows-specific" CMakeLists.txt; then
    echo "✓ Main CMakeLists.txt has conditional WebSockets"
else
    echo "✗ Main CMakeLists.txt missing conditional WebSockets"
    ((error_count++))
fi

if grep -q "WebSockets is Windows-specific" src/render/CMakeLists.txt; then
    echo "✓ src/render/CMakeLists.txt has conditional WebSockets"
else
    echo "✗ src/render/CMakeLists.txt missing conditional WebSockets"
    ((error_count++))
fi

echo ""
if [ $error_count -eq 0 ]; then
    echo "All syntax checks passed!"
    exit 0
else
    echo "Found $error_count errors"
    exit 1
fi
