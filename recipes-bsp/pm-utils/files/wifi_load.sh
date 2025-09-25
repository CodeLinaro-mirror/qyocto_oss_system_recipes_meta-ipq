#!/bin/sh
#
# Copyright (c) 2015-2016, 2019, The Linux Foundation. All rights reserved.
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC
#

type ipq_board_name &>/dev/null  || ipq_board_name() {
	local board="$(cat /tmp/sysinfo/board_name | sed 's/^\([^-]*-\)\{1\}//g')"
	if [[ "$board" == *rdp* ]]; then
		board=$(cat /tmp/sysinfo/board_name | awk -F, '{print$2}')
	fi
	echo "$board"
}

ipq_wifi_load()
{
	if [ -f /lib/modules/$(uname -r)/ath11k.ko ]; then
		modprobe ath11k
		modprobe ath11k_ahb
		modprobe ath11k_pci
		if [ -f /lib/modules/$(uname -r)/ath12k.ko ]; then
			modprobe ath12k

			#check new modules are present and insmod it
			if [ -f /lib/modules/$(uname -r)/ath12k_wifi7.ko ]; then
				modprobe qca-wifi-nss-plugins
				modprobe ath12k_wifi7
				if [ "$(ls -1 /sys/kernel/debug/ath11k/ | wc -l)" -gt 0 ]; then
					#wait for two phy entries
					while [ "$(iw dev | grep -c '^phy')" -lt 2 ]; do
						sleep 1
					done
				else
					#wait for one phy entry
					while ! iw dev | grep -q phy; do
						sleep 1
					done
				fi
			fi
		fi
		sleep 2
		/etc/utopia/service.d/service_wlan.sh wlan-start
	elif [ -f /lib/modules/$(uname -r)/ath12k.ko ]; then
		modprobe ath12k

		#check new modules are present and insmod it
		if [ -f /lib/modules/$(uname -r)/ath12k_wifi7.ko ]; then
			modprobe qca-wifi-nss-plugins
			modprobe ath12k_wifi7
			if [ "$(ls -1 /sys/kernel/debug/ath11k/ | wc -l)" -gt 0 ]; then
				#wait for two phy entries
				while [ "$(iw dev | grep -c '^phy')" -lt 2 ]; do
					sleep 1
				done
			else
				#wait for one phy entry
				while ! iw dev | grep -q phy; do
					sleep 1
				done
			fi
		fi
		sleep 2
		/etc/utopia/service.d/service_wlan.sh wlan-start
	else
		/usr/bin/rdk_qca_wifi.sh powersave_false
	fi
}

ipq_wifi_unload()
{
	if [ $(lsmod | grep ath11k | wc -l) -gt 0 ]; then
		/etc/utopia/service.d/service_wlan.sh wlan-stop
		sleep 2
		rmmod ath11k_ahb
		rmmod ath11k_pci
		rmmod ath11k
		if [ $(lsmod | grep ath12k | wc -l) -gt 0 ]; then
			#check new modules are present and rmmod it
			if [ $(lsmod | grep ath12k_wifi7 | wc -l) -gt 0 ]; then
				rmmod ath12k_wifi7
				rmmod qca-wifi-nss-plugins
			fi
			rmmod ath12k
		fi
	elif [ $(lsmod | grep ath12k | wc -l) -gt 0 ]; then
		/etc/utopia/service.d/service_wlan.sh wlan-stop
		sleep 2
		#check new modules are present and rmmod it
		if [  $(lsmod | grep ath12k_wifi7 | wc -l) -gt 0 ]; then
			rmmod ath12k_wifi7
			rmmod qca-wifi-nss-plugins
		fi
		rmmod ath12k
	else
		/usr/bin/rdk_qca_wifi.sh powersave_true
	fi
}

ipq_wifi_reload()
{
	ipq_wifi_unload
	ipq_wifi_load
}

board=$(ipq_board_name)
case "$1" in
	load)
		case "$board" in
		ap-al* | db-al* | ap-mi* | db-mi* | ipq5424*)
			ipq_wifi_load ;;
		esac ;;
	unload)
		case "$board" in
		ap-al* | db-al* | ap-mi* | db-mi* | ipq5424*)
			ipq_wifi_unload ;;
		esac ;;
	reload)
		case "$board" in
		ap-al* | db-al* | ap-mi* | db-mi* | ipq5424*)
			ipq_wifi_reload ;;
		esac ;;
esac
