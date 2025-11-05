# Environment settings for GammaRay build
# These paths can be overridden by environment variables or CMake cache

# Allow environment variables to override these paths
if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT $ENV{VCPKG_ROOT})
else()
    set(VCPKG_ROOT C:/source/vcpkg)
endif()

if(DEFINED ENV{QT_ROOT})
    set(QT_ROOT $ENV{QT_ROOT})
else()
    set(QT_ROOT C:/Qt6.8.3/6.8.3/msvc2022_64)
endif()

if(DEFINED ENV{VK_SDK_ROOT})
    set(VK_SDK_ROOT $ENV{VK_SDK_ROOT})
else()
    set(VK_SDK_ROOT C:/VulkanSDK/1.3.290.0)
endif()

message("Using VCPKG_ROOT: ${VCPKG_ROOT}")
message("Using QT_ROOT: ${QT_ROOT}")
message("Using VK_SDK_ROOT: ${VK_SDK_ROOT}")

