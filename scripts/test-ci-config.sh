#!/bin/bash

# Quick test script for GammaRay CI/CD setup
# This script validates the GitHub Actions workflow configuration

set -e

echo "=== GammaRay CI/CD Configuration Test ==="
echo

# Test 1: Check if all required files exist
echo "Test 1: Checking required files..."
required_files=(
    ".github/workflows/windows-build-simple.yml"
    ".github/workflows/windows-qemu-simple.yml"
    ".github/workflows/README.md"
    "env_settings.cmake"
    "CMakeLists.txt"
    "scripts/local-qemu-build.sh"
    "docker-compose.yml"
    "docker/vcpkg.Dockerfile"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    else
        echo "  ✅ $file"
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "❌ Missing files:"
    for file in "${missing_files[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

echo "✅ All required files present"

# Test 2: Validate YAML syntax
echo
echo "Test 2: Validating YAML syntax..."
workflow_files=(
    ".github/workflows/windows-build-simple.yml"
    ".github/workflows/windows-qemu-simple.yml"
)

for yaml_file in "${workflow_files[@]}"; do
    if command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null && echo "  ✅ $yaml_file" || echo "  ❌ $yaml_file (invalid YAML)"
    else
        echo "  ⚠️  Cannot validate $yaml_file (python3 not available)"
    fi
done

# Test 3: Check CMake configuration
echo
echo "Test 3: Checking CMake configuration..."
if [ -f "CMakeLists.txt" ]; then
    if grep -q "vcpkg" CMakeLists.txt; then
        echo "  ✅ vcpkg integration found"
    else
        echo "  ❌ vcpkg integration not found"
    fi
    
    if grep -q "env_settings.cmake" CMakeLists.txt; then
        echo "  ✅ Environment settings included"
    else
        echo "  ❌ Environment settings not included"
    fi
fi

# Test 4: Validate environment settings
echo
echo "Test 4: Checking environment settings..."
if [ -f "env_settings.cmake" ]; then
    if grep -q "VCPKG_ROOT" env_settings.cmake; then
        echo "  ✅ VCPKG_ROOT defined"
    else
        echo "  ❌ VCPKG_ROOT not defined"
    fi
    
    if grep -q "QT_ROOT" env_settings.cmake; then
        echo "  ✅ QT_ROOT defined"
    else
        echo "  ❌ QT_ROOT not defined"
    fi
    
    if grep -q "ENV{VCPKG_ROOT}" env_settings.cmake; then
        echo "  ✅ Environment variable override support"
    else
        echo "  ⚠️  Environment variable override support not found"
    fi
fi

# Test 5: Check Docker files
echo
echo "Test 5: Checking Docker configuration..."
if [ -f "docker/vcpkg.Dockerfile" ]; then
    if grep -q "vcpkg" docker/vcpkg.Dockerfile; then
        echo "  ✅ vcpkg Dockerfile contains vcpkg commands"
    else
        echo "  ❌ vcpkg Dockerfile missing vcpkg commands"
    fi
fi

if [ -f "docker-compose.yml" ]; then
    if grep -q "windows/amd64" docker-compose.yml; then
        echo "  ✅ Docker Compose includes Windows platform"
    else
        echo "  ❌ Docker Compose missing Windows platform"
    fi
fi

# Test 6: Check script permissions
echo
echo "Test 6: Checking script permissions..."
if [ -f "scripts/local-qemu-build.sh" ]; then
    if [ -x "scripts/local-qemu-build.sh" ]; then
        echo "  ✅ local-qemu-build.sh is executable"
    else
        echo "  ❌ local-qemu-build.sh is not executable"
    fi
fi

# Test 7: Verify vcpkg dependencies list
echo
echo "Test 7: Checking vcpkg dependencies..."
vcpkg_packages=(
    "gflags"
    "sqlite3"
    "detours"
    "gtest"
    "libvpx"
    "opus"
    "fftw3"
    "easyhook"
    "glm"
    "sdl2"
    "jemalloc"
    "protobuf"
    "asio"
    "openssl"
    "ffmpeg"
    "opencv"
    "cpr"
)

echo "  Checking workflow files for vcpkg packages..."
for package in "${vcpkg_packages[@]}"; do
    if grep -r "$package:x64-windows" .github/workflows/ > /dev/null 2>&1; then
        echo "    ✅ $package"
    else
        echo "    ❌ $package (not found in workflows)"
    fi
done

# Test 8: Generate summary
echo
echo "=== Configuration Summary ==="
echo "Project: GammaRay"
echo "Build System: CMake with vcpkg"
echo "CI/CD Platform: GitHub Actions"
echo "Target Platform: Windows x64"
echo "Cross-compilation: QEMU + Docker"
echo "Qt Version: 6.8.3"
echo "Compiler: MSVC 2022"
echo

echo "=== Next Steps ==="
echo "1. Push changes to trigger GitHub Actions"
echo "2. Monitor build logs for any issues"
echo "3. Test artifact extraction and verification"
echo "4. Validate build outputs"
echo

echo "=== Local Testing ==="
echo "To test locally:"
echo "1. Install Docker with QEMU support"
echo "2. Run: ./scripts/local-qemu-build.sh"
echo "3. Check build artifacts in ./local-windows-build"
echo

echo "✅ Configuration test completed!"