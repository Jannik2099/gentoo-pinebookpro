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

chmod 4711 /bin/passwd
echo "applied fix for sddm login"

sed -i "s/COMMON_FLAGS=\"/COMMON_FLAGS=\"-march=armv8-a+crc+crypto -mcpu=cortex-a72.cortex-a53 /" /etc/portage/make.conf
if [ "$(grep -e MAKEOPTS /etc/portage/make.conf)" = "" ]; then
	echo "MAKEOPTS=\"-j6 -l10\"" >> /etc/portage/make.conf
fi
echo "applied optimal settings to make.conf"

#mkdir -p /etc/portage/repo.postsync.d
#install -m 755 "${FILES}"/overrides/default-overrides.sh /etc/portage/repo.postsync.d
#install -m 644 "${FILES}"/overrides/default-overrides.patch /etc/portage/repo.postsync.d
#echo "installed default profile patches"

#There are currently no profile overrides necessary for succesfully building stuff (that I know of), I'll leave this here to uncomment when needed
#Last override was related to firefox neon, closed by the arm64 profile https://gitweb.gentoo.org/repo/gentoo.git/commit/?id=3cb587fffab8ed32347dc455d2dc59a51cff351e
#TODO: have a cleaner implementation of profile overrides - is this possible just with patching use.mask and use.force in profiles/base ?

if [ "${gles2}" != "no" ]; then
	install -Dm 755 "${FILES}"/overrides/gles2-overrides.sh /etc/portage/repo.postsync.d/gles2-overrides.sh
	install -Dm 644 "${FILES}"/overrides/gles2-overrides-1.patch /etc/portage/repo.postsync.d/gles2-overrides-1.patch
	install -Dm 644 "${FILES}"/overrides/gles2-overrides-2.patch /etc/portage/repo.postsync.d/gles2-overrides-2.patch
	sed -i "s/USE=\"/USE=\"gles2 /" /etc/portage/make.conf
	echo "installed gles2 profile patches"
	echo "NOTE: this will disable OpenGL acceleration in place of gles2!"
fi

#Should gles2 be applied via make.conf or profiles/desktop/make.defaults ?
#TODO: add a script to revert these profile changes if desired

if [ "${wayland}" = "yes" ]; then
	install -Dm 755 "${FILES}"/overrides/wayland-overrides.sh /etc/portage/repo.postsync.d/wayland-overrides.sh
	install -Dm 644 "${FILES}"/overrides/wayland-overrides-1.patch /etc/portage/repo.postsync.d/wayland-overrides-1.patch
	sed -i "s/USE=\"USE=\"wayland /" /etc/portage/make.conf
	echo "installed wayland profile patches"
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

if ! test -d /var/db/repos/gentoo; then
	echo "syncing main repository, this will take a while"
	sleep 3s
	emerge-webrsync
fi
emerge -u layman
yes | layman -o https://raw.githubusercontent.com/Jannik2099/pinebookpro-overlay/master/repositories.xml -f -a pinebookpro-overlay
