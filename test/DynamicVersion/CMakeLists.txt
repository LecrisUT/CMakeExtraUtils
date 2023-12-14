cmake_minimum_required(VERSION 3.20)

find_package(CMakeExtraUtils REQUIRED)

include(DynamicVersion)
if (DEFINED FALLBACK_VERSION)
    dynamic_version(FALLBACK_VERSION ${FALLBACK_VERSION})
else ()
    dynamic_version()
endif ()

project(Test_DynamicVersion
        VERSION ${PROJECT_VERSION}
        LANGUAGES NONE)
