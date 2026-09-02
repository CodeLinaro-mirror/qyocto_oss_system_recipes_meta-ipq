FILESEXTRAPATHS:prepend := "${THISDIR}:"

SRCREV = "b4cfeba930ae9d6c7c59275d1b33f50032c72b40"

SRC_URI:remove = " \
    git://git.yoctoproject.org/pseudo;branch=oe-core \
    file://0001-configure-Prune-PIE-flags.patch \
    file://older-glibc-symbols.patch \
"

SRC_URI:prepend = "git://git.yoctoproject.org/pseudo;protocol=https;branch=master "

SRC_URI:append:class-native = " file://older-glibc-symbols-b4.patch"
SRC_URI:append:class-nativesdk = " file://older-glibc-symbols-b4.patch"
