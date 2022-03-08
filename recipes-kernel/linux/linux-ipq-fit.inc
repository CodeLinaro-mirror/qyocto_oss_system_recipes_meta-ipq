
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

COMPATIBLE_MACHINE = "(ipq806x|ipq40xx|ipq807x|ipq807x_64|ipq95xx)"

KMACHINE = "${MACHINE}"

INSANE_SKIP_kernel-dev = "debug-files"

PARALLEL_MAKE = ""
KARCH ?= "arm"
DEPENDS += "u-boot-mkimage-native rsync-native dtc-native"

FIT_IMAGE_NAME_ipq40xx = "qcom-ipq40xx-ap.dkxx.itb"
FIT_IMAGE_NAME_ipq807x = "qcom-ipq807x-ap.hkxx.itb"
FIT_IMAGE_NAME_ipq807x_64 = "qcom-ipq807x-ap.hkxx.itb"
FIT_IMAGE_NAME_ipq95xx = "ipq95xx-ap.alxx.itb"
SOC_TYPE = "${@d.getVar('SOC_FAMILY', True).split(':')[1]}"

mk_fit_images() {
	name=$1
	addr=$2

#	oe_runmake ${DTB_PATH}/${name}.dtb
	echo "pwd = `pwd`"
	cd ../fit
	oe_runmake "ARCH=${KARCH}" \
			'DESCRIPTION=IPQ Yocto Linux FIT (Flattened Image Tree)' \
			"LINUX_VERSION=${LINUX_VERSION}" \
			"ADDRESS=${addr}" \
			'KERNEL_IMAGE=${B}/arch/${KARCH}/boot/Image' \
			"DTB=${B}/arch/${KARCH}/boot/dts/${DTB_PATH}/${name}.dtb" \
			"DTB_NAME=${name}"
	mv linux.fit fit-${name}.itb
	mv fdt.fit fdt.fit-${name}
	cd ${B}
}

generate_FDT() {
	name=$1
	board_name=$2

	cat << EOF >> ${B}/../fit/multi.its
		fdt@${board_name} {
			description = "${name} Tree blob";
			data = /incbin/("${B}/arch/${KARCH}/boot/dts/${DTB_PATH}/${name}.dtb");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
			hash@1 {
				algo = "crc32";
			};
			hash@2 {
				algo = "sha1";
			};
		};
EOF
}

generate_CONFIG() {
	board_name=$1

	cat << EOF >> ${B}/../fit/multi.its
		config@${board_name} {
			description = DESCRIPTION;
			kernel = "kernel@1";
			fdt = "fdt@${board_name}";
		};
EOF
}

mk_multi_fit_image() {
	name=$1
	addr=$2

	echo "pwd = `pwd`"
	cd ../fit
	sed -i -e 's/ARCH/${KARCH}/' -e "s/LOAD/${addr}/" \
		-e "s/LINUX_VERSION/${LINUX_VERSION}/" \
		-e "s/ENTRY/${addr}/" \
		-e 's/DESCRIPTION/"IPQ Yocto Linux FIT (Flattened Image Tree)"/' ${B}/../fit/multi.its

	oe_runmake multi.fit
	mv multi.fit fit-${name}.itb
	cd ${B}
}

find_device_tree() {
       echo "$(basename $(find ${B}/arch/${KARCH}/boot/dts/${DTB_PATH} -name $1*.dtb) 2>/dev/null)"
}

generate_its() {

	for d in ${KERNEL_DEVICETREE}; do
		if [ ! -e "$d" ]; then
			dts=$(find_device_tree "${d%.dtb}")
			mk_fit_images "${dts%.dtb}" ${KERNEL_LOADADDR}
		fi
	done

	cp ${B}/../fit/multi.its.in ${B}/../fit/multi.its
	i=0
	for d in ${KERNEL_DEVICETREE}; do
		if [ ! -e "$d" ]; then
			dts=$(find_device_tree "${d%.dtb}")
			board_name=$(basename $dts .dtb | sed -e 's/^\([^-]*-\)\{1\}//g')
			generate_FDT "${dts%.dtb}" $board_name
		fi
	done

	cat << EOF >> ${B}/../fit/multi.its
	};
	configurations {
		default = "config@1";
EOF

	i=0
	for d in ${KERNEL_DEVICETREE}; do
		if [ ! -e "$d" ]; then
			dts=$(find_device_tree "${d%.dtb}")
			board_name=$(basename $dts .dtb | sed -e 's/^\([^-]*-\)\{1\}//g')
			generate_CONFIG $board_name
		fi
	done
	cat << EOF >> ${B}/../fit/multi.its
	};
};
EOF
	mk_multi_fit_image $(basename ${FIT_IMAGE_NAME_${SOC_TYPE}} .itb) ${KERNEL_LOADADDR}
}

install_fit_images() {
	name=$1
	install ${B}/../fit/fit-${name}.itb ${DEPLOYDIR}/fit-${name}.itb

}

do_deploy_append() {

	generate_its
	mkdir -p ${DEPLOYDIR}/dtbs
	for d in ${KERNEL_DEVICETREE}; do
		if [ ! -e "$d" ]; then
			dts=$(find_device_tree "${d%.dtb}")
			install_fit_images "${dts%.dtb}"
			install ${B}/arch/${KARCH}/boot/dts/${DTB_PATH}/${d} ${DEPLOYDIR}/dtbs/
		fi
	done
	install_fit_images $(basename ${FIT_IMAGE_NAME_${SOC_TYPE}} .itb)
	install ${B}/vmlinux ${DEPLOYDIR}/${MACHINE}-vmlinux.elf
	install ${B}/arch/${KARCH}/boot/Image ${DEPLOYDIR}/dtbs/
}
