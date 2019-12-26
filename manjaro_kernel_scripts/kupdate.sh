#!/bin/sh

source /usr/src/manjaro_kernel_scripts/envvars.sh

cd $KDIR
git clean -f
git reset --hard HEAD
git -C $PATCHDIR clean -f
git -C $PATCHDIR reset --hard HEAD
patch -Np1 -i $PATCHDIR/0001-net-smsc95xx-Allow-mac-address-to-be-set-as-a-parame.patch
make menuconfig
sed -i "s/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"-MANJARO-ARM-${TIMESTAMP}\"/" .config
make oldconfig
