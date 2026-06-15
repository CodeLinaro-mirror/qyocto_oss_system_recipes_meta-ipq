DESCRIPTION = "UIO debug driver providing per-subsystem shared-memory debug channels"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=f3b90e78ea0cffb20bf5cca7947a896d"

inherit module

CLEANBROKEN = "1"

FILESPATH = "${TOPDIR}/../opensource/:"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://qca-debug-uio"

PACKAGES += "kernel-module-qca-debug-uio"

DEPENDS = "virtual/kernel"

S = "${WORKDIR}/qca-debug-uio/"

EXTRA_CFLAGS += " \
		-Werror \
		-Wall \
		-fno-stack-protector \
		-I${S} \
		-I${S}/exports \
		-DDEBUG_LEVEL=3 \
		"

do_configure() {
	true
}

do_compile() {
	unset LDFLAGS
	make -C "${STAGING_KERNEL_BUILDDIR}" \
	CROSS_COMPILE="${TARGET_PREFIX}" \
	ARCH="${KARCH}" \
	M="${S}" \
	EXTRA_CFLAGS="${EXTRA_CFLAGS}" \
	modules
}

do_install() {
	install -d ${D}${base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/${PN}
	install -m 0644 ${S}/debug_uio${KERNEL_OBJECT_SUFFIX} ${D}${base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/${PN}
	install -d ${D}${includedir}/qca-debug-uio
	install -m 0644 ${S}/exports/debug_uio_public.h ${D}${includedir}/qca-debug-uio/
	install -m 0644 ${S}/Module.symvers ${D}${includedir}/qca-debug-uio/Module.symvers
}

KERNEL_MODULE_AUTOLOAD += "debug_uio"

