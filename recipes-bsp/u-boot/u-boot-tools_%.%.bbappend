DEPENDS_remove = "openssl"
DEPENDS_append += " libssl-1.0.2n-native "

do_configure_append() {
	mkdir -p ${S}/include/config;
	touch ${S}/include/config/auto.conf;
	mkdir -p ${S}/include/generated
	touch ${S}/include/generated/autoconf.h
}

EXTRA_OEMAKE_class-native += 'HOSTLOADLIBES_mkimage="-static ${STAGING_INCDIR_NATIVE}/libssl-1.0.2n/libssl.a  ${STAGING_INCDIR_NATIVE}/libssl-1.0.2n/libcrypto.a -ldl -lpthread " '
EXTRA_OEMAKE_class-target += 'HOSTLOADLIBES_mkimage="-static ${STAGING_INCDIR_NATIVE}/libssl-1.0.2n/libssl.a  ${STAGING_INCDIR_NATIVE}/libssl-1.0.2n/libcrypto.a -ldl -lpthread " '

export  HOST_EXTRACFLAGS+=" -I${STAGING_INCDIR_NATIVE}/libssl-1.0.2n/ "

do_compile() {
       cd ${B}
       oe_runmake -C ${S} \
       HOSTCC="gcc  " \
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

BBCLASSEXTEND += " native "
