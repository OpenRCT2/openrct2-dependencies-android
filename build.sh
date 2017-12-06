#!/bin/sh

echo "ANDROID_HOME=${ANDROID_HOME}"

ANDROID_SDK=${ANDROID_HOME}
ANDROID_NDK="${ANDROID_SDK}/ndk-bundle"
CMAKE="${ANDROID_SDK}/cmake/3.6.3155560/bin/cmake"
CMAKE_MAKE_PROGRAM="${ANDROID_SDK}/cmake/3.6.3155560/bin/ninja"
CMAKE_TOOLCHAIN_FILE="${ANDROID_NDK}/build/cmake/android.toolchain.cmake"

ANDROID_NATIVE_API_LEVEL=16

ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
H_DIR="$(pwd)"

mkdir "${H_DIR}/dist"

for ANDROID_ABI in "${ABIS[@]}"
do
    :
    echo "\n\nRunning Cmake script (${ANDROID_ABI}) ...\n\n"
    
    B_DIR="${H_DIR}/build/${ANDROID_ABI}/build"
    OBJ_DIR="${H_DIR}/dist/${ANDROID_ABI}/obj"
    LIB_DIR="${H_DIR}/dist/${ANDROID_ABI}/lib"
    INC_DIR="${H_DIR}/dist/${ANDROID_ABI}/include"
    eval $CMAKE \
        -H${H_DIR} \
        -B${B_DIR} \
        -GNinja \
        -DANDROID_ABI=$ANDROID_ABI \
        -DANDROID_NDK=$ANDROID_NDK \
        -DANDROID_STL="c++_shared" \
        -DANDROID_CPP_FEATURES="rtti\ exceptions" \
        -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$OBJ_DIR \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_MAKE_PROGRAM=$CMAKE_MAKE_PROGRAM \
        -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
        -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}

    mkdir -p $LIB_DIR
    mkdir -p $INC_DIR
    
    pushd $B_DIR
    eval $CMAKE_MAKE_PROGRAM
    popd
    
    cp -r "${B_DIR}/contrib/include/." $INC_DIR
    cp -r "${B_DIR}/jansson/src/jansson_ext-build/include/." $INC_DIR
    cp -r "${B_DIR}/contrib/lib/libfreetype.so" $LIB_DIR
    cp -r "${B_DIR}/contrib/lib/libpng16.so" $LIB_DIR
    cp -r "${B_DIR}/contrib/lib/libspeexdsp.so" $LIB_DIR
    cp -r "${B_DIR}/contrib/lib/libSDL2-2.0.so" $LIB_DIR
    cp -r "${B_DIR}/contrib/lib/libSDL2main.a" $LIB_DIR
    cp -r "${B_DIR}/jansson/src/jansson_ext-build/lib/libjansson.so" $LIB_DIR
    
    pushd "${H_DIR}/dist/${ANDROID_ABI}"
    zip -r "${H_DIR}/dist/openrct2-libs-android-${ANDROID_ABI}.zip" .
    popd
    
done

