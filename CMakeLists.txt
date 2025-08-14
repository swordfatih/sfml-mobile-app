cmake_minimum_required(VERSION 3.28)

if(NOT DEFINED APP_NAME)
    file(READ "${CMAKE_SOURCE_DIR}/config.json" APP_CONFIG_JSON)
    string(JSON APP_NAME GET "${APP_CONFIG_JSON}" APP_NAME)
endif()

project(CMakeSFMLProject LANGUAGES CXX)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/*.cpp")

include(FetchContent)
FetchContent_Declare(SFML
    GIT_REPOSITORY https://github.com/SFML/SFML.git
    GIT_TAG 3.0.1
    GIT_SHALLOW ON
    EXCLUDE_FROM_ALL
    SYSTEM)
FetchContent_MakeAvailable(SFML)

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(CMAKE_MACOSX_BUNDLE YES)
    if(DEFINED INFO_PLIST_PATH)
        set(INFO_PLIST ${INFO_PLIST_PATH})
    else()
        set(INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    endif()
    add_executable(${APP_NAME} MACOSX_BUNDLE ${SRC_FILES})
    set_target_properties(${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${INFO_PLIST})
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
    add_library(${APP_NAME} SHARED ${SRC_FILES})
    set(CMAKE_ANDROID_STL_TYPE c++_static)
    set_target_properties(${APP_NAME} PROPERTIES ANDROID_API_MIN 21 ANDROID_API 33)
else()
    add_executable(${APP_NAME} ${SRC_FILES})
endif()

target_compile_features(${APP_NAME} PRIVATE cxx_std_23)
target_link_libraries(${APP_NAME} PRIVATE SFML::Graphics SFML::Main)
