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
IPQ_BASE_PKGS = "sysstat u-boot-fw-utils  mtd mtd-utils initoverlay wififw-mount qca-qmi-framework qca-diag diag-router qca-thermald ipq-boot procps watchdog-keepalive mcproxy qcawifi-scripts button-hotplug gpio-button-hotplug wolfssl i2c-tools ${SYSUPGRADE} e2fsprogs e2fsprogs-mke2fs e2fsprogs-e2fsck jsonfilter"
IPQ_BASE_PKGS:append:dunfell = " libnghttp2 "

# NETWORK_PKGS = "qca-mcs-app open-iw wireless-tools dhcp-server"
NETWORK_PKGS = "ethtool iproute2 iproute2-tc iptables mcproxy nat46 ntp qca-mcs-lkm qca-mcs-app qca-nss-netfn-tcpst libnl-tcpst nss-tcp-st-cli linuxptp"

QCA_NSS_PPE = "qca-nss-ppe qca-nss-ppe-vp qca-nss-ppe-ds qca-nss-ppe-qdisc qca-nss-ppe-l2tp qca-nss-ppe-netlink qca-nss-ppe-rule qca-nss-ppe-client"

QCA_NSS_PPE_TUN = "qca-nss-ppe-tun qca-nss-ppe-tunipip6 qca-nss-ppe-mapt qca-nss-ppe-gretap qca-nss-ppe-vxlanmgr"

QCA_NSS_SAP = "qca-nsm-app qca-nsm-lib qca-sal-qos qca-sal-qos-test qca-sal-rule qca-sal-rule-test"

NSS_PKGS += "${QCA_NSS_PPE} ${QCA_NSS_PPE_TUN} qca-nss-sfe qca-nss-eip qca-ovsmgr qca-nss-dscpstats qca-nss-userspace-oss qca-nss-libppenl qca-nss-flowmgr qca-nss-dp qca-nss-ecm ${QCA_NSS_SAP} udp-clf qca-nss-nsm qca-nss-fls "

IPQ95XX_NSS_PKGS += "qca-nss-fw-eip-al"

QCA_NSS_FW = "qca-nss-fw"

QCA_NSS_CLIENTS = "qca-nss-clients"

RFS_PKGS = "qca-rfs"

QCA_EDMA = "qca-edma"

SSDK_NOHNAT_PKGS ="qca-ssdk-nohnat qca-ssdk-shell qca-macsec qca8k"

QCA_PHY_PKGS = "qca-nss-phy aqr-phy"

SSDK_HNAT_PKGS ="qca-ssdk-hnat qca-ssdk-shell"

SHORTCUT_FE = "shortcut-fe simulated-driver"

QCA_ECM = "qca-nss-ecm"

AFC_PKGS = "qca-afc qca-afc-daemon qca-afc-files qti-pairing qti-provisioning qti-mfg-provision qti-encrypt qti-wifi-location"

WIFI_PKGS = "qca-cfg80211 qca-cfg80211tool qca-wifi qca-cnss qca-hapd-supp qca-hapd-supp-macsec wififw-mount qca-wifi-files wireless-tools hostapd-scripts wpasupplicant-scripts ath6kl-utils qca-ftm athtestcmd myftm wlan-iw qca-cnss-daemon qca-wifi-plugins qca-athdiag qca-icm qca-athssd qca-rsrcmgr"

MCS_PKGS = "qca-mcs-lkm"
# "qca-mcs-app" is cnss dependent

WIFI_EZMESH_PKGS = "qca-ezmesh qca-whc-repacd qca-wsplcd qca-hyctl"

#FWA_PKGS = "rmnetctl qdl kickstart"
FWA_PKGS = " "

AI_WASM_PKG = "wasm-container-interfaces wasm-container-apis fd"
AI_PKG = "${AI_WASM_PKG} snpe winai-sdk winai-sample-app"

GWAPPS_PKG = "unzip nghttp2 mosquitto libwebsockets wasm-micro-runtime ca-certificates package-manager-agent"

#LICENSING_PKG = "softsku-qwin-agent softsku-sdk"

TEST_PKGS = "${FWA_PKGS} ${AFC_PKGS} ${AI_PKG} ${GWAPPS_PKG} iozone3 dosfstools lrzsz i2c-tools gptfdisk iperf samba ntfs-3g ebtables iperf3 pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lvm2 lua5.1 valgrind openssh i2c-rw-utils security-assurance-test lmbench cryptsetup squashfs4 qca-wlanfw-upgrade ${WIFI_EZMESH_PKGS} strace kexec-tools file rng-tools modemmanager tcpdump perf gpsd gpsclient ifli"

#QYOCTO_TEST_PKGS = "perf stress-ng"
QYOCTO_TEST_PKGS = " dosfstools ntfs-3g iozone3 lrzsz i2c-tools gptfdisk iperf samba tcpdump pciutils minicom util-linux gpio-debug clk-debug shadow coreutils lua5.1 valgrind openssh ltp squashfs4 qca-wlanfw-upgrade "

#UTILS = "perf"
UTILS = "pm-utils ppp ppp-oe rp-pppoe pdt"
