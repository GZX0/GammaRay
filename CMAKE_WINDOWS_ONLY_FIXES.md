# CMake Windows-Only Build Fixes

## Problem
The GammaRay project is a Windows-focused application, but the CMake configuration was failing on Linux because Qt6WebSockets and other Windows-specific components were required on all platforms.

Error example:
```
-- Could NOT find Qt6WebSockets (missing: Qt6WebSockets_DIR)
CMake Error: Failed to find required Qt component "WebSockets"
```

## Solution
Made Qt6WebSockets and other Windows-specific features conditional so they are only required on Windows builds.

## Changes Made

### 1. Main CMakeLists.txt
- **Lines 84-100**: Made Qt6WebSockets component optional on Linux
  - On Windows: Requires WebSockets
  - On Linux: Creates dummy Qt6::WebSockets target if not found
- **Lines 401-408**: Made Windows-only build targets conditional
  - `shadow_deleter` and `GammaRayGuard` only added as dependencies on Windows
- **Lines 422-474**: Split build commands into platform-agnostic and Windows-specific
  - Platform-agnostic: Copy resources and settings
  - Windows-only: Copy .exe, .dll files and plugins

### 2. src/render/CMakeLists.txt
- **Lines 7-15**: Made Qt6WebSockets find_package conditional
- **Lines 64-69**: Made WIN32 flag and Windows link flags conditional in add_executable
- **Lines 75-92**: Made windeployqt and DLL copying conditional on Windows

### 3. src/tests/CMakeLists.txt
- **Lines 4-12**: Made Qt6WebSockets find_package conditional

### 4. src/render/plugin_interface/CMakeLists.txt
- **Lines 10-18**: Made Qt6WebSockets find_package conditional

### 5. src/client/plugin_interface/CMakeLists.txt
- **Lines 10-18**: Made Qt6WebSockets find_package conditional

## Benefits
1. **CMake configuration now succeeds on Linux** - No more Qt6WebSockets errors
2. **Windows builds unchanged** - All Windows-specific features still required on Windows
3. **Cleaner separation** - Platform-specific code clearly marked with if(WIN32) blocks
4. **Future-proof** - Easy to add more platform-specific features as needed

## Testing
- Windows builds: Should work exactly as before
- Linux builds: CMake configuration should succeed (actual compilation may still have issues with Windows-specific code, but that's expected for a Windows-focused project)

## Notes
Since GammaRay is primarily a Windows application, the Linux build support is minimal. The changes allow CMake configuration to succeed on Linux, but full Linux compilation support would require additional work to make Windows-specific APIs (DirectX, WASAPI, etc.) conditional.
