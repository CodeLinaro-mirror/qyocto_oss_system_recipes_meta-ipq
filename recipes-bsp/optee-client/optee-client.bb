# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-2-Clause

DESCRIPTION = "Normal World Client side of the TEE (OP-TEE)"
HOMEPAGE = "https://github.com/OP-TEE/optee_client"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=69663ab153298557a59c67a60a743e5b"

PV = "4.6.0"
PR = "r0"

SRC_URI = "https://github.com/OP-TEE/optee_client/archive/refs/tags/${PV}.tar.gz;downloadfilename=optee_client-${PV}.tar.gz \
           file://tee-supplicant.service \
          "
SRC_URI[sha256sum] = "a970338c9f69861901336716d89684646e4480b9970996a5b3581ae7d49fdaa3"

S = "${WORKDIR}/optee_client-${PV}"

# libuuid is required (same as QSDK: DEPENDS:=+libuuid)
DEPENDS = "util-linux-libuuid"

inherit cmake systemd pkgconfig

SYSTEMD_SERVICE:${PN} = "tee-supplicant.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

# Only applicable to ipq52xx and ipq96xx (same as QSDK: @TARGET_ipq96xx||TARGET_ipq52xx)
COMPATIBLE_MACHINE = "ipq52xx_64|ipq52xx|ipq96xx_64|ipq96xx"

EXTRA_OECMAKE = " \
    -DCMAKE_BUILD_TYPE=Release \
    -DCFG_TEE_CLIENT_LOAD_PATH=/lib/optee_armtz \
    -DCFG_TEE_FS_PARENT_PATH=/data/tee \
    -DBUILD_SHARED_LIBS=ON \
"

# Override do_install to match QSDK package/install exactly:
# QSDK ships only the .so libs, tee-supplicant binary, and init script.
# RDK equivalent replaces the init script with a systemd service unit.
do_install() {
    # Libraries (aligned with QSDK: CP out/lib*/lib*.so* /usr/lib/)
    # Note: Yocto cmake build outputs to ${B}/<lib>/ (QSDK uses ${B}/out/<lib>/)
    install -d ${D}${libdir}
    cp -a ${B}/libteec/libteec.so*       ${D}${libdir}/
    cp -a ${B}/libckteec/libckteec.so*   ${D}${libdir}/
    cp -a ${B}/libteeacl/libteeacl.so*   ${D}${libdir}/
    cp -a ${B}/libseteec/libseteec.so*   ${D}${libdir}/

    # Binary (aligned with QSDK: INSTALL_BIN out/tee-supplicant/tee-supplicant /usr/sbin/)
    install -d ${D}${sbindir}
    install -m 0755 ${B}/tee-supplicant/tee-supplicant ${D}${sbindir}/

    # Systemd service (RDK equivalent of QSDK's tee-supplicant.init in /etc/init.d/)
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/tee-supplicant.service \
        ${D}${systemd_unitdir}/system/tee-supplicant.service
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants
    ln -sf ${systemd_unitdir}/system/tee-supplicant.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/tee-supplicant.service
}

FILES:${PN} = " \
    ${sbindir}/tee-supplicant \
    ${libdir}/libteec.so* \
    ${libdir}/libckteec.so* \
    ${libdir}/libteeacl.so* \
    ${libdir}/libseteec.so* \
    ${systemd_unitdir}/system/tee-supplicant.service \
    ${systemd_unitdir}/system/multi-user.target.wants/tee-supplicant.service \
"

INSANE_SKIP:${PN} += "ldflags dev-so"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
SOLIBS = ".so"
FILES_SOLIBSDEV = ""
