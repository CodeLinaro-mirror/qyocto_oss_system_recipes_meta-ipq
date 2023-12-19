
SRC_URI += "file://fragment.cfg;subdir=busybox-1.31.1 \
            file://lock.c;subdir=busybox-1.31.1/miscutils \
            file://telnet.init \
            "

do_install:append() {
	install -d ${D}/etc/init.d/
	install -m 0755 ${WORKDIR}/telnet.init ${D}/etc/init.d/telnet
}

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
