cmake_minimum_required(VERSION 3.25)
project(Test_FetchContent LANGUAGES NONE)

include(FetchContent)
FetchContent_Declare(CMakeExtraUtils
		GIT_REPOSITORY https://github.com/LecriUT/CMakeExtraUtils)
set(FETCHCONTENT_SOURCE_DIR_CMAKEEXTRAUTILS ${CMAKE_CURRENT_LIST_DIR}/../../)
FetchContent_MakeAvailable(CMakeExtraUtils)

include(DynamicVersion)
