#List of the packages for IPQ Platform categorized

# UBI image generation support
include recipes-core/images/ipq-images.inc

IMAGE_FEATURES += "package-management"

QYOCTO_PKGS = "uci libnl dropbear bridge-utils lua"

# IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools u-boot-fw-utils mtd initoverlay procps watchdog button-hotplug mcproxy"
IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools mtd initoverlay wififw-mount qca-qmi-framework qca-qmi-framework-qrtr qca-time-services qca-diag ipq-boot procps watchdog mcproxy"

# NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables iputils dhcp-server wireless-tools mcproxy qca-mcs-lkm qca-mcs-app"
NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables iputils dhcp-server mcproxy nat46"

NSS_PKGS += " \
	    qca-nss-dp \
	    qca-nss-ecm \
	    "

IPQ95XX_NSS_PKGS += "qca-nss-ppe qca-nss-sfe"

QCA_NSS_FW = "qca-nss-fw"

QCA_NSS_CLIENTS = "qca-nss-clients"

RFS_PKGS = "qca-rfs"

QCA_EDMA = "qca-edma"

SSDK_NOHNAT_PKGS ="qca-ssdk-nohnat qca-ssdk-shell"

SSDK_HNAT_PKGS ="qca-ssdk-hnat qca-ssdk-shell"

SHORTCUT_FE = "shortcut-fe simulated-driver"

QCA_ECM = "qca-nss-ecm"

WIFI_PKGS = "qca-hostapd  qca-wpasupplicant qca-cfg80211 qca-cfg80211tool qca-wifi qca-cnss wififw-mount qca-wifi-files iw wireless-tools hostapd-scripts wpasupplicant-scripts"

MCS_PKGS = "qca-mcs-lkm"

# TEST_PKGS = "iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba tcpdump ntfs-3g perf"
TEST_PKGS = "iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba  perf"

UTILS = "perf pm-utils file rng-tools"
# UTILS = "perf pm-utils file rng-tools ppp ppp-oe"
