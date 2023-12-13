cmake_minimum_required(VERSION 3.20)
project(test_import_find_package LANGUAGES NONE)

find_package(CMakeExtraUtils REQUIRED CONFIG)

# Smoke test: Make sure the modules are importable
include(DynamicVersion)
include(PackageComps)
