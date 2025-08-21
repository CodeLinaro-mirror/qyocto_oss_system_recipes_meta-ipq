DESCRIPTION = "U-boot bootloader for IPQ40xx"
LICENSE = "GPLv2"
SECTION = "bootloaders"

require recipes-bsp/u-boot/u-boot.inc
DEPENDS = "linux-ipq bison-native lzop-native bc-native libssl-1.0.2n-native"
DEPENDS:remove = "openssl"

FILESPATH =+ "${TOPDIR}/../boot/:"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

LOCALVERSION ?= "+yocto"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ipq40xx|ipq807x|ipq95xx|ipq95xx_64|ipq53xx_64|ipq53xx|ipq54xx_64|ipq54xx)"
# DEPENDS +="u-boot-mkimage-native"

SRC_URI = "file://u-boot "

S = "${WORKDIR}/u-boot"

UBOOT_MACHINE_ipq40xx = "ipq40xx_defconfig"
UBOOT_MACHINE_ipq807x = "ipq807x_defconfig"

UBOOT_MACHINE:ipq54xx_64 = "ipq5424_nand \
	ipq5424_norplusnand \
	ipq5424_mmc \
	ipq5424_norplusmmc \
"
UBOOT_MACHINE:ipq54xx = "ipq5424_nand32 \
	ipq5424_norplusnand32 \
	ipq5424_mmc32 \
	ipq5424_norplusmmc32 \
"
UBOOT_MACHINE:ipq53xx_64 = "ipq5332_nand \
	ipq5332_norplusnand \
	ipq5332_mmc \
	ipq5332_norplusmmc \
"
UBOOT_MACHINE:ipq53xx = "ipq5332_nand32 \
	ipq5332_norplusnand32 \
	ipq5332_mmc32 \
	ipq5332_norplusmmc32 \
"
UBOOT_MACHINE:ipq95xx_64 = "ipq9574_nand \
	ipq9574_norplusnand \
	ipq9574_mmc \
	ipq9574_norplusmmc \
"
UBOOT_MACHINE:ipq95xx = "ipq9574_nand32 \
	ipq9574_norplusnand32 \
	ipq9574_mmc32 \
	ipq9574_norplusmmc32 \
"
UBOOT_MAKE_TARGET = "all"

export  HOST_EXTRACFLAGS+=" -I${STAGING_INCDIR_NATIVE}/libressl-3.7.2/ "

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

CFLAGS:append = " -Wno-error=address-of-packed-member -Wno-error "
do_configure () {
	sed -i 's/HOSTCC       = cc/HOSTCC       = gcc/g' ${S}/Makefile
	for config in ${UBOOT_MACHINE}; do
		install -d ${WORKDIR}/u-boot-${config}/
		cp -rf ${S}/* ${WORKDIR}/u-boot-${config}/
		oe_runmake -C ${WORKDIR}/u-boot-${config}/ ${config}_defconfig
	done
}

do_compile() {
	for config in ${UBOOT_MACHINE}; do
		oe_runmake -C ${WORKDIR}/u-boot-${config} HOSTLDLIBS_mkimage="-static ${STAGING_INCDIR_NATIVE}/libressl-3.7.2/libssl.a ${STAGING_INCDIR_NATIVE}/libressl-3.7.2/libcrypto.a -lpthread" ${UBOOT_MAKE_TARGET}
		touch ${WORKDIR}/u-boot-${config}/u-boot-initial-env
	done
}

do_install() {
	install -d ${D}${bindir}
	for config in ${UBOOT_MACHINE}; do
		${OBJCOPY} ${WORKDIR}/u-boot-${config}/u-boot ${WORKDIR}/u-boot-${config}/u-boot-dtb
		${OBJCOPY} ${WORKDIR}/u-boot-${config}/u-boot-dtb --set-section-flags .dtb=CONTENTS,ALLOC,DATA --update-section .dtb=${WORKDIR}/u-boot-${config}/fit-dtb.blob.lzo
		cp ${WORKDIR}/u-boot-${config}/u-boot-dtb ${D}${bindir}/u-boot-${config}-${PV}-${PR}.${UBOOT_ELF_SUFFIX}
		cp ${WORKDIR}/u-boot-${config}/u-boot-dtb ${D}${bindir}/u-boot-${config}-${PV}-${PR}-stripped.${UBOOT_ELF_SUFFIX}
		${STRIP} ${D}${bindir}/u-boot-${config}-${PV}-${PR}-stripped.${UBOOT_ELF_SUFFIX}
		cp ${WORKDIR}/u-boot-${config}/u-boot.bin ${D}${bindir}/${config}-${PV}-${PR}-u-boot.img
	done
}


do_deploy() {
	cp ${D}${bindir}/* ${DEPLOYDIR}/
}
addtask deploy before do_build after do_install

FILES:${PN}-env = " ${bindir}/dumpimage /usr/bin/*"
INSANE_SKIP:${PN} = "already-stripped"
INSANE_SKIP:${PN}-env += "ldflags"
