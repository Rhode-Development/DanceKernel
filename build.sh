#!/bin/bash
clear
export ARCH=arm64
export PLATFORM_VERSION=14
export ANDROID_MAJOR_VERSION=u
ln -s /usr/bin/python2.7 $HOME/python
export PATH=$HOME/:$PATH
mkdir out

ARGS='
CC=/home/zetlink/toolchain/aosp-clang/bin/clang
CROSS_COMPILE=/home/zetlink/toolchain/gcc/bin/aarch64-linux-android-
CLANG_TRIPLE=aarch64-linux-gnu-
ARCH=arm64
'
make -C $(pwd) O=$(pwd)/out ${ARGS} clean && make -C $(pwd) O=$(pwd)/out ${ARGS} mrproper
make -C $(pwd) O=$(pwd)/out ${ARGS} vendor/bengal-perf_defconfig vendor/debugfs.config vendor/ext_config/moto-bengal.config vendor/ext_config/rhode-default.config
#make -C $(pwd) O=$(pwd)/out ${ARGS} menuconfig
#make -C $(pwd) O=$(pwd)/out ${ARGS} -j$(nproc)
make -C $(pwd) O=$(pwd)/out ${ARGS} dtbs dtboimage

mkdir -p modules
find . -type f -name "*.ko" -exec cp -n {} modules \;
echo "Module files copied to the 'modules' folder."

echo "Script Finish"
