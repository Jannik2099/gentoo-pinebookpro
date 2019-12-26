#!/bin/sh

patch /var/db/repos/gentoo/profiles/arch/arm64/package.use.mask /etc/portage/repo.postsync.d/default-overrides.patch
