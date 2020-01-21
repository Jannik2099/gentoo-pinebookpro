#!/bin/sh

unalias -a

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

. /etc/profile
FILES=$(readlink -f "$0" | xargs dirname)

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

		--wayland)
		wayland=${2}
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

install -Dm 644 "${FILES}"/linux-firmware-20191215 /etc/portage/savedconfig/sys-kernel/linux-firmware-20191215

mkdir -p /etc/portage/package.use
install -Dm 644 "${FILES}"/mesa /etc/portage/package.use/mesa

chmod 4711 /bin/passwd
echo "applied fix for sddm login"

install -Dm 644 "${FILES}"/make.conf /etc/portage/make.conf
if test -d /usr/aarch64-gentoo-linux-musl; then
	patch /etc/portage/make.conf make.conf.musl.patch
fi
echo "applied optimal settings to make.conf"

rm -rf /usr/portage
mkdir -p /var/db/repos/gentoo
mkdir -p /var/cache/distfiles
mkdir -p /var/cache/binpkgs

if [ "${gles2}" != "no" ]; then
	sed -i "s/USE=\"/USE=\"gles2 gles2-only /" /etc/portage/make.conf
	echo "installed gles2 profile patches"
	echo "NOTE: this will disable OpenGL acceleration in place of gles2!"
fi

if [ "${wayland}" = "yes" ]; then
	sed -i "s/USE=\"/USE=\"wayland /" /etc/portage/make.conf
	echo "installed wayland profile patches. using wayland is NOT recommended right now!!!"
fi

if [ "${zram}" != "no" ]; then
	if [ "${init}" = "systemd" ]; then
		install -Dm 644 "${FILES}"/zram/zram0.service /etc/systemd/system/zram0.service
		ln -s /etc/systemd/system/zram0.service /etc/systemd/system/multi-user.target.wants/zram0.service
	else
		install -Dm 755 "${FILES}"/zram/zram0 /etc/init.d/zram0
		ln -s /etc/init.d/zram0 /etc/runlevels/default/zram0
	fi
	echo "enabled zram swap drive"
fi

echo "syncing main repository, this will take a while"
emerge-webrsync

echo "installing pinebookpro-overlay, this will take an even longer while"
emerge -u portage
install -Dm 644 "${FILES}"/package.accept_keywords /etc/portage/package.accept_keywords
emerge eselect-repository
eselect repository add pinebookpro-overlay git https://github.com/Jannik2099/gentoo-pinebookpro.git
emerge -u pinebookpro-profile-overrides
echo "installed pinebookpro-overlay"

if test -d /usr/aarch64-gentoo-linux-musl; then
	eselect repository enable musl
	echo "installed musl overlay"
fi

echo "don't forget to select a profile!"
echo "see eselect profile"
