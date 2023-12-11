
FILESEXTRAPATHS:append := "${THISDIR}/files:"
SRC_URI += "file://95-gpio-buttons.rules \
	    file://001-remove_shared_mount_229.patch \
	    file://0018-distinguish-XSI-compliant-strerror_r-from-GNU-specif.patch \
	    file://98-q6mem-dump.rules \
	    "
PACKAGECONFIG:remove_libc-musl = "utmp"
do_install:append() {
	install -d ${D}/lib/udev/rules.d/
	install -m 0755 ${WORKDIR}/95-gpio-buttons.rules ${D}/lib/udev/rules.d/
	install -m 0755 ${WORKDIR}/98-q6mem-dump.rules ${D}/lib/udev/rules.d/
}

FILES:${PN} += " \
		/lib/udev/rules.d/95-gpio-buttons.rules \
		/lib/udev/rules.d/98-q6mem-dump.rules \
		"
