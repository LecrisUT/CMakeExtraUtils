cmake_minimum_required(VERSION 3.25)
## The following need to be set
#set(CMakeExtraUtils_ROOT)

find_package(CMakeExtraUtils REQUIRED)

include(DynamicVersion)
dynamic_version()

project(Test_DynamicVersion_Simple
		VERSION ${PROJECT_VERSION})

message("Version: ${Test_DynamicVersion_Simple_VERSION}")
