DESCRIPTION = "Congo fig_v2 companion hostap tools — wpa_supplicant_fig / wpa_cli_fig / hostapd_fig / hostapd_cli_fig"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://COPYING;md5=5ebcb90236d1ad640558c3d3cd3035df"

# Upstream hostap on w1.fi. Pin to the HEAD verified during Congo STA bring-up.
# https://git.w1.fi/hostap.git/
SRC_URI = "git://w1.fi/hostap.git;protocol=https;branch=main;name=hostap;destsuffix=hostap \
    file://wpa-supplicant-fig.service \
    file://wpa-supplicant-fig-post.sh \
    file://udhcpc-wlan0.service \
    file://wpa_cli_fig.action \
    file://wpa_supplicant_fig.conf \
"
SRCREV_hostap = "890d573a18647feb71b08031a2bda41682ed3c6e"
SRCREV_FORMAT = "hostap"
PV = "2.11+git"

S = "${WORKDIR}/hostap"

DEPENDS = "libnl openssl"

inherit systemd

# hostap tree ships wpa_supplicant/android.config + hostapd/android.config as
# the vendor "start here" template. Derive .config from that template by
# uncommenting the keys required for Congo (per the internal build guide),
# switching libnl20 -> libnl32, and appending the keys the template does not
# carry. Keeps the recipe self-contained — no static .config in files/.
HOSTAP_WPAS_ENABLE = " \
    CONFIG_DRIVER_WEXT CONFIG_DRIVER_NL80211 CONFIG_OCV CONFIG_DEBUG_FILE \
    CONFIG_IEEE80211AC CONFIG_MBO CONFIG_FILS CONFIG_PMKSA_CACHE_EXTERNAL \
    CONFIG_MESH CONFIG_OWE CONFIG_USIM_SIMULATOR"
HOSTAP_WPAS_APPEND = " \
    CONFIG_LIBNL32 CONFIG_IEEE80211AX CONFIG_IEEE80211W CONFIG_IEEE80211N \
    CONFIG_IEEE80211BE CONFIG_TESTING_OPTIONS CONFIG_EAP_TLSV1_3 \
    CONFIG_SIM_SIMULATOR CONFIG_SAE_PK CONFIG_DPP CONFIG_SUITEB \
    CONFIG_SUITEB192 CONFIG_SAE CONFIG_DPP2"

HOSTAPD_ENABLE = "CONFIG_DRIVER_NL80211 CONFIG_FST CONFIG_MBO CONFIG_OWE CONFIG_OCV"
HOSTAPD_APPEND = " \
    CONFIG_LIBNL32 CONFIG_TESTING_OPTIONS CONFIG_IEEE80211AC \
    CONFIG_IEEE80211AX CONFIG_IEEE80211BE CONFIG_DPP2 CONFIG_ACS \
    CONFIG_SAE CONFIG_DPP"

hostap_render_config() {
    # $1 = source android.config, $2 = dest .config,
    # $3 = space-sep list of keys to uncomment (must already be commented),
    # $4 = space-sep list of keys to append (not in template).
    install -m 0644 "$1" "$2"

    # Comment out CONFIG_LIBNL20=y — template has it as active; we replace
    # with LIBNL32 via the append list. If LIBNL20 gets left active, hostap
    # Makefile picks up the v2.0 API and won't link against libnl-3.
    sed -i 's|^CONFIG_LIBNL20=y|#CONFIG_LIBNL20=y|' "$2"

    # Drop the Android-only include hook — we don't ship android_config_*.inc
    # and the Makefile-side wildcard just no-ops, but the doc explicitly
    # comments it out so mirror that.
    sed -i 's|^include \$(wildcard \$(LOCAL_PATH)/android_config_\*\.inc)|#&|' "$2"

    for key in $3; do
        # Turn "#CONFIG_FOO=y" into "CONFIG_FOO=y". Only touch commented lines
        # to stay idempotent under sstate reuse.
        sed -i "s|^#${key}=y$|${key}=y|" "$2"
    done

    {
        echo ""
        echo "# Congo bring-up: keys not present in vendor android.config"
        for key in $4; do echo "${key}=y"; done
        echo ""
        echo "# Yocto: pick up libnl-3 headers from sysroot"
        echo "CFLAGS += -I${STAGING_INCDIR}/libnl3"
        echo "LIBS += -lnl-3 -lnl-genl-3"
        echo "LIBS_p += -lnl-3 -lnl-genl-3"
        echo "LIBS_h += -lnl-3 -lnl-genl-3"
    } >> "$2"
}

do_configure() {
    hostap_render_config \
        ${S}/wpa_supplicant/android.config ${S}/wpa_supplicant/.config \
        "${HOSTAP_WPAS_ENABLE}" "${HOSTAP_WPAS_APPEND}"
    hostap_render_config \
        ${S}/hostapd/android.config ${S}/hostapd/.config \
        "${HOSTAPD_ENABLE}" "${HOSTAPD_APPEND}"
}

EXTRA_OEMAKE = "V=1"

do_compile() {
    oe_runmake -C ${S}/wpa_supplicant clean
    oe_runmake -C ${S}/wpa_supplicant wpa_supplicant wpa_cli
    oe_runmake -C ${S}/hostapd clean
    oe_runmake -C ${S}/hostapd hostapd hostapd_cli
}

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${S}/wpa_supplicant/wpa_supplicant ${D}${sbindir}/wpa_supplicant_fig
    install -m 0755 ${S}/wpa_supplicant/wpa_cli        ${D}${sbindir}/wpa_cli_fig
    install -m 0755 ${S}/hostapd/hostapd               ${D}${sbindir}/hostapd_fig
    install -m 0755 ${S}/hostapd/hostapd_cli           ${D}${sbindir}/hostapd_cli_fig

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/wpa-supplicant-fig.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/udhcpc-wlan0.service       ${D}${systemd_unitdir}/system
    install -m 0755 ${WORKDIR}/wpa-supplicant-fig-post.sh ${D}${sbindir}/wpa-supplicant-fig-post.sh

    # Enable services at image build time to avoid postinst failures in fakeroot.
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -sf /lib/systemd/system/wpa-supplicant-fig.service \
        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa-supplicant-fig.service
    ln -sf /lib/systemd/system/udhcpc-wlan0.service \
        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/udhcpc-wlan0.service

    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/wpa_supplicant_fig.conf    ${D}${sysconfdir}/wpa_supplicant_fig.conf
    install -m 0755 ${WORKDIR}/wpa_cli_fig.action         ${D}${sysconfdir}/wpa_cli_fig.action
}

FILES:${PN} = "${sbindir}/wpa_supplicant_fig ${sbindir}/wpa_cli_fig ${sbindir}/hostapd_fig ${sbindir}/hostapd_cli_fig \
    ${sbindir}/wpa-supplicant-fig-post.sh \
    ${systemd_unitdir}/system/wpa-supplicant-fig.service \
    ${systemd_unitdir}/system/udhcpc-wlan0.service \
    ${sysconfdir}/wpa_supplicant_fig.conf \
    ${sysconfdir}/wpa_cli_fig.action \
    ${sysconfdir}/systemd/system/multi-user.target.wants/wpa-supplicant-fig.service \
    ${sysconfdir}/systemd/system/multi-user.target.wants/udhcpc-wlan0.service \
"
RDEPENDS:${PN} = "libnl openssl"

INHIBIT_PACKAGE_STRIP = "1"

SYSTEMD_SERVICE:${PN} = "wpa-supplicant-fig.service udhcpc-wlan0.service"
SYSTEMD_AUTO_ENABLE = "disable"
