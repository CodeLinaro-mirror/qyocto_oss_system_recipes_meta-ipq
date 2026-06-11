# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC

DESCRIPTION = "Remote Processor Firmware Mount Script for IPQ9650. \
    Mounts CDSP and Prime firmware squashfs partitions early at boot \
    and creates the firmware symlinks required by fastrpc / cdsprpcd."
HOMEPAGE = "https://github.com/qualcomm/fastrpc"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/ISC;md5=f3b90e78ea0cffb20bf5cca7947a896d"

inherit systemd

SRC_URI = " \
    file://rproc_fw_mount.sh \
    file://rproc-fw-mount.service \
"

S = "${WORKDIR}"

# rproc-fw-mount is only applicable to ipq96xx (IPQ9650 has CDSP + Prime)
COMPATIBLE_MACHINE = "ipq96xx_64|ipq96xx"

SYSTEMD_SERVICE:${PN} = "rproc-fw-mount.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    # Install the mount script
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/rproc_fw_mount.sh ${D}${sbindir}/rproc_fw_mount.sh

    # Install the systemd service unit
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/rproc-fw-mount.service \
        ${D}${systemd_unitdir}/system/rproc-fw-mount.service

    # Enable the service at boot via systemd symlink
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants
    ln -sf ${systemd_unitdir}/system/rproc-fw-mount.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/rproc-fw-mount.service
}

FILES:${PN} = " \
    ${sbindir}/rproc_fw_mount.sh \
    ${systemd_unitdir}/system/rproc-fw-mount.service \
    ${systemd_unitdir}/system/multi-user.target.wants/rproc-fw-mount.service \
"
