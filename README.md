# CMakeExtraUtils

Extra utilities for cmake:

- [`DynamicVersion`](cmake/DynamicVersion.md)
- [`PackageComps`](cmake/PackageComps.md)

## Installation

These utilities can be included using both `find_package()` and `ExternalProject`, e.g. if `CMakeExtraUtils` is already
installed on your system:

```cmake
cmake_minimum_required(VERSION 3.20)

find_package(CMakeExtraUtils REQUIRED)

include(DynamicVersion)
dynamic_version()

project(MyProject
        VERSION ${PROJECT_VERSION})
```

or if you want to download a specific version:

```cmake
cmake_minimum_required(VERSION 3.20)

FetchContet_Declare(CMakeExtraUtils
        GIT_REPOSITORY https://github.com/LecriUT/CMakeExtraUtils
        GIT_TAG v0.1.1)
FetchContent_MakeAvailable(CMakeExtraUtils)

include(DynamicVersion)
dynamic_version()

project(MyProject
        VERSION ${PROJECT_VERSION})
```

## TODO for v1.0

- [x] Automation:
- [x] Add simple pre-commit and `pyproject.toml` environment
- [x] Fix `DynamicVersion` to work with buildable projects
- [ ] Test coverage:
  - [ ] `DynamicVersion`
  - [ ] `PackageComps`
