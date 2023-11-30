#!/bin/bash

export ver="1.5.3"
if which $(pwd)/srt >/dev/null; then
  echo ""
else
  git clone git@github.com:Haivision/srt.git
  pushd srt
  git checkout refs/tags/v${ver}
  popd
fi

export IPHONEOS_DEPLOYMENT_TARGET=13.0
SDKVERSION=$(xcrun --sdk iphoneos --show-sdk-version)

srt() {
  IOS_OPENSSL=$(pwd)/OpenSSL/$1

  mkdir -p ./build/iOS/$3
  pushd ./build/iOS/$3
  ../../../srt/configure --cmake-prefix-path=$IOS_OPENSSL --ios-disable-bitcode=1 --ios-platform=$2 --ios-arch=$3 --cmake-toolchain-file=scripts/iOS.cmake --USE_OPENSSL_PC=off
  make
  install_name_tool -id "@executable_path/Frameworks/libsrt.${ver}.dylib" "libsrt.${ver}.dylib"
  popd
}

# compile
srt iphonesimulator SIMULATOR64 x86_64
srt iphoneos OS arm64

# lipo
lipo -output libsrt-iOS.a -create ./build/iOS/x86_64/libsrt.a  ./build/iOS/arm64/libsrt.a

# extract header files
make