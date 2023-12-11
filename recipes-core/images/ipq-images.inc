# This include forces the generation of a ubinize UBI image
# file with having total three UBI volumes as kernel, ubi_rootfs
# and rootfs_data.

IMAGE_TYPEDEP_ubi        = "squashfs squashfs-xz"
ITB_IMAGE_NAME_ipq40xx   = "fit-qcom-ipq40xx-ap.dkxx.itb"
ITB_IMAGE_NAME_ipq807x   = "fit-qcom-ipq807x-ap.hkxx.itb"
ITB_IMAGE_NAME_ipq807x_64   = "fit-qcom-ipq807x-ap.hkxx.itb"
ITB_IMAGE_NAME_ipq95xx   = "fit-ipq95xx-ap.alxx.itb"
ITB_IMAGE_NAME_ipq95xx_64   = "fit-ipq95xx-ap.alxx.itb"
ITB_IMAGE_NAME_ipq53xx   = "fit-ipq53xx-ap.mixx.itb"
ITB_IMAGE_NAME_ipq53xx_64   = "fit-ipq53xx-ap.mixx.itb"

UBINIZE_CFG              = "${DEPLOY_DIR_IMAGE}/ubinize-${MACHINE}.cfg"

IMAGE_PREPROCESS_COMMAND += "create_ipq_ubi_img;"
SOC_TYPE="${@d.getVar('SOC_FAMILY', True).split(':')[1]}"
IMAGE_NAME_SUFFIX ??= ".rootfs"

create_ipq_ubi_img() {
   create_ubinize_config
}

create_ubinize_config() {
   echo \[kernel\] > "${UBINIZE_CFG}"
   echo mode=ubi >> "${UBINIZE_CFG}"
   echo "$SOC_TYPE" >> "${UBINIZE_CFG}"
   echo image="${DEPLOY_DIR_IMAGE}/${ITB_IMAGE_NAME_${SOC_TYPE}}" >> "${UBINIZE_CFG}"
   echo vol_id=0 >> "${UBINIZE_CFG}"
   echo vol_type=dynamic >> "${UBINIZE_CFG}"
   echo vol_name=kernel >> "${UBINIZE_CFG}"

   echo \[rootfs\] >> "${UBINIZE_CFG}"
   echo mode=ubi >> "${UBINIZE_CFG}"
   echo image="${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.squashfs-xz" >> "${UBINIZE_CFG}"
   echo vol_id=1 >> "${UBINIZE_CFG}"
   echo vol_type=dynamic >> "${UBINIZE_CFG}"
   echo vol_name=ubi_rootfs >> "${UBINIZE_CFG}"

   echo \[rootfs_data\] >> "${UBINIZE_CFG}"
   echo mode=ubi >> "${UBINIZE_CFG}"
   echo vol_id=2 >> "${UBINIZE_CFG}"
   echo vol_type=dynamic >> "${UBINIZE_CFG}"
   echo vol_name=rootfs_data >> "${UBINIZE_CFG}"
   echo vol_size=1KiB >> "${UBINIZE_CFG}"
   echo vol_flags=autoresize >> "${UBINIZE_CFG}"
}

IMAGE_CMD_ubi() {

   ubinize ${UBINIZE_ARGS} -o ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ubi ${UBINIZE_CFG}
   mkdir -p ${IMGDEPLOYDIR}/debug/modules
   cp -afn $(find $(find ${BASE_WORKDIR}/${MACHINE_ARCH}${HOST_VENDOR}-${HOST_OS}/ -name image) -name *.ko) ${IMGDEPLOYDIR}/debug/modules
}

do_rootfs:append() {
    bb.build.exec_func("do_prebuiltfunction",d)
}


find_depend_package(){
local myvar
local myvar1
local cmdpkgs
local packagename

    echo "Extracting prebuilt depends ipk:$1 , $2"
    ar -x $1
    tar -xf control.tar.gz -C "${prebuiltpath}/ctrlpath"
    if [ $( cat ${prebuiltpath}/ctrlpath/control | grep -c "Depends:") = 0 ]; then
        echo "Depends not present in $1 in control"
        return
    fi
    myvar=`cat ${prebuiltpath}/ctrlpath/control | grep  "Depends:"`
    if [ -n "$myvar" -o "$myvar" ]
    then
        for myvar1 in `echo $myvar  | tr "," "\n" | cut -d " " -f 2`
        do
            if [ -z "$myvar1" ]
            then
                echo "String is empty/String length is zero"
                break
            fi
            if [ $( ${cmd} list-installed | grep -c "$myvar1") = 0 ]; then
                cmdpkgs="$myvar1*.ipk"
                packagename=`find ${prebuiltpath} -maxdepth 1 -name "$cmdpkgs"`
                if [ -z "$packagename" ]
                then
                    myvar1=$myvar1"_"
                    cmdpkgs="$myvar1*.ipk"
                    echo "checking in deploypath for $myvar1"
                    packagename=`find ${deploypath} -name "$cmdpkgs"`
                    if [ -z "$packagename" ]
                    then
                        echo "+++++++++++ please copy "$myvar1" package into prebuiltipk path +++++++++++"
                        break
                    fi
                fi
                find_depend_package $packagename ${prebuiltpath}
                echo "${cmd} install $packagename"
                ${cmd} install $packagename
            else
                echo "$myvar1 already installed"
            fi
        done
    else
        echo "No depends for file: $1"
    fi
}

do_prebuiltfunction(){

    rootfspath="${WORKDIR}/rootfs"
    prebuiltpath="${TOPDIR}/../prebuiltipk"
    imageinstallpkgs="${IMAGE_INSTALL}"
    deploypath="${DEPLOY_DIR_IPK}"
    machinetype="${KARCH}"
    case $machinetype in
        "arm")
            prebuiltpath="${prebuiltpath}/32"
        ;;
        "arm64")
            prebuiltpath="${prebuiltpath}/64"
        ;;
    esac

    cmd="${STAGING_BINDIR_NATIVE}/opkg --volatile-cache -f ${WORKDIR}/opkg.conf -t ${WORKDIR}/temp/ipktemp/ -o ${WORKDIR}/rootfs   --force_postinstall --prefer-arch-to-version   --add-ignore-recommends qtbase-fonts-qpf --add-ignore-recommends udev-hwdb --add-ignore-recommends qtbase-fonts-ttf-vera --add-ignore-recommends qtbase-fonts-pfa  "

    if [ -e "${prebuiltpath}" ]
    then
        for file in `find ${prebuiltpath} -name "*.ipk"`
        do
            packagebasename=`basename $file`
            packagebasename=$( echo $packagebasename | cut -d"_" -f1)
            for prebuiltpkg in `echo "$imageinstallpkgs" | tr " " "\n" | grep "$packagebasename"`
            do
                echo "prebuiltpkg=$prebuiltpkg"
                if [ "$prebuiltpkg" = "$packagebasename" ]; then
                    echo "Extracting prebuilt ipk:$file"
                    mkdir -p "${prebuiltpath}/ctrlpath"
                    find_depend_package $file ${prebuiltpath}
                    echo "${cmd} install $file"
                    ${cmd} install $file
                    [ -e control.tar.gz ] && rm control.tar.gz
                    [ -e data.tar.xz ] && rm data.tar.xz
                    [ -e debian-binary ] && rm debian-binary
                fi
            done

        done
    fi
}
