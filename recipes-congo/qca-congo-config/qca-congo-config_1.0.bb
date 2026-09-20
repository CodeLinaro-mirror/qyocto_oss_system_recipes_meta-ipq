DESCRIPTION = "Congo (fig_v2) INI — WCNSS_qcom_cfg.ini shipped in-recipe under files/."
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://WCNSS_qcom_cfg.ini;beginline=1;endline=2;md5=e97692d5e662d2c34f564e41fe850e23"

PR = "r0"

SRC_URI = " \
    file://WCNSS_qcom_cfg.ini \
"

S = "${WORKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}/lib/firmware/wlan/qca_cld/fig_v2
    install -m 0644 ${WORKDIR}/WCNSS_qcom_cfg.ini \
        ${D}/lib/firmware/wlan/qca_cld/fig_v2/WCNSS_qcom_cfg.ini
}

FILES:${PN} = " \
    /lib/firmware/wlan/qca_cld/fig_v2/WCNSS_qcom_cfg.ini \
"

# Pre-built binaries — suppress OE QA strip/run-time checks.
INSANE_SKIP:${PN} += "already-stripped ldflags arch buildpaths file-rdeps libdir staticdev"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
