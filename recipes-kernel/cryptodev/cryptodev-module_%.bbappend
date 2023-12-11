FILESEXTRAPATHS:append := "${THISDIR}/files:"

EXTRA_OEMAKE += '\
    EXTRA_CFLAGS=" -Wno-error=vla  " \
'
