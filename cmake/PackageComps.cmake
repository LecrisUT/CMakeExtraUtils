## Helpers to configure package components
# Special handling for `static` and `shared` components
# Implementation inspired by Alex Reinking blog post
# https://alexreinking.com/blog/building-a-dual-shared-and-static-library-with-cmake.html
#
#
#

list(APPEND CMAKE_MESSAGE_CONTEXT PackageComps)

# TODO: Move these to functions with minimal macro that actually does the `include()`
macro(get_component _comp)
	# Import a specific package component
	#
	# Macro variables::
	#   _comp (string): Package component name
	# Named arguments::
	#   PACKAGE (string): Project name. Also used as prefix
	#   LIB_PREFIX (string): Static/Shared library prefix
	#   FALLBACK_PREFIX (string): Allowed library fallback prefix
	# Options
	#   PRINT: Print results when loading each component
	#   CHECK_REQUIRED: Check if component is required and not present

	list(APPEND CMAKE_MESSAGE_CONTEXT get_component)
	set(ARGS_Options "")
	set(ARGS_OneValue "")
	set(ARGS_MultiValue "")
	list(APPEND ARGS_Options
			PRINT
			CHECK_REQUIRED
	)
	list(APPEND ARGS_OneValue
			PACKAGE
			LIB_PREFIX
			FALLBACK_PREFIX
	)

	cmake_parse_arguments(ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}" ${ARGN})


	if (NOT DEFINED ARGS_PACKAGE)
		message(AUTHOR_WARNING
				"PACKAGE not passed to get_comp"
		)
		set(ARGS_PACKAGE "${CMAKE_FIND_PACKAGE_NAME}")
	endif ()
	if (ARGS_PRINT)
		set(stdout_type STATUS)
	else ()
		set(stdout_type VERBOSE)
	endif ()

	message(${stdout_type}
			"Trying to include component: ${_comp}"
	)

	message(DEBUG
			"Passed arguments:\n"
			"PACKAGE = ${ARGS_PACKAGE}\n"
			"_comp = ${_comp}\n"
			"LIB_PREFIX = ${ARGS_LIB_PREFIX}\n"
			"FALLBACK_PREFIX = ${ARGS_FALLBACK_PREFIX}\n"
			"PRINT = ${ARGS_PRINT}\n"
			"CHECK_REQUIRED = ${ARGS_CHECK_REQUIRED}\n"
			"${ARGS_PACKAGE}_FIND_REQUIRED_${_comp} = ${${ARGS_PACKAGE}_FIND_REQUIRED_${_comp}}\n"
			"${ARGS_PACKAGE}_${_comp}_SharedStatic = ${${ARGS_PACKAGE}_${_comp}_SharedStatic}"
	)

	# Set default component to not found
	set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)

	if (DEFINED ARGS_LIB_PREFIX)
		# We may have shared/static components
		message(DEBUG
				"Including ${_comp} with possible shared/static:"
		)

		if (${ARGS_PACKAGE}_${_comp}_SharedStatic)
			# If we know it is a shared/static target parse it appropriately
			message(DEBUG
					"${_comp} has to have shared/static library:"
			)

			# Try to load shared/static library
			if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}_${ARGS_LIB_PREFIX}.cmake)
				# Load the correct library
				include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}_${ARGS_LIB_PREFIX}.cmake)
				message(DEBUG
						"Including ${ARGS_PACKAGE}Targets_${_comp}_${ARGS_LIB_PREFIX}.cmake: ${${ARGS_PACKAGE}_FOUND}"
				)
				# Check if include was successful
				if (${ARGS_PACKAGE}_FOUND)
					set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
					set(${ARGS_PACKAGE}_${_comp}_LIB_TYPE ${ARGS_LIB_PREFIX})
				else ()
					set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
					message(${stdout_type}
							"Could not load component ${_comp} of type ${ARGS_LIB_PREFIX}"
					)
					return()
				endif ()
			elseif (ARGS_FALLBACK_PREFIX)
				# Try to load the fallback library if have one
				include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}_${ARGS_FALLBACK_PREFIX}.cmake OPTIONAL
						RESULT_VARIABLE ${ARGS_PACKAGE}_${_comp}_FOUND)
				message(DEBUG
						"Including ${ARGS_PACKAGE}Targets_${_comp}_${ARGS_FALLBACK_PREFIX}.cmake: ${${ARGS_PACKAGE}_${_comp}_FOUND}"
				)
				# Reformat Comp_FOUND variable to TRUE/FALSE and check if include was successful
				if (${ARGS_PACKAGE}_${_comp}_FOUND AND ${ARGS_PACKAGE}_FOUND)
					set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
					set(${ARGS_PACKAGE}_${_comp}_LIB_TYPE ${ARGS_FALLBACK_PREFIX})
				else ()
					set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
					message(${stdout_type}
							"Could not find component ${_comp} of type ${ARGS_LIB_PREFIX}"
					)
					return()
				endif ()
			else ()
				set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
				message(${stdout_type}
						"Could not load component ${_comp} of either type ${ARGS_LIB_PREFIX} or ${ARGS_FALLBACK_PREFIX}"
				)
				return()
			endif ()
		elseif (NOT DEFINED ${ARGS_PACKAGE}_${_comp}_SharedStatic)
			# If we don't know what type of target it is try to load shared/static
			message(DEBUG
					"${_comp} is of unknown type. Trying to find shared/static:"
			)
			if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}_${ARGS_LIB_PREFIX}.cmake)
				# Load the correct library
				include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}_${ARGS_LIB_PREFIX}.cmake)
				message(DEBUG
						"Including ${ARGS_PACKAGE}Targets_${_comp}_${ARGS_LIB_PREFIX}.cmake: ${${ARGS_PACKAGE}_FOUND}"
				)
				# Check if include was successful
				if (${ARGS_PACKAGE}_FOUND)
					set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
					set(${ARGS_PACKAGE}_${_comp}_LIB_TYPE ${ARGS_LIB_PREFIX})
				else ()
					set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
					# Return because we know it is a shared/static component from the presence of the file
					message(${stdout_type}
							"Could not load component ${_comp} of type ${ARGS_LIB_PREFIX}"
					)
					return()
				endif ()
			elseif (ARGS_FALLBACK_PREFIX)
				# Try to load the fallback library if have one
				include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}_${ARGS_FALLBACK_PREFIX}.cmake OPTIONAL
						RESULT_VARIABLE ${ARGS_PACKAGE}_${_comp}_FOUND)
				message(DEBUG
						"Including ${ARGS_PACKAGE}Targets_${_comp}_${ARGS_FALLBACK_PREFIX}.cmake: ${${ARGS_PACKAGE}_${_comp}_FOUND}"
				)
				# Reformat Comp_FOUND variable to TRUE/FALSE and check if include was successful
				if (${ARGS_PACKAGE}_${_comp}_FOUND AND ${ARGS_PACKAGE}_FOUND)
					set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
					set(${ARGS_PACKAGE}_${_comp}_LIB_TYPE ${ARGS_FALLBACK_PREFIX})
				elseif (NOT ${ARGS_PACKAGE}_FOUND)
					# File was present, but failed to load
					set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
					message(${stdout_type}
							"Could not load component ${_comp} of type ${ARGS_FALLBACK_PREFIX}"
					)
					return()
				else ()
					unset(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
				endif ()
			endif ()
		endif ()

		# Handle the non-shared/static library targets
		if (DEFINED ${ARGS_PACKAGE}_${_comp}_SharedStatic AND NOT ${ARGS_PACKAGE}_${_comp}_SharedStatic)
			# If we know the package is not shared/static library handle it as the main component file
			include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}.cmake OPTIONAL
					RESULT_VARIABLE ${ARGS_PACKAGE}_${_comp}_FOUND)
			message(DEBUG
					"Including ${ARGS_PACKAGE}Targets_${_comp}.cmake: ${${ARGS_PACKAGE}_${_comp}_FOUND}"
			)
			# Reformat Comp_FOUND variable to TRUE/FALSE and check if include was successful
			if (${ARGS_PACKAGE}_${_comp}_FOUND AND ${ARGS_PACKAGE}_FOUND)
				set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
			else ()
				set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
				message(${stdout_type}
						"Could not load component ${_comp}"
				)
				return()
			endif ()
		else ()
			# Otherwise still try to parse the non shared/static library
			message(DEBUG
					"Trying to include ${ARGS_PACKAGE}Targets_${_comp}.cmake (${ARGS_PACKAGE}_${_comp}_FOUND=${${ARGS_PACKAGE}_${_comp}_FOUND})"
			)
			if (DEFINED ${ARGS_PACKAGE}_${_comp}_SharedStatic)
				# We know it is a static/shared library, only fail if the include has failed, not if it doesn't exist
				include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}.cmake OPTIONAL)
				if (NOT ${ARGS_PACKAGE}_FOUND)
					set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
					message(${stdout_type}
							"Could not load component ${_comp}"
					)
					return()
				endif ()
			else ()
				# We don't know what type the component is. Try to set it to found ${${ARGS_PACKAGE}_${_comp}_FOUND}
				include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}.cmake OPTIONAL
						RESULT_VARIABLE _temp_flag)
				message(DEBUG
						"Include result:\n"
						"_temp_flag=${_temp_flag}\n"
						"${ARGS_PACKAGE}_${_comp}_FOUND = ${${ARGS_PACKAGE}_${_comp}_FOUND}"
				)

				# Check if either it was static/shared or arbitrary component
				if ((${ARGS_PACKAGE}_${_comp}_FOUND OR _temp_flag) AND ${ARGS_PACKAGE}_FOUND)
					set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
				else ()
					set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
					message(${stdout_type}
							"Could not load component ${_comp}"
					)
					return()
				endif ()
			endif ()
		endif ()
	else ()
		# We do not have shared/static components
		message(DEBUG
				"Including ${_comp} without shared/static:"
		)
		# Check if required component is installed
		include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_comp}.cmake OPTIONAL
				RESULT_VARIABLE ${ARGS_PACKAGE}_${_comp}_FOUND)
		# Reformat Comp_FOUND variable to TRUE/FALSE and check if include was successful
		if (${ARGS_PACKAGE}_${_comp}_FOUND AND ${ARGS_PACKAGE}_FOUND)
			set(${ARGS_PACKAGE}_${_comp}_FOUND TRUE)
		else ()
			set(${ARGS_PACKAGE}_${_comp}_FOUND FALSE)
			message(${stdout_type}
					"Could not load component ${_comp}"
			)
			return()
		endif ()
	endif ()

	message(${stdout_type}
			"Found component ${_comp} ${${ARGS_PACKAGE}_${_comp}_LIB_TYPE}"
	)
endmacro()

macro(find_components)
	# Include all available components
	#
	# Requires a target file format equivalent to those generated by `export_component`
	#
	# Named arguments::
	#   COMPONENTS (list<string>): List of supported components (without deprecated components). If empty will just load global target
	#   DEPRECATED_COMPONENTS (list<string>): List of deprecated components.
	# Options
	#   PRINT: Print results when loading each component
	#   LOAD_ALL_DEFAULT: Load all supported components if no components are passed
	#   HAVE_GLOBAL: Whether global targets file is defined (see bellow)
	#   HAVE_GLOBAL_SHARED_STATIC: Whether global static/shared targets file is defined (see bellow)
	# Assumptions ::
	#   Defined variables in ${PACKAGE}Config.cmake file::
	#     ${PACKAGE}_<comp>_Replacement (string): Replacement components for component <comp>. If not defined will ignore.
	#     ${PACKAGE}_<comp>_SharedStatic (bool): Whether the component should have static/shared targets. If not defined will try to find target.
	#   Name format of target files:
	#     ${PACKAGE}Targets.cmake: Global targets
	#     ${PACKAGE}Targets-{static/shared}.cmake: Global static/shared library targets
	#     ${PACKAGE}Targets-<comp>.cmake: Component targets
	#     ${PACKAGE}Targets-{static/shared}-<comp>.cmake: Static/Shared component library targets
	#
	# For a reference to the find_package variables check:
	# https://cmake.org/cmake/help/latest/command/find_package.html#package-file-interface-variables

	list(APPEND CMAKE_MESSAGE_CONTEXT find_components)
	set(ARGS_Options "")
	set(ARGS_OneValue "")
	set(ARGS_MultiValue "")
	list(APPEND ARGS_Options
			PRINT
			LOAD_ALL_DEFAULT
			HAVE_GLOBAL
			HAVE_GLOBAL_SHARED_STATIC
	)
	list(APPEND ARGS_MultiValue
			COMPONENTS
			DEPRECATED_COMPONENTS
	)

	cmake_parse_arguments(ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}" ${ARGN})

	## Basic checks
	set(ARGS_PACKAGE ${CMAKE_FIND_PACKAGE_NAME})
	if (NOT DEFINED ARGS_COMPONENTS AND DEFINED ${ARGS_PACKAGE}_Supported_Comps)
		set(ARGS_COMPONENTS ${${ARGS_PACKAGE}_Supported_Comps})
	endif ()
	if (NOT DEFINED ARGS_DEPRECATED_COMPONENTS AND DEFINED ${ARGS_PACKAGE}_Deprecated_Comps)
		set(ARGS_DEPRECATED_COMPONENTS ${${ARGS_PACKAGE}_Deprecated_Comps})
	elseif (NOT DEFINED ARGS_DEPRECATED_COMPONENTS)
		set(ARGS_DEPRECATED_COMPONENTS "")
	endif ()

	if (ARGS_PRINT)
		set(stdout_type STATUS)
	else ()
		set(stdout_type VERBOSE)
	endif ()


	# Setting package found to true by default
	# Using `include()` on `<PACKAGE>Targets.cmake` will set `<PACKAGE>_FOUND` to false if it errors
	set(${ARGS_PACKAGE}_FOUND TRUE)

	message(${stdout_type}
			"Looking for package components of ${ARGS_PACKAGE}"
	)
	message(DEBUG
			"Passed arguments:\n"
			"PACKAGE = ${ARGS_PACKAGE}\n"
			"COMPONENTS = ${ARGS_COMPONENTS}\n"
			"DEPRECATED_COMPONENTS = ${ARGS_DEPRECATED_COMPONENTS}\n"
			"LOAD_ALL_DEFAULT = ${ARGS_LOAD_ALL_DEFAULT}\n"
			"HAVE_GLOBAL = ${ARGS_HAVE_GLOBAL}\n"
			"HAVE_GLOBAL_SHARED_STATIC = ${ARGS_HAVE_GLOBAL_SHARED_STATIC}\n"
			"${ARGS_PACKAGE}_FIND_COMPONENTS = ${${ARGS_PACKAGE}_FIND_COMPONENTS}"
	)
	file(GLOB _cmake_target_files RELATIVE ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/*)
	message(DEBUG
			"CMAKE_CURRENT_LIST_DIR = ${CMAKE_CURRENT_LIST_DIR}\n"
			"Files: ${_cmake_target_files}"
	)

	if (NOT DEFINED ARGS_COMPONENTS)
		# End early if no component logic is defined
		if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets.cmake)
			message(WARNING
					"No ${ARGS_PACKAGE}Targets.cmake file bundled. (Report to package distributor of ${ARGS_PACKAGE})"
			)
			set(${ARGS_PACKAGE}_FOUND FALSE)
		else ()
			include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets.cmake)
			message(${stdout_type}
					"Found package: ${ARGS_PACKAGE} -> ${${ARGS_PACKAGE}_FOUND}"
			)
		endif ()
		return()
	else ()
		# Check if package support shared/static components
		if ("shared" IN_LIST ARGS_COMPONENTS AND "static" IN_LIST ARGS_COMPONENTS)
			set(_with_shared_static TRUE)
		elseif (NOT "shared" IN_LIST ARGS_COMPONENTS AND NOT "static" IN_LIST ARGS_COMPONENTS)
			set(_with_shared_static FALSE)
		else ()
			message(FATAL_ERROR
					"COMPONENTS list is incompatible\n"
					"Please include both `static` and `shared` components"
			)
			set(${ARGS_PACKAGE}_FOUND FALSE)
			return()
		endif ()
	endif ()

	# Set subfunction options
	set(sub_func_ARGS "")
	list(APPEND
			PACKAGE ${ARGS_PACKAGE})
	if (ARGS_PRINT)
		list(APPEND sub_func_ARGS PRINT)
	endif ()

	# Initialize components check
	set(${ARGS_PACKAGE}_COMPONENTS "")

	# Check for unknown components
	# TODO: Not checking for different name used in ${CMAKE_FIND_PACKAGE_NAME}
	foreach (comp IN LISTS ${ARGS_PACKAGE}_FIND_COMPONENTS)
		if (NOT comp IN_LIST ARGS_COMPONENTS)
			if (comp IN_LIST ARGS_DEPRECATED_COMPONENTS)
				set(extra_msg "")
				if (DEFINED ${ARGS_PACKAGE}_${comp}_Replacement)
					list(APPEND ${ARGS_PACKAGE}_FIND_COMPONENTS ${${ARGS_PACKAGE}_${comp}_Replacement})
					set(extra_msg "Replace component: ${comp} -> ${${ARGS_PACKAGE}_${comp}_Replacement}")
				else ()
					set(extra_msg "Importing ${comp} has now no effect")
				endif ()
				message(DEPRECATION
						"Trying to import deprecated component of package: ${ARGS_PACKAGE}\n"
						"Deprecated component: ${comp}\n"
						"${extra_msg}"
				)
				list(REMOVE_ITEM ${ARGS_PACKAGE}_FIND_COMPONENTS ${comp})
			else ()
				message(WARNING
						"Failed to load package: ${ARGS_PACKAGE}\n"
						"Trying to import unknown component of package: ${ARGS_PACKAGE}\n"
						"Unsupported component: ${comp}"
				)
				set(${ARGS_PACKAGE}_FOUND FALSE)
				return()
			endif ()
		endif ()
	endforeach ()

	# Handle shared and static components
	if (_with_shared_static)
		# Error if both shared and static components are requested
		if ("shared" IN_LIST ${ARGS_PACKAGE}_FIND_COMPONENTS AND "static" IN_LIST ${ARGS_PACKAGE}_FIND_COMPONENTS)
			message(WARNING
					"Failed to load package: ${ARGS_PACKAGE}\n"
					"Cannot load both `shared` and `static` components at the same time. Select only one of those two"
			)
			set(${ARGS_PACKAGE}_FOUND FALSE)
			return()
		endif ()

		# Get the shared/static targets to be loaded
		if ("shared" IN_LIST ${ARGS_PACKAGE}_FIND_COMPONENTS)
			list(REMOVE_ITEM ${ARGS_PACKAGE}_FIND_COMPONENTS shared)
			set(_libPrefix shared)
		elseif ("static" IN_LIST ${ARGS_PACKAGE}_FIND_COMPONENTS)
			list(REMOVE_ITEM ${ARGS_PACKAGE}_FIND_COMPONENTS static)
			set(_libPrefix static)
		elseif (DEFINED ${ARGS_PACKAGE}_SHARED_LIBS)
			if (${ARGS_PACKAGE}_SHARED_LIBS)
				set(_libPrefix shared)
			else ()
				set(_libPrefix static)
			endif ()
		else ()
			if (DEFINED BUILD_SHARED_LIBS AND NOT BUILD_SHARED_LIBS)
				set(_libPrefix static)
				set(_fallbackPrefix shared)
			else ()
				set(_libPrefix shared)
				set(_fallbackPrefix static)
			endif ()
		endif ()
		list(APPEND sub_func_ARGS LIB_PREFIX ${_libPrefix})
		if (DEFINED _fallbackPrefix)
			list(APPEND sub_func_ARGS FALLBACK_PREFIX ${_fallbackPrefix})
		endif ()
	endif ()

	message(DEBUG
			"_with_shared_static = ${_with_shared_static}\n"
			"_libPrefix = ${_libPrefix}\n"
			"_fallbackPrefix = ${_fallbackPrefix}\n"
			"sub_func_ARGS = ${sub_func_ARGS}"
	)

	# Parse global targets
	# Note: These have to be parsed before components in case components depend on it.
	#       Global targets should not have component dependencies
	if (ARGS_HAVE_GLOBAL)
		message(VERBOSE
				"Trying to include ${ARGS_PACKAGE}Targets.cmake"
		)
		if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets.cmake)
			include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets.cmake)
			if (NOT ${ARGS_PACKAGE}_FOUND)
				# Check if include was successful
				message(WARNING
						"Failed to load package: ${ARGS_PACKAGE}\n"
						"Could not load file: ${ARGS_PACKAGE}Targets.cmake"
				)
				set(${ARGS_PACKAGE}_FOUND FALSE)
				return()
			endif ()
		else ()
			message(WARNING
					"Failed to load package: ${ARGS_PACKAGE}\n"
					"Missing file: ${ARGS_PACKAGE}Targets.cmake (Report to package distributor of ${ARGS_PACKAGE})"
			)
			set(${ARGS_PACKAGE}_FOUND FALSE)
			return()
		endif ()
	endif ()

	# Parse global static/shared targets
	if (_with_shared_static AND ARGS_HAVE_GLOBAL_SHARED_STATIC)
		message(VERBOSE
				"Trying to include ${ARGS_PACKAGE}Targets_${_libPrefix}.cmake (or ${_fallbackPrefix})"
		)
		if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_libPrefix}.cmake)
			include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_libPrefix}.cmake)
			set(${ARGS_PACKAGE}_LIB_TYPE ${_libPrefix})
		elseif (DEFINED _fallbackPrefix AND EXISTS ${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_fallbackPrefix}.cmake)
			include(${CMAKE_CURRENT_LIST_DIR}/${ARGS_PACKAGE}Targets_${_fallbackPrefix}.cmake)
			set(${ARGS_PACKAGE}_LIB_TYPE ${_fallbackPrefix})
		else ()
			message(WARNING
					"Failed to load package: ${ARGS_PACKAGE}\n"
					"Could not load static/shared component: ${_libPrefix}\n"
					"Missing file: ${ARGS_PACKAGE}Targets_${_libPrefix}.cmake"
			)
			set(${ARGS_PACKAGE}_FOUND FALSE)
			return()
		endif ()
		if (NOT ${ARGS_PACKAGE}_FOUND)
			# Check if include was successful
			message(WARNING
					"Failed to load package: ${ARGS_PACKAGE}\n"
					"Could not load file: ${ARGS_PACKAGE}Targets_${${ARGS_PACKAGE}_LIB_TYPE}.cmake"
			)
			set(${ARGS_PACKAGE}_FOUND FALSE)
			return()
		endif ()
	endif ()

	# Parse components
	if (${ARGS_PACKAGE}_FIND_COMPONENTS)
		# If specific components are passed handle only these components
		message(VERBOSE
				"Trying to search for specific components: ${${ARGS_PACKAGE}_FIND_COMPONENTS}"
		)
		foreach (comp IN LISTS ${ARGS_PACKAGE}_FIND_COMPONENTS)
			# Should make sure <PACKAGE>_FOUND is always true to know if component is found or not
			set(${ARGS_PACKAGE}_FOUND TRUE)
			get_component(${comp} CHECK_REQUIRED ${sub_func_ARGS})
			if (${ARGS_PACKAGE}_FIND_REQUIRED_${comp} AND NOT ${ARGS_PACKAGE}_${comp}_FOUND)
				message(DEBUG
						"Failed to load package: ${ARGS_PACKAGE}\n"
						"Could not load component: ${comp}"
				)
				set(${ARGS_PACKAGE}_FOUND FALSE)
				return()
			endif ()
			# Append components found
			list(APPEND ${ARGS_PACKAGE}_COMPONENTS ${comp})
		endforeach ()
	elseif (ARGS_LOAD_ALL_DEFAULT)
		# If no components are passed and ${_load_all_default} is true, get all supported components
		list(REMOVE_ITEM ARGS_COMPONENTS "static" "shared")
		message(VERBOSE
				"Trying to search for all components: ${ARGS_COMPONENTS}"
		)
		foreach (comp IN LISTS ARGS_COMPONENTS)
			# Should make sure <PACKAGE>_FOUND is always true to know if component is found or not
			set(${ARGS_PACKAGE}_FOUND TRUE)
			get_component(${comp} ${sub_func_ARGS})
			if (${ARGS_PACKAGE}_${comp}_FOUND)
				# No need to fail if component not found. Just add the successful ones
				list(APPEND ${ARGS_PACKAGE}_COMPONENTS ${comp})
			endif ()
		endforeach ()
		# At the end some components might have set <PACKAGE>_FOUND false. Reset it to true because these are optional
		set(${ARGS_PACKAGE}_FOUND TRUE)
	endif ()

	# Final print status
	message(${stdout_type}
			"Found package: ${ARGS_PACKAGE}"
	)
endmacro()

function(export_component)
	# Export package component
	#
	# Designed to be compatible with `find_components`
	#
	# Named arguments::
	#   PROJECT (string) [${PROJECT_NAME}]: Project name. Also used as prefix
	#   TARGET (string) [${PROJECT}Targets or ${PROJECT}Targets-${COMPONENT}]: Target export component
	#   COMPONENT (string): Package component
	#   LIB_TYPE (string) : Whether the target is shared/static or general

	list(APPEND CMAKE_MESSAGE_CONTEXT export_component)
	set(ARGS_Options "")
	set(ARGS_OneValue "")
	set(ARGS_MultiValue "")
	list(APPEND ARGS_Options
			PRINT
	)
	list(APPEND ARGS_OneValue
			PROJECT
			TARGET
			COMPONENT
			LIB_TYPE
	)
	set(LIB_TYPE_Choices "")
	list(APPEND LIB_TYPE_Choices static shared)

	# Include GNUInstallDirs if not done already
	if (NOT DEFINED CMAKE_INSTALL_DATAROOTDIR)
		include(GNUInstallDirs)
	endif ()

	# Choose appropriate target install location
	get_property(ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
	if (NOT ENABLED_LANGUAGES)
		set(install_prefix ${CMAKE_INSTALL_DATAROOTDIR})
	else ()
		set(install_prefix ${CMAKE_INSTALL_LIBDIR})
	endif ()

	cmake_parse_arguments(ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}" ${ARGN})

	if (NOT DEFINED ARGS_PROJECT)
		set(ARGS_PROJECT "${PROJECT_NAME}")
	endif ()
	if (DEFINED ARGS_LIB_TYPE AND NOT ARGS_LIB_TYPE IN_LIST LIB_TYPE_Choices)
		message(FATAL_ERROR
				"Unknown LIB_TYPE passed: ${ARGS_LIB_TYPE}\n"
				"  Valid choices: ${LIB_TYPE_Choices}")
	endif ()

	if (ARGS_PRINT)
		set(stdout_type STATUS)
	else ()
		set(stdout_type VERBOSE)
	endif ()

	# Configure target and target file
	if (ARGS_COMPONENT)
		if (NOT DEFINED ARGS_TARGET)
			set(ARGS_TARGET "${ARGS_PROJECT}Targets-${ARGS_COMPONENT}")
		endif ()
		if (ARGS_LIB_TYPE)
			set(TargetFile "${ARGS_PROJECT}Targets_${ARGS_COMPONENT}_${ARGS_LIB_TYPE}.cmake")
		else ()
			set(TargetFile "${ARGS_PROJECT}Targets_${ARGS_COMPONENT}.cmake")
		endif ()
	else ()
		if (NOT DEFINED ARGS_TARGET)
			set(ARGS_TARGET "${ARGS_PROJECT}Targets")
		endif ()
		if (ARGS_LIB_TYPE)
			set(TargetFile "${ARGS_PROJECT}Targets_${ARGS_LIB_TYPE}.cmake")
		else ()
			set(TargetFile "${ARGS_PROJECT}Targets.cmake")
		endif ()
	endif ()

	install(EXPORT ${ARGS_TARGET}
			FILE ${TargetFile}
			NAMESPACE ${ARGS_PROJECT}::
			DESTINATION ${install_prefix}/cmake/${ARGS_PROJECT}
			COMPONENT ${ARGS_PROJECT}_Development)
	export(EXPORT ${ARGS_TARGET}
			FILE ${TargetFile}
			NAMESPACE ${ARGS_PROJECT}::)

	message(${stdout_type}
			"Configured package component for export\n"
			"  Target: ${Target}\n"
			"  TargetFile: ${TargetFile}"
	)
endfunction()

list(POP_BACK CMAKE_MESSAGE_CONTEXT)
