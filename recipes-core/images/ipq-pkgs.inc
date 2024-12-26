#List of the packages for IPQ Platform categorized

# UBI image generation support
include recipes-core/images/ipq-images.inc

IMAGE_FEATURES += "package-management"

QYOCTO_PKGS = " libnl dropbear bridge-utils lua5.1 "
SYSUPGRADE_ipq95xx_64 = "sysupgrade-helper sysupgrade"
SYSUPGRADE_ipq95xx = "u-boot-2016-env sysupgrade "

SYSUPGRADE_ipq53xx_64 = "sysupgrade-helper sysupgrade"
SYSUPGRADE_ipq53xx = "u-boot-2016-env sysupgrade "

SYSUPGRADE_ipq54xx_64 = "sysupgrade-helper sysupgrade"
SYSUPGRADE_ipq54xx = "u-boot-2016-env sysupgrade "

FONTANA_PKG = "omci  omciibc  swacl-if  sw-hook  trex-drv  util-ubus gpon-server"

# IPQ_BASE_PKGS = "button-hotplug ${SYSUPGRADE} datarmnet"
IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools u-boot-fw-utils  mtd mtd-utils mtd-utils-ubifs initoverlay wififw-mount qca-qmi-framework qca-diag diag-router qca-thermald ipq-boot procps watchdog-keepalive mcproxy qcawifi-scripts button-hotplug gpio-button-hotplug modemmanager tcpdump wolfssl i2c-tools ${SYSUPGRADE}"
IPQ_BASE_PKGS:append:dunfell = " libnghttp2 "

# NETWORK_PKGS = "qca-mcs-app open-iw wireless-tools dhcp-server"
NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables mcproxy nat46 ntp qca-mcs-lkm qca-mcs-app"

QCA_NSS_PPE = "qca-nss-ppe qca-nss-ppe-vp qca-nss-ppe-ds qca-nss-ppe-qdisc qca-nss-ppe-l2tp qca-nss-ppe-netlink qca-nss-ppe-rule qca-nss-ppe-client"

QCA_NSS_PPE_TUN = "qca-nss-ppe-tun qca-nss-ppe-tunipip6 qca-nss-ppe-mapt qca-nss-ppe-gretap qca-nss-ppe-vxlanmgr"

NSS_PKGS += "${QCA_NSS_PPE} ${QCA_NSS_PPE_TUN} qca-nss-sfe qca-nss-eip qca-ovsmgr qca-nss-dscpstats qca-nss-userspace-oss qca-nss-libppenl \
	    qca-nss-dp \
	    qca-nss-ecm \
	    "

IPQ95XX_NSS_PKGS += "qca-nss-fw-eip-al"

QCA_NSS_FW = "qca-nss-fw"

QCA_NSS_CLIENTS = "qca-nss-clients"

RFS_PKGS = "qca-rfs"

QCA_EDMA = "qca-edma"

SSDK_NOHNAT_PKGS ="qca-ssdk-nohnat qca-ssdk-shell qca-macsec qca8k"

QCA_PHY_PKGS = "qca-nss-phy"

SSDK_HNAT_PKGS ="qca-ssdk-hnat qca-ssdk-shell"

SHORTCUT_FE = "shortcut-fe simulated-driver"

QCA_ECM = "qca-nss-ecm"

AFC_PKGS = "qca-afc qca-afc-files qti-pairing qti-provisioning qti-mfg-provision qti-encrypt"

WIFI_PKGS = "qca-cfg80211 qca-cfg80211tool qca-wifi qca-cnss qca-hapd-supp qca-hapd-supp-macsec wififw-mount qca-wifi-files wireless-tools hostapd-scripts wpasupplicant-scripts ath6kl-utils qca-ftm athtestcmd myftm wlan-iw qca-cnss-daemon qca-wifi-plugins"

MCS_PKGS = "qca-mcs-lkm"
# "qca-mcs-app" is cnss dependent

WIFI_EZMESH_PKGS = "qca-ezmesh qca-whc-repacd qca-wsplcd qca-hyctl"

#FWA_PKGS = "rmnetctl qdl kickstart"
FWA_PKGS = " "

#TEST_PKGS = "perf stress-ng security-assurance-test ${AFC_PKGS} ${WIFI_EZMESH_PKGS}"
TEST_PKGS = "${FWA_PKGS} iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba ntfs-3g ebtables iperf3 pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lvm2 lua5.1 valgrind openssh ltp i2c-rw-utils lmbench cryptsetup squashfs4 qca-wlanfw-upgrade ${WIFI_EZMESH_PKGS}"

#QYOCTO_TEST_PKGS = "perf stress-ng"
QYOCTO_TEST_PKGS = " dosfstools ntfs-3g iozone3 lrzsz i2c-tools gptfdisk iperf samba tcpdump pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lua5.1 valgrind openssh ltp squashfs4 qca-wlanfw-upgrade "

#UTILS = "perf"
UTILS = "pm-utils file rng-tools ppp ppp-oe rp-pppoe pdt"
