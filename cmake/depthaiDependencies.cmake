if(CONFIG_MODE)
    set(_DEPTHAI_PREFIX_PATH_ORIGINAL ${CMAKE_PREFIX_PATH})
    set(_DEPTHAI_MODULE_PATH_ORIGINAL ${CMAKE_MODULE_PATH})
    set(_DEPTHAI_FIND_ROOT_PATH_MODE_PACKAGE_ORIGINAL ${CMAKE_FIND_ROOT_PATH_MODE_PACKAGE})
    # Fixes Android NDK build, where prefix path is ignored as its not inside sysroot
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE "BOTH")
    # Sets where to search for packages about to follow
    set(CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/${_IMPORT_PREFIX}" ${CMAKE_PREFIX_PATH})
    set(_QUIET "QUIET")
else()
    # Permit to avoid to use hunter for some dependencies
    # Note: if you need to pass COMPONENTS to hunter_add_package,
    # this macro needs to be changed
    macro(depthai_hunter_add_package depthai_dep_package)
        if(DEFINED HUNTER_SKIP_PACKAGE_${depthai_dep_package} 
           AND HUNTER_SKIP_PACKAGE_${depthai_dep_package})
            message(STATUS "Skipping depthai-core dependency ${depthai_dep_package} as HUNTER_SKIP_PACKAGE_${depthai_dep_package} is ENABLED")
        else()
            hunter_add_package(${package})
        endif()
    endmacro()

    set(DEPTHAI_SHARED_LIBS ${BUILD_SHARED_LIBS})
    depthai_hunter_add_package(nlohmann_json)
    if(NOT DEPTHAI_XLINK_LOCAL)
        depthai_hunter_add_package(XLink)
    endif()
    depthai_hunter_add_package(BZip2)
    depthai_hunter_add_package(FP16)
    depthai_hunter_add_package(libarchive-luxonis)
    depthai_hunter_add_package(spdlog)
    depthai_hunter_add_package(ZLIB)
    if(DEPTHAI_ENABLE_BACKWARD)
        depthai_hunter_add_package(Backward)
    endif()
    depthai_hunter_add_package(libnop)
    if(DEPTHAI_PCL_SUPPORT)
        depthai_hunter_add_package(jsoncpp)
    endif()
endif()

# If library was build as static, find all dependencies
if(NOT CONFIG_MODE OR (CONFIG_MODE AND NOT DEPTHAI_SHARED_LIBS))

    # BZip2 (for bspatch)
    find_package(BZip2 ${_QUIET} CONFIG REQUIRED)

    # FP16 for conversions
    find_package(FP16 ${_QUIET} CONFIG REQUIRED)

    # libarchive for firmware packages
    find_package(archive_static ${_QUIET} CONFIG REQUIRED)
    find_package(lzma ${_QUIET} CONFIG REQUIRED)
    # ZLIB for compressing Apps
    find_package(ZLIB CONFIG REQUIRED)

    # spdlog for library and device logging
    find_package(spdlog ${_QUIET} CONFIG REQUIRED)

    # Backward
    if(DEPTHAI_ENABLE_BACKWARD)
        # Disable automatic check for additional stack unwinding libraries
        # Just use the default compiler one
        set(STACK_DETAILS_AUTO_DETECT FALSE CACHE BOOL "Auto detect backward's stack details dependencies")
        find_package(Backward ${_QUIET} CONFIG REQUIRED)
        unset(STACK_DETAILS_AUTO_DETECT)
    endif()

endif()

# Add threads (c++)
find_package(Threads ${_QUIET} REQUIRED)

# Nlohmann JSON
find_package(nlohmann_json 3.6.0 ${_QUIET} CONFIG REQUIRED)

# libnop for serialization
find_package(libnop ${_QUIET} CONFIG REQUIRED)

# XLink
if(DEPTHAI_XLINK_LOCAL AND (NOT CONFIG_MODE))
    set(_BUILD_SHARED_LIBS_SAVED "${BUILD_SHARED_LIBS}")
    set(BUILD_SHARED_LIBS OFF)
    add_subdirectory("${DEPTHAI_XLINK_LOCAL}" ${CMAKE_CURRENT_BINARY_DIR}/XLink)
    set(BUILD_SHARED_LIBS "${_BUILD_SHARED_LIBS_SAVED}")
    unset(_BUILD_SHARED_LIBS_SAVED)
    list(APPEND targets_to_export XLink)
else()
    find_package(XLink ${_QUIET} CONFIG REQUIRED HINTS "${CMAKE_CURRENT_LIST_DIR}/XLink" "${CMAKE_CURRENT_LIST_DIR}/../XLink")
endif()

# OpenCV 4 - (optional, quiet always)
find_package(OpenCV 4 QUIET CONFIG)
if(DEPTHAI_PCL_SUPPORT AND NOT TARGET JsonCpp::JsonCpp)
    find_package(jsoncpp)
endif()
set(MODULE_TEMP ${CMAKE_MODULE_PATH})
set(PREFIX_TEMP ${CMAKE_PREFIX_PATH})
set(CMAKE_MODULE_PATH ${_DEPTHAI_MODULE_PATH_ORIGINAL})
set(CMAKE_PREFIX_PATH ${_DEPTHAI_PREFIX_PATH_ORIGINAL})
if(DEPTHAI_PCL_SUPPORT)
    find_package(PCL CONFIG COMPONENTS common visualization)
endif()
set(CMAKE_MODULE_PATH ${MODULE_TEMP})
set(CMAKE_PREFIX_PATH ${PREFIX_TEMP})

# include optional dependency cmake
if(DEPTHAI_DEPENDENCY_INCLUDE)
    include(${DEPTHAI_DEPENDENCY_INCLUDE} OPTIONAL)
endif()

# Cleanup
if(CONFIG_MODE)
    set(CMAKE_PREFIX_PATH ${_DEPTHAI_PREFIX_PATH_ORIGINAL})
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ${_DEPTHAI_FIND_ROOT_PATH_MODE_PACKAGE_ORIGINAL})
    unset(_DEPTHAI_PREFIX_PATH_ORIGINAL)
    unset(_DEPTHAI_FIND_ROOT_PATH_MODE_PACKAGE_ORIGINAL)
    unset(_QUIET)
else()
    set(DEPTHAI_SHARED_LIBS)
endif()
