# Platform-specific paths
if(WIN32)
    # Windows paths
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
else()
    # Linux/Unix paths
    if(DEFINED ENV{VCPKG_ROOT})
        set(VCPKG_ROOT $ENV{VCPKG_ROOT})
    else()
        set(VCPKG_ROOT $ENV{HOME}/vcpkg)
    endif()
    
    if(DEFINED ENV{QT_ROOT})
        set(QT_ROOT $ENV{QT_ROOT})
    else()
        # Try to find Qt6 installation
        find_program(QMAKE_PATH qmake6)
        if(QMAKE_PATH)
            get_filename_component(QT_ROOT "${QMAKE_PATH}" DIRECTORY)
            get_filename_component(QT_ROOT "${QT_ROOT}" DIRECTORY)
        else()
            set(QT_ROOT /usr/local/Qt-6.6.2)
        endif()
    endif()
    
    if(DEFINED ENV{VK_SDK_ROOT})
        set(VK_SDK_ROOT $ENV{VK_SDK_ROOT})
    else()
        set(VK_SDK_ROOT /usr/local/VulkanSDK)
    endif()
endif()

