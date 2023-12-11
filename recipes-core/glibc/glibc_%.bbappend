# Add strlcat and strlcpy patches

CFLAGS:append = " -Wno-error=maybe-uninitialized -Wno-error=format-overflow "

FILESEXTRAPATHS:append := "${THISDIR}/files:"
SRC_URI += "file://0027-Support-for-strlcat-strlcpy-for-glibc.patch"
