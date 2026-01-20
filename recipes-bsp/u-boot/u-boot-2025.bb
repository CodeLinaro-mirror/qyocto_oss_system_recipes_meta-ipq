DESCRIPTION = "U-boot bootloader for IPQ95xx/53xxx/54xx/52xx/96xx"
LICENSE = "GPLv2"
SECTION = "bootloaders"

require recipes-bsp/u-boot/u-boot.inc
DEPENDS = "linux-ipq bison-native lzop-native bc-native libssl-1.0.2n-native"
DEPENDS:remove = "openssl"

FILESPATH =+ "${TOPDIR}/../boot/:"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

LOCALVERSION ?= "+yocto"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ipq95xx|ipq95xx_64|ipq53xx_64|ipq53xx|ipq54xx_64|ipq54xx|ipq52xx|ipq52xx_64|ipq96xx_64|ipq96xx)"

SRC_URI = "file://u-boot-2025"

S = "${WORKDIR}/u-boot-2025"


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
UBOOT_MACHINE:ipq52xx_64 = "ipq5210_nand \
	ipq5210_norplusnand \
	ipq5210_mmc \
	ipq5210_norplusmmc \
"
UBOOT_MACHINE:ipq52xx = "ipq5210_nand32 \
	ipq5210_norplusnand32 \
	ipq5210_mmc32 \
	ipq5210_norplusmmc32 \
"
UBOOT_MACHINE:ipq96xx_64 = "ipq9650_nand \
	ipq9650_norplusnand \
	ipq9650_mmc \
	ipq9650_norplusmmc \
"
UBOOT_MACHINE:ipq52xx = "ipq9650_nand32 \
	ipq9650_norplusnand32 \
	ipq9650_mmc32 \
	ipq9650_norplusmmc32 \
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

UBOOT_VERSION_FILE ?= "${TOPDIR}/../../version"
UBOOT_VERSION_TARGET_MAKEFILE ?= "${S}/Makefile"

do_patch() {
    cp -fpR -u ${TOPDIR}/../boot/files/* ${S}/
    UBOOT_NHSS_VERSION=""
    if [ -f "${UBOOT_VERSION_FILE}" ]; then
        UBOOT_NHSS_VERSION=$(awk -F. 'NF == 4 {
            if (length($2) > 1)
                print $1 "." substr($2, 1, 1) "." substr($2, 2) "-" $4;
            else
                print $1 "." $2 "-" $4;
        }' "${UBOOT_VERSION_FILE}")
    else
        bbwarn "Version file ${UBOOT_VERSION_FILE} not found; skipping version update"
    fi

    if [ -n "${UBOOT_NHSS_VERSION}" ]; then
        if [ -f "${UBOOT_VERSION_TARGET_MAKEFILE}" ]; then
            echo "Setting SUBLEVEL to ${UBOOT_NHSS_VERSION} in ${UBOOT_VERSION_TARGET_MAKEFILE}"

            # Replace the SUBLEVEL assignment line
            sed -i "/^SUBLEVEL[[:space:]]*=/s@.*@SUBLEVEL = ${UBOOT_NHSS_VERSION}@" "${UBOOT_VERSION_TARGET_MAKEFILE}"

            # Change occurrences of .$(SUBLEVEL) to -$(SUBLEVEL)
            # (keep $ literal for Make by using single quotes)
            sed -i 's/\.\$(SUBLEVEL)/-\$(SUBLEVEL)/g' "${UBOOT_VERSION_TARGET_MAKEFILE}"
        else
            bbwarn "Target Makefile ${UBOOT_VERSION_TARGET_MAKEFILE} not found; skipping version update"
        fi
    else
        bbwarn "NHSS_VERSION not computed (bad format or empty ${UBOOT_VERSION_FILE}); skipping"
    fi

#    # Apply patches from patches directory
#    if [ -d ${TOPDIR}/../boot/patches ]; then
#        for patch in ${TOPDIR}/../boot/patches/*.patch; do
#            if [ -f "$patch" ]; then
#                echo "Applying patch: $patch"
#                patch -d "${S}" -p1 < "$patch" || exit 1
#            fi
#        done
#    fi
}

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
		# Determine architecture (32/64-bit)
		case "$config" in
		*32) ARCH_OBJ="elf32-littlearm" ;;
		*)   ARCH_OBJ="elf64-littleaarch64" ;;
		esac

		# Extract TEXT_BASE and TEXT_SIZE from defconfig
		TEXT_BASE=$(grep "CONFIG_TEXT_BASE" ${WORKDIR}/u-boot-${config}/configs/${config}_defconfig | cut -d'=' -f2)
		TEXT_SIZE=$(grep "CONFIG_TEXT_SIZE" ${WORKDIR}/u-boot-${config}/configs/${config}_defconfig | cut -d'=' -f2)

		# Generate custom linker script
		LD_SCRIPT="MEMORY { DDR (rxw) : ORIGIN = ${TEXT_BASE}, LENGTH = ${TEXT_SIZE} } PHDRS { data PT_LOAD FLAGS(5); } ENTRY(_entry) SECTIONS { . = ${TEXT_BASE}; _entry = . ;	.data : { *(.data) . = ALIGN(4);} > DDR :data _end = .; }"

		echo "${LD_SCRIPT}" > ${WORKDIR}/u-boot-${config}/u-boot-${config}-custom.ld

		# Convert u-boot.bin to object file
		${OBJCOPY} -I binary -O ${ARCH_OBJ} --change-addresses ${TEXT_BASE} --set-start ${TEXT_BASE} \
			${WORKDIR}/u-boot-${config}/u-boot.bin ${WORKDIR}/u-boot-${config}/u-boot.o

		# Link to create custom ELF
		${LD} ${WORKDIR}/u-boot-${config}/u-boot.o -T ${WORKDIR}/u-boot-${config}/u-boot-${config}-custom.ld \
			-o ${D}${bindir}/u-boot-${config}-${PV}-${PR}.elf

		# Copy original unstripped/stripped ELF
		cp ${WORKDIR}/u-boot-${config}/u-boot ${D}${bindir}/u-boot-${config}-${PV}-${PR}-unstripped.elf
		cp ${WORKDIR}/u-boot-${config}/u-boot ${D}${bindir}/u-boot-${config}-${PV}-${PR}-stripped.elf
		${STRIP} ${D}${bindir}/u-boot-${config}-${PV}-${PR}-stripped.elf

		# Copy binary image
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
