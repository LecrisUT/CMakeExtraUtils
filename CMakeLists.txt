cmake_minimum_required(VERSION 3.25)

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(DynamicVersion)
get_dynamic_version()

project(cmake_utils
		VERSION ${PROJECT_VERSION})
