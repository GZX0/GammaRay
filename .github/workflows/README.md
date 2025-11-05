# GammaRay CI/CD Workflows

This repository contains GitHub Actions workflows for building GammaRay on Windows using vcpkg and QEMU cross-compilation.

## Available Workflows

### 1. `windows-build.yml` - Primary Windows Build
**Trigger**: Push to main/develop, Pull Requests

**Features**:
- Uses GitHub Actions Windows runners
- Installs and caches vcpkg dependencies
- Supports both Premium and OpenSource builds
- Matrix builds for Release/Debug configurations
- Qt 6.8.3 integration
- Automatic artifact upload

**Build Matrix**:
- Build Types: Release, Debug
- Premium: ON, OFF

### 2. `windows-qemu-cross-compile.yml` - QEMU Cross-Compile
**Trigger**: Push to `ci/windows-qemu-vcpkg-build` branch, Manual dispatch

**Features**:
- Uses QEMU for Windows emulation on Ubuntu runners
- Docker-based Windows build environment
- Multi-stage Docker build for efficiency
- Cross-compilation from Linux to Windows
- Artifact extraction and verification

### 3. `windows-qemu-build.yml` - Legacy QEMU Build
**Trigger**: Same as primary workflow

**Features**:
- Combination of Windows runners and QEMU fallback
- Cross-platform Linux builds
- Release package creation

## Build Dependencies

The workflows automatically install the following vcpkg packages:

```
gflags:x64-windows
sqlite3:x64-windows
detours:x64-windows
gtest:x64-windows
libvpx:x64-windows
opus:x64-windows
fftw3:x64-windows
easyhook:x64-windows
glm:x64-windows
sdl2:x64-windows
jemalloc:x64-windows
protobuf:x64-windows
asio:x64-windows
openssl:x64-windows
ffmpeg:x64-windows
opencv:x64-windows
cpr:x64-windows
```

## Environment Configuration

The build process uses the `env_settings.cmake` file which supports:
- Environment variable overrides (`VCPKG_ROOT`, `QT_ROOT`, `VK_SDK_ROOT`)
- Default Windows development paths
- CI/CD friendly configuration

## Artifacts

### Primary Build Artifacts
- `gammaray-windows-{build-type}-premium-{premium}/`
- Contains all built executables, libraries, and resources

### QEMU Cross-Compile Artifacts
- `gammaray-windows-qemu-cross-compile/`
- Complete Windows build from Linux environment

### Release Packages
- `gammaray-windows-release-package/`
- Compressed archives with checksums
- Only created for main branch pushes

## Local Development

To test these workflows locally:

### Using Docker (QEMU Cross-Compile)
```bash
# Build the Docker image
docker build -f docker/windows/Dockerfile -t gammaray-windows-build .

# Run and extract artifacts
docker create --name gammaray-temp gammaray-windows-build
docker cp gammaray-temp:C:/gammaray ./local-build
docker rm gammaray-temp
```

### Using Windows Environment
1. Install Visual Studio 2022 with C++ development tools
2. Install vcpkg and bootstrap it
3. Install Qt 6.8.3
4. Set environment variables:
   ```cmd
   set VCPKG_ROOT=C:\path\to\vcpkg
   set QT_ROOT=C:\Qt\6.8.3\msvc2022_64
   ```
5. Run the build:
   ```cmd
   mkdir build
   cd build
   cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
   cmake --build . --config Release
   ```

## Troubleshooting

### Common Issues

1. **vcpkg Dependency Conflicts**
   - Clear the vcpkg cache in GitHub Actions
   - Ensure all dependencies use the same triplet (x64-windows)

2. **Qt Path Issues**
   - Verify Qt installation matches the expected version (6.8.3)
   - Check that the Qt architecture matches (win64_msvc2022_64)

3. **QEMU Build Failures**
   - Ensure Docker Buildx is properly configured
   - Check Windows container compatibility
   - Verify all dependencies are available in Windows containers

4. **Memory Issues**
   - Reduce parallel build jobs (`--parallel 2`)
   - Use smaller Docker base images if needed

### Debugging QEMU Builds

To debug QEMU cross-compilation issues:

1. Enable verbose logging:
   ```yaml
   - name: Debug container
     run: |
       docker run --platform windows/amd64 -it gammaray-windows-build cmd
   ```

2. Check container logs:
   ```bash
   docker logs <container-id>
   ```

3. Inspect the build environment:
   ```powershell
   # Inside Windows container
   Get-ChildItem C:\
   Get-ChildItem C:\vcpkg
   Get-ChildItem C:\Qt
   ```

## Performance Optimization

### Caching Strategies
- vcpkg dependencies are cached by platform and hash
- Qt installations are cached using the official action
- Docker layers are optimized for multi-stage builds

### Parallel Builds
- Windows builds use 4 parallel jobs
- QEMU builds use 4 parallel jobs
- Adjust based on runner resources

## Security Considerations

- All third-party dependencies are managed through vcpkg
- Docker base images use official Microsoft repositories
- No secrets are exposed in the workflow files
- Artifacts are automatically expired after retention period

## Contributing

When modifying these workflows:

1. Test changes in a feature branch first
2. Verify both Windows and QEMU builds work
3. Update this documentation if adding new dependencies
4. Ensure all environment variables are properly documented
5. Test artifact generation and extraction