FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append() {
        install -d ${D}${bindir}
        install -m 0755 ${WORKDIR}/git/libdm/dm-tools/dmsetup ${D}${bindir}
        install -m 0755 ${WORKDIR}/git/tools/lvm ${D}${bindir}
}
