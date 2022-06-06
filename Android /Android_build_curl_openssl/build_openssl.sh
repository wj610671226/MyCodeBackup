#!/usr/bin/env bash
export ANDROID_NDK_HOME=/Users/30san/Library/Android/sdk/ndk/24.0.8215888

export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
MIN_SDK_VERSION=23

if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "ndk目录不存在"
    exit
fi

#if [ "$#" -lt 1 ]; then
#    THE_ARCH=armv7a
#else
#    THE_ARCH=$(tr [A-Z] [a-z] <<< "$1")
#fi
#
#case "$THE_ARCH" in
#  arm64-v8a)
#    HOST="aarch64-linux-android"
#    ;;
#  armeabi-v7a)
#    HOST="armv7a-linux-androideabi"
#    ;;
#  x86_64)
#    HOST="x86_64-linux-android"
#    ;;
#  *)
#    echo "ERROR: Unknown architecture $1"
#    [ "$0" = "$BASH_SOURCE" ] && exit 1 || return 1
#    ;;
#esac

rm -rf ./build_openssl
mkdir -p build_openssl/build
cd ./build_openssl
echo "pwd = $(pwd)"

THE_ARCH=arm64-v8a
HOST="aarch64-linux-androideabi"
echo "THE_ARCH: $THE_ARCH"
echo "HOST: $HOST"

# curl common configuration arguments
# disable functionalities here to reduce size
#ARGUMENTS=" \
#    --with-pic \
#    --disable-shared
#    "
#

#autoreconf -fi

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64
export TARGET_HOST=$HOST
export ANDROID_ARCH=$THE_ARCH
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

export PREFIX=$(pwd)/android-lib

../openssl_source/Configure android

make && make install


echo "完成"



