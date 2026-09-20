DESCRIPTION = "Congo qcacld-3.0 WLAN driver (fig_v2.ko) — built against in-tree platform/qca-wifi-host-cmn/fw-api sources"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://core/hdd/src/wlan_hdd_main.c;beginline=1;endline=18;md5=8a11da8e96402ba7442d528c6061234b"

inherit module externalsrc

EXTERNALSRC = "${TOPDIR}/../wifi/qca-congo/qcacld-3.0"
EXTERNALSRC_BUILD = "${EXTERNALSRC}"
PV = "1.0+ext"
S = "${EXTERNALSRC}"

DEPENDS = "virtual/kernel qca-congo-platform"

do_compile() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MAKEFLAGS
    unset KBUILD_CFLAGS KBUILD_CPPFLAGS KCPPFLAGS KCFLAGS
    ulimit -s unlimited

    # Direct workspace paths (no /tmp shim). Workspace realpath is short
    # enough (~66 chars) to keep kbuild argv under MAX_ARG_STRLEN (128 KB).
    QC_WD="$(readlink -f "${S}/..")"
    QC_KS="${STAGING_KERNEL_DIR}"
    QC_KB="${STAGING_KERNEL_BUILDDIR}"

    XCC="${TARGET_PREFIX}"
    KCFLAGS_RDK="-Wno-error=maybe-uninitialized -Wno-error=parentheses -Wno-error=unused-function -Wno-error=missing-prototypes -Wno-error=enum-conversion -Wno-error=int-conversion -Wno-error=implicit-function-declaration -Wno-error=array-bounds -Wno-error=stringop-overflow -Wno-error=stringop-truncation -Wno-error=address -Wno-error=incompatible-pointer-types -Wno-error=stringop-overread -Wno-unused-variable "

    # Build fig_v2.ko via direct kbuild — bypass qcacld top Makefile.
    # Consume platform headers + Module.symvers from the sysroot exported
    # by qca-congo-platform (see SYSROOT_DIRS there). No local platform
    # pre-build; DEPENDS = qca-congo-platform already staged those files.
    bbnote "qca-congo-qcacld: build fig_v2.ko using platform symvers from sysroot"
    make -j 16 -C "$QC_KS" \
        O="$QC_KB" \
        M="$QC_WD/qcacld-3.0" \
        ARCH=arm64 CROSS_COMPILE="$XCC" \
        KCFLAGS="$KCFLAGS_RDK" \
        WLAN_ROOT="$QC_WD/qcacld-3.0" \
        WLAN_PROFILE=ipq5424_gki_fig-v2 \
        MODNAME=fig_v2 \
        CONFIG_CNSS_SDIO=n CONFIG_CLD_HL_SDIO_CORE=n \
        CONFIG_QCA_WIFI_ISOC=0 CONFIG_QCA_WIFI_2_0=1 \
        CONFIG_QCA_CLD_WLAN=m \
	CONFIG_CNSS_IO_COHERENCY=y \
        WLAN_PLATFORM_INC="${STAGING_INCDIR}/qca-congo-platform" \
        KBUILD_EXTRA_SYMBOLS="${STAGING_INCDIR}/qca-congo-platform/Module.symvers" \
        modules \
        || die "fig_v2.ko build failed"
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    install -m 0644 ${S}/fig_v2.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
}

KERNEL_MODULE_AUTOLOAD = ""

FILES:${PN} = "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/fig_v2.ko"

# RDEPENDS clear: drop auto-generated kernel-module-fig-v2-<kver> on which
# nothing provides (we install the .ko under FILES:${PN} directly).
RDEPENDS:${PN} = "qca-congo-platform"

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
}
