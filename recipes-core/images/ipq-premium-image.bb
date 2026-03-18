# Base this image on core-image-minimal

include recipes-core/images/core-image-minimal.bb
include recipes-core/images/ipq-pkgs.inc

IMAGE_INSTALL += " \
	kernel-modules \
	${IPQ_BASE_PKGS} \
	${QYOCTO_PKGS} \
	${NETWORK_PKGS} \
	${UTILS} \
	${WIFI_PKGS} \
	"

NSS:ipq95xx_64 = "${SSDK_NOHNAT_PKGS} \
		  ${NSS_PKGS} \
		  ${IPQ95XX_NSS_PKGS} \
		  "

NSS:ipq53xx_64 = "${SSDK_NOHNAT_PKGS} \
                  ${NSS_PKGS} \
                  "

NSS:ipq54xx_64 = "${SSDK_NOHNAT_PKGS} \
                  ${NSS_PKGS} \
                  "

EXTRA_IMAGEDEPENDS += " \
		${QYOCTO_TEST_PKGS} \
		"
IMAGE_INSTALL += " \
		  ${NSS} \
		  "

IPQ_BASE_PKGS:remove = " ${SYSUPGRADE} datarmnet modemmanager libnghttp2 wolfssl "

UTILS:remove = " rp-pppoe pdt "

NETWORK_PKGS:remove = " dhcp-server iw ntp "
