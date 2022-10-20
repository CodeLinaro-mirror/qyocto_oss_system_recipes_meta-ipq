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

do_getprofiletype () {
	LINUX_IPQ_VERSION=`echo ${PREFERRED_VERSION_linux-yocto} | awk -F% '{print $1}'`
        sed -i 's/CONFIG_CNSS2=y/# CONFIG_CNSS2 is not set/g' ${WORKDIR}/../../${PREFERRED_PROVIDER_virtual/kernel}/${LINUX_IPQ_VERSION}-${PR}/defconfig
        sed -i 's/CONFIG_CNSS2_GENL=y/# CONFIG_CNSS2_GENL is not set/g' ${WORKDIR}/../../${PREFERRED_PROVIDER_virtual/kernel}/${LINUX_IPQ_VERSION}-${PR}/defconfig
        sed -i 's/CONFIG_CNSS2_QCA9574_SUPPORT=y/# CONFIG_CNSS2_QCA9574_SUPPORT is not set/g' ${WORKDIR}/../../${PREFERRED_PROVIDER_virtual/kernel}/${LINUX_IPQ_VERSION}-${PR}/defconfig
}
addtask getprofiletype before do_prepare_recipe_sysroot
