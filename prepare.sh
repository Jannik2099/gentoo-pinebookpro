#!/bin/sh

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	cat "$(readlink -f "$0" | xargs dirname)/helpfile"
	exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
	echo "not run as root!"
	exit 1
fi

if [ "$(stat -c %d:%i /)" = "$(stat -c %d:%i /proc/1/root/.)" ]; then
	echo "not running in a chroot!!!"
	exit 1
fi

FILES=$(readlink -f "$0" | xargs dirname)
TEMPDIR=/var/tmp/gentoo-pinebookpro

if [ $(($# % 2)) -eq 1 ]; then
	echo "Invalid prompts, usage is ./prepare.sh --parameter1 value1 --parameter2 value2 ..."
	exit 1
fi

i=1
j=$#
while [ "${i}" -le "${j}" ]; do
	case ${1} in
		--gles2)
		gles2=${2}
		;;

		--manjaro_kernel)
		manjaro_kernel=${2}
		;;

		--rootuuid)
		ROOTUUID=${2}
		;;

		--zram)
		zram=${2}
		;;

		*)
		echo "invalid options"
		exit 1
		;;
	esac
	i=$((i + 2))
	shift 2
done

if test -f /bin/systemctl; then
	init=systemd
else
	init=openrc
fi
echo "detected init=${init}"

chmod 4711 /bin/passwd
echo "applied fix for sddm login"

sed -i "s/COMMON_FLAGS=\"/COMMON_FLAGS=\"-march=armv8-a+crc+crypto -mcpu=cortex-a72.cortex-a53 /" /etc/portage/make.conf
if [ "$(grep -e MAKEOPTS /etc/portage/make.conf)" = "" ]; then
	echo "MAKEOPTS=\"-j6\"" >> /etc/portage/make.conf
fi
echo "applied optimal settings to make.conf"

install -Dm755 "${FILES}"/overrides/default-overrides.sh /etc/portage/repo.postsync.d
install -Dm644 "${FILES}"/overrides/default-overrides.patch /etc/portage/repo.postsync.d
echo "installed default profile patches"

if [ "${gles2}" != "no" ]; then
	install -Dm755 "${FILES}"/overrides/gles2-overrides.sh /etc/portage/repo.postsync.d
	install -Dm644 "${FILES}"/overrides/gles2-overrides-1.patch /etc/portage/repo.postsync.d
	install -Dm644 "${FILES}"/overrides/gles2-overrides-2.patch /etc/portage/repo.postsync.d
	sed -i "s/USE=\"/USE=\"gles2 /" /etc/portage/make.conf
	echo "installed gles2 profile patches"
	echo "NOTE: this will disable OpenGL acceleration in place of gles2!"
fi

if [ "${manjaro_kernel}" != "no" ]; then
	install -Dm755 "${FILES}"/manjaro_kernel_scripts/kupdate.sh /usr/src/manjaro_kernel_scripts
	install -Dm755 "${FILES}"/manjaro_kernel_scripts/kinstall.sh /usr/src/manjaro_kernel_scripts
	install -Dm755 "${FILES}"/manjaro_kernel_scripts/envvars.sh /usr/src/manjaro_kernel_scripts
	echo "installed manjaro kernel scripts"

	if test ! -f /usr/bin/git; then
		if test ! -d /var/db/repos; then
			echo "syncing repo - this might take a while"
			emerge-webrsync
		fi
		echo "updating portage - this might take a while"
		emerge -u1 sys-apps/portage
		echo "installing git - this might take a while"
		emerge -u dev-vcs/git
	fi

	echo "fetching manjaro sources - this might take a while"
	git -C /usr/src clone https://gitlab.manjaro.org/tsys/linux-pinebook-pro.git
	eselect kernel set linux-pinebook-pro
	mkdir -p /usr/src/manjaro_kernel_scripts/patches
	git -C /usr/src/manjaro_kernel_scripts/patches clone https://gitlab.manjaro.org/manjaro-arm/packages/core/linux-pinebookpro
	cp /usr/src/linux/arch/arm64/configs/pinebook_pro_defconfig /usr/src/linux/.config
	echo "installed manjaro kernel sources"

	mkdir -p "${TEMPDIR}"

	git -C "${TEMPDIR}" clone https://gitlab.manjaro.org/manjaro-arm/packages/community/pinebookpro-post-install.git
	install -Dm644 "${TEMPDIR}"/pinebookpro-post-install/10-usb-kbd.hwdb /etc/udev/hwdb.d

	git -C "${TEMPDIR}" clone https://gitlab.manjaro.org/tsys/pinebook-firmware.git
	mkdir -p /lib/firmware
	cp -R "${TEMPDIR}"/pinebook-firmware/brcm /lib/firmware
	cp -R "${TEMPDIR}"/pinebook-firmware/rockchip /lib/firmware
	echo "installed manjaro firmware"

	install -Dm755 "${FILES}"/manjaro_kernel_scripts/extlinux.conf /boot/extlinux
	if [ "${ROOTUUID}" != "" ] && [ "${ROOTUUID}" != "no" ]; then
		ROOTUUID=$(findmnt --target / -o UUID | grep -v UUID)
	fi
	if [ "${ROOTUUID}" = "" ]; then
		echo "no ROOT UUID set"
	else
		echo "using ${ROOTUUID} as ROOT UUID"
		sed -i "s/root=UUID=/root=UUID=${ROOTUUID}/" /boot/extlinux/extlinux.conf
	fi
	echo "installed basic extlinux.conf"
fi

if [ "${zram}" != "no" ]; then
	if [ "${init}" = "systemd" ]; then
		install -Dm644 "${FILES}"/zram/zram0.service /etc/systemd/system
		ln -s /etc/systemd/system/zram0.service /etc/sysemd/system/multi-user.target.wants/zram0.service
	else
		install -Dm755 "${FILES}"/zram/zram0 /etc/init.d
		ln -s /etc/init.d/zram0 /etc/runlevels/default/zram0
	fi
	echo "enabled zram swap drive"
fi
