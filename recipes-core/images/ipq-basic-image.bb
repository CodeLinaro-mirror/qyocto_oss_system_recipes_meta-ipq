# Base this image on core-image-minimal

include recipes-core/images/core-image-minimal.bb
include recipes-core/images/ipq-pkgs.inc

# Include modules in rootfs
IMAGE_INSTALL += " \
	kernel-modules \
	${IPQ_BASE_PKGS} \
	${QYOCTO_PKGS} \
	${UTILS} \
	${QCA_PHY_PKGS} \
	${SSDK_NOHNAT_PKGS} \
	"

#EXTRA_IMAGEDEPENDS += " \
#		${QYOCTO_TEST_PKGS} \
#		"


IPQ_BASE_PKGS:remove = " ${SYSUPGRADE} datarmnet modemmanager libnghttp2 wolfssl "

UTILS:remove = " rp-pppoe pdt "

NETWORK_PKGS:remove = " dhcp-server iw ntp "
