# CMake Configuration Fixes - Summary

## Problem Description
The GammaRay project had CMake configuration issues that prevented building on both Windows and Linux platforms:

1. **Windows Issues:**
   - Hardcoded vcpkg path `C:/source/vcpkg` causing toolchain file not found errors
   - Missing Ninja build tool configuration
   - Windows-specific libraries and flags not properly conditional

2. **Linux Issues:**
   - Windows paths being used on Linux (e.g., `C:/source/vcpkg`)
   - Missing vcpkg setup for Linux
   - Platform-specific compiler flags being applied to Linux

## Fixes Implemented

### 1. Environment Settings (`env_settings.cmake`)
- Made all paths platform-aware using `if(WIN32)` conditions
- Added support for environment variables (`VCPKG_ROOT`, `QT_ROOT`, `VK_SDK_ROOT`)
- Provided fallback paths for both Windows and Linux
- Added automatic Qt path detection for Linux

### 2. Main CMakeLists.txt
- Added platform-specific configuration section
- Made vcpkg toolchain file inclusion conditional
- Fixed include and library directories to be platform-aware
- Made Windows-specific definitions conditional (`-DUNICODE`, `-DWIN32_LEAN_AND_MEAN`, etc.)
- Fixed OpenCV path handling for both platforms
- Made Windows-specific linker flags conditional
- Conditionalized Windows-only executables (GammaRayGuard, shadow_deleter)
- Fixed library linking to separate Windows and Linux dependencies
- Made Windows-specific post-build commands conditional

### 3. Client CMakeLists.txt (`src/client/CMakeLists.txt`)
- Made Windows-specific library linking conditional
- Separated Windows and Linux library dependencies

### 4. Plugin CMakeLists.txt (`src/render/plugins/ffmpeg_encoder/CMakeLists.txt`)
- Made Windows-specific FFmpeg library linking conditional
- Added Linux FFmpeg library support

### 5. GitHub Actions Workflow (`.github/workflows/build-release.yml`)
- Added Linux vcpkg installation and configuration
- Enhanced Linux system dependencies
- Made both Windows and Linux use environment variables for paths
- Added required vcpkg package installation for both platforms

### 6. Git Configuration
- Updated `.gitignore` to include `build/` directory

## Key Technical Changes

### Platform Detection
```cmake
if(WIN32)
    # Windows-specific configuration
else()
    # Linux/Unix configuration
endif()
```

### Environment Variable Support
```cmake
if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT $ENV{VCPKG_ROOT})
else()
    set(VCPKG_ROOT <default_path>)
endif()
```

### Conditional Library Linking
```cmake
if(WIN32)
    target_link_libraries(... Windows-specific.libs)
else()
    target_link_libraries(... Linux-specific-libs)
endif()
```

## Testing
Created `test_cmake_config.sh` script to validate configuration changes.

## Result
The build system now properly supports:
- **Windows**: MSVC compiler with vcpkg integration, Windows-specific libraries
- **Linux**: GCC/Clang with vcpkg integration, system package support
- **Cross-platform**: Proper path handling, conditional compilation, platform-specific dependencies

The configuration errors about missing vcpkg toolchain files and Ninja build tools should now be resolved on both platforms.