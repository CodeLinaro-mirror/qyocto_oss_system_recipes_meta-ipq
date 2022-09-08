#!/bin/sh

#
# Copyright (c) 2015-2016, The Linux Foundation. All rights reserved.
#
# Copyright (c) 2022, Qualcomm Innovation Center, Inc. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

. /lib/ipq.sh
. /lib/functions/boot.sh

# ipq806x_power_auto()
#   Changes the governor to ondemand and sets the default parameters for cpu ondemand governor.
#   The parameters are tuned for best performance than for power.
#   Also, the up_thresholds have been set to low value, to workaround the cpu
#   utilization anamolies we are seeing with kcpustat with tickless kernel.

ipq806x_power_auto() {
        echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

        # Change the minimum operating frequency for CPU0.
        # This is required for cases where large amount of network traffic is sent
        # instantaneously  without any ramp-up time , when CPU is at minimum perf level.
        # At 384 MHz, CPU0 stays fully busy in softirq context and doesn't move to ksoftirqd, and
        # doesn't give any other thread including cpufreq thread a chance to run.
        # Hence, the CPU frequency is locked up at 384MHz till the traffic is stopped.
        # Increasing the min frequency for CPU0 to 800 MHz (L2=1GHz), allows 4 Gbps instantaneous
        # traffic without any hangs/lockups.
        #
        # CPU1 min frequency also has to be increased because there is a hardware constraint
        # kraits cannot operate at 384MHz when L2 is at 1GHz.
        #
        # The impact on idle-state power with this change is about ~40-45mW.
        echo "800000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo "800000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq

        # Change sampling rate for frequency scaling decisions to 1s, from 10 ms
        echo "1000000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate

        # Change sampling rate for frequency down scaling decision to 10s
        echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor

        # Change the CPU load threshold above which frequency is up-scaled to
        # turbo frequency,to 50%
        echo 50 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
}

ipq40xx_power_auto() {
        # change scaling governor as ondemand to enable clock scaling based on system load
        echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

        # set scaling min freq as 200 MHz
        echo "200000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

        # Change sampling rate for frequency scaling decisions to 1s, from 10 ms
        echo "1000000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate

        # Change sampling rate for frequency down scaling decision to 10s
        echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor

        # Change the CPU load threshold above which frequency is up-scaled to
        # turbo frequency,to 50%
        echo 50 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
}

ipq9574_power_auto() {
	# change scaling governor as ondemand to enable clock scaling based on system load
	echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

	# Change sampling rate for frequency scaling decisions to 1s, from 10 ms
	echo "1000000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate

	# Change sampling rate for frequency down scaling decision to 10s
	echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor

	# Change the CPU load threshold above which frequency is up-scaled to
	# turbo frequency,to 50%
	echo 50 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
}

ipq8064_ac_power()
{
	echo "Entering AC-Power Mode"
# Krait Power-UP Sequence
	ipq806x_power_auto

# Clocks Power-UP Sequence
	echo 400000000 > /sys/kernel/debug/clk/afab_a_clk/rate
	echo 64000000 > /sys/kernel/debug/clk/dfab_a_clk/rate
	echo 64000000 > /sys/kernel/debug/clk/sfpb_a_clk/rate
	echo 64000000 > /sys/kernel/debug/clk/cfpb_a_clk/rate
	echo 133000000 > /sys/kernel/debug/clk/nssfab0_a_clk/rate
	echo 133000000 > /sys/kernel/debug/clk/nssfab1_a_clk/rate
	echo 400000000 > /sys/kernel/debug/clk/ebi1_a_clk/rate

# Enabling Auto scale on NSS cores
	echo 1 > /proc/sys/dev/nss/clock/auto_scale

# PCIe Power-UP Sequence
#	sleep 1
#	echo 1 > /sys/bus/pci/rcrescan
	sleep 2
	echo 1 > /sys/bus/pci/rescan

	sleep 1

# Wifi Power-up Sequence
	/etc/utopia/service.d/service_wlan.sh wlan-start

# Bringing Up LAN Interface
	sysevent set lan-start

# Sata Power-UP Sequence
	[ -f /sys/devices/platform/msm_sata.0/ahci.0/msm_sata_suspend ] && {
		echo 0 > /sys/devices/platform/msm_sata.0/ahci.0/msm_sata_suspend
	}
	[ -f sys/devices/soc.2/29000000.sata/ipq_ahci_suspend ] && {
		echo 0 > sys/devices/soc.2/29000000.sata/ipq_ahci_suspend
	}

	sleep 1
	echo "- - -" > /sys/class/scsi_host/host0/scan

# USB Power-UP Sequence
	[ -d /sys/module/dwc3_ipq ] || modprobe dwc3-ipq
	[ -d /sys/module/dwc3_qcom ] || modprobe dwc3-qcom
	[ -d /sys/module/phy_qcom_hsusb ] || modprobe phy-qcom-hsusb
	[ -d /sys/module/phy_qcom_ssusb ] || modprobe phy-qcom-ssusb
	[ -d /sys/module/dwc3 ] || modprobe dwc3

# SD/MMC Power-UP sequence
	local emmcblock="$(find_mmc_part "rootfs")"

	if [ -z "$emmcblock" ]; then
		if [[ -f /tmp/sysinfo/sd_drvname  && ! -d /sys/block/mmcblk0 ]]
		then
			sd_drvname=$(cat /tmp/sysinfo/sd_drvname)
			echo $sd_drvname > /sys/bus/amba/drivers/mmci-pl18x/bind
		fi
	fi

	exit 0
}

ipq8064_battery_power()
{
	echo "Entering Battery Mode..."

# Wifi Power-down Sequence
	/etc/utopia/service.d/service_wlan.sh wlan-stop

# Bring Down LAN Interface
	sysevent set lan-stop

# PCIe Power-Down Sequence

# Remove devices
	sleep 2
	for i in `ls /sys/bus/pci/devices/`; do
		d=/sys/bus/pci/devices/${i}
		v=`cat ${d}/vendor`
		[ "xx${v}" != "xx0x17cb" ] && echo 1 > ${d}/remove
	done

# Remove Buses
	sleep 2
	for i in `ls /sys/bus/pci/devices/`; do
		d=/sys/bus/pci/devices/${i}
		echo 1 > ${d}/remove
	done

# Remove RC
	sleep 2

	[ -f /sys/bus/pci/rcremove ] && {
		echo 1 > /sys/bus/pci/rcremove
	}
	[ -f /sys/devices/pci0000:00/pci_bus/0000:00/rcremove ] && {
		echo 1 > /sys/devices/pci0000:00/pci_bus/0000:00/rcremove
	}
	sleep 1

# Find scsi devices and remove it

	partition=`cat /proc/partitions | awk -F " " '{print $4}'`

	for entry in $partition; do
		sd_entry=$(echo $entry | cut -c1-2)

		if [ "$sd_entry" = "sd" ]; then
			[ -f /sys/block/$entry/device/delete ] && {
				echo 1 > /sys/block/$entry/device/delete
			}
		fi
	done

# Sata Power-Down Sequence
	[ -f /sys/devices/platform/msm_sata.0/ahci.0/msm_sata_suspend ] && {
		echo 1 > /sys/devices/platform/msm_sata.0/ahci.0/msm_sata_suspend
	}
	[ -f /sys/devices/soc.2/29000000.sata/ipq_ahci_suspend ] && {
		echo 1 > /sys/devices/soc.2/29000000.sata/ipq_ahci_suspend
	}

# USB Power-down Sequence
	[ -d /sys/module/dwc3_ipq ] && rmmod dwc3-ipq
	[ -d /sys/module/dwc3 ] && rmmod dwc3
	[ -d /sys/module/dwc3_qcom ] && rmmod dwc3-qcom
	[ -d /sys/module/phy_qcom_hsusb ] && rmmod phy-qcom-hsusb
	[ -d /sys/module/phy_qcom_ssusb ] && rmmod phy-qcom-ssusb

	sleep 1

#SD/MMC Power-down Sequence
	local emmcblock="$(find_mmc_part "rootfs")"

	if [ -z "$emmcblock" ]; then
		if [ -d /sys/block/mmcblk0 ]
		then
			sd_drvname=`readlink /sys/block/mmcblk0 | awk -F "/" '{print $5}'`
			echo "$sd_drvname" > /tmp/sysinfo/sd_drvname
			echo $sd_drvname > /sys/bus/amba/drivers/mmci-pl18x/unbind
		fi
	fi

# Disabling Auto scale on NSS cores
	echo 0 > /proc/sys/dev/nss/clock/auto_scale

# Clocks Power-down Sequence

	echo 400000000 > /sys/kernel/debug/clk/afab_a_clk/rate
	echo 32000000 > /sys/kernel/debug/clk/dfab_a_clk/rate
	echo 32000000 > /sys/kernel/debug/clk/sfpb_a_clk/rate
	echo 32000000 > /sys/kernel/debug/clk/cfpb_a_clk/rate
	echo 133000000 > /sys/kernel/debug/clk/nssfab0_a_clk/rate
	echo 133000000 > /sys/kernel/debug/clk/nssfab1_a_clk/rate
	echo 400000000 > /sys/kernel/debug/clk/ebi1_a_clk/rate

# Scaling Down UBI Cores
	echo 110000000 > /proc/sys/dev/nss/clock/current_freq

# Krait Power-down Sequence
	echo 384000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo 384000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
	echo "powersave" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo "powersave" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
}

ipq4019_ap_dk01_1_ac_power()
{
	echo "Entering AC-Power Mode"
# Cortex Power-UP Sequence
	ipq40xx_power_auto

# Power on Malibu PHY of LAN ports
	ssdk_sh port poweron set 1
	ssdk_sh port poweron set 2
	ssdk_sh port poweron set 3
	ssdk_sh port poweron set 4
# Wifi Power-up Sequence
	/etc/utopia/service.d/service_wlan.sh wlan-start

# USB Power-UP Sequence
	if ! [ -d /sys/module/dwc3_ipq40xx -o -d /sys/module/dwc3_of_simple ]
	then
		modprobe phy-qca-baldur
		modprobe phy-qca-uniphy
		if [ -e /lib/modules/$(uname -r)/dwc3-of-simple.ko ]
		then
			modprobe dwc3-of-simple
		else
			modprobe dwc3-ipq40xx
		fi
		modprobe dwc3
	fi

# LAN interface up
	sysevent set lan-start

	exit 0
}

ipq4019_ap_dk01_1_battery_power()
{
	echo "Entering Battery Mode..."

# Wifi Power-down Sequence
	/etc/utopia/service.d/service_wlan.sh wlan-stop

# Find scsi devices and remove it

	partition=`cat /proc/partitions | awk -F " " '{print $4}'`

	for entry in $partition; do
		sd_entry=$(echo $entry | cut -c1-2)

		if [ "$sd_entry" = "sd" ]; then
			[ -f /sys/block/$entry/device/delete ] && {
				echo 1 > /sys/block/$entry/device/delete
			}
		fi
	done

# Power off Malibu PHY of LAN ports
	ssdk_sh port poweroff set 1
	ssdk_sh port poweroff set 2
	ssdk_sh port poweroff set 3
	ssdk_sh port poweroff set 4

# USB Power-down Sequence
	if [ -d /sys/module/dwc3_ipq40xx -o -d /sys/module/dwc3_of_simple ]
	then
		rmmod dwc3
		if [ -d /sys/module/dwc3_ipq40xx ]
		then
			rmmod dwc3-ipq40xx
		else
			rmmod dwc3-of-simple
		fi
		rmmod phy-qca-uniphy
		rmmod phy-qca-baldur
	fi
	sleep 2

# LAN interface down
	sysevent set lan-stop

# Cortex Power-down Sequence
	echo 48000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo "powersave" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
}

ipq4019_ap_dk04_1_ac_power()
{
	echo "Entering AC-Power Mode"
# Cortex Power-UP Sequence
	ipq40xx_power_auto

# Power on Malibu PHY of LAN ports
	ssdk_sh port poweron set 1
	ssdk_sh port poweron set 2
	ssdk_sh port poweron set 3
	ssdk_sh port poweron set 4

# PCIe Power-UP Sequence
	sleep 1
	echo 1 > /sys/bus/pci/rcrescan
	sleep 2
	echo 1 > /sys/bus/pci/rescan

	sleep 1

# Wifi Power-up Sequence
	/etc/utopia/service.d/service_wlan.sh wlan-start

# USB Power-UP Sequence
	if ! [ -d /sys/module/dwc3_ipq40xx -o -d /sys/module/dwc3_of_simple ]
	then
		modprobe phy-qca-baldur
		modprobe phy-qca-uniphy
		if [ -e /lib/modules/$(uname -r)/dwc3-of-simple.ko ]
		then
			modprobe dwc3-of-simple
		else
			modprobe dwc3-ipq40xx
		fi
		modprobe dwc3
	fi

# LAN interface up
	sysevent set lan-start

# SD/MMC Power-UP sequence
	local emmcblock="$(find_mmc_part "rootfs")"

	if [ -z "$emmcblock" ]; then
		if [[ -f /tmp/sysinfo/sd_drvname  && ! -d /sys/block/mmcblk0 ]]
		then
			sd_drvname=$(cat /tmp/sysinfo/sd_drvname)
			echo $sd_drvname > /sys/bus/platform/drivers/sdhci_msm/bind
		fi
	fi

	sleep 1

	exit 0
}

ipq4019_ap_dk04_1_battery_power()
{
	echo "Entering Battery Mode..."


# PCIe Power-Down Sequence

# Remove devices
	sleep 2
	for i in `ls /sys/bus/pci/devices/`; do
		d=/sys/bus/pci/devices/${i}
		v=`cat ${d}/vendor`
		[ "xx${v}" != "xx0x17cb" ] && echo 1 > ${d}/remove
	done

# Remove Buses
	sleep 2
	for i in `ls /sys/bus/pci/devices/`; do
		d=/sys/bus/pci/devices/${i}
		echo 1 > ${d}/remove
	done

# Remove RC
	sleep 2

	[ -f /sys/bus/pci/rcremove ] && {
		echo 1 > /sys/bus/pci/rcremove
	}
	[ -f /sys/devices/pci0000:00/pci_bus/0000:00/rcremove ] && {
		echo 1 > /sys/devices/pci0000:00/pci_bus/0000:00/rcremove
	}
	sleep 1

# Wifi Power-down Sequence
	/etc/utopia/service.d/service_wlan.sh wlan-stop

# Find scsi devices and remove it

	partition=`cat /proc/partitions | awk -F " " '{print $4}'`

	for entry in $partition; do
		sd_entry=$(echo $entry | cut -c1-2)

		if [ "$sd_entry" = "sd" ]; then
			[ -f /sys/block/$entry/device/delete ] && {
				echo 1 > /sys/block/$entry/device/delete
			}
		fi
	done

# Power off Malibu PHY of LAN ports
	ssdk_sh port poweroff set 1
	ssdk_sh port poweroff set 2
	ssdk_sh port poweroff set 3
	ssdk_sh port poweroff set 4

# USB Power-down Sequence
	if [ -d /sys/module/dwc3_ipq40xx -o -d /sys/module/dwc3_of_simple ]
	then
		rmmod dwc3
		if [ -d /sys/module/dwc3_ipq40xx ]
		then
			rmmod dwc3-ipq40xx
		else
			rmmod dwc3-of-simple
		fi
		rmmod phy-qca-uniphy
		rmmod phy-qca-baldur
	fi
	sleep 2
#SD/MMC Power-down Sequence
	local emmcblock="$(find_mmc_part "rootfs")"

	if [ -z "$emmcblock" ]; then
		if [ -d /sys/block/mmcblk0 ]
		then
			sd_drvname=`readlink /sys/block/mmcblk0 | grep -o "[0-9]*.sdhci"`
			echo "$sd_drvname" > /tmp/sysinfo/sd_drvname
			echo $sd_drvname > /sys/bus/platform/drivers/sdhci_msm/unbind
		fi
	fi

# LAN interface down
	sysevent set lan-stop

# Cortex Power-down Sequence
	echo 48000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	echo "powersave" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
}

ipq8074_ac_power()
{
	echo "Entering AC-Power Mode"
# Cortex Power-UP Sequence
	/etc/init.d/powerctl restart

# Power on Malibu PHY of LAN ports
	# ssdk_sh port poweron sequence goes here

# PCIe Power-UP Sequence
	sleep 1
	echo 1 > /sys/bus/pci/rcrescan
	sleep 2
	echo 1 > /sys/bus/pci/rescan

	sleep 1

# Wifi Power-up Sequence
	# wifi powerup sequence goes here

# USB Power-UP Sequence
	# USB powerup sequence goes here

# LAN interface up
	ifup lan

# SD/MMC Power-UP sequence
	# SD/MMC powerup sequence goes here
	sleep 1

	exit 0
}

ipq8074_battery_power()
{
	echo "Entering Battery Mode..."


# PCIe Power-Down Sequence

# Remove devices
	sleep 2
	for i in `ls /sys/bus/pci/devices/`; do
		d=/sys/bus/pci/devices/${i}
		v=`cat ${d}/vendor`
		[ "xx${v}" != "xx0x17cb" ] && echo 1 > ${d}/remove
	done

# Remove Buses
	sleep 2
	for i in `ls /sys/bus/pci/devices/`; do
		d=/sys/bus/pci/devices/${i}
		echo 1 > ${d}/remove
	done

# Remove RC
	sleep 2

	[ -f /sys/bus/pci/rcremove ] && {
		echo 1 > /sys/bus/pci/rcremove
	}
	[ -f /sys/devices/pci0000:00/pci_bus/0000:00/rcremove ] && {
		echo 1 > /sys/devices/pci0000:00/pci_bus/0000:00/rcremove
	}
	sleep 1

# Wifi Power-down Sequence
	# wifi unload sequence goes here

# Find scsi devices and remove it

# Power off Malibu PHY of LAN ports
	# ssdk_sh port poweroff sequence goes here

# USB Power-down Sequence
	# USB power down sequence goes here

	sleep 2
#SD/MMC Power-down Sequence
	# SD/MMC powerdown sequence goes here

# LAN interface down
	ifdown lan

# Cortex Power-down Sequence

}


ipq9574_phy_power_on()
{
	local board=$(ipq_board_name)
	case "$board" in
		qcom,ipq9574-ap-al01-c1 | qcom,ipq9574-ap-al02-c1 | qcom,ipq9574-ap-al02-c2 | db-al01-c1 | db-al01-c2 | db-al01-c3 |\
			db-al02-c1 | db-al02-c2)
			ssdk_sh port poweron set 2
			ssdk_sh port poweron set 3
			ssdk_sh port poweron set 4
			ssdk_sh port poweron set 5
			ssdk_sh port poweron set 6
		;;
		db-al02-c3)
			ssdk_sh port poweron set 2
			ssdk_sh port poweron set 3
			ssdk_sh port poweron set 4
			ssdk_sh port poweron set 6
		;;
	esac
}

ipq9574_phy_power_off()
{
	local board=$(ipq_board_name)
	case "$board" in
		qcom,ipq9574-ap-al01-c1 | qcom,ipq9574-ap-al02-c1 | qcom,ipq9574-ap-al02-c2 | db-al01-c1 | db-al01-c2 | db-al01-c3 |\
			db-al02-c1 | db-al02-c2)
			ssdk_sh port poweroff set 2
			ssdk_sh port poweroff set 3
			ssdk_sh port poweroff set 4
			ssdk_sh port poweroff set 5
			ssdk_sh port poweroff set 6
		;;
		db-al02-c3)
			ssdk_sh port poweroff set 2
			ssdk_sh port poweroff set 3
			ssdk_sh port poweroff set 4
			ssdk_sh port poweroff set 6
		;;
	esac
}

ipq9574_ac_power()
{
	echo "Entering AC-Power Mode"
# Cortex Power-UP Sequence
	ipq9574_power_auto

# Enabling Auto scale on NSS cores
	echo 1 > /proc/sys/dev/nss/clock/auto_scale

# Power on PHYs of LAN ports
	ipq9574_phy_power_on
# PCIe Power-UP Sequence
	sleep 2
	echo 1 > /sys/bus/pci/rcrescan
	sleep 1

# USB Power-UP Sequence
	if [ -e /lib/modules/$(uname -r)/dwc3-qcom.ko ]
	then
		modprobe phy-qcom-qusb2.ko
		modprobe dwc3-qcom.ko
		modprobe dwc3.ko
		modprobe usb_f_qdss.ko
	fi

	if [ -d config/usb_gadget/g1 ]
	then
		echo "8a00000.dwc3" > /config/usb_gadget/g1/UDC
	fi

# LAN interface up
	sysevent set lan-start

# Wifi Power-up Sequence
	if [ -f /lib/modules/$(uname -r)/ath11k.ko ]; then
		modprobe ath11k
		modprobe ath11k_ahb
		modprobe ath11k_pci
		sleep 2
		/etc/utopia/service.d/service_wlan.sh wlan-start
	else
		systemctl start qca-wifi.service
	fi

# SD/MMC Power-UP sequence
	local emmcblock="$(find_mmc_part "rootfs")"

	if [ -z "$emmcblock" ]; then
		for sd_drvname in $(cat /tmp/sysinfo/sd_drvname)
		do
			echo $sd_drvname > /sys/bus/platform/drivers/sdhci_msm/bind
		done
	fi

	sleep 1

	exit 0
}

ipq9574_battery_power()
{
	echo "Entering Battery Mode..."

# Wifi Power-down Sequence
	lsmod | grep ath11k > /dev/null
	if [ $? -eq 0 ]; then
		/etc/utopia/service.d/service_wlan.sh wlan-stop
		sleep 2
		rmmod ath11k_pci
		rmmod ath11k_ahb
		rmmod ath11k
	else
		systemctl stop qca-wifi.service
	fi

# PCIe Power-Down Sequence

	[ -f /sys/bus/pci/rcremove ] && {
		echo 1 > /sys/bus/pci/rcremove
	}
	sleep 1

# Find scsi devices and remove it
	partition=`cat /proc/partitions | awk -F " " '{print $4}'`

	for entry in $partition; do
		sd_entry=$(echo $entry | cut -c 2)

		if [ "$sd_entry" = "sd" ]; then
			[ -f /sys/block/$entry/device/delete ] && {
				echo 1 > /sys/block/$entry/device/delete
			}
		fi
	done


# Power off PHYs of LAN ports
        ipq9574_phy_power_off
# USB Power-down Sequence
	if [ -d config/usb_gadget/g1 ]
	then
		echo "" > /config/usb_gadget/g1/UDC
	fi

	if [ -d /sys/module/dwc3_qcom ]
	then
		rmmod usb_f_qdss
		rmmod dwc3
		rmmod dwc3_qcom
		rmmod phy_qcom_qusb2
	fi
	sleep 2

#SD/MMC Power-down Sequence
	local emmcblock="$(find_mmc_part "rootfs")"

	if [ -z "$emmcblock" ]; then
		rm /tmp/sysinfo/sd_drvname
		if [ -d /sys/block/mmcblk0 ]; then
			sd_drvname=`readlink /sys/block/mmcblk0 | grep -o "[0-9]*.sdhci[^/]*"`
			echo "$sd_drvname" >> /tmp/sysinfo/sd_drvname
			echo $sd_drvname >> /sys/bus/platform/drivers/sdhci_msm/unbind
		fi
	fi

# LAN interface down
	sysevent set lan-stop

# Disabling Auto scale on NSS cores
	echo 0 > /proc/sys/dev/nss/clock/auto_scale

# Scaling Down UBI Cores
	echo 1500000000 > /proc/sys/dev/nss/clock/current_freq;

# Cortex Power-down Sequence
	echo "powersave" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

}

board=$(ipq_board_name)
case "$1" in
	false)
		case "$board" in
		db149 | ap148 | ap145 | ap148_1xx | db149_1xx | db149_2xx | ap145_1xx | ap160 | ap160_2xx | ap161 | ak01_1xx)
			ipq8064_ac_power ;;
		ap-dk01.1-c1 | ap-dk01.1-c2 | ap-dk05.1-c1)
			ipq4019_ap_dk01_1_ac_power ;;
		ap-dk04.1-c1 | ap-dk04.1-c2 | ap-dk04.1-c3 | ap-dk04.1-c4 | ap-dk04.1-c5 | ap-dk06.1-c1 | ap-dk07.1-c1 | ap-dk07.1-c2)
			ipq4019_ap_dk04_1_ac_power ;;
		hk01)
			ipq8074_ac_power ;;
		qcom,ipq9574-ap-al01-c1 | qcom,ipq9574-ap-al02-c1 | qcom,ipq9574-ap-al02-c2 | qcom,ipq9574-ap-al02-c3 | qcom,ipq9574-ap-al02-c5 | qcom,ipq9574-ap-al02-c10)
			ipq9574_ac_power ;;
		esac ;;
	true)
		case "$board" in
		db149 | ap148 | ap145 | ap148_1xx | db149_1xx | db149_2xx | ap145_1xx | ap160 | ap160_2xx | ap161 | ak01_1xx)
			ipq8064_battery_power ;;
		ap-dk01.1-c1 | ap-dk01.1-c2 | ap-dk05.1-c1)
			ipq4019_ap_dk01_1_battery_power ;;
		ap-dk04.1-c1 | ap-dk04.1-c2 | ap-dk04.1-c3 | ap-dk04.1-c4 | ap-dk04.1-c5 | ap-dk06.1-c1 | ap-dk07.1-c1 | ap-dk07.1-c2)
			ipq4019_ap_dk04_1_battery_power ;;
		hk01)
			ipq8074_battery_power ;;
		qcom,ipq9574-ap-al01-c1 | qcom,ipq9574-ap-al02-c1 | qcom,ipq9574-ap-al02-c2 | qcom,ipq9574-ap-al02-c3 | qcom,ipq9574-ap-al02-c5 | qcom,ipq9574-ap-al02-c10)
			ipq9574_battery_power ;;
		esac ;;
esac
