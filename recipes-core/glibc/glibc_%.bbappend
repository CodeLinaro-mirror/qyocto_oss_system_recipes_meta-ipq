# Add strlcat and strlcpy patches

FILESEXTRAPATHS_append := "${THISDIR}/files:"
SRC_URI += "file://0027-Support-for-strlcat-strlcpy-for-glibc.patch"
