DESCRIPTION = "U-boot bootloader for IPQ40xx"
LICENSE = "GPLv2"
SECTION = "bootloaders"

require ${COREBASE}/meta/recipes-bsp/u-boot/u-boot.inc
FILESPATH =+ "${TOPDIR}/../boot/:"
LIC_FILES_CHKSUM = "file://COPYING;md5=1707d6db1d42237583f50183a5651ecb"

LOCALVERSION ?= "+yocto"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "ipq40xx"
DEPENDS +="u-boot-mkimage-native"

SRC_URI = "file://uboot-1.0"
S = "${WORKDIR}/uboot-1.0"

UBOOT_MACHINE = "ipq40xx_cdp_config"

# FLAGS need to be included for Uboot
UBOOT_LDFLAGS= "-L${STAGING_LIBDIR} -L${STAGING_BASELIBDIR}"
UBOOT_LDFLAGS+= "-L${STAGING_LIBDIR}/${TARGET_SYS}/${PREFERED_VERSION_LIBGCC}"

# Image files for Uboot
UBOOT_IMAGETYPE ?= "bin"
UBOOT_ELF_SUFFIX ?= "elf"
UBOOT_ELF = "u-boot"
UBOOT_ELF_IMAGE ?= "u-boot-${MACHINE}-${PV}-${PR}.${UBOOT_ELF_SUFFIX}"
UBOOT_ELF_BINARY ?= "u-boot.${UBOOT_ELF_SUFFIX}"


do_compile() {
	make CROSS_COMPILE=${TARGET_PREFIX} ${UBOOT_MACHINE}
	make CROSS_COMPILE=${TARGET_PREFIX} LDFLAGS="${UBOOT_LDFLAGS}" HOSTSTRIP=true
}

do_deploy:append() {
	install ${S}/${UBOOT_ELF} ${DEPLOYDIR}/${UBOOT_ELF_IMAGE}
	if [ ! -e ${UBOOT_ELF_BINARY} ]; then
		ln -sf ${UBOOT_ELF_IMAGE} ${UBOOT_ELF_BINARY}
	fi
	cp u-boot-${MACHINE}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} u-boot-${MACHINE}-${PV}-${PR}-stripped.${UBOOT_ELF_SUFFIX}
	${STRIP} u-boot-${MACHINE}-${PV}-${PR}-stripped.${UBOOT_ELF_SUFFIX}
}
