#List of the packages for IPQ Platform categorized

# UBI image generation support
include recipes-core/images/ipq-images.inc

IMAGE_FEATURES += "package-management"

QYOCTO_PKGS = "uci libnl dropbear bridge-utils lua"

# IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools u-boot-fw-utils mtd initoverlay procps watchdog button-hotplug mcproxy"
IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools  mtd initoverlay procps watchdog mcproxy"

# NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables iputils dhcp-server wireless-tools mcproxy qca-mcs-lkm qca-mcs-app"
NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables iputils dhcp-server mcproxy "

NSS_PKGS = " \
	    qca-nss-dp \
	    qca-nss-drv \
	    qca-nss-fw \
	    qca-nss-clients \
	    "

QCA_NSS_FW = "qca-nss-fw"

QCA_NSS_CLIENTS = "qca-nss-clients"

RFS_PKGS = "qca-rfs"

QCA_EDMA = "qca-edma"

SSDK_NOHNAT_PKGS ="qca-ssdk-nohnat qca-ssdk-shell"

SSDK_HNAT_PKGS ="qca-ssdk-hnat qca-ssdk-shell"

SHORTCUT_FE = "shortcut-fe simulated-driver"

QCA_ECM = "qca-nss-ecm"

WIFI_PKGS = "qca-hostapd qca-wpasupplicant qca-wififw qca-cfg80211 qca-wifi qca-wifi-tools qca-qcmbr iw"

MCS_PKGS = "qca-mcs-lkm qca-mcs-app"

# TEST_PKGS = "iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba tcpdump ntfs-3g perf"
TEST_PKGS = "iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba  perf"

UTILS = "perf pm-utils file rng-tools ppp ppp-oe"
