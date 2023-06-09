# Base this image on core-image-minimal

include recipes-core/images/core-image-minimal.bb
include recipes-core/images/ipq-pkgs.inc

IMAGE_INSTALL += " \
	kernel-modules \
	${IPQ_BASE_PKGS} \
	${QYOCTO_PKGS} \
	${NETWORK_PKGS} \
	${UTILS} \
	${NSS} \
	"

NSS_ipq95xx_64 = "${SSDK_NOHNAT_PKGS} \
		${NSS_PKGS} \
		${IPQ95XX_NSS_PKGS} \
		"

NSS_ipq95xx = "${SSDK_NOHNAT_PKGS} \
		${NSS_PKGS} \
		${IPQ95XX_NSS_PKGS} \
		"
NSS_ipq53xx_64 = "${SSDK_NOHNAT_PKGS} \
		${NSS_PKGS} \
		${IPQ53XX_NSS_PKGS} \
		"

NSS_ipq53xx = "${SSDK_NOHNAT_PKGS} \
		${NSS_PKGS} \
		${IPQ53XX_NSS_PKGS} \
		"

EXTRA_IMAGEDEPENDS += " \
		${QYOCTO_TEST_PKGS} \
		"
UTILS_remove = " perf rp-pppoe pdt "

IPQ_BASE_PKGS_remove = " ${SYSUPGRADE} datarmnet modemmanager libnghttp2 wolfssl "
IPQ95XX_NSS_PKGS_remove = " strongswan "
IPQ53XX_NSS_PKGS_remove = " strongswan "

NETWORK_PKGS_remove = " iw ntp"
NETWORK_PKGS_append = " open-iw open-hostapd open-mac80211 iperf ath-driver-init dhcp-client "
LC_ALL = "C"

do_getprofiletype () {
        echo "The task is required to avoid race condition"
}
addtask getprofiletype before do_prepare_recipe_sysroot
