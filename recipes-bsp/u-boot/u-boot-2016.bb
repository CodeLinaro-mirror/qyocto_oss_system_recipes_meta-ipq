DESCRIPTION = "U-boot bootloader for IPQ40xx"
LICENSE = "GPLv2"
SECTION = "bootloaders"

require recipes-bsp/u-boot/u-boot.inc
DEPENDS = "linux-ipq"
FILESPATH =+ "${TOPDIR}/../boot/:"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

LOCALVERSION ?= "+yocto"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ipq40xx|ipq807x|ipq95xx|ipq53xx)"
# DEPENDS +="u-boot-mkimage-native"

SRC_URI = "file://u-boot-2016 \
	file://0001-fix-uboot-build-errors.patch "

S = "${WORKDIR}/u-boot-2016"
B = "${WORKDIR}/build"

UBOOT_MACHINE_ipq40xx = "ipq40xx_defconfig"
UBOOT_MACHINE_ipq807x = "ipq807x_defconfig"
UBOOT_MACHINE_ipq95xx = "ipq9574_defconfig"
UBOOT_MACHINE_ipq53xx = "ipq5332_defconfig"
UBOOT_MAKE_TARGET = "all"

EXTRA_OEMAKE = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${TARGET_PREFIX}gcc ${TOOLCHAIN_OPTIONS}" STRIP=true V=1'
EXTRA_OEMAKE += 'TARGETCC="${CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS} -Wno-error "'
EXTRA_OEMAKE += 'UBOOT_INITIAL_ENV=1'
EXTRA_OEMAKE += "DTC=${WORKDIR}/../../${PREFERRED_PROVIDER_virtual/kernel}/${LINUX_VERSION}-${PR}/${BB_DEFAULT_TASK}/scripts/dtc/dtc"
PARALLEL_MAKE = "-j 1"

# Image files for Uboot
UBOOT_IMAGETYPE ?= "bin"
UBOOT_ELF_SUFFIX ?= "elf"
UBOOT_ELF = "u-boot"
UBOOT_ELF_IMAGE ?= "u-boot-${MACHINE}-${PV}-${PR}.${UBOOT_ELF_SUFFIX}"
UBOOT_ELF_BINARY ?= "u-boot.${UBOOT_ELF_SUFFIX}"

CFLAGS_append = "-Wno-error=address-of-packed-member -Wno-error "
do_configure () {
	oe_runmake -C ${S} O=${B} mrproper
	sed -i 's/HOSTCC       = cc/HOSTCC       = gcc/g' ${S}/Makefile
	oe_runmake -C ${S} O=${B} ${UBOOT_MACHINE}
}

do_compile_prepend() {
	mkdir -p ${B}/arch/ ${B}/arch/${UBOOT_ARCH}/ ${B}/arch/${UBOOT_ARCH}/dts
	cp -rf  ${S}/arch/${UBOOT_ARCH}/dts/* ${B}/arch/${UBOOT_ARCH}/dts/
}

do_compile() {
	oe_runmake -C ${S} O=${B} ${UBOOT_MAKE_TARGET}
	touch ${B}/u-boot-initial-env
}

do_install() {
	install -d ${D}${bindir}
        install -m 0755 ${B}/tools/dumpimage ${D}${bindir}/dumpimage
}

do_deploy_append() {
	cp u-boot-${MACHINE}-${PV}-${PR}.${UBOOT_ELF_SUFFIX} u-boot-${MACHINE}-${PV}-${PR}-stripped.${UBOOT_ELF_SUFFIX}
	${STRIP} u-boot-${MACHINE}-${PV}-${PR}-stripped.${UBOOT_ELF_SUFFIX}
}
FILES_${PN}-env = " ${bindir}/dumpimage "
INSANE_SKIP_${PN}-env += "ldflags"
