#!/bin/bash

# Local QEMU Windows Build Script for GammaRay
# This script simulates the GitHub Actions QEMU build locally

set -e

echo "=== GammaRay Local QEMU Windows Build ==="
echo "This script builds GammaRay for Windows using QEMU on Linux"
echo

# Check prerequisites
check_prereqs() {
    echo "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker buildx version &> /dev/null; then
        echo "❌ Docker Buildx is not available"
        exit 1
    fi
    
    if ! docker run --help | grep -q "platform"; then
        echo "❌ Docker platform support is not available"
        exit 1
    fi
    
    echo "✅ Prerequisites check passed"
}

# Set up QEMU
setup_qemu() {
    echo "Setting up QEMU for Windows emulation..."
    
    # Check if QEMU is already registered
    if ! docker buildx inspect | grep -q "windows/amd64"; then
        echo "Registering QEMU platforms..."
        docker run --privileged --rm tonistiigi/binfmt --install all
    else
        echo "QEMU platforms already registered"
    fi
    
    echo "✅ QEMU setup completed"
}

# Create Dockerfile
create_dockerfile() {
    echo "Creating Windows build Dockerfile..."
    
    mkdir -p docker/windows
    
    cat > docker/windows/Dockerfile << 'EOF'
# Windows Server Core build image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS builder

# Use PowerShell for all commands
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Set working directory
WORKDIR C:/build

# Install chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Visual Studio Build Tools and components
RUN choco install -y visualstudio2022buildtools --no-progress --params "'--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'"; \
    choco install -y visualstudio2022workload-nativedesktop --no-progress

# Install additional tools
RUN choco install -y git cmake --no-progress

# Install vcpkg
RUN git clone https://github.com/Microsoft/vcpkg.git C:/vcpkg; \
    cd C:/vcpkg; \
    .\bootstrap-vcpkg.bat

# Install vcpkg dependencies (batch install for efficiency)
WORKDIR C:/vcpkg
RUN .\vcpkg.exe install gflags:x64-windows sqlite3:x64-windows detours:x64-windows gtest:x64-windows libvpx:x64-windows opus:x64-windows fftw3:x64-windows easyhook:x64-windows glm:x64-windows sdl2:x64-windows jemalloc:x64-windows protobuf:x64-windows asio:x64-windows openssl:x64-windows ffmpeg:x64-windows opencv:x64-windows cpr:x64-windows

# Install Qt
RUN choco install -y qt6 --version=6.8.3 --no-progress

# Set environment variables
ENV VCPKG_ROOT=C:/vcpkg
ENV QT_ROOT=C:/Qt/6.8.3/msvc2022_64
ENV CMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake

# Copy source code
WORKDIR C:/build/GammaRay
COPY . .

# Create environment settings for CI
RUN "set(VCPKG_ROOT C:/vcpkg)" | Out-File -FilePath "env_settings.cmake" -Encoding utf8; \
    "set(QT_ROOT C:/Qt/6.8.3/msvc2022_64)" | Out-File -FilePath "env_settings.cmake" -Encoding utf8 -Append; \
    "set(VK_SDK_ROOT C:/VulkanSDK/1.3.290.0)" | Out-File -FilePath "env_settings.cmake" -Encoding utf8 -Append

# Build the project
RUN mkdir build; \
    cd build; \
    cmake .. ^ \
      -G "Visual Studio 17 2022" ^ \
      -A x64 ^ \
      -DCMAKE_BUILD_TYPE=Release ^ \
      -DCMAKE_TOOLCHAIN_FILE="C:/vcpkg/scripts/buildsystems/vcpkg.cmake" ^ \
      -DVCPKG_TARGET_TRIPLET=x64-windows ^ \
      -DBUILD_PREMIUM=OFF ^ \
      -DJEMALLOC_ENABLED=ON ^ \
      -DMEMORY_STST_ENABLED=OFF ^ \
      -DBUILD_FROM="LOCAL_QEMU"; \
    cmake --build . --config Release --parallel 4; \
    cmake --install . --config Release --prefix C:/build/GammaRay/install

# Create final runtime image
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022
COPY --from=builder C:/build/GammaRay/install C:/gammaray
WORKDIR C:/gammaray
CMD ["cmd"]
EOF

    echo "✅ Dockerfile created"
}

# Build the Docker image
build_image() {
    echo "Building Windows Docker image with QEMU..."
    echo "This may take 30-60 minutes on first run..."
    
    # Create buildx builder if it doesn't exist
    if ! docker buildx inspect gammaray-builder &> /dev/null; then
        docker buildx create --name gammaray-builder --use
    fi
    
    # Build the image
    docker buildx build \
        --platform windows/amd64 \
        --load \
        -f docker/windows/Dockerfile \
        -t gammaray-windows-local \
        .
    
    echo "✅ Docker image built successfully"
}

# Extract build artifacts
extract_artifacts() {
    echo "Extracting build artifacts..."
    
    # Create container to extract files
    docker create --platform windows/amd64 --name gammaray-extract gammaray-windows-local
    
    # Wait for container to be ready
    sleep 5
    
    # Extract artifacts
    docker cp gammaray-extract:C:/gammaray ./local-windows-build
    
    # Clean up container
    docker rm gammaray-extract
    
    echo "✅ Artifacts extracted to ./local-windows-build"
}

# Verify build
verify_build() {
    echo "Verifying build artifacts..."
    
    if [ ! -d "./local-windows-build" ]; then
        echo "❌ Build artifacts directory not found"
        exit 1
    fi
    
    echo "Build artifacts:"
    find ./local-windows-build -name "*.exe" -o -name "*.dll" | head -10
    
    # Create build info
    cat > ./local-windows-build/BUILD_INFO.txt << EOF
GammaRay Local QEMU Windows Build
==================================
Build Date: $(date)
Host: $(uname -a)
Docker: $(docker --version)
Build Method: Local QEMU Cross-Compile
Platform: Windows x64
Compiler: MSVC 2022
Dependencies: vcpkg + Qt6.8.3
EOF
    
    echo "✅ Build verification completed"
    echo "Build info written to ./local-windows-build/BUILD_INFO.txt"
}

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    docker buildx rm gammaray-builder 2>/dev/null || true
    echo "✅ Cleanup completed"
}

# Main execution
main() {
    echo "Starting local QEMU Windows build process..."
    echo
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Run build steps
    check_prereqs
    setup_qemu
    create_dockerfile
    build_image
    extract_artifacts
    verify_build
    
    echo
    echo "🎉 Build completed successfully!"
    echo "Artifacts are available in: ./local-windows-build"
    echo
    echo "To create a distributable package:"
    echo "  cd local-windows-build"
    echo "  zip -r ../gammaray-windows-local-build.zip ."
    echo
}

# Help function
show_help() {
    echo "GammaRay Local QEMU Windows Build Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --clean    Clean up Docker resources and exit"
    echo "  -v, --verify   Only verify existing build artifacts"
    echo
    echo "Examples:"
    echo "  $0              # Run full build process"
    echo "  $0 --clean      # Clean up resources"
    echo "  $0 --verify     # Verify existing build"
    echo
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -c|--clean)
        cleanup
        exit 0
        ;;
    -v|--verify)
        if [ -d "./local-windows-build" ]; then
            verify_build
            exit 0
        else
            echo "❌ No build artifacts found to verify"
            exit 1
        fi
        ;;
    "")
        main
        ;;
    *)
        echo "❌ Unknown option: $1"
        show_help
        exit 1
        ;;
esac