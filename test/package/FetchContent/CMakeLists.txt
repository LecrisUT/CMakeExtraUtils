cmake_minimum_required(VERSION 3.20)
project(test_import_FetchContent LANGUAGES NONE)

include(FetchContent)

if (DEFINED ENV{PACKIT_SOURCE_URL})
	set(git_repo $ENV{PACKIT_SOURCE_URL})
else ()
	set(git_repo https://github.com/LecrisUT/CmakeExtraUtils)
endif ()
if (DEFINED ENV{PACKIT_SOURCE_SHA})
	set(git_tag $ENV{PACKIT_SOURCE_SHA})
elseif (DEFINED ENV{PACKIT_COMMIT_SHA})
	set(git_tag $ENV{PACKIT_COMMIT_SHA})
else ()
	set(git_tag main)
endif ()

FetchContent_Declare(CMakeExtraUtils
		GIT_REPOSITORY ${git_repo}
		GIT_TAG ${git_tag}
)
FetchContent_MakeAvailable(CMakeExtraUtils)

# Smoke test: Make sure the modules are importable
include(DynamicVersion)
include(PackageComps)
