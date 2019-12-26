#!/bin/sh

patch /var/db/repos/gentoo/profiles/targets/desktop/package.use.mask /etc/portage/repo.postsync.d/gles2-overrides-1.patch
patch /var/db/repos/gentoo/profiles/base/package.use.mask /etc/portage/repo.postsync.d/gles2-overrides-2.patch
