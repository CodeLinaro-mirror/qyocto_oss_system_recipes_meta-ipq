LICENSE = "ISC"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://ipq-power-save.sh \
	file://cold_boot.sh \
	file://wifi_load.sh "

RDEPENDS:${PN}:remove = "grep"

do_install:append() {
	install -d ${D}/etc/pm/power.d/
	install -m 0755 ${WORKDIR}/ipq-power-save.sh ${D}/etc/pm/power.d/
	install -m 0755 ${WORKDIR}/cold_boot.sh ${D}/etc/pm/power.d/
	install -d ${D}/sbin
	install -m 0755 ${D}/usr/bin/on_ac_power ${D}/sbin/
	rm -rf ${D}/usr/lib/pm-utils/power.d/
	install -d ${D}/usr/sbin
	install -m 0755 ${WORKDIR}/wifi_load.sh ${D}/usr/sbin
}

FILES:${PN} += "${sysconfdir}/*"
