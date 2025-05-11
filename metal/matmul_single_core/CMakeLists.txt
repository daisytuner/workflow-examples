cmake_minimum_required(VERSION 3.14)

project(demo C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

include(../cmake/CPM.cmake)

# Required by tt-metal API, but not packaged with it
CPMAddPackage(
    NAME Boost
    VERSION 1.86.0
    URL
        https://github.com/boostorg/boost/releases/download/boost-1.86.0/boost-1.86.0-cmake.tar.xz
        URL_HASH
        SHA256=2c5ec5edcdff47ff55e27ed9560b0a0b94b07bd07ed9928b476150e16b0efc57
    OPTIONS
        "BOOST_ENABLE_CMAKE ON"
        "BOOST_SKIP_INSTALL_RULES ON"
        "BUILD_SHARED_LIBS OFF"
        "BOOST_INCLUDE_LIBRARIES core\\\;container\\\;smart_ptr\\\;interprocess\\\;asio\\\;lockfree"
    FIND_PACKAGE_ARGUMENTS "CONFIG REQUIRED"
)

# Its a dependency of the original example and used somewhere in tt-metal. Unsure if its a runtime dependency
# CPMAddPackage(
#     NAME nlohmann_json
#     GITHUB_REPOSITORY nlohmann/json
#     GIT_TAG v3.11.3
#     OPTIONS
#         "CMAKE_MESSAGE_LOG_LEVEL NOTICE"
# )

add_executable(demo
    matmul_single_core.cpp
)

target_include_directories(demo PRIVATE
    # reflect
    $ENV{TT_METAL_INSTALL_DIR}/include/metalium-thirdparty
	# tt_metal APIs
	$ENV{TT_METAL_INSTALL_DIR}/include
    $ENV{TT_METAL_INSTALL_DIR}/libexec/tt-metallium/tt_metal/api
    $ENV{TT_METAL_INSTALL_DIR}/libexec/tt-metallium/tt_metal/hostdevcommon/api

    .
    ..
)

target_link_directories(demo PRIVATE
    $ENV{TT_METAL_INSTALL_DIR}/lib
)

target_link_libraries(demo PRIVATE
    # metallium dependencies that ship with it
    tt_metal
    fmt # internal dependency of tt_metal
    # dependencies of metallium that do not ship with TT-Metal libs dir (yet)
    Boost::container
    Boost::core
    # nlohmann_json::nlohmann_json
    # TracyClient
)
