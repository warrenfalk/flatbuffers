#!/bin/bash

# To build flatc for windows:
# In Developer Command Prompt:
#  mkdir built
#  cd built
#  cmake .. -G "Visual Studio 15"
#  msbuild FlatBuffers.sln /p:Configuration=Release

# To build on linux:
#  mkdir -p build && cd build && cmake .. -G "Unix Makefiles" -DFLATBUFFERS_BUILD_TESTS=OFF -DFLATBUFFERS_INSTALL=OFF -DFLATBUFFERS_BUILD_FLATLIB=OFF -DFLATBUFFERS_BUILD_FLATC=ON -DFLATBUFFERS_BUILD_FLATHASH=OFF -DFLATBUFFERS_CODE_SANITIZE=ON
#  make
#  strip -s flatc

# To build on Mac:
#  mkdir -p built && cd built && cmake .. -G "XCode" -DFLATBUFFERS_BUILD_TESTS=OFF -DFLATBUFFERS_INSTALL=OFF -DFLATBUFFERS_BUILD_FLATLIB=OFF -DFLATBUFFERS_BUILD_FLATC=ON -DFLATBUFFERS_BUILD_FLATHASH=OFF -DFLATBUFFERS_CODE_SANITIZE=ON
#  xcodebuild -configuration release


if [ $# -ne 1 ]; then
  cat <<EOF
Usage: $0 <VERSION_NUMBER>

Example:
  $ $0 3.0.0

This script will download pre-built flatc binaries from maven repository and
create the FlatBuffers.Tools package.
EOF
  exit 1
fi

PATH=.:${PATH}
hash nuget 2>/dev/null || {
  curl https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -f -s -o nuget.exe || {
    echo "Can't find nuget, download failed"
    exit 1
  }
}

VERSION_NUMBER=$1
# <directory name> <binary file name> pairs.
declare -a FILE_NAMES=(          \
  windows_x86 windows-x86_32.exe \
  windows_x64 windows-x86_64.exe \
  macosx_x64  osx-x86_64     \
  linux_x86   linux-x86_32   \
  linux_x64   linux-x86_64   \
)

set -e

mkdir -p flatc
# Create a zip file for each binary.
for((i=0;i<${#FILE_NAMES[@]};i+=2));do
  DIR_NAME=${FILE_NAMES[$i]}
  mkdir -p flatc/$DIR_NAME

  if [ ${DIR_NAME:0:3} = "win" ]; then
    TARGET_BINARY="flatc.exe"
  else
    TARGET_BINARY="flatc"
  fi

  if [ ! -f flatc/$DIR_NAME/$TARGET_BINARY ]; then
    BINARY_NAME=${FILE_NAMES[$(($i+1))]}
    # TODO: someone get the flatc executables uploaded to maven just like the protocol buffer team does
    BINARY_URL=http://repo1.maven.org/maven2/com/google/flatbuffers/flatc/${VERSION_NUMBER}/flatc-${VERSION_NUMBER}-${BINARY_NAME}

    if ! curl ${BINARY_URL} -f -o flatc/$DIR_NAME/$TARGET_BINARY &> /dev/null; then
      echo "[ERROR] Failed to download ${BINARY_URL}" >&2
      echo "[ERROR] Skipped flatc/$DIR_NAME/$TARGET_BINARY" >&2
      continue
    fi
  fi

done

nuget pack FlatBuffers.Tools.nuspec
