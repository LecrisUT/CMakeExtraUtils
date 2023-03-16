cmake_minimum_required(VERSION 3.25)
## The following need to be set
#set(CmakeExtraUtils_ROOT)

find_package(CmakeExtraUtils REQUIRED)

include(DynamicVersion)
get_dynamic_version()

project(Test_DynamicVersion_Simple
		VERSION ${PROJECT_VERSION})
