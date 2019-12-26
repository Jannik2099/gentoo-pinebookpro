# gentoo-pinebookpro
A collection of scripts to prepare a Gentoo tarball for the pinebook pro

Disclaimer:

I do not recommend Gentoo for people new to Linux. This script, while unable to damage your running system, is a testing release.

How to use:

`./prepare.sh -h` to display usage, this is safe to run in any environment and will not read or write anything.

Chroot into the tarball
Mount the boot partition
Put the files of this repository into the tarball - preferably in a new folder at top level or somewhere in /var/tmp
Set up stuff according to the gentoo handbook: https://wiki.gentoo.org/wiki/Handbook:AMD64 . 
Run the script!
Compile and install the kernel, update your boot configuration accordingly.
If you enabled the manjaro kernel (on by default) there are two scripts in /usr/src/manjaro_kernel_scripts : kupdate.sh and kinstall.sh
kupdate will pull the newest kernel sources and start menuconfig, kinstall will compile and install the kernel, modules and dtb
Boot the pinebook pro and enjoy!

If you do not select the manjaro kernel option you will have to source the device firmware yourself - it is not included in linux-firmware right now.
