LICENSE = "GPLv2"

require recipes-kernel/linux/linux-qca-ipq.inc
require recipes-kernel/linux/linux-ipq-fit.inc

LINUX_VERSION ?= "5.4"
LINUX_DESCRIPTION = "QTI IPQ Linux 5.4"

FILESPATH =+ "${TOPDIR}/../:"
SRC_URI = "file://kernel \
	   file://defconfig \
	   file://ipq95xx-default \
	   file://ipq95xx_64-default \
	   file://ipq_debug_kasan \
	   "
S = "${WORKDIR}/kernel"
SRC_URI += "file://fit"

# MAKEOPTS += KBUILD_VERBOSE=1
# MAKEOPTS += KERNEL_SRC_PATH="$(STAGING_KERNEL_DIR)"
EXTRA_CFLAGS += "-I${B}/../kernel/include/linux -I${B}/../kernel/include/linux/lzma -include types.h -Wno-error"
EXTRA_OEMAKE += " \
        EXTRA_CFLAGS='${EXTRA_CFLAGS}' \
        "
#EXTRA_OEMAKE_append += " \
#	KERNEL_SRC_PATH=$(STAGING_KERNEL_DIR) \
#	"

#  MAKEOPTS += __KERNEL__=1
COMPATIBLE_MACHINE = "(ipq807x|ipq807x_64|ipq95xx|ipq95xx_64)"
KERNEL_IMAGETYPE ?= "Image"
