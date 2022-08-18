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

NSS_ipq95xx_64 = "${SSDK_NOHNAT_PKGS} \
		  ${NSS_PKGS} \
		  ${IPQ95XX_NSS_PKGS} \
		  "

NSS_ipq95xx = "${SSDK_NOHNAT_PKGS} \
		${NSS_PKGS} \
		${IPQ95XX_NSS_PKGS} \
		"

IMAGE_INSTALL += " \
		${NSS} \
		"

EXTRA_IMAGEDEPENDS += " \
		${TEST_PKGS} \
		"
TEST_PKGS_remove = " ebtables iperf3 lvm2 "
IPQ_BASE_PKGS_remove = " ipq-boot "
UTILS_remove = " rp-pppoe "
