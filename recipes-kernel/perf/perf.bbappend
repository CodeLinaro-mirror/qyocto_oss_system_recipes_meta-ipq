

RDEPENDS:${PN}:remove = "elfutils"
# DEPENDS_${PN}_append = "elfutils"
DEPENDS:append = " elfutils "

EXTRA_OEMAKE = '\
    -C ${S}/tools/perf \
    O=${B} \
    CROSS_COMPILE=${TARGET_PREFIX} \
    ARCH=${ARCH} \
    CC="${CC}" \
    AR="${AR}" \
    LD="${LD}" \
    EXTRA_CFLAGS="-Wno-error=format -lpthread  -D__UCLIBC__" \
    perfexecdir=${libexecdir} \
    JOBS=1 NO_GTK2=1 ${TUI_DEFINES} NO_DWARF=1 NO_LIBUNWIND=1 NO_LIBDW_DWARF_UNWIND=1 ${LIBUNWIND_DEFINES} \
    NO_NEWT=1 NO_LZMA=1 NO_BACKTRACE=1 NO_LIBNUMA=1 NO_LIBAUDIT=1 NO_LIBCRYPTO=1 NO_LIBCAP=1 NO_LIBPERL=1 \
    WERROR=0 \
    prefix=/usr \
'

EXTRA_OEMAKE += "\
    'DESTDIR=${D}' \
    'prefix=${prefix}' \
    'bindir=${bindir}' \
    'sharedir=${datadir}' \
    'sysconfdir=${sysconfdir}' \
    'perfexecdir=${libexecdir}/perf-core' \
    'ETC_PERFCONFIG=${@os.path.relpath(sysconfdir, prefix)}' \
    'sharedir=${@os.path.relpath(datadir, prefix)}' \
    'mandir=${@os.path.relpath(mandir, prefix)}' \
    'infodir=${@os.path.relpath(infodir, prefix)}' \
"
