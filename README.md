# gentoo-pinebookpro

A collection of scripts to prepare a Gentoo tarball for the pinebook pro

Disclaimer:

I do not recommend Gentoo for people new to Linux. This script, while unable to damage your running system, is a beta release.

## How to use

READ THE GENTOO HANDBOOK!!! https://wiki.gentoo.org/wiki/Handbook:AMD64

`./prepare.sh -h` to display usage, this is safe to run in any environment and will not read or write anything.

Download a Stage 3 arm64 tarball - usually from http://distfiles.gentoo.org/experimental/arm64/
Extract the tarball as root, otherwise you'll mess up file permission!
Put the files of this repository into the tarball - preferably into /var/tmp/gentoo-pinebookpro
Chroot into the tarball as explained in the Handbook - https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Copy_DNS_info
Execute the script prepare.sh - it is recommended to not change the default options unless you really know what this will do, and what will break if you do. 

This script doesn't ship with a bootloader or similar, please consult README.md in the boot directory

From there on, do the usual tarball installation following the Gentoo Handbook.
Use `sys-kernel/pinebookpro-manjaro-sources` as the kernel

## Changes to the Gentoo repository

I have changed or added some ebuilds via my overlay `pinebookpro-overlay` . It is installed by the prepare script via layman.
The Kernel ebuild `sys-kernel/pinebookpro-manjaro-soruces` has been added. `virtual/linux-sources` has been adapted accordingly. The Vanilla and Gentoo sources do not work right now and have been masked.
The wifi firmware is packaged as `sys-firmware/pinebookpro-firmware` , from `sys-kernel/linux-firmware` only rockchip/dptx.bin is needed, the configuration is done by the script (see `/etc/portage/savedconfig/sys-kernel/linux-firmware-yyyymmdd`)
An ebuild for miscellaneous fixes `sys-firmware/pinebookpro-misc` has been added. Please emerge this after having booted into Gentoo, it will most likely fail in a chroot. It is required for full functionality.
The xorg server `x11-base/xorg-server` has been changed to disable glamor when wayland is enabled, as this breaks xwayland applications. This comes at a significant performance cost, to disable this the useflag `USE=glamor` has been added. You can ignore this if you don't want to use wayland.
The 2D Xorg driver `x11-drivers/xf86-video-fbturbo` has been added. It is required for most DEs that use full OpenGL instead of gles

## Useful stuff for people new to Gentoo

Ebuilds (the scripts that configure, compile and install a package) are sometimes not released as stable or not released at all for all architectures. This is called keywording: for example, KEYWORDS="amd64 ~arm64" indicates the ebuild is marked stable for amd64, testing for arm64 and masked for all other architectures.
You can and will override this a lot by editing `/etc/portage/package.accept_keywords` . Adding `category/package keyword` to this file will emerge the latest version that uses the respective keyword. For example, firefox has all LTS releases marked stable and all others marked testing. `www-client/firefox ~arm64` would always select the latest release. Dependencies that require keyword changes can be automatically unmasked and the changes merged with `dispatch-conf`

## Known issues

General:

	Issue:	The keyboard / touchpad is unresponsive sometimes
	Fix:	Make sure you have updated the keyboard / touchpad firmware, see https://github.com/ayufan-rock64/pinebook-pro-keyboard-updater

	Issue:	The PBP charges a lot slower after a while, the charging LED starts blinking
	Fix	This is a weird safety feature of the battery controller. It usually goes away after charging to full or restarting

	Issue:	The Kernel takes ages to boot!
	Fix:	Make sure CONFIG_CRYPTO_RSA is a module. Additionally there's another issue where some uboot versions initialize the big cores at 12 MHz, which will slow down things quite a lot until the Kernel loads the cpu governor. This can be fixed by adding maxcpus=4 to your kernel line and then onlining the two big cores afterwards.

KDE Plasma:

	Issue:	system settings crashes when trying to open some submenus
	Fix:	Add LIBGL_ALWAYS_SOFTWARE=1 to your /etc/environment, restart the session, do your changes, comment that line out, restart the session

	Issue:	SDDM crashes / becomes unresponsive
	Fix:	This only seems to happen in the SDDM login menu when you don't login within ~1m. Restart SDDM and be quicker next time :P . Help in debugging this is welcome
