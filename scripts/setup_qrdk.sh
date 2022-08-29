# Copyright (c) 2020, The Linux Foundation. All rights reserved.
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
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE

# It is recommended to save any standard error messages by running script as
# 'bash setup_qrdk.sh 2>&1 | tee /var/tmp/setup_qrdk_run.log'

thisscript=$(basename $0)
timestring=$(date '+%Y%m%d_%H%M%S%z')
logdir=/var/tmp/qrdk_setup_${timestring}
mkdir -pv $logdir

echo "[$(date '+%D %T')] Start QRDK Setup Script: $thisscript"
echo "Log files will be stored at: $logdir"

echo "Checking for current user permissions."
if [ $(id -u) -ne 0 ] ; then echo "ERROR: You need sudo rights before proceeding. Run this script as sudo user or root!!!!" ; exit 1 ; fi

#check if git tool is installed on the host machine before proceeding
which git
if [ $? -eq 0 ]; then
	echo "$(git --version) found, Proceeding with setup..."
else
	echo "ERROR: git is not installed. Exiting the setup script"
	exit 1
fi
echo "Found $(lsb_release -d | awk -F: '{print $2}') OS installed on this system"

dpkg --list > ${logdir}/pkgs_found_before.log 2>&1

apt-get -y install make gcc g++ diffstat texinfo chrpath bc gcc-multilib git gawk build-essential autoconf libtool libncurses-dev gettext gperf lib32z1 libc6-i386 g++-multilib python-git

dpkg --list > ${logdir}/pkgs_found_after.log 2>&1

gzip -9 ${logdir}/*

echo "[$(date '+%D %T')] End QRDK Setup Script: $thisscript"

#rm -rf ${logdir}
