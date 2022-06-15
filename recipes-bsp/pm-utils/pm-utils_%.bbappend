LICENSE = "ISC"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://ipq-power-save.sh \
	file://cold_boot.sh "

do_install_append() {
	install -d ${D}/etc/pm/power.d/
	install -m 0755 ${WORKDIR}/ipq-power-save.sh ${D}/etc/pm/power.d/
	install -m 0755 ${WORKDIR}/cold_boot.sh ${D}/etc/pm/power.d/
	install -d ${D}/sbin
	cp ${D}/usr/bin/on_ac_power ${D}/sbin/
	rm -rf ${D}/usr/lib/pm-utils/power.d/
}

FILES_${PN} += "${sysconfdir}/*"
