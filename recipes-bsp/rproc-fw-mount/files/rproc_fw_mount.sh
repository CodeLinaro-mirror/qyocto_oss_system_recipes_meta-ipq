#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC
#
# Remote Processor Firmware Mount Script for IPQ9650
# Mounts CDSP and Prime firmware partitions
#
# Aligned with QSDK init.d/rproc_fw_mount standard.
# Adapted for systemd (start/stop) and standard Linux (no OpenWrt helpers).

# ---------------------------------------------------------------------------
# Helper functions (replace OpenWrt /lib/functions/system.sh equivalents)
# ---------------------------------------------------------------------------

# find_mmc_part <partlabel>
# Returns the block device path for a GPT/eMMC partition with the given label.
# Tries both the full label (e.g. "0:CDSPFW") and the short form ("CDSPFW").
find_mmc_part() {
    local partname="$1"
    local shortname="${partname#0:}"
    local dev

    # Try exact label via blkid
    dev=$(blkid -L "${partname}" 2>/dev/null)
    [ -n "$dev" ] && { echo "$dev"; return 0; }

    # Try without "0:" prefix
    if [ "$shortname" != "$partname" ]; then
        dev=$(blkid -L "${shortname}" 2>/dev/null)
        [ -n "$dev" ] && { echo "$dev"; return 0; }
    fi

    # Try /dev/disk/by-partlabel symlinks
    if [ -L "/dev/disk/by-partlabel/${partname}" ]; then
        readlink -f "/dev/disk/by-partlabel/${partname}"
        return 0
    fi
    if [ "$shortname" != "$partname" ] && \
       [ -L "/dev/disk/by-partlabel/${shortname}" ]; then
        readlink -f "/dev/disk/by-partlabel/${shortname}"
        return 0
    fi

    echo ""
}

# find_mtd_part <partname>
# Returns the MTD block device path (/dev/mtdblockN) for an MTD partition
# with the given name as listed in /proc/mtd.
# On NAND systems, after ubiattach this also finds direct MTD squashfs
# partitions (e.g. cdsp_fw, prime_fw) by name.
find_mtd_part() {
    local partname="$1"
    local mtdnum

    mtdnum=$(grep "\"${partname}\"" /proc/mtd 2>/dev/null | awk -F: '{print $1}' | sed 's/mtd//')
    if [ -n "$mtdnum" ]; then
        echo "/dev/mtdblock${mtdnum}"
    fi
}

# ---------------------------------------------------------------------------
# get_partname_new() - determines partition suffix based on the booted bank.
# Reads PARTLABEL from /proc/cmdline (same logic as QSDK).
# Returns "1" if booted from inactive/alternate bank, "" for primary bank.
# ---------------------------------------------------------------------------
get_partname_new() {
    local partlabel
    partlabel=$(cat /proc/cmdline 2>/dev/null | grep -o 'PARTLABEL=[^ ]*' | cut -d= -f2)
    case "$partlabel" in
        rootfs-inactive) echo "1" ;;
        *)               echo "" ;;
    esac
}

# ---------------------------------------------------------------------------
# mount_cdsp_fw <arch>
# ---------------------------------------------------------------------------
mount_cdsp_fw() {
    local arch=$1
    local emmc_part=""
    local nand_part=""
    local part_name="0:CDSPFW"
    local ubi_part_name="rootfs"

    # Check if already mounted
    if mount | grep -q CDSP_FW; then
        echo "CDSP FW already mounted" > /dev/console 2>&1
        return 0
    fi

    # Select primary or alternate partition based on booted bank
    local index
    index=$(get_partname_new)
    if [ "$index" = "1" ]; then
        part_name="${part_name}_${index}"
        ubi_part_name="${ubi_part_name}_${index}"
    fi

    # Detect flash type: NAND takes priority over eMMC
    emmc_part=$(find_mmc_part "$part_name" 2>/dev/null)
    nand_part=$(find_mtd_part "$ubi_part_name" 2>/dev/null)
    if [ -n "$nand_part" ]; then
        emmc_part=""
    fi

    # Create mount point
    mkdir -p /lib/firmware/$arch/CDSP_FW

    if [ -n "$emmc_part" ]; then
        # Mount eMMC partition
        /bin/mount -t squashfs "$emmc_part" /lib/firmware/$arch/CDSP_FW > /dev/kmsg 2>&1
        if [ $? -eq 0 ]; then
            echo "CDSP FW mount from eMMC successful" > /dev/console 2>&1
        else
            echo "CDSP FW mount from eMMC failed" > /dev/console 2>&1
            return 1
        fi
    elif [ -n "$nand_part" ]; then
        # Mount NAND partition (direct MTD squashfs or UBI volume)
        local PART
        PART=$(grep "\"${ubi_part_name}\"" /proc/mtd 2>/dev/null | awk -F: '{print $1}')
        # Attach UBI device if not already attached
        ubiattach -p /dev/$PART 2>/dev/null || true
        sync
        local ubi_part
        ubi_part=$(find_mtd_part cdsp_fw 2>/dev/null)
        if [ -n "$ubi_part" ]; then
            /bin/mount -t squashfs "$ubi_part" /lib/firmware/$arch/CDSP_FW > /dev/kmsg 2>&1
            if [ $? -ne 0 ]; then
                echo "CDSP FW mount failed, retry after 1 sec" > /dev/console 2>&1
                sleep 1
                /bin/mount -t squashfs "$ubi_part" /lib/firmware/$arch/CDSP_FW > /dev/kmsg 2>&1
                if [ $? -ne 0 ]; then
                    echo "CRITICAL: CDSP FW mount failed after retry" > /dev/console 2>&1
                    return 1
                fi
            fi
            echo "CDSP FW mount from NAND successful" > /dev/console 2>&1
        else
            echo "CDSP UBI volume not found" > /dev/console 2>&1
            return 1
        fi
    else
        echo "No CDSP FW partition found" > /dev/console 2>&1
        return 1
    fi

    # Verify critical firmware files exist
    if [ -f /lib/firmware/$arch/CDSP_FW/cdsp.mbn ] && \
       [ -f /lib/firmware/$arch/CDSP_FW/cdsp_dtb.mbn ]; then
        echo "CDSP FW files verified successfully" > /dev/console 2>&1
    else
        echo "WARNING: CDSP FW files not found" > /dev/console 2>&1
    fi

    # Create symbolic links
    cd /lib/firmware
    ln -sf /lib/firmware/$arch/CDSP_FW/cdsp.mbn .
    ln -sf /lib/firmware/$arch/CDSP_FW/cdsp_dtb.mbn .
    ln -sf /lib/firmware/$arch/CDSP_FW/cdspr.jsn .
    mkdir -p /usr/lib/dsp/
    cd /usr/lib/dsp/
    ln -sf /lib/firmware/$arch/CDSP_FW/fastrpc* .
    ln -sf /lib/firmware/$arch/CDSP_FW/lib* .
}

# ---------------------------------------------------------------------------
# mount_prime_fw <arch>
# ---------------------------------------------------------------------------
mount_prime_fw() {
    local arch=$1
    local emmc_part=""
    local nand_part=""
    local part_name="0:PRIMEFW"
    local ubi_part_name="rootfs"

    # Check if already mounted
    if mount | grep -q PRIME_FW; then
        echo "Prime FW already mounted" > /dev/console 2>&1
        return 0
    fi

    # Select primary or alternate partition based on booted bank
    local index
    index=$(get_partname_new)
    if [ "$index" = "1" ]; then
        part_name="${part_name}_${index}"
        ubi_part_name="${ubi_part_name}_${index}"
    fi

    # Detect flash type: NAND takes priority over eMMC
    emmc_part=$(find_mmc_part "$part_name" 2>/dev/null)
    nand_part=$(find_mtd_part "$ubi_part_name" 2>/dev/null)
    if [ -n "$nand_part" ]; then
        emmc_part=""
    fi

    # Create mount point
    mkdir -p /lib/firmware/$arch/PRIME_FW

    if [ -n "$emmc_part" ]; then
        # Mount eMMC partition
        /bin/mount -t squashfs "$emmc_part" /lib/firmware/$arch/PRIME_FW > /dev/kmsg 2>&1
        if [ $? -eq 0 ]; then
            echo "Prime FW mount from eMMC successful" > /dev/console 2>&1
        else
            echo "Prime FW mount from eMMC failed" > /dev/console 2>&1
            return 1
        fi
    elif [ -n "$nand_part" ]; then
        # Mount NAND partition (direct MTD squashfs or UBI volume)
        local PART
        PART=$(grep "\"${ubi_part_name}\"" /proc/mtd 2>/dev/null | awk -F: '{print $1}')
        # Attach UBI device if not already attached
        ubiattach -p /dev/$PART 2>/dev/null || true
        sync
        local ubi_part
        ubi_part=$(find_mtd_part prime_fw 2>/dev/null)
        if [ -n "$ubi_part" ]; then
            /bin/mount -t squashfs "$ubi_part" /lib/firmware/$arch/PRIME_FW > /dev/kmsg 2>&1
            if [ $? -ne 0 ]; then
                echo "Prime FW mount failed, retry after 1 sec" > /dev/console 2>&1
                sleep 1
                /bin/mount -t squashfs "$ubi_part" /lib/firmware/$arch/PRIME_FW > /dev/kmsg 2>&1
                if [ $? -ne 0 ]; then
                    echo "CRITICAL: Prime FW mount failed after retry" > /dev/console 2>&1
                    return 1
                fi
            fi
            echo "Prime FW mount from NAND successful" > /dev/console 2>&1
        else
            echo "Prime UBI volume not found" > /dev/console 2>&1
            return 1
        fi
    else
        echo "No Prime FW partition found" > /dev/console 2>&1
        return 1
    fi

    # Verify critical firmware file exists
    if [ -f /lib/firmware/$arch/PRIME_FW/qcom_prime_ipq.elf ]; then
        echo "Prime FW file verified successfully" > /dev/console 2>&1
    else
        echo "WARNING: Prime FW file not found" > /dev/console 2>&1
    fi

    # Create symbolic link
    cd /lib/firmware
    ln -sf /lib/firmware/$arch/PRIME_FW/qcom_prime_ipq.elf .
}

# ---------------------------------------------------------------------------
# stop_cdsp_fw / stop_prime_fw
# ---------------------------------------------------------------------------
stop_cdsp_fw() {
    local arch=$1
    local emmc_part=""
    local nand_part=""
    local part_name="0:CDSPFW"
    local ubi_part_name="rootfs"

    local index
    index=$(get_partname_new)
    if [ "$index" = "1" ]; then
        part_name="${part_name}_${index}"
        ubi_part_name="${ubi_part_name}_${index}"
    fi

    emmc_part=$(find_mmc_part "$part_name" 2>/dev/null)
    nand_part=$(find_mtd_part "$ubi_part_name" 2>/dev/null)

    if [ -n "$emmc_part" ] || [ -n "$nand_part" ]; then
        umount /lib/firmware/$arch/CDSP_FW 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "CDSP FW umount successful" > /dev/console 2>&1
        fi
    fi

    rm -f /lib/firmware/cdsp.mbn
    rm -f /lib/firmware/cdsp_dtb.mbn
}

stop_prime_fw() {
    local arch=$1
    local emmc_part=""
    local nand_part=""
    local part_name="0:PRIMEFW"
    local ubi_part_name="rootfs"

    local index
    index=$(get_partname_new)
    if [ "$index" = "1" ]; then
        part_name="${part_name}_${index}"
        ubi_part_name="${ubi_part_name}_${index}"
    fi

    emmc_part=$(find_mmc_part "$part_name" 2>/dev/null)
    nand_part=$(find_mtd_part "$ubi_part_name" 2>/dev/null)

    if [ -n "$emmc_part" ] || [ -n "$nand_part" ]; then
        umount /lib/firmware/$arch/PRIME_FW 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Prime FW umount successful" > /dev/console 2>&1
        fi
    fi

    rm -f /lib/firmware/qcom_prime_ipq.elf
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# /proc/device-tree/model is a null-terminated binary file; strip nulls first.
platform=$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0' | grep -o "IPQ[^ /]*" | head -1)

case "$1" in
    start)
        if echo "$platform" | grep -qiE "IPQ96"; then
            mount_prime_fw "IPQ9650"

            mount_cdsp_fw "IPQ9650"
            if [ $? -eq 0 ]; then
                # Start CDSP remoteproc only on 64-bit (aarch64) builds
                build_arch=$(grep -o "aarch64\|arm" /proc/version | head -1)
                if [ "$build_arch" = "aarch64" ]; then
                    # Find the remoteproc whose firmware is cdsp.mbn
                    cdsp_rproc=""
                    for rproc in /sys/class/remoteproc/remoteproc*; do
                        fw=$(cat $rproc/firmware 2>/dev/null)
                        if [ "$fw" = "cdsp.mbn" ]; then
                            cdsp_rproc=$(basename $rproc)
                            break
                        fi
                    done

                    if [ -n "$cdsp_rproc" ]; then
                        echo "Booting CDSP" > /dev/console 2>&1
                        echo start > /sys/class/remoteproc/$cdsp_rproc/state
                        echo "Starting RFS for CDSP" > /dev/console 2>&1
                        tftp_server &
                    else
                        echo "CDSP remoteproc not found in /sys/class/remoteproc/" > /dev/console 2>&1
                    fi
                fi
            else
                echo "Skipping CDSP boot due to mount failure" > /dev/console 2>&1
            fi
        fi
        ;;
    stop)
        if echo "$platform" | grep -qiE "IPQ96"; then
            stop_cdsp_fw "IPQ9650"
            stop_prime_fw "IPQ9650"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
