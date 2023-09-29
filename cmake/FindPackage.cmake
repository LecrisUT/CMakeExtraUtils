include_guard()
find_package(PkgConfig QUIET)

macro(FindPackage name)
	#[===[.md
	# FindPackage

	A compatibility macro that links [`find_package(CONFIG)`][find_package] packages with `pkg-config`. This should only
	be called within a `Find<PackageName>.cmake` file.

	## Synopsis
	```cmake
	  FindPackage(<name>
	  		[NAMES <name1> <name2>]
	  		[PKG_MODULE_NAMES <name1> <name2>]
	  		[PKG_MODULE_SPECS <spec1> <spec2>]
	  		[HAVE_FALLBACK]
	  )
	```

	## Options
	`name`
	: Name to be used when calling [`find_package(CONFIG)`][find_package]. Generally should be
	  `${CMAKE_FIND_PACKAGE_NAME}`

	`NAMES`
	: Additional names to be used when searching with [`find_package(CONFIG)`][find_package]

	`PKG_MODULE_NAMES`
	: If provided, it will run [`pkg_search_module()`][pkg_search_module] if [`find_package(CONFIG)`][find_package]
	  fails

	`PKG_MODULE_SPECS`
	: The pkg-config specs used in [`pkg_search_module()`][pkg_search_module]

	  :::{note}
	  Version range syntax is not supported for pkg-config searching. Only the lower bound will be respected.
	  :::

	`HAVE_FALLBACK`
	: Whether the calling `Find<PackageName>.cmake` file has fallback to use [`find_library`][find_library] and
	  [`find_path`][find_path]

	## See Also
	- [find_package]: <inv:cmake:cmake:command#command:find_package>
	- [pkg_search_module]: <inv:cmake:cmake:command#command:pkg_search_module>
	- [find_library]: <inv:cmake:cmake:command#command:find_library>
	- [find_path]: <inv:cmake:cmake:command#command:find_path>

	]===]

	list(APPEND CMAKE_MESSAGE_CONTEXT "FindPackage")
	set(ARGS_Options "HAVE_FALLBACK")
	set(ARGS_OneValue "")
	set(ARGS_MultiValue "NAMES;PKG_MODULE_NAMES;PKG_MODULE_SPECS")
	cmake_parse_arguments(ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}" ${ARGN})

	# First try to find native <PackageName>Config.cmake
	# Build the arguments
	# COMPONENTS
	set(_comp_args)
	set(_opt_comp_args)
	if (DEFINED ${name}_FIND_COMPONENTS)
		list(APPEND _comp_args COMPONENTS)
		foreach (_comp IN LISTS ${name}_FIND_COMPONENTS)
			if (${name}_FIND_REQUIRED_${_comp})
				list(APPEND _comp_args ${_comp})
			else ()
				if (NOT DEFINED _opt_comp_args)
					list(APPEND _opt_comp_args OPTIONAL_COMPONENTS)
				endif ()
				list(APPEND _opt_comp_args ${_comp})
			endif ()
		endforeach ()
	endif ()

	# Version
	# Try range format first, otherwise use the default
	set(_version_args ${${name}_FIND_VERSION_RANGE})
	if (NOT DEFINED _version_args)
		set(_version_args ${${name}_FIND_VERSION})
	endif ()
	if (${name}_FIND_VERSION_EXACT)
		list(APPEND _version_args EXACT)
	endif ()

	# QUIET
	set(_quiet_arg)
	if (${name}_FIND_QUIETLY)
		list(APPEND _quiet_arg QUIET)
	endif ()

	# REQUIRED
	set(_required_arg)
	if (NOT ARGS_HAVE_FALLBACK AND ${name}_FIND_REQUIRED)
		list(APPEND _required_arg REQUIRED)
	endif ()

	# REGISTRY_VIEW
	set(_registry_view_arg)
	if (${name}_FIND_REGISTRY_VIEW)
		list(APPEND _registry_view REGISTRY_VIEW ${${name}_FIND_REGISTRY_VIEW})
	endif ()

	# NAMES
	set(_names_args)
	if (DEFINED ARGS_NAMES)
		list(APPEND _names_args NAMES ${ARGS_NAMES})
	endif ()

	# Disable CMAKE_REQUIRE_FIND_PACKAGE_<PackageName> because there is a fallthrough to pkg-config
	set(CMAKE_REQUIRE_FIND_PACKAGE_${name} FALSE)

	# Try <PackageName>Config.cmake
	find_package(${name} ${_version_args} ${_quiet_arg} CONFIG
			${_comp_args}
			${_opt_comp_args}
			${_registry_view_arg}
			${_names_args}
	)
	if (${name}_FOUND)
		find_package_handle_standard_args(${name}
				CONFIG_MODE HANDLE_COMPONENTS
		)
	elseif (PKG_CONFIG_FOUND)
		# Try pkg-config next
		# Construct the moduleSpec to search for
		if (NOT DEFINED ARGS_PKG_MODULE_SPECS)
			if (NOT DEFINED ARGS_PKG_MODULE_NAMES)
				set(ARGS_PKG_MODULE_NAMES ${name})
			endif ()
			if (DEFINED ${name}_FIND_VERSION_RANGE)
				# Can only parse the minimum requirement
				foreach (_pkg_name IN LISTS ARGS_PKG_MODULE_NAMES)
					list(APPEND ARGS_PKG_MODULE_SPECS "${_pkg_name}>=${${name}_FIND_VERSION_MIN}")
				endforeach ()
			elseif ({${name}_FIND_VERSION_EXACT)
				# Requesting exact version
				foreach (_pkg_name IN LISTS ARGS_PKG_MODULE_NAMES)
					list(APPEND ARGS_PKG_MODULE_SPECS "${_pkg_name}=${${name}_FIND_VERSION}")
				endforeach ()
			elseif (DEFINED ${name}_FIND_VERSION)
				# Otherwise treat the request as minimum requirement
				foreach (_pkg_name IN LISTS ARGS_PKG_MODULE_NAMES)
					list(APPEND ARGS_PKG_MODULE_SPECS "${_pkg_name}>=${${name}_FIND_VERSION}")
				endforeach ()
			else ()
				# Fallthrough if no version is required
				foreach (_pkg_name IN LISTS ARGS_PKG_MODULE_NAMES)
					list(APPEND ARGS_PKG_MODULE_SPECS "${_pkg_name}")
				endforeach ()
			endif ()
		endif ()
		# Call pkg-config
		if (CMAKE_VERSION VERSION_LESS 3.28)
			# https://gitlab.kitware.com/cmake/cmake/-/issues/25228
			set(ENV{PKG_CONFIG_ALLOW_SYSTEM_CFLAGS} 1)
		endif ()
		if (CMAKE_VERSION VERSION_LESS 3.22)
			# Back-porting
			# https://gitlab.kitware.com/cmake/cmake/-/merge_requests/6345
			set(ENV{PKG_CONFIG_ALLOW_SYSTEM_LIBS} 1)
		endif ()
		pkg_search_module(${name}
				${_required_arg} ${_quiet_arg}
				IMPORTED_TARGET
				${ARGS_PKG_MODULE_SPECS})
		# Mark the package as found by pkg-config
		if (${name}_FOUND)
			set(${name}_PKGCONFIG True)
		endif ()
	endif ()

	# Sanitize local variables in order to not contaminate future calls
	set(ARGS_Options)
	set(ARGS_OneValue)
	set(ARGS_MultiValue)
	set(ARGS_UNPARSED_ARGUMENTS)
	set(ARGS_NAMES)
	set(ARGS_PKG_MODULE_NAMES)
	set(ARGS_PKG_MODULE_SPECS)
	set(_version_args)
	set(_quiet_arg)
	set(_comp_args)
	set(_opt_comp_args)
	set(_registry_view_arg)
	set(_names_args)
	set(_pkg_name)
	list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endmacro()
