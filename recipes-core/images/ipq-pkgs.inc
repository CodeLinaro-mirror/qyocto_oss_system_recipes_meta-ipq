#List of the packages for IPQ Platform categorized

# UBI image generation support
include recipes-core/images/ipq-images.inc

IMAGE_FEATURES += "package-management"

QYOCTO_PKGS = " libnl dropbear bridge-utils lua5.1 "

# IPQ_BASE_PKGS = "button-hotplug"
IPQ_BASE_PKGS = "sysstat strace e2fsprogs kexec-tools u-boot-fw-utils  mtd mtd-utils mtd-utils-ubifs initoverlay wififw-mount qca-thermald qca-qmi-framework qca-diag ipq-boot procps watchdog mcproxy qca-time-services "

# NETWORK_PKGS = "qca-mcs-lkm qca-mcs-app"
NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables iputils iputils-tracepath iputils-traceroute6 iproute2  iw dhcp-server wireless-tools mcproxy nat46 "

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

MCS_PKGS = "qca-mcs-lkm qca-mcs-app"

FWA_PKGS = "ipqcm-server ipqcm-client qmuxd dsutils qca-diag qmi-services qmi qmi-core qmi-client-helper qmi-client-qmux rmnetctl configdb xmllib  qnicorn netmgr udev-scripts libevdev udev qdi datarmnet"

TEST_PKGS = "${FWA_PKGS} iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba tcpdump ntfs-3g perf stress-ng ebtables iperf3 pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lvm2 lua5.1 valgrind openssh ltp"

UTILS = "perf pm-utils file rng-tools ppp ppp-oe rp-pppoe"
