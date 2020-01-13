# About booting on the pbp

This script doesn't install any bootloader or similar. I recommend using the stock uboot that came with the debian install, the manjaro uboot should work aswell.
The stock uboot is configured to boot from SD card first, so you can try this without overwriting your eMMC. Running Gentoo long term on an SD card is probably a bad idea.

In this folder you'll find an example /boot using extlinux. Your boot partition should be ext4 or FAT32 , your root can be whatever your kernel supports. When formatting the eMMC, be very careful to start the first partition at sector 32768 , anything before that is used by uboot. The boot partition should be marked bootable and the drive partitioned as MBR / dos

`make install` doesn't install the correct image right now, you'll have to copy it manually. Instructions are in the Image file
