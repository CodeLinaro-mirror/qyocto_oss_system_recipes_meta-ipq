SOC_FAMILY = "IPQ"

DEFAULTTUNE ?= "cortexa7thf-neon-vfpv4"
include conf/machine/include/soc-family.inc
include conf/machine/include/tune-cortexa7.inc

IMAGE_FSTYPES = "squashfs squashfs-xz ubi ext4"
MKUBIFS_ARGS = "-m 2048 -e 124KiB -c 4096 -U -F"
UBINIZE_ARGS = "-m 2048 -p 128KiB"

SYSVINIT_ENABLED_GETTYS = ""

KARCH = "arm"
KERNEL_IMAGETYPE ?= "Image"
TARGET_FPU="softfp"

MACHINE_FEATURES += "apm usbhost keyboard squashfs vfat ext2 screen touchscreen bluetooth wifi sdio"

MACHINE_EXTRA_RRECOMMENDS += " kernel-modules"

RDEPENDS_kernel-base = ""
