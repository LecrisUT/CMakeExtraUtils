cmake_minimum_required(VERSION 3.25)
project(Test_find_package LANGUAGES NONE)

## The following need to be set
#set(CMakeExtraUtils_ROOT)
find_package(CMakeExtraUtils REQUIRED)

include(DynamicVersion)
