cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_VERBOSE_MAKEFILE on)

include(ExternalProject)

set(EXTERNALPROJECT_DEFAULT_ARGS
    -DANDROID_ABI:STRING=${ANDROID_ABI}
    -DANDROID_NDK:PATH=${ANDROID_NDK}
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DCMAKE_MAKE_PROGRAM:STRING=${CMAKE_MAKE_PROGRAM}
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE}
    -DANDROID_NATIVE_API_LEVEL:STRING=${ANDROID_NATIVE_API_LEVEL}
)

set(MAKE "${ANDROID_NDK}/prebuilt/${ANDROID_NDK_HOST_SYSTEM_NAME}/bin/make${ANDROID_TOOLCHAIN_SUFFIX}")
string(FIND "${ANDROID_TOOLCHAIN_NAME}" "-" TOOLCHAIN_TRIPLE_END REVERSE)
string(SUBSTRING "${ANDROID_TOOLCHAIN_NAME}" 0 ${TOOLCHAIN_TRIPLE_END} TOOLCHAIN_TRIPLE)

#libpng
ExternalProject_Add(png_ext
    PREFIX "${CMAKE_BINARY_DIR}/png"
    URL http://download.sourceforge.net/libpng/libpng-1.6.26.tar.gz

    CONFIGURE_COMMAND ""

    BUILD_COMMAND "${CMAKE_SOURCE_DIR}/autoconf-png.sh" ${MAKE} ${TOOLCHAIN_TRIPLE} ${ANDROID_ARCH_NAME} ${ANDROID_PLATFORM_LEVEL} "${CMAKE_BINARY_DIR}/contrib/"
    BUILD_IN_SOURCE ON
    BUILD_BYPRODUCTS
        ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_SHARED_LIBRARY_PREFIX}png${CMAKE_SHARED_LIBRARY_SUFFIX}

    INSTALL_COMMAND ""

    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)

add_library(png SHARED IMPORTED)
set_target_properties(png PROPERTIES IMPORTED_LOCATION
    ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_SHARED_LIBRARY_PREFIX}png${CMAKE_SHARED_LIBRARY_SUFFIX}
)
add_dependencies(png png_ext)
include_directories("${CMAKE_BINARY_DIR}/contrib/include")


#libfreetype
ExternalProject_Add(freetype_ext
    PREFIX "${CMAKE_BINARY_DIR}/freetype"
    URL http://download.savannah.gnu.org/releases/freetype/freetype-2.6.5.tar.gz

    CMAKE_CACHE_ARGS
      ${EXTERNALPROJECT_DEFAULT_ARGS}
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/contrib
      -DWITH_PNG:BOOL=ON
      -DWITH_HarfBuzz:BOOL=OFF
      -DPNG_LIBRARY:PATH=${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_SHARED_LIBRARY_PREFIX}png${CMAKE_SHARED_LIBRARY_SUFFIX}
      -DPNG_PNG_INCLUDE_DIR:PATH=${CMAKE_BINARY_DIR}/contrib/include/libpng16
      -DBUILD_SHARED_LIBS:BOOL=ON

    BUILD_BYPRODUCTS
        ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_SHARED_LIBRARY_PREFIX}freetype${CMAKE_SHARED_LIBRARY_SUFFIX}

    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)
add_dependencies(freetype_ext png)

add_library(freetype STATIC IMPORTED)
set_target_properties(freetype PROPERTIES IMPORTED_LOCATION
    ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_SHARED_LIBRARY_PREFIX}freetype${CMAKE_SHARED_LIBRARY_SUFFIX}
)
add_dependencies(freetype freetype_ext)


#libjansson
ExternalProject_Add(jansson_ext
    PREFIX "${CMAKE_BINARY_DIR}/jansson"
    URL https://github.com/akheron/jansson/archive/v2.8.tar.gz

    CMAKE_CACHE_ARGS
      ${EXTERNALPROJECT_DEFAULT_ARGS}
      -DJANSSON_EXAMPLES:BOOL=OFF
      -DJANSSON_BUILD_SHARED_LIBS:BOOL=ON

    BUILD_BYPRODUCTS
        ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jansson${CMAKE_STATIC_LIBRARY_SUFFIX}

    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)

add_library(jansson STATIC IMPORTED)
set_target_properties(jansson PROPERTIES IMPORTED_LOCATION
    ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_STATIC_LIBRARY_PREFIX}jansson${CMAKE_STATIC_LIBRARY_SUFFIX}
)
add_dependencies(jansson jansson_ext)

#libspeexdsp
if(YES)
ExternalProject_Add(speexdsp_ext
    PREFIX "${CMAKE_BINARY_DIR}/speexdsp"
    URL https://github.com/xiph/speexdsp/archive/SpeexDSP-1.2rc3.tar.gz

    CONFIGURE_COMMAND ""

    BUILD_COMMAND "${CMAKE_SOURCE_DIR}/autoconf.sh" ${MAKE} ${TOOLCHAIN_TRIPLE} ${ANDROID_ARCH_NAME} ${ANDROID_PLATFORM_LEVEL} "${CMAKE_BINARY_DIR}/contrib/"
    BUILD_IN_SOURCE ON

    INSTALL_COMMAND ""

    BUILD_BYPRODUCTS
        ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_STATIC_LIBRARY_PREFIX}speexdsp${CMAKE_STATIC_LIBRARY_SUFFIX}

    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)

add_library(speexdsp STATIC IMPORTED)
set_target_properties(speexdsp PROPERTIES IMPORTED_LOCATION
    ${CMAKE_BINARY_DIR}/contrib/lib/${CMAKE_STATIC_LIBRARY_PREFIX}speexdsp${CMAKE_STATIC_LIBRARY_SUFFIX}
)
add_dependencies(speexdsp speexdsp_ext)
endif()

# libsdl2
ExternalProject_Add(sdl_ext
    PREFIX "${CMAKE_BINARY_DIR}/sdl"
    URL https://www.libsdl.org/release/SDL2-2.0.5.tar.gz

    PATCH_COMMAND patch --strip=1 --batch -i "${CMAKE_SOURCE_DIR}/sdl.patch"

    CMAKE_CACHE_ARGS
      ${EXTERNALPROJECT_DEFAULT_ARGS}
      -DANDROID_TOOLCHAIN:STRING=gcc
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/contrib
      -DHAVE_SDL_THREADS:BOOL=ON
      -DVIDEO_DUMMY:BOOL=OFF
      -DDISKAUDIO:BOOL=OFF
      -DPTHREADS:BOOL=ON
      -DPTHREADS_SEM:BOOL=ON
      -DSDL_SHARED:BOOL=ON
      -DSDL_STATIC:BOOL=OFF

    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)
