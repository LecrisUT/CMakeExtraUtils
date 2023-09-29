include_guard()
include(FetchContent)

function(CEU_FetchContent_Declare name)
	#[===[.md
	# CEU_FetchContent_Declare

	A short compatibility function to mimic FIND_PACKAGE_ARGS functionality. All arguments are equivalent to
	upstream [`FetchContent_Declare`][FetchContent_Declare] from version `3.24`

	## Synopsis
	```cmake
	  CEU_FetchContent_Declare(<name>
	  		[LIST_VAR <var>]
	  		...
	  )
	```

	## Options
	`<name>`
	: Name of the FetchContent declared item

	`LIST_VAR`
	: Variable where to accumulate the declared items. If [`find_package`][find_package] was used, the declared item is
	  not appended to the list. Otherwise the item is appended so that it is later called through
	  [`FetchContent_MakeAvailable`][FetchContent_MakeAvailable]

	`...`
	: All other arguments are passed directly to `FetchContent_Declare`

	## See also
	- [find_package]: <inv:cmake:cmake:command#command:find_package>
	- [FetchContent_Declare]: <inv:cmake:cmake:command#command:fetchcontent_declare>
	- [FetchContent_MakeAvailable]: <inv:cmake:cmake:command#command:fetchcontent_makeavailable>
	]===]

	if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.24)
		# If cmake supports `FIND_PACKAGE_ARGS` simply pass the arguments to the native function
		FetchContent_Declare(${name} ${ARGN})
	else ()
		list(APPEND CMAKE_MESSAGE_CONTEXT "CEU_FetchContent_Declare")

		set(ARGS_Options "OVERRIDE_FIND_PACKAGE")
		set(ARGS_OneValue "LIST_VAR")
		set(ARGS_MultiValue "FIND_PACKAGE_ARGS")
		cmake_parse_arguments(ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}" ${ARGN})

		if (ARGS_OVERRIDE_FIND_PACKAGE)
			message(FATAL_ERROR "Cannot back-port OVERRIDE_FIND_PACKAGE")
		endif ()

		# First check for FETCHCONTENT_SOURCE_DIR_<uppercaseName>
		# this always takes precedence, and should be treated as a FetchContent package
		string(TOUPPER ${name} upper_name)
		if (NOT DEFINED FETCHCONTENT_SOURCE_DIR_${upper_name})
			# Next handle according to FETCHCONTENT_TRY_FIND_PACKAGE_MODE
			if (NOT DEFINED FETCHCONTENT_TRY_FIND_PACKAGE_MODE)
				set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE OPT_IN)
			endif ()
			# Check if `FIND_PACKAGE_ARGS` was passed
			if ((FETCHCONTENT_TRY_FIND_PACKAGE_MODE STREQUAL "OPT_IN" AND DEFINED ARGS_FIND_PACKAGE_ARGS) OR
			(FETCHCONTENT_TRY_FIND_PACKAGE_MODE STREQUAL "ALWAYS"))
				# Try to do find_package. If it fails fallthrough and use FetchContent
				# The package should have `FIND_PACKAGE_ARGS REQUIRED` to deny fallthrough
				find_package(${name} ${ARGS_FIND_PACKAGE_ARGS})
				# Check if package was found. The variable name should always be `${name}_FOUND` and set by
				# cmake itself internally
				if (${name}_FOUND)
					# Early return to avoid adding to LIST_VAR
					return()
				endif ()
			endif ()
			# The remaining case is `FETCHCONTENT_TRY_FIND_PACKAGE_MODE == NEVER` which should should fall through
		endif ()
		# Continue to call `FetchContent_Declare` as usual
		# Pass all other arguments that were used
		FetchContent_Declare(${name}
				${ARGS_UNPARSED_ARGUMENTS})
	endif ()

	# Finally add to LIST_VAR argument to be handled by FetchContent_MakeAvailable
	if (DEFINED ARGS_LIST_VAR)
		list(APPEND ${ARGS_LIST_VAR} ${name})
	endif ()
endfunction()

function(CEU_FetchContent_MakeAvailable)
	#[===[.md
	# CEU_FetchContent_MakeAvailable

	A small wrapper around [`FetchContent_MakeAvailable`][FetchContent_MakeAvailable] to run scripts before and/or
	after the call to [`FetchContent_MakeAvailable`][FetchContent_MakeAvailable]. See the options details for common
	examples when they are used

	## Synopsis
	```cmake
	  CEU_FetchContent_MakeAvailable(<name1> <name2>
	  		[MODULES_PATH <path>]
	  		[PREFIX <path>]
	  		[BEFORE_SUFFIX <string>]
	  		[AFTER_SUFFIX <string>]
	  )
	```

	## Options
	`<name1> ...`
	: Names of the FetchContent projects to be made available. If using together with `CEU_FetchContent_Declare`, it
	  should use the list specified in `LIST_VAR`

	`MODULES_PATH` [Default: `${PROJECT_SOURCE_DIR}/cmake/compat`]
	: Path to the module directory where to search for files to be run before/after
	  [`FetchContent_MakeAvailable][FetchContent_MakeAvailable]

	`PREFIX` [Default: `FetchContent`]
	: The prefix that is prepended to the file name that is searched to be included before/after
	  [`FetchContent_MakeAvailable`][FetchContent_MakeAvailable]. Specifically the filenames that are searched for are
	  constructed as `<PREFIX><name><BEFORE_SUFFIX/AFTER_SUFFIX>.cmake`

	`BEFORE_SUFFIX` [Default: `_Before`]
	: The suffix path name used to search for the file to be included **before** the
	  [`FetchContent_MakeAvailable`][FetchContent_MakeAvailable] call. See `PREFIX` option for more details

	`AFTER_SUFFIX` [Default: `_After`]
	: The suffix path name used to search for the file to be included **after** the
	  [`FetchContent_MakeAvailable`][FetchContent_MakeAvailable] call. See `PREFIX` option for more details

	## See also
	- [FetchContent_Declare]: <inv:cmake:cmake:command#command:fetchcontent_declare>
	- [FetchContent_MakeAvailable]: <inv:cmake:cmake:command#command:fetchcontent_makeavailable>
	]===]

	list(APPEND CMAKE_MESSAGE_CONTEXT "CEU_FetchContent_MakeAvailable")
	set(ARGS_Options "")
	set(ARGS_OneValue "MODULES_PATH;PREFIX;BEFORE_SUFFIX;AFTER_SUFFIX")
	set(ARGS_MultiValue "")
	cmake_parse_arguments(ARGS "${ARGS_Options}" "${ARGS_OneValue}" "${ARGS_MultiValue}" ${ARGN})

	if(NOT DEFINED ARGS_MODULES_PATH)
		set(ARGS_MODULES_PATH ${PROJECT_SOURCE_DIR}/cmake/compat)
	endif ()
	if(NOT DEFINED ARGS_PREFIX)
		set(ARGS_PREFIX FetchContent)
	endif ()
	if(NOT DEFINED ARGS_BEFORE_SUFFIX)
		set(ARGS_BEFORE_SUFFIX _Before)
	endif ()
	if(NOT DEFINED ARGS_AFTER_SUFFIX)
		set(ARGS_AFTER_SUFFIX _After)
	endif ()

	foreach (pkg IN LISTS ARGS_UNPARSED_ARGUMENTS)
		include(${ARGS_MODULES_PATH}/${ARGS_PREFIX}${pkg}${ARGS_BEFORE_SUFFIX}.cmake OPTIONAL)
		FetchContent_MakeAvailable(${pkg})
		include(${ARGS_MODULES_PATH}/${ARGS_PREFIX}${pkg}${ARGS_AFTER_SUFFIX}.cmake OPTIONAL)
	endforeach ()
endfunction()
