# Minimum version follows the current Ubuntu LTS and RHEL version
cmake_minimum_required(VERSION 3.20)
if (POLICY CMP0140)
	# Enable using return(PROPAGATE)
	# TODO: Remove when cmake 3.25 is commonly distributed
	cmake_policy(SET CMP0140 NEW)
endif ()

#[==============================================================================================[
#                                   Basic project definition                                   #
]==============================================================================================]

list(APPEND CMAKE_MESSAGE_CONTEXT CMakeExtraUtils)

# dogfooding `DynamicVersion` module in order to set the CMakeExtraUtils version
list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
include(DynamicVersion)
dynamic_version(PROJECT_PREFIX CMakeExtraUtils_)

project(CMakeExtraUtils
		VERSION ${PROJECT_VERSION}
		DESCRIPTION "Extra utilities for cmake"
		HOMEPAGE_URL https://github.com/LecrisUT/CmakeExtraUtils
		LANGUAGES NONE
)
# Back-porting to PROJECT_IS_TOP_LEVEL to older cmake
# TODO: Remove when requiring cmake >= 3.21
if (NOT DEFINED CMakeExtraUtils_IS_TOP_LEVEL)
	if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
		set(PROJECT_IS_TOP_LEVEL ON)
		set(CMakeExtraUtils_IS_TOP_LEVEL ON)
	else ()
		set(PROJECT_IS_TOP_LEVEL OFF)
		set(CMakeExtraUtils_IS_TOP_LEVEL_IS_TOP_LEVEL OFF)
	endif ()
endif ()


#[==============================================================================================[
#                                            Options                                            #
]==============================================================================================]

option(CMAKEEXTRAUTILS_TESTS "CMakeExtraUtils: Include tests" ${PROJECT_IS_TOP_LEVEL})
option(CMAKEEXTRAUTILS_INSTALL "CMakeExtraUtils: Install project files" ${PROJECT_IS_TOP_LEVEL})

#[==============================================================================================[
#                                     Project configuration                                     #
]==============================================================================================]

if (CMAKEEXTRAUTILS_INSTALL)
	include(CMakePackageConfigHelpers)
	if (UNIX)
		include(GNUInstallDirs)
	endif ()
endif ()

#[==============================================================================================[
#                                       External packages                                       #
]==============================================================================================]

# No external dependencies

#[==============================================================================================[
#                                        Main definition                                        #
]==============================================================================================]

# Nothing to actually configure for this project. Only the CMake native tests

if (CMAKEEXTRAUTILS_TESTS)
	enable_testing()
	add_subdirectory(test)
endif ()

#[==============================================================================================[
#                                       Install or Export                                       #
]==============================================================================================]

# Install package files
if (CMAKEEXTRAUTILS_INSTALL)
	# Will show developer warning, but can't supress it :(
	# Package files
	write_basic_package_version_file(
			CMakeExtraUtilsConfigVersion.cmake
			VERSION ${PROJECT_VERSION}
			# TODO: Currently unstable api, change when v1.0 is released
			COMPATIBILITY SameMinorVersion
			ARCH_INDEPENDENT
	)
	configure_package_config_file(
			cmake/CMakeExtraUtilsConfig.cmake.in
			CMakeExtraUtilsConfig.cmake
			INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/cmake/CMakeExtraUtils
	)
	install(FILES
			${CMAKE_CURRENT_BINARY_DIR}/CMakeExtraUtilsConfigVersion.cmake
			${CMAKE_CURRENT_BINARY_DIR}/CMakeExtraUtilsConfig.cmake
			DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/cmake/CMakeExtraUtils
	)
	# Bundled cmake files
	install(FILES
			cmake/DynamicVersion.cmake
			cmake/PackageComps.cmake
			DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/cmake/CMakeExtraUtils
	)
endif ()

# Make project available for FetchContent
if (NOT PROJECT_IS_TOP_LEVEL)
	# Propagate variables for FetchContent
	# All variables have to be consistent with CMakeExtraUtilsConfig.cmake
	if (CMAKE_VERSION VERSION_LESS 3.25)
		# TODO: Remove when cmake 3.25 is commonly distributed
		set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION ${CMakeExtraUtils_VERSION} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_MAJOR ${CMakeExtraUtils_VERSION_MAJOR} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_MINOR ${CMakeExtraUtils_VERSION_MINOR} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_PATCH ${CMakeExtraUtils_VERSION_PATCH} PARENT_SCOPE)
		set(CMakeExtraUtils_VERSION_TWEAK ${CMakeExtraUtils_VERSION_TWEAK} PARENT_SCOPE)
	endif ()
	return(PROPAGATE
			CMAKE_MODULE_PATH
			CMakeExtraUtils_VERSION
			CMakeExtraUtils_VERSION_MAJOR
			CMakeExtraUtils_VERSION_MINOR
			CMakeExtraUtils_VERSION_PATCH
			CMakeExtraUtils_VERSION_TWEAK
	)
endif ()
