FILESEXTRAPATHS:append := "${THISDIR}/files:"
EXTRA_OECONF:remove= "no-md4"

SRC_URI += "https://github.com/openssl/openssl/releases/download/openssl-${PKGVER}/openssl-${PKGVER}.tar.gz"
SRC_URI[sha256sum] = "57e03c50feab5d31b152af2b764f10379aecd8ee92f16c985983ce4a99f7ef86"
PKGVER= "3.0.16"

SRC_URI:remove = "http://www.openssl.org/source/openssl-${PV}.tar.gz"
SRC_URI:remove = "file://0001-Configure-do-not-tweak-mips-cflags.patch"

S = "${WORKDIR}/openssl-3.0.16"

do_configure () {
	# When we upgrade glibc but not uninative we see obtuse failures in openssl. Make
	# the issue really clear that perl isn't functional due to symbol mismatch issues.
	cat <<- EOF > ${WORKDIR}/perltest
	#!/usr/bin/env perl
	use POSIX;
	EOF
	chmod a+x ${WORKDIR}/perltest
	${WORKDIR}/perltest

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
	linux-arc | linux-microblaze*)
		target=linux-latomic
		;;
	linux-arm*)
		target=linux-armv4
		;;
	linux-aarch64*)
		target=linux-aarch64
		;;
	linux-i?86 | linux-viac3)
		target=linux-x86
		;;
	linux-gnux32-x86_64 | linux-muslx32-x86_64 )
		target=linux-x32
		;;
	linux-gnu64-x86_64)
		target=linux-x86_64
		;;
	linux-mips | linux-mipsel)
		# specifying TARGET_CC_ARCH prevents openssl from (incorrectly) adding target architecture flags
		target="linux-mips32 ${TARGET_CC_ARCH}"
		;;
	linux-gnun32-mips*)
		target=linux-mips64
		;;
	linux-*-mips64 | linux-mips64 | linux-*-mips64el | linux-mips64el)
		target=linux64-mips64
		;;
	linux-nios2* | linux-sh3 | linux-sh4 | linux-arc*)
		target=linux-generic32
		;;
	linux-powerpc)
		target=linux-ppc
		;;
	linux-powerpc64)
		target=linux-ppc64
		;;
	linux-powerpc64le)
		target=linux-ppc64le
		;;
	linux-riscv32)
		target=linux-generic32
		;;
	linux-riscv64)
		target=linux-generic64
		;;
	linux-sparc | linux-supersparc)
		target=linux-sparcv9
		;;
	mingw32-x86_64)
		target=mingw64
		;;
	esac

	useprefix=${prefix}
	if [ "x$useprefix" = "x" ]; then
		useprefix=/
	fi
	# WARNING: do not set compiler/linker flags (-I/-D etc.) in EXTRA_OECONF, as they will fully replace the
	# environment variables set by bitbake. Adjust the environment variables instead.
	PERLEXTERNAL="$(realpath ${S}/external/perl/Text-Template-*/lib)"
	test -d "$PERLEXTERNAL" || bberror "PERLEXTERNAL '$PERLEXTERNAL' not found!"
	HASHBANGPERL="/usr/bin/env perl" PERL=perl PERL5LIB="$PERLEXTERNAL" \
	perl ${S}/Configure ${EXTRA_OECONF} ${PACKAGECONFIG_CONFARGS} ${DEPRECATED_CRYPTO_FLAGS} --prefix=$useprefix --openssldir=${libdir}/ssl-3 --libdir=${libdir} $target
	perl ${B}/configdata.pm --dump
}

do_install_ptest:prepend () {
	install -d ${D}${PTEST_PATH}/test
	install -m755 ${B}/test/p_minimal.so ${D}${PTEST_PATH}/test
}

do_install:prepend:class-nativesdk () {
	echo 'export SSL_CERT_DIR="$OECORE_NATIVE_SYSROOT/usr/lib/ssl/certs"' >> ${WORKDIR}/environment.d-openssl.sh
	echo 'export SSL_CERT_FILE="$OECORE_NATIVE_SYSROOT/usr/lib/ssl/certs/ca-certificates.crt"' >> ${WORKDIR}/environment.d-openssl.sh
	echo 'export OPENSSL_MODULES="$OECORE_NATIVE_SYSROOT/usr/lib/ossl-modules/"' >> ${WORKDIR}/environment.d-openssl.sh
	echo 'export OPENSSL_ENGINES="$OECORE_NATIVE_SYSROOT/usr/lib/engines-3"' >> ${WORKDIR}/environment.d-openssl.sh
}
