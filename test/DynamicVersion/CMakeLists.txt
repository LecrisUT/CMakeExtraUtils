cmake_minimum_required(VERSION 3.20)

list(APPEND CMAKE_MESSAGE_CONTEXT TestProject)

find_package(CMakeExtraUtils REQUIRED)

include(DynamicVersion)
if (DEFINED FALLBACK_VERSION)
    dynamic_version(FALLBACK_VERSION ${FALLBACK_VERSION})
else ()
    dynamic_version()
endif ()

project(TestProject
        VERSION ${PROJECT_VERSION}
        LANGUAGES CXX)

message("version: ${PROJECT_VERSION}")
message("version-full: ${PROJECT_VERSION_FULL}")
message("commit: ${GIT_COMMIT}")
message("short-hash: ${GIT_SHORT_HASH}")
message("describe: ${GIT_DESCRIBE}")
message("distance: ${GIT_DISTANCE}")

configure_file(src/version.h.in version.h)
add_executable(version src/version.cpp)
target_include_directories(version PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
add_dependencies(version Version)

set_property(DIRECTORY APPEND PROPERTY
        CMAKE_CONFIGURE_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/.git_commit
)
configure_file(src/commit.h.in commit.h)
add_executable(commit src/commit.cpp)
target_include_directories(commit PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
add_dependencies(commit GitHash)
