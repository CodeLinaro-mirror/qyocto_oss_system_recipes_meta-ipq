# Base this image on core-image-minimal

include recipes-core/images/core-image-minimal.bb
include recipes-core/images/ipq-pkgs.inc

# Include modules in rootfs
IMAGE_INSTALL += " \
	kernel-modules \
	${IPQ_BASE_PKGS} \
	${NETWORK_PKGS} \
	${UTILS} \
	${SSDK_NOHNAT_PKGS} \
	"

EXTRA_IMAGEDEPENDS += " \
		${QYOCTO_TEST_PKGS} \
		"

IPQ_BASE_PKGS_remove = " ipq-boot "

UTILS_remove = " rp-pppoe pdt "
