#!/bin/bash

# Test script to validate CMake configuration fixes
echo "Testing CMake configuration fixes..."

# Create a test build directory
mkdir -p build_test
cd build_test

# Test Linux configuration (simulated)
echo "Testing Linux configuration..."
export VCPKG_ROOT="$HOME/vcpkg"
export QT_ROOT="/usr/local/Qt-6.6.2"

# Run CMake configuration only (dry run)
cmake -S .. -B . -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DGR_PROJECT_PATH="$(pwd)/.." \
    --dry-run 2>&1 | head -20

echo ""
echo "Configuration test completed. Check for any path-related errors above."
echo ""
echo "Key fixes implemented:"
echo "1. Platform-specific environment variable handling"
echo "2. Conditional Windows/Linux paths in CMakeLists.txt"
echo "3. Proper vcpkg toolchain file inclusion"
echo "4. Platform-specific library linking"
echo "5. Windows-specific build commands made conditional"

# Cleanup
cd ..
rm -rf build_test