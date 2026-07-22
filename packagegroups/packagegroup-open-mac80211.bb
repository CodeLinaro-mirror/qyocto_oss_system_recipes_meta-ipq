SUMMARY = "Basic programs and scripts required by LE system"
DESCRIPTION = "Package group to bring in all basic packages for LE system"
LICENSE = "BSD-3-Clause"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
	open-mac80211 \
	wififw-mount \
	initoverlay \
	ipq-boot \
	qca-athdiag \
	qca-cfg80211 \
	qca-cfg80211tool \
	qca-cnssdiag \
	qca-udtool \
	common-headers \
	qca-diag \
	"
RDEPENDS:${PN}:append:echo = " qca-wifi-nss-plugins"
