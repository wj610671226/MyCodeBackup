#!/usr/bin/env bash
NDK=/var/ndk/android-ndk-r23b
MIN_SDK_VERSION=23

if [ -z "$NDK" ]; then
    echo "ndk目录不存在"
    exit
fi

rm -rf ./build
mkdir ./build
cd build

THE_ARCH=arm64-v8a

case "$THE_ARCH" in
  arm64-v8a)
    HOST="aarch64-linux-android"
    ;;
  armeabi-v7a)
    HOST="armv7a-linux-androideabi"
    ;;
  x86_64)
    HOST="x86_64-linux-android"
    ;;
  *)
    echo "ERROR: Unknown architecture $1"
    [ "$0" = "$BASH_SOURCE" ] && exit 1 || return 1
    ;;
esac

echo "THE_ARCH: $THE_ARCH"
echo "HOST: $HOST"
  
# curl common configuration arguments
# disable functionalities here to reduce size
#ARGUMENTS=" \
#    --with-pic \
#    --disable-shared
#    "


#autoreconf -fi

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
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

echo "CC: $CC"

#../curl/configure --host=$TARGET_HOST \
#            --target=$PREFIX \
#            --prefix=$PWD/build/$ANDROID_ARCH \
#            --disable-static \
#            --enable-shared \
#            --without-ssl

../curl/configure --host=$TARGET_HOST \
            --prefix=$PWD/build/$ANDROID_ARCH \
            --disable-static \
            --enable-shared \
            

#make && make install

echo "完成"
            

