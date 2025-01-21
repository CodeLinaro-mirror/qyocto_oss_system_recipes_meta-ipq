SUMMARY = "A image for the RDK extender yocto build"

inherit rdk-image
IMAGE_FEATURES_remove = "read-only-rootfs"
IMAGE_ROOTFS_SIZE = "8192"

IMAGE_INSTALL += " \
    bridge-utils \
    curl \
    dibbler-client \
    dibbler-server \
    dnsmasq \
    dropbear \
    glib-2.0 \
    gnutls \
    igmpproxy \
    iptables \
    libnl \
    log4c \
    openssl \
    popt \
    zlib \
    libsyswrapper \
    ${@bb.utils.contains("DISTRO_FEATURES", "safec", "safec", "" , d)} \
    rbus \
    ccsp-common-library \
    utopia \
    ccsp-common-startup \
    ccsp-cr \
    ccsp-dmcli \
    ccsp-psm \
    ccsp-tr069-pa \
    sysint-broadband \
    hal-platform \
    hal-vlan \
    hal-wifi \
    breakpad-wrapper \
    rdk-logger \
    rdk-extender \
    ccsp-misc \
"

do_rootfs[nostamp] = "1"

#Workaround to add device.properties
add_device_properties_file() {
    touch ${IMAGE_ROOTFS}/etc/device.properties
}
ROOTFS_POSTPROCESS_COMMAND_append = "add_device_properties_file; "
