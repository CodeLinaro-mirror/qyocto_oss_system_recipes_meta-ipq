include recipes-core/images/ipq-images.inc

do_rootfs[depends] += "linux-ipq:do_deploy"
