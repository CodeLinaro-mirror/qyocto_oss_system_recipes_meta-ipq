DEPENDS:remove = "openssl"
DEPENDS:append += " libssl-1.0.2n-native "

do_configure:append() {
	mkdir -p ${S}/include/config;
	touch ${S}/include/config/auto.conf;
	mkdir -p ${S}/include/generated
	echo "#define  CONFIG_FIT_PRINT 1" >> ${S}/include/generated/autoconf.h
	echo "#define  CONFIG_TOOLS_CRC32 1" >> ${S}/include/generated/autoconf.h
	echo "#define  CONFIG_TOOLS_SHA1 1" >> ${S}/include/generated/autoconf.h
	echo "#define  CONFIG_TOOLS_FIT 1" >> ${S}/include/generated/autoconf.h
	echo "#define  CONFIG_TOOLS_FIT_PRINT 1" >> ${S}/include/generated/autoconf.h
	echo "#define  CONFIG_TOOLS_FIT_RSASSA_PSS 1" >> ${S}/include/generated/autoconf.h
	echo "#define  CONFIG_TOOLS_FIT_SIGNATURE_MAX_SIZE 0xffffffff" >> ${S}/include/generated/autoconf.h
	touch ${S}/include/generated/autoconf.h
}

export  HOST_EXTRACFLAGS+=" -I${STAGING_INCDIR_NATIVE}/libressl-3.7.2/ "
do_compile() {
	cd ${B}
	make -C ${S} \
	HOSTCC="gcc" \
	HOSTLDLIBS_mkimage="-static ${STAGING_INCDIR_NATIVE}/libressl-3.7.2/libssl.a  ${STAGING_INCDIR_NATIVE}/libressl-3.7.2/libcrypto.a  -ldl -lpthread " \
	HOSTLOADLIBES_mkimage="-static ${STAGING_INCDIR_NATIVE}/libressl-3.7.2/libssl.a  ${STAGING_INCDIR_NATIVE}/libressl-3.7.2/libcrypto.a  -ldl -lpthread " \
	no-dot-config-targets=tools-only \
	CONFIG_MKIMAGE_DTC_PATH=dtc \
	CONFIG_FIT=y \
	CONFIG_FIT_SIGNATURE=y \
	CONFIG_FIT_SIGNATURE_MAX_SIZE=0x10000000 \
	CONFIG_CMD_CRC32=y \
	CONFIG_FIT_PRINT=y \
	CONFIG_TOOLS_FIT=y \
	CONFIG_TOOLS_FIT_PRINT=y \
	CONFIG_TOOLS_LIBCRYPTO=y \
	CONFIG_CMD_CRC32=y \
	tools-only O=${B}
}

do_install:append() {
	mkdir -p ${DEPLOY_DIR_IMAGE}
	install -m 0755 tools/mkimage ${DEPLOY_DIR_IMAGE}/
}
