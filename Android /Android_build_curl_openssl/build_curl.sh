#!/usr/bin/env bash
ABI armeabi-v7a
export ANDROID_NDK_ROOT=/Users/30san/Library/Android/sdk/ndk/24.0.8215888

if [ -z "$ANDROID_NDK_ROOT" ]; then
    echo "ndk目录不存在"
    exit
fi

# Error checking
if [ ! -d "$ANDROID_NDK_ROOT/toolchains" ]; then
    echo "ERROR: ANDROID_NDK_ROOT is not a valid path. Please set it."
    [ "$0" = "$BASH_SOURCE" ] && exit 1 || return 1
fi

rm -rf ./build
mkdir -p build
cd build

#####################################################################

if [ "$#" -lt 1 ]; then
    THE_ARCH=armv7a
else
    THE_ARCH=$(tr [A-Z] [a-z] <<< "$1")
fi
# https://developer.android.com/ndk/guides/abis.html
case "$THE_ARCH" in
  arm|armv5|armv6|armv7|armeabi)
    TOOLCHAIN_BASE="arm-linux-androideabi"
    TOOLNAME_BASE="arm-linux-androideabi"
    AOSP_ABI="armeabi"
    AOSP_ARCH="arch-arm"
    AOSP_FLAGS="-march=armv5te -mtune=xscale -mthumb -msoft-float -funwind-tables -fexceptions -frtti"
    ;;
  armv7a|armeabi-v7a)
    TOOLCHAIN_BASE="arm-linux-androideabi"
    TOOLNAME_BASE="arm-linux-androideabi"
    AOSP_ABI="armeabi-v7a"
    AOSP_ARCH="arch-arm"
    AOSP_FLAGS="-march=armv7-a -mthumb -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -funwind-tables -fexceptions -frtti"
    ;;
  hard|armv7a-hard|armeabi-v7a-hard)
    TOOLCHAIN_BASE="arm-linux-androideabi"
    TOOLNAME_BASE="arm-linux-androideabi"
    AOSP_ABI="armeabi-v7a"
    AOSP_ARCH="arch-arm"
    AOSP_FLAGS="-mhard-float -D_NDK_MATH_NO_SOFTFP=1 -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -funwind-tables -fexceptions -frtti -Wl,--no-warn-mismatch -Wl,-lm_hard"
    ;;
  neon|armv7a-neon)
    TOOLCHAIN_BASE="arm-linux-androideabi"
    TOOLNAME_BASE="arm-linux-androideabi"
    AOSP_ABI="armeabi-v7a"
    AOSP_ARCH="arch-arm"
    AOSP_FLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -funwind-tables -fexceptions -frtti"
    ;;
  armv8|armv8a|aarch64|arm64|arm64-v8a)
    TOOLCHAIN_BASE="aarch64-linux-android"
    TOOLNAME_BASE="aarch64-linux-android"
    AOSP_ABI="arm64-v8a"
    AOSP_ARCH="arch-arm64"
    AOSP_FLAGS="-funwind-tables -fexceptions -frtti"
    ;;
  mips|mipsel)
    TOOLCHAIN_BASE="mipsel-linux-android"
    TOOLNAME_BASE="mipsel-linux-android"
    AOSP_ABI="mips"
    AOSP_ARCH="arch-mips"
    AOSP_FLAGS="-funwind-tables -fexceptions -frtti"
    ;;
  mips64|mipsel64|mips64el)
    TOOLCHAIN_BASE="mips64el-linux-android"
    TOOLNAME_BASE="mips64el-linux-android"
    AOSP_ABI="mips64"
    AOSP_ARCH="arch-mips64"
    AOSP_FLAGS="-funwind-tables -fexceptions -frtti"
    ;;
  x86)
    TOOLCHAIN_BASE="x86"
    TOOLNAME_BASE="i686-linux-android"
    AOSP_ABI="x86"
    AOSP_ARCH="arch-x86"
    AOSP_FLAGS="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -funwind-tables -fexceptions -frtti"
    ;;
  x86_64|x64)
    TOOLCHAIN_BASE="x86_64"
    TOOLNAME_BASE="x86_64-linux-android"
    AOSP_ABI="x86_64"
    AOSP_ARCH="arch-x86_64"
    AOSP_FLAGS="-march=x86-64 -msse4.2 -mpopcnt -mtune=intel -funwind-tables -fexceptions -frtti"
    ;;
  *)
    echo "ERROR: Unknown architecture $1"
    [ "$0" = "$BASH_SOURCE" ] && exit 1 || return 1
    ;;
esac

AOSP_TOOLCHAIN_PATH=""
for host in "linux-x86_64" "darwin-x86_64" "linux-x86" "darwin-x86"
do
#    if [ -d "$ANDROID_NDK_ROOT/toolchains/$TOOLCHAIN_BASE-$AOSP_TOOLCHAIN_SUFFIX/prebuilt/$host/bin" ]; then
#        AOSP_TOOLCHAIN_PATH="$ANDROID_NDK_ROOT/toolchains/$TOOLCHAIN_BASE-$AOSP_TOOLCHAIN_SUFFIX/prebuilt/$host/bin"
#        break
#    fi
    if [ -d "$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host/bin" ]; then
        AOSP_TOOLCHAIN_PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host/bin"
        break
    fi
done

export AOSP_SYSROOT="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/sysroot"
#####################################################################

export CC="$AOSP_TOOLCHAIN_PATH/aarch64-linux-android26-clang"
export AS=$CC
export AR=$AOSP_TOOLCHAIN_PATH/llvm-ar
export CXX="$AOSP_TOOLCHAIN_PATH/aarch64-linux-android26-clang++"
export LD=$AOSP_TOOLCHAIN_PATH/ld
export RANLIB=$AOSP_TOOLCHAIN_PATH/llvm-ranlib
export STRIP=$AOSP_TOOLCHAIN_PATH/llvm-strip

export CFLAGS="-pie -fPIE -stdlib=libc++"
export LDFLAGS="-pie -fPIE -stdlib=libc++"



#####################################################################
export PREFIX=$(pwd)/android-lib

VERBOSE=1
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" != "0" ]; then
  echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
  echo "AOSP_TOOLCHAIN_PATH: $AOSP_TOOLCHAIN_PATH"
  echo "AOSP_ABI: $AOSP_ABI"
  echo "AOSP_API: $AOSP_API"
  echo "CC: $CC"
  echo "AOSP_SYSROOT: $AOSP_SYSROOT"
fi

#CPPFLAGS="-I$(pwd)/../openssl/include" LDFLAGS="-L$(pwd)/../openssl/lib"
#
#../curl_new/configure \
#    --prefix=$PREFIX \
#    --enable-static \
#    --enable-shared \
#    --host=aarch64-linux-android \
#    --with-openssl=$(pwd)/../openssl \
#    --without-zlib
#armv7a-linux-androideabi aarch64-linux-android

../curl/configure --host=x86_64-linux-android \
            --target=$PREFIX \
            --prefix=$PWD/build/$AOSP_ARCH \
            --disable-static \
            --enable-shared \
            --without-ssl
    
make
make install
[ "$0" = "$BASH_SOURCE" ] && exit 0 || return 0

