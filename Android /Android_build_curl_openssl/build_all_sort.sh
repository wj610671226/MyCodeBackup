#!/bin/bash

rm -rf ./build
mkdir -p build
cd build

#for arch in armeabi armeabi-v7a armeabi-v7a-hard arm64-v8a mips mips64 x86 x86_64
for arch in arm64-v8a
do
    bash ../build_curl_sort.sh $arch
done
