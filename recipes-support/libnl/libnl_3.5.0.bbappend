
do_install:append() {
	cp -fR ${AUTOTOOLS_AUXDIR}/include/netlink-private ${D}${includedir}/
	cp -fR ${AUTOTOOLS_AUXDIR}/include/linux-private ${D}${includedir}/
}
