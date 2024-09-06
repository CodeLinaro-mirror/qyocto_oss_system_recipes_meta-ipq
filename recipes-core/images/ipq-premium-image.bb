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
#${WIFI_PKGS} \
#Enable once wifi is enabled.

NSS_ipq95xx_64 = "${SSDK_NOHNAT_PKGS} \
		  ${NSS_PKGS} \
		  ${IPQ95XX_NSS_PKGS} \
		  "

EXTRA_IMAGEDEPENDS += " \
		${QYOCTO_TEST_PKGS} \
		"
IMAGE_INSTALL += " \
		  ${NSS_ipq95xx_64} \
		  "

IPQ_BASE_PKGS:remove = " ${SYSUPGRADE} datarmnet modemmanager libnghttp2 wolfssl "

UTILS:remove = " rp-pppoe pdt "

NETWORK_PKGS:remove = " dhcp-server iw ntp "
