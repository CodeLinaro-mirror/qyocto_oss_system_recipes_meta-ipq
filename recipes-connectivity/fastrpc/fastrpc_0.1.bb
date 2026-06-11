# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause

DESCRIPTION = "Qualcomm FastRPC userspace library and daemon. \
    FastRPC is a mechanism that allows the application processor (HLOS) to \
    invoke functions on a remote DSP processor (CDSP) and vice versa."
HOMEPAGE = "https://github.com/qualcomm/fastrpc"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=b67986b6880754696d418dbaa2cf51d1"

inherit autotools-brokensep pkgconfig systemd

DEPENDS = "libyaml libbsd"

SRC_URI = "git://github.com/qualcomm/fastrpc.git;protocol=https;branch=main \
           file://fastrpc.rules \
          "
SRCREV = "8572ae1c45d38a4dc8853b1b9b6738207ab1ce94"

S = "${WORKDIR}/git"

# fastrpc is only applicable to ipq96xx which has a CDSP
COMPATIBLE_MACHINE = "ipq96xx_64|ipq96xx"

EXTRA_OECONF = "--with-systemdsystemunitdir=${systemd_unitdir}/system"

SYSTEMD_SERVICE:${PN} = "cdsprpcd.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_configure:prepend() {
    cd ${S}
    chmod +x ${S}/autogen.sh
    ${S}/autogen.sh
}

do_install:append() {
    # Install udev rules for fastrpc device nodes
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/fastrpc.rules ${D}${sysconfdir}/udev/rules.d/

    # Enable cdsprpcd service at boot via systemd symlink
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants
    ln -sf ${systemd_unitdir}/system/cdsprpcd.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/cdsprpcd.service

    # ipq96xx only has a CDSP — remove ADSP/SDSP/GDSP binaries, libraries,
    # service files and test artifacts installed by make install for other DSPs.

    # Remove non-CDSP daemon binaries
    rm -f ${D}${bindir}/adsprpcd
    rm -f ${D}${bindir}/sdsprpcd
    rm -f ${D}${bindir}/gdsprpcd
    rm -f ${D}${bindir}/fastrpc_test

    # Remove non-CDSP libraries
    rm -f ${D}${libdir}/libadsprpc.so*
    rm -f ${D}${libdir}/libadsp_default_listener.so*
    rm -f ${D}${libdir}/libsdsprpc.so*
    rm -f ${D}${libdir}/libsdsp_default_listener.so*
    rm -rf ${D}${libdir}/fastrpc_test

    # Remove non-CDSP systemd service files
    rm -f ${D}${systemd_unitdir}/system/adsprpcd.service
    rm -f ${D}${systemd_unitdir}/system/adsprpcd_audiopd.service
    rm -f ${D}${systemd_unitdir}/system/sdsprpcd.service
    rm -f ${D}${systemd_unitdir}/system/gdsp0rpcd.service
    rm -f ${D}${systemd_unitdir}/system/gdsp1rpcd.service
    rm -f ${D}${systemd_unitdir}/system/cdsp1rpcd.service

    # Remove test data
    rm -rf ${D}${datadir}/fastrpc_test
    rmdir --ignore-fail-on-non-empty ${D}${datadir}
}

FILES:${PN} = " \
    ${bindir}/cdsprpcd \
    ${libdir}/libcdsprpc.so* \
    ${libdir}/libcdsp_default_listener.so* \
    ${systemd_unitdir}/system/cdsprpcd.service \
    ${systemd_unitdir}/system/multi-user.target.wants/cdsprpcd.service \
    ${sysconfdir}/udev/rules.d/fastrpc.rules \
"

INSANE_SKIP:${PN} += "ldflags dev-so"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
SOLIBS = ".so"
FILES_SOLIBSDEV = ""
