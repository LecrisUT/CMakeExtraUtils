cmake_minimum_required(VERSION 3.25)
project(Test_import LANGUAGES NONE)

include(FetchContent)
FetchContent_Declare(CMakeExtraUtils
		GIT_REPOSITORY https://github.com/LecrisUT/CMakeExtraUtils
		GIT_TAG main
		# Use REQUIRED so that import fails when local package is not found
		FIND_PACKAGE_ARGS REQUIRED CONFIG)
FetchContent_MakeAvailable(CMakeExtraUtils)

include(DynamicVersion)
