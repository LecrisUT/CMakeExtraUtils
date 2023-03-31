cmake_minimum_required(VERSION 3.25)

find_package(CMakeExtraUtils REQUIRED)

include(DynamicVersion)
dynamic_version()

project(Test_DynamicVersion
		VERSION ${PROJECT_VERSION}
		LANGUAGES NONE)
