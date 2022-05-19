
do_configure_append() {
	mkdir -p ${S}/include/config;
	touch ${S}/include/config/auto.conf;
	mkdir -p ${S}/include/generated
	touch ${S}/include/generated/autoconf.h
}

do_compile() {
	cd ${B}
	make -C ${S} \
	HOSTCC="gcc" \
	HOSTLOADLIBES_mkimage="-static -lssl -lcrypto -ldl" \
	no-dot-config-targets=tools-only \
	CONFIG_MKIMAGE_DTC_PATH=dtc \
	CONFIG_FIT=y \
	CONFIG_FIT_SIGNATURE=y \
	CONFIG_FIT_SIGNATURE_MAX_SIZE=0x10000000 \
	tools-only O=${B}
}

do_install_append() {
	mkdir -p ${DEPLOY_DIR_IMAGE}
	install -m 0755 tools/mkimage ${DEPLOY_DIR_IMAGE}/
}	
