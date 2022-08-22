DESCRIPTION = "Linux kernel for IPQ platforms"
SECTION = "kernel"
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

inherit kernel

# Put a local version until we have a true SRCREV to point to
LOCALVERSION ?= "+yocto"
SCMVERSION ?= "n"

SRC_URI += "file://fit"

INITRAMFS_IMAGE = ""
INITRAMFS_IMAGE_BUNDLE = "1"
KERNEL_INITRAMFS ?= '${@oe.utils.conditional("INITRAMFS_IMAGE_BUNDLE", "1", "1", "", d)}'

KCONFIG_MODE = "--alldefconfig"
KERNEL_MODULE_AUTOLOAD += "${MACHINE_FEATURES}"

# Set a variable in .configure
# $1 - Configure variable to be set
# $2 - value [n/y/value]
kernel_conf_variable() {
	CONF_SED_SCRIPT="$CONF_SED_SCRIPT /CONFIG_$1[ =]/d;"
	if test "$2" = "n"
	then
		echo "# CONFIG_$1 is not set" >> ${B}/.config
	else
		echo "CONFIG_$1=$2" >> ${B}/.config
	fi
}

# returns all the elements from the src uri that are .cfg files
def find_cfgs(d):
    sources=src_patches(d, True)
    sources_list=[]
    for s in sources:
        if s.endswith('.cfg'):
            sources_list.append(s)

    return sources_list

copy_kernel_config() {
	CONFIG_NAME="${@d.getVar('SOC_FAMILY', True).split(':')[1]}"
    cat ${B}/../${CONFIG_NAME}-default >> ${WORKDIR}/defconfig || die "No default configuration for ${MACHINE}/${KERNEL_DEFCONFIG} available."
	if [ "${DEBUG_KASAN_PROFILE}" = "true" ]; then
		cat ${B}/../ipq_debug_kasan >> ${WORKDIR}/defconfig || die "No default configuration for ${MACHINE}/${KERNEL_DEFCONFIG} available."
	fi
}

do_configure_prepend() {
	# cleanup existing .config
	echo "" > ${B}/.config
	CONF_SED_SCRIPT=""

	copy_kernel_config
	kernel_conf_variable LOCALVERSION "\"${LOCALVERSION}\""
	kernel_conf_variable LOCALVERSION_AUTO y
	if [ ! -z "${KERNEL_INITRAMFS}" ]; then
		kernel_conf_variable BLK_DEV_INITRD y
		kernel_conf_variable INITRAMFS_SOURCE ""
		kernel_conf_variable RD_GZIP y
		kernel_conf_variable OVERLAY_FS y
		kernel_conf_variable SQUASHFS y
		kernel_conf_variable UBIFS_FS y
        fi

	sed -e "${CONF_SED_SCRIPT}" < '${WORKDIR}/defconfig' >> '${B}/.config'

	KERNEL_CONFIG_FRAGMENTS="${@" ".join(find_cfgs(d))}"
	if [ "${SCMVERSION}" = "y" ]; then
		# Add GIT revision to the local version
		head=`git --git-dir=${S}/.git  rev-parse --verify --short HEAD 2> /dev/null`
		printf "%s%s" +g $head > ${B}/.scmversion
	fi

    # Check for kernel config fragments.  The assumption is that the config
    # fragment will be specified with the absolute path.  For example:
    #   * ${WORKDIR}/config1.cfg
    #   * ${S}/config2.cfg
    # Iterate through the list of configs and make sure that you can find
    # each one.  If not then error out.
    # NOTE: If you want to override a configuration that is kept in the kernel
    #       with one from the OE meta data then you should make sure that the
    #       OE meta data version (i.e. ${WORKDIR}/config1.cfg) is listed
    #       after the in kernel configuration fragment.
    # Check if any config fragments are specified.
    if [ ! -z "${KERNEL_CONFIG_FRAGMENTS}" ]
    then
        for f in ${KERNEL_CONFIG_FRAGMENTS}
        do
            # Check if the config fragment was copied into the WORKDIR from
            # the OE meta data
            if [ ! -e "$f" ]
            then
                echo "Could not find kernel config fragment $f"
                exit 1
            fi
        done

        # Now that all the fragments are located merge them.
        ( cd ${WORKDIR} && ${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${B}/.config ${KERNEL_CONFIG_FRAGMENTS} 1>&2 )
    fi

#	yes '' | oe_runmake -C ${S} O=${B} oldconfig
#        oe_runmake -C ${S} O=${B} savedefconfig && cp ${B}/defconfig ${WORKDIR}/defconfig.saved
	mkdir -p ${B}/arch/${KARCH}/boot/dts/
	cp -rf ${S}/arch/${KARCH}/boot/dts/${DTB_PATH}/* ${B}/arch/${KARCH}/boot/dts/
}




do_install_append() {
        oe_runmake headers_install INSTALL_HDR_PATH=${D}${exec_prefix}/src/linux-${KERNEL_VERSION} ARCH=$ARCH
        install -d ${D}/boot
        make dtbs || true
        install -m 0644 ${S}/arch/${KARCH}/boot/dts/${DTB_PATH}/*.dtb ${D}/boot || true
}

PACKAGES =+ "kernel-headers ${PN}"
FILES_kernel-headers = "${exec_prefix}/src/linux*"
FILES_${PN} += "/boot/*"
