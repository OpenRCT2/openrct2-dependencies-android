#!/bin/sh

ANDROID_SDK="/usr/local/opt/android-sdk"
ANDROID_NDK="${ANDROID_SDK}/ndk-bundle"
CMAKE="${ANDROID_SDK}/cmake/3.6.3155560/bin/cmake"
CMAKE_MAKE_PROGRAM="${ANDROID_SDK}/cmake/3.6.3155560/bin/ninja"
CMAKE_TOOLCHAIN_FILE="${ANDROID_NDK}/build/cmake/android.toolchain.cmake"

ANDROID_NATIVE_API_LEVEL=16

ABIS=("armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mips" "mips64")

for ANDROID_ABI in "${ABIS[@]}"
do
    :
    echo "\n\nRunning Cmake script (${ANDROID_ABI}) ...\n\n"
    
    H_DIR="$(pwd)"
    B_DIR="$(pwd)/build/${ANDROID_ABI}/build"
    OBJ_DIR="$(pwd)/build/${ANDROID_ABI}/obj"
    echo $CMAKE \
        -H${H_DIR} \
        -B${B_DIR} \
#        -G\"Android Gradle - Ninja\" \
        -GNinja \
        -DANDROID_ABI=$ANDROID_ABI \
        -DANDROID_NDK=$ANDROID_NDK \
        -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$OBJ_DIR \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_MAKE_PROGRAM=$CMAKE_MAKE_PROGRAM \
        -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
        -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
    
    pushd $B_DIR
    echo $CMAKE_MAKE_PROGRAM
    popd
done

