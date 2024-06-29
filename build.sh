#!/bin/bash

# Initialize variables

GRN='\033[01;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[01;31m'
RST='\033[0m'
ORIGIN_DIR=$(pwd)
DEVICE='rhode'
IMAGE=$ORIGIN_DIR/out/arch/arm64/boot/Image.gz
ARGS='
CC=/home/zetlink/toolchain/aosp-clang/bin/clang
CROSS_COMPILE=/home/zetlink/toolchain/gcc/bin/aarch64-linux-android-
CLANG_TRIPLE=aarch64-linux-gnu-
ARCH=arm64
'

script_echo() {
    echo "  $1"
}
exit_script() {
    kill -INT $$
}
build_kernel_image() {
    script_echo " "
    script_echo "Building Dance Kernel For $DEVICE"

    make -C $(pwd) O=$(pwd)/out ${ARGS} clean && make -C $(pwd) O=$(pwd)/out ${ARGS} mrproper
    make -C $(pwd) O=$(pwd)/out ${ARGS} vendor/bengal-perf_defconfig vendor/debugfs.config vendor/ext_config/moto-bengal.config vendor/ext_config/rhode-default.config
    make -C $(pwd) O=$(pwd)/out ${ARGS} menuconfig
    make -C $(pwd) O=$(pwd)/out ${ARGS} -j$(nproc)
    make -C $(pwd) O=$(pwd)/out ${ARGS} dtbs dtbo.img

    SUCCESS=$?
    echo -e "${RST}"

    if [ $SUCCESS -eq 0 ] && [ -f "$IMAGE" ]
    then
        echo -e "${GRN}"
        script_echo "------------------------------------------------------------"
        script_echo "Compilation successful..."
        script_echo "Image can be found at out/arch/arm64/boot/Image.gz"
        script_echo  "------------------------------------------------------------"
        build_flashable_zip
    elif [ $SUCCESS -eq 130 ]
    then
        echo -e "${RED}"
        script_echo "------------------------------------------------------------"
        script_echo "Build force stopped by the user."
        script_echo "------------------------------------------------------------"
        echo -e "${RST}"
    elif [ $SUCCESS -eq 1 ]
    then
        echo -e "${RED}"
        script_echo "------------------------------------------------------------"
        script_echo "Compilation failed.."
        script_echo "------------------------------------------------------------"
        echo -e "${RST}"
        cleanup
    fi
}
build_flashable_zip() {
    script_echo " "
    script_echo "I: Building kernel image..."
    echo -e "${GRN}"
    cp "$ORIGIN_DIR"/out/arch/arm64/boot/{Image.gz,dtbo.img} Dance/
    cp "$ORIGIN_DIR"/out/arch/arm64/boot/dts/vendor/qcom/khaje-moto-base.dtb Dance/dtb
    cd "$ORIGIN_DIR"/Dance/ || exit
    zip -r9 "DanceKernel-Test.zip" META-INF version anykernel.sh tools Image.gz dtb dtbo.img
    rm -rf {Image.gz,dtb,dtbo.img}
    cd ../
}

build_kernel_image
