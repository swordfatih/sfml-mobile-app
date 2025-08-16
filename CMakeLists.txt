cmake_minimum_required(VERSION 3.28)

file(READ "${CMAKE_SOURCE_DIR}/config.json" APP_CONFIG_JSON)
string(JSON APP_NAME GET "${APP_CONFIG_JSON}" APP_NAME)
string(JSON MOBILE_ICON GET "${APP_CONFIG_JSON}" MOBILE_ICON)

project(${APP_NAME} LANGUAGES CXX)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(ASSETS_DIR "${CMAKE_SOURCE_DIR}/assets")

file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/*.cpp")

include(FetchContent)
FetchContent_Declare(SFML GIT_REPOSITORY https://github.com/SFML/SFML.git GIT_TAG 3.0.1 GIT_SHALLOW ON EXCLUDE_FROM_ALL SYSTEM)
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
    target_link_libraries(${APP_NAME} PRIVATE SFML::Main)

    set_source_files_properties("${CMAKE_SOURCE_DIR}/${MOBILE_ICON}" PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    target_sources(${APP_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/${MOBILE_ICON}")

elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
    add_library(${APP_NAME} SHARED ${SRC_FILES})
    set_target_properties(${APP_NAME} PROPERTIES ANDROID_API_MIN 21 ANDROID_API 33 OUTPUT_NAME "sfml_app")
    target_link_libraries(${APP_NAME} PRIVATE android log -Wl,--whole-archive SFML::Main -Wl,--no-whole-archive)
    add_custom_command(TARGET ${APP_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/android_assets/res/mipmap" COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/${MOBILE_ICON}" "${CMAKE_BINARY_DIR}/android_assets/res/mipmap/ic_launcher.png" COMMAND ${CMAKE_COMMAND} -E copy_directory "${ASSETS_DIR}" "${CMAKE_BINARY_DIR}/android_assets/assets")

else()
    add_executable(${APP_NAME} ${SRC_FILES})
endif()
    
target_link_libraries(${APP_NAME} PRIVATE SFML::Graphics)
target_compile_features(${APP_NAME} PRIVATE cxx_std_23)

add_custom_command(TARGET ${APP_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory "${ASSETS_DIR}" "$<TARGET_FILE_DIR:${APP_NAME}>/assets")
