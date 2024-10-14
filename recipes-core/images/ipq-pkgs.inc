#List of the packages for IPQ Platform categorized

# UBI image generation support
include recipes-core/images/ipq-images.inc

IMAGE_FEATURES += "package-management"

QYOCTO_PKGS = " libnl dropbear bridge-utils lua5.1 "
SYSUPGRADE_ipq95xx_64 = "sysupgrade-helper sysupgrade"
SYSUPGRADE_ipq95xx = "u-boot-2016-env sysupgrade "

SYSUPGRADE_ipq53xx_64 = "sysupgrade-helper sysupgrade"
SYSUPGRADE_ipq53xx = "u-boot-2016-env sysupgrade "

SYSUPGRADE_ipq807x_64 = "sysupgrade-helper sysupgrade"
SYSUPGRADE_ipq807x = "u-boot-2016-env sysupgrade "

# IPQ_BASE_PKGS = "button-hotplug"
IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools u-boot-fw-utils  mtd mtd-utils mtd-utils-ubifs initoverlay wififw-mount qca-thermald ipq-boot procps watchdog-keepalive mcproxy qcawifi-scripts ${SYSUPGRADE} button-hotplug gpio-button-hotplug datarmnet modemmanager tcpdump libnghttp2 wolfssl"

# NETWORK_PKGS = "qca-mcs-app open-iw wireless-tools"
NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables dhcp-server mcproxy nat46 ntp qca-mcs-lkm"

NSS_PKGS += " \
	    qca-nss-dp \
	    qca-nss-ecm \
	    "

QCA_NSS_PPE = "qca-nss-ppe qca-nss-ppe-vp qca-nss-ppe-ds qca-nss-ppe-qdisc qca-nss-ppe-l2tp qca-nss-ppe-netlink qca-nss-ppe-rule qca-nss-ppe-client"

QCA_NSS_PPE_TUN = "qca-nss-ppe-tun qca-nss-ppe-tunipip6 qca-nss-ppe-mapt qca-nss-ppe-gretap qca-nss-ppe-vxlanmgr"

IPQ95XX_NSS_PKGS += "${QCA_NSS_PPE} ${QCA_NSS_PPE_TUN} qca-nss-sfe qca-nss-eip qca-nss-fw-eip-al qca-ovsmgr qca-nss-dscpstats qca-nss-userspace-oss qca-nss-libppenl"
IPQ53XX_NSS_PKGS += "${QCA_NSS_PPE} ${QCA_NSS_PPE_TUN} qca-nss-sfe qca-nss-eip qca-ovsmgr qca-nss-dscpstats qca-nss-userspace-oss qca-nss-libppenl"
IPQ54XX_NSS_PKGS += "${QCA_NSS_PPE} ${QCA_NSS_PPE_TUN} qca-nss-sfe qca-nss-eip qca-ovsmgr qca-nss-dscpstats qca-nss-userspace-oss qca-nss-libppenl"
IPQ807X_NSS_PKGS += "qca-nss-fw qca-nss-drv strongswan qca-nss-clients qca-nss-fw-eip-hk"

QCA_NSS_FW = "qca-nss-fw"

QCA_NSS_CLIENTS = "qca-nss-clients"

RFS_PKGS = "qca-rfs"

QCA_EDMA = "qca-edma"

SSDK_NOHNAT_PKGS ="qca-ssdk-nohnat qca-ssdk-shell qca-macsec"

SSDK_HNAT_PKGS ="qca-ssdk-hnat qca-ssdk-shell"

SHORTCUT_FE = "shortcut-fe simulated-driver"

QCA_ECM = "qca-nss-ecm"

AFC_PKGS = "qca-afc qca-afc-files qti-pairing qti-provisioning qti-mfg-provision qti-encrypt"

WIFI_PKGS = "qca-cfg80211 qca-cfg80211tool qca-wifi qca-cnss qca-hapd-supp qca-hapd-supp-macsec wififw-mount qca-wifi-files wireless-tools hostapd-scripts wpasupplicant-scripts ath6kl-utils athtestcmd myftm iw"

MCS_PKGS = "qca-mcs-lkm"
# "qca-mcs-app" is cnss dependent

WIFI_EZMESH_PKGS = "qca-ezmesh qca-whc-repacd qca-wsplcd qca-hyctl"

FWA_PKGS = "qca-diag rmnetctl qdl kickstart"

TEST_PKGS = "${FWA_PKGS} iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba ntfs-3g perf stress-ng ebtables iperf3 pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lvm2 lua5.1 valgrind openssh ltp i2c-rw-utils  security-assurance-test lmbench cryptsetup squashfs4 qca-wlanfw-upgrade ${AFC_PKGS} ${WIFI_EZMESH_PKGS} "


QYOCTO_TEST_PKGS = " dosfstools ntfs-3g iozone3 lrzsz i2c-tools gptfdisk iperf samba tcpdump perf stress-ng pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lua5.1 valgrind openssh ltp squashfs4 qca-wlanfw-upgrade "

UTILS = "perf pm-utils file rng-tools ppp ppp-oe rp-pppoe pdt"
