#!/bin/sh

patch /var/db/repos/gentoo/profiles/arch/arm64/package.use.stable.mask /etc/portage/repo.postsync.d/wayland-overrides-1.patch
