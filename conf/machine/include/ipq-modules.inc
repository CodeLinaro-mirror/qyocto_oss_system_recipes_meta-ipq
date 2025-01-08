

KERNEL_MODULE_AUTOLOAD += "dwc3"
module_autoload_dwc3 = "usbcore usb-common dwc3 phy-qca-baldur phy-qca-uniphy dwc3-ipq40xx dwc3-qcom phy-qcom-qusb2 "

KERNEL_MODULE_AUTOLOAD += "usb-storage"
module_autoload_usb-storage = "usb-storage sd_mod scsi_mod"

KERNEL_MODULE_AUTOLOAD += "phy-qcom-m31"
module_autoload_phy-qcom-m31 = "phy-qcom-m31"

KERNEL_MODULE_AUTOLOAD += "fat"
module_autoload_fat = "fat vfat msdos nls_base nls_cp437 nls_iso8859-1"

KERNEL_MODULE_AUTOLOAD += "ehci-hcd"
module_autoload_ehci-hcd = "ehci-hcd ehci-platform"

KERNEL_MODULE_AUTOLOAD += "xhci-hcd"
module_autoload_xhci-hcd = "xhci-hcd"

KERNEL_MODULE_AUTOLOAD += "xhci-pci"
module_autoload_xhci-pci = "xhci-pci"

KERNEL_MODULE_AUTOLOAD += "xhci-plat-hcd"
module_autoload_xhci-plat-hcd = "xhci-plat-hcd"

KERNEL_MODULE_AUTOLOAD += "leds-gpio"
module_autoload_leds-gpio = "leds-gpio"

KERNEL_MODULE_AUTOLOAD += "cfg80211"
module_autoload_cfg80211 = "cfg80211"

KERNEL_MODULE_AUTOLOAD += "phy-qca-m31"
module_autoload_phy-qca-m31 = "phy-qca-m31"

# net/netfilter kernel loadable modules
KERNEL_MODULE_AUTOLOAD += "ip_tables iptable_filter iptable_mangle iptable_raw xt_nat nf_log_ipv4"
KERNEL_MODULE_AUTOLOAD += "bootconfig libcomposite uas usb_f_diag g_diag  diagchar"

KERNEL_MODULE_AUTOLOAD += "nf_conntrack"
module_autoload_nf_conntrack += "nf_conntrack nf_conntrack_tftp nf_conntrack_amanda nf_conntrack_broadcast \
			nf_conntrack_ftp nf_conntrack_h323 nf_conntrack_irc nf_conntrack_netlink \
			nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_sip nf_conntrack_snmp \
			nf_conntrack_tftp nf_nat_amanda nf_nat_ftp nf_nat_irc \
			nf_nat_proto_sctp nf_nat_sip nf_nat_tftp x_tables xt_CT xt_CLASSIFY xt_DSCP xt_ecn xt_HL \
			xt_mac xt_pkttype xt_tcpmss xt_comment xt_esp  xt_quota xt_TCPMSS xt_connbytes \
			xt_helper xt_mark xt_policy xt_recent xt_tcpudp xt_connlimit xt_hl xt_multiport \
			xt_REDIRECT xt_time xt_connmark xt_length xt_nat xt_state xt_conntrack \
			xt_limit xt_owner xt_statistic xt_addrtype xt_dscp xt_DSCP xt_LOG xt_physdev xt_string"


# net/ipv4/netfilter kernel loadable modules
KERNEL_MODULE_AUTOLOAD += "nf_conntrack_ipv4"
module_autoload_nf_conntrack_ipv4 += "nf_conntrack_ipv4 nf_defrag_ipv4"

KERNEL_MODULE_AUTOLOAD += "nf_nat_redirect"
module_autoload_nf_nat_redirect += "nf_nat_redirect nf_nat_ipv4 nf_nat_snmp_basic nf_nat_pptp nf_nat_h323 nf_nat_proto_gre arp_tables \
			   arpt_mangle arptable_filter iptable_filter iptable_mangle iptable_nat \
			   iptable_raw ipt_ah ipt_ECN ipt_MASQUERADE ipt_REJECT"

# net/ipv6/netfilter kernel loadable modules
KERNEL_MODULE_AUTOLOAD += "nf_conntrack_ipv6"
module_autoload_nf_conntrack_ipv6 += "nf_conntrack_ipv6 nf_defrag_ipv6"

KERNEL_MODULE_AUTOLOAD += "ip6_tables ip6table_filter ip6table_mangle ip6table_raw ip6t_REJECT nf_log_ipv6"

# ppp kernel loadable modules
KERNEL_MODULE_AUTOLOAD += "pppoe"
module_autoload_pppoe += "gre crc-ccitt ppp_async ppp_generic pppox pppoe pptp l2tp_ppp"
