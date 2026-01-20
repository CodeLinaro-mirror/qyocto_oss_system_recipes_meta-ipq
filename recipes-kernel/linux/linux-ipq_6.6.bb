LICENSE = "GPLv2"

require recipes-kernel/linux/linux-qca-ipq.inc
require recipes-kernel/linux/linux-ipq-fit.inc

LINUX_VERSION ?= "6.6"
LINUX_DESCRIPTION = "QTI IPQ Linux 6.6"

FILESPATH =+ "${TOPDIR}/../:"
SRC_URI = "file://kernel \
	   file://defconfig \
	   file://ipq95xx-default \
	   file://ipq95xx_64-default \
	   file://ipq54xx-default \
	   file://ipq54xx_64-default \
	   file://ipq52xx-default \
	   file://ipq52xx_64-default \
	   file://ipq96xx-default \
	   file://ipq96xx_64-default \
	   file://ipq53xx-default \
	   file://ipq53xx_64-default \
	   file://ipq807x_64-default \
	   file://ipq807x-default \
	   file://ipq_debug \
	   file://ipq_debug_kasan \
	   "
S = "${WORKDIR}/kernel"
SRC_URI += "file://fit"

# MAKEOPTS += KBUILD_VERBOSE=1
# MAKEOPTS += KERNEL_SRC_PATH="$(STAGING_KERNEL_DIR)"
EXTRA_CFLAGS += " -I${B}/../kernel -I${B}/../kernel/include/linux/ -I${B}/../kernel/include/linux/lzma/ -Wno-error=misleading-indentation "
EXTRA_OEMAKE += " \
        EXTRA_CFLAGS='${EXTRA_CFLAGS}' \
        "
#EXTRA_OEMAKE:append += " \
#	KERNEL_SRC_PATH=$(STAGING_KERNEL_DIR) \
#	"

#  MAKEOPTS += __KERNEL__=1
COMPATIBLE_MACHINE = "(ipq807x|ipq807x_64|ipq95xx|ipq95xx_64|ipq53xx|ipq53xx_64|ipq54xx_64|ipq54xx|ipq96xx_64|ipq96xx|ipq52xx_64|ipq52xx)"
KERNEL_IMAGETYPE ?= "Image"

do_install:prepend() {
	install -d ${D}/lib/modules/${KERNEL_VERSION}/
	touch ${D}/lib/modules/${KERNEL_VERSION}/source
}
