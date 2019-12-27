# gentoo-pinebookpro
A collection of scripts to prepare a Gentoo tarball for the pinebook pro

Disclaimer:

I do not recommend Gentoo for people new to Linux. This script, while unable to damage your running system, is a testing release.

How to use:

READ THE GENTOO HANDBOOK!!! https://wiki.gentoo.org/wiki/Handbook:AMD64

`./prepare.sh -h` to display usage, this is safe to run in any environment and will not read or write anything.

Download a Stage 3 arm64 tarball - usually from http://distfiles.gentoo.org/experimental/arm64/
Put the files of this repository into the tarball - preferably into /var/tmp/gentoo-pinebookpro
Chroot into the tarball as explained in the Handbook - https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Copy_DNS_info
Mount the desired boot partition
Run the script!
If you enabled the manjaro kernel (on by default) there are two scripts in /usr/src/manjaro_kernel_scripts : kupdate.sh and kinstall.sh
kupdate will pull the newest kernel sources and start menuconfig, kinstall will compile and install the kernel, modules and dtb
Compile and install the kernel
Follow the other handbook instructions
Boot the pinebook pro and enjoy!

If you do not select the manjaro kernel option you will have to source the device firmware yourself - it is not included in linux-firmware right now.
The vanilla kernel lacks display driver support - I recommend using the manjaro sources
