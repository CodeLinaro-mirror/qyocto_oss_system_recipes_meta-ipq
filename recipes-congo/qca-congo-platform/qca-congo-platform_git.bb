DESCRIPTION = "Congo CNSS platform driver (cnss2.ko + cnss_prealloc.ko + cnss_nl.ko + cnss_utils.ko + cnss_plat_ipc_qmi_svc.ko + wlan_firmware_service.ko)"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://cnss2/main.c;beginline=1;endline=5;md5=aedcbf4485c83cd3a628647b0064ec5f"

inherit module externalsrc

EXTERNALSRC = "${TOPDIR}/../wifi/qca-congo/platform"
EXTERNALSRC_BUILD = "${EXTERNALSRC}"
PV = "1.0+ext"
S = "${EXTERNALSRC}"

DEPENDS = "virtual/kernel"

EXTRA_OEMAKE += "CONFIG_CNSS_OUT_OF_TREE=y \
                 USE_EXTERNAL_CONFIGS=y \
                 CONFIG_CNSS2=m \
                 CONFIG_CNSS2_QMI=y \
                 CONFIG_CNSS2_DEBUG=y \
                 CONFIG_CNSS_QMI_SVC=m \
                 CONFIG_CNSS_PLAT_IPC_QMI_SVC=m \
                 CONFIG_CNSS_GENL=m \
                 CONFIG_WCNSS_MEM_PRE_ALLOC=m \
                 CONFIG_CNSS_PREALLOC_DEBUG_LEAK=y \
                 CONFIG_CNSS_UTILS=m \
                 CONFIG_CNSS2_SSR_DRIVER_DUMP=y \
                 CONFIG_PCIE_QCOM_ECAM=y \
                 CONFIG_PINCTRL_MSM_NO_EXT=y \
                 CONFIG_QLI=y \
                 CONFIG_EXCLUDE_ICNSS=y \
		 CONFIG_CNSS2_SDIO=n \
		 CONFIG_SDIO_QCN=n \
		 CONFIG_CNSS_QUIRKS_DEFAULT=0x1c0000 \
		 CONFIG_CNSS_IO_COHERENCY=y \
                 WLAN_PLATFORM_ROOT=${S}"

MODULES_MODULE_SYMVERS_LOCATION = "."

do_compile() {
    oe_runmake -C "${STAGING_KERNEL_DIR}" \
        ${EXTRA_OEMAKE} \
        M="${S}" \
        modules
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    install -m 0644 ${S}/cnss2/cnss2.ko                     ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    install -m 0644 ${S}/cnss_genl/cnss_nl.ko               ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    install -m 0644 ${S}/cnss_prealloc/cnss_prealloc.ko     ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    install -m 0644 ${S}/cnss_utils/cnss_plat_ipc_qmi_svc.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    install -m 0644 ${S}/cnss_utils/wlan_firmware_service.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    install -m 0644 ${S}/cnss_utils/cnss_utils.ko           ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/

    install -d ${D}${includedir}/cnss
    install -m 0644 ${S}/inc/cnss2.h ${D}${includedir}/cnss/
}

KERNEL_MODULE_AUTOLOAD = ""

FILES:${PN} = "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/*.ko ${includedir}/cnss"

# Disable auto-RDEPENDS on kernel-module-*-<kver> providers.
# The module class generates these from the .ko files we install,
# but we install the .ko files directly under FILES:${PN}, so the
# kernel-module-* sub-packages are empty and never produced.
# Without this, opkg fails do_rootfs with "nothing provides
# kernel-module-cnss-nl-6.6.47+yocto".

# Disable kernel-module-split.bbclass auto-split which would inject
# RDEPENDS on kernel-module-<ko>-<KERNEL_VERSION> sub-packages.
# We ship the .ko files under FILES:${PN} directly; no per-ko sub-pkgs.
KERNEL_SPLIT_MODULES = "0"

# kernel-module-split.bbclass do_install:append still creates
# /etc/modules-load.d + /etc/modprobe.d even when KERNEL_SPLIT_MODULES=0;
# the splitter normally cleans them up via os.rmdir but we short-circuit
# that path. Remove them ourselves to silence the installed-vs-shipped QA.
do_install:append() {
    rmdir ${D}${sysconfdir}/modules-load.d ${D}${sysconfdir}/modprobe.d 2>/dev/null || true
    rmdir ${D}${sysconfdir} 2>/dev/null || true

    # Sysroot exports for qca-congo-qcacld: same headers and Module.symvers
    # this recipe just produced, so qcacld can link fig_v2.ko without
    # re-building platform. Both live under ${includedir} so they land in
    # the default -dev sub-package (build-time-only, never in rootfs).
    install -d ${D}${includedir}/qca-congo-platform
    install -m 0644 ${S}/inc/*.h              ${D}${includedir}/qca-congo-platform/
    install -m 0644 ${S}/Module.symvers       ${D}${includedir}/qca-congo-platform/Module.symvers
}
