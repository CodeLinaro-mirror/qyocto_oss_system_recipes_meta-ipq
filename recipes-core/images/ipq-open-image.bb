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
		${QYOCTO_TEST_PKGS} \
		"
UTILS_remove = " rp-pppoe pdt "

IPQ_BASE_PKGS_remove = " ipq-boot ${SYSUPGRADE} "
IPQ_BASE_PKGS_append = " ipq-board "

NETWORK_PKGS_remove = " iw "
NETWORK_PKGS_append = " open-iw open-hostapd open-mac80211 iperf ath-autoload "
LC_ALL = "C"

do_getprofiletype () {
        echo "The task is required to avoid race condition"
}
addtask getprofiletype before do_prepare_recipe_sysroot
