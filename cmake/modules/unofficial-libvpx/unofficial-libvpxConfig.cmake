# This is a dummy config file to satisfy find_package(unofficial-libvpx)
# when using system libvpx. The target unofficial::libvpx::libvpx is expected
# to be defined by the main CMakeLists.txt or manually.

if(NOT TARGET unofficial::libvpx::libvpx)
    message(STATUS "unofficial::libvpx::libvpx target not defined. This config file assumes it is defined externally.")
endif()
