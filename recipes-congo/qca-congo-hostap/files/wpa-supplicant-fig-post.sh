#!/bin/sh
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
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
reload_config_after_overlay() {
	until [ -n "$(systemctl show -p ExecMainExitTimestamp \
			--value initoverlay.service 2>/dev/null)" ]; do
		sleep 0.5
	done
	until [ -S /var/run/wpa_supplicant/wlan0 ]; do
		sleep 0.2
	done
	wpa_cli_fig -i wlan0 reconfigure >/dev/null 2>&1
	wpa_cli_fig -i wlan0 scan >/dev/null 2>&1
}
reload_config_after_overlay &

while true; do
    until ! ip link show wlan0 >/dev/null 2>&1; do sleep 0.5; done
    until ip link show wlan0 >/dev/null 2>&1; do sleep 0.2; done
    until [ -S /var/run/wpa_supplicant/wlan0 ]; do sleep 0.2; done
    sleep 0.5
    wpa_cli_fig -i wlan0 scan >/dev/null 2>&1
done &
