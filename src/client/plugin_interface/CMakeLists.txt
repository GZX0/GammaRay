project(tc_client_plugin)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# WebSockets is Windows-specific for this project
if(WIN32)
    find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets Network Core Core5Compat WebSockets Network Charts Svg)
    find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Network Core Core5Compat WebSockets Network Charts Svg)
else()
    find_package(Qt6 REQUIRED COMPONENTS Widgets Network Core Network Svg)
    # Try to find Charts optionally for Linux
    find_package(Qt6Charts QUIET)
    if(NOT Qt6Charts_FOUND)
        message(STATUS "Qt6Charts not found on Linux, creating dummy target")
        add_library(Qt6_Charts_Client INTERFACE IMPORTED)
    endif()
    # WebSockets and Core5Compat are already handled in main CMakeLists.txt with dummy targets if not found
endif()

set(PLUGIN_SRCS
        ${CMAKE_CURRENT_SOURCE_DIR}/ct_plugin_interface.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ct_plugin_context.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ct_media_record_plugin_interface.cpp
)

add_library(${PROJECT_NAME} ${PLUGIN_SRCS})
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets Qt6::Network Qt6::Core Qt6::Core5Compat
         Qt6::WebSockets Qt6::Network Qt6_Charts_Client Qt6::Svg tc_common_new)