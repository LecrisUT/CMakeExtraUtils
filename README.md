# CmakeExtraUtils

Extra utilities for cmake:

- [`DynamicVersion`](cmake/DynamicVersion.md)

## Installation

These utilities can be included using both `find_package()` and `ExternalProject`, e.g.:
```cmake
cmake_minimum_required(VERSION 3.25)

find_package(CmakeExtraUtils REQUIRED)

include(DynamicVersion)
dynamic_version()

project(MyProject
        VERSION ${PROJECT_VERSION})
```

## TODO for v1.0

- [ ] Add Github actions:
    - [ ] Documentation
    - [ ] Test
    - [ ] Release
- [ ] Add simple pre-commit and `pyproject.toml` environment
- [x] Fix `DynamicVersion` to work with buildable projects
