FILESEXTRAPATHS_append := "${THISDIR}/files:"

DEPENDS += " cryptodev-linux "

SRC_URI += " \
           file://110-openwrt_targets.patch \
	   file://120-strip-cflags-from-binary.patch \
           file://130-dont-build-tests-fuzz.patch \
           file://140-allow-prefer-chacha20.patch \
           file://150-openssl.cnf-add-engines-conf.patch \
           file://400-eng_devcrypto-save-ioctl-if-EVP_MD_.FLAG_ONESHOT.patch \
           file://410-eng_devcrypto-add-configuration-options.patch \
           file://420-eng_devcrypto-add-command-to-dump-driver-info.patch \
           file://430-e_devcrypto-make-the-dev-crypto-engine-dynamic.patch \
           file://500-e_devcrypto-default-to-not-use-digests-in-engine.patch \
           file://510-e_devcrypto-ignore-error-when-closing-session.patch \
            "
do_configure () {
        os=${HOST_OS}
        case $os in
        linux-gnueabi |\
        linux-gnuspe |\
        linux-musleabi |\
        linux-muslspe |\
        linux-musl )
                os=linux
                ;;
        *)
                ;;
        esac
        target="$os-${HOST_ARCH}"
        case $target in
        linux-arm*)
                target=linux-armv4
                ;;
        linux-aarch64*)
                target=linux-aarch64
                ;;
        esac

        useprefix=${prefix}
        if [ "x$useprefix" = "x" ]; then
                useprefix=/
        fi
        # WARNING: do not set compiler/linker flags (-I/-D etc.) in EXTRA_OECONF, as they will fully replace the
        # environment variables set by bitbake. Adjust the environment variables instead.
        HASHBANGPERL="/usr/bin/env perl" PERL=perl PERL5LIB="${S}/external/perl/Text-Template-1.46/lib/" \
	perl ${S}/Configure ${EXTRA_OECONF} ${PACKAGECONFIG_CONFARGS}  shared no-blake2  no-ec2m disable-hw-padlock no-hw  no-sm3  no-whirlpool no-rfc3779 disable-dynamic-engine no-afalgeng enable-devcryptoeng no-hw-padlock no-gost no-dtls no-comp no-nextprotoneg  --prefix=$useprefix --openssldir=${libdir}/ssl-1.1 --libdir=${libdir} $target
        perl ${B}/configdata.pm --dump
}

