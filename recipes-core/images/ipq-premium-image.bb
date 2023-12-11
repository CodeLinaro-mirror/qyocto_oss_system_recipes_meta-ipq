# Base this image on core-image-minimal

include recipes-core/images/core-image-minimal.bb
include recipes-core/images/ipq-pkgs.inc

IMAGE_INSTALL += " \
	kernel-modules \
	${IPQ_BASE_PKGS} \
	${QYOCTO_PKGS} \
	${NETWORK_PKGS} \
	${UTILS} \
	"

EXTRA_IMAGEDEPENDS += " \
		${QYOCTO_TEST_PKGS} \
		"

EXTRA_IMAGEDEPENDS:remove = "${QYOCTO_TEST_PKGS}"

IPQ_BASE_PKGS:remove = " ${SYSUPGRADE} datarmnet modemmanager libnghttp2 wolfssl "

UTILS:remove = " rp-pppoe pdt "

NETWORK_PKGS:remove = " dhcp-server iw ntp "
