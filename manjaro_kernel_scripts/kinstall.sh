#!/bin/sh

source /usr/src/manjaro_kernel_scripts/envvars.sh

cd "${KDIR}"
make prepare
make modules_prepare
make -j6 Image modules dtbs
make modules_install

KVER=`cat include/config/kernel.release` #needed for dracut and others
mv "${BOOTDIR}"/Image "${BOOTDIR}"/Image.bak

if test -f "${BOOTDIR}"/initramfs; then
	mv "${BOOTDIR}"/initramfs "${BOOTDIR}"/initramfs.bak
fi

cp arch/arm64/boot/Image "${BOOTDIR}"/Image
cp arch/arm64/boot/dts/rockchip/rk3399-pinebook-pro.dtb "${BOOTDIR}"/rk3399-pinebook-pro.dtb
