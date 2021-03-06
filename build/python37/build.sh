#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}
#
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=Python
VER=3.7.7
PKG=runtime/python-37
MVER=${VER%.*}
SUMMARY="$PROG $MVER"
DESC="$SUMMARY"

# This component does not yet build with gcc 10
set_gccver 9

BUILD_DEPENDS_IPS="developer/build/autoconf developer/pkg-config"
RUN_DEPENDS_IPS="
    compress/bzip2
    database/sqlite-3
    library/expat
    library/libffi
    library/libxml2
    library/ncurses
    library/readline
    library/security/openssl
    library/zlib
    system/library/gcc-runtime
    developer/object-file
"
XFORM_ARGS="-D PYTHONVER=$MVER"

HARDLINK_TARGETS="
    usr/bin/python$MVER
"

set_python_version $MVER
set_arch 64

export CCSHARED="-fPIC"
CPPFLAGS+=" -I/usr/include/ncurses -D_LARGEFILE64_SOURCE"
CPPFLAGS+=" -DSKIP_ZIP_PATH"
CPPFLAGS64="`pkg-config --cflags libffi`"
CC+=' -m64'
export DFLAGS=-64
MAKE_ARGS="
    DFLAGS=-64
    DESTSHARED=/usr/lib/python$MVER/lib-dynload
"
MAKE_INSTALL_ARGS=DESTSHARED=/usr/lib/python$MVER/lib-dynload

CONFIGURE_OPTS="
    --enable-shared
    --with-dtrace
    --with-system-ffi
    --with-system-expat
    --enable-ipv6
    --without-ensurepip
    ac_cv_func_getentropy=no
"

TESTSUITE_SED="
    1,/tests* OK/ {
        /tests* OK/p
        d
    }
"

launch_testsuite() {
    EXTRATESTOPTS="-uall,-network,-audio,-gui,-largefile"
    EXTRATESTOPTS+=" -j 1"
    export EXTRATESTOPTS
    # Some tests have non-ASCII characters
    _LC_ALL=$LC_ALL
    export LC_ALL=en_US.UTF-8
    LC_ALL=$LC_ALL run_testsuite "$@"
    export LC_ALL=$_LC_ALL
}

test_dtrace() {
    [ -n "$SKIP_TESTSUITE" ] && return
    pushd $TMPDIR/$BUILDDIR >/dev/null
    # Dtrace tests require elevated privileges. They will have been skipped
    # as part of the full testsuite run.
    $PFEXEC $MAKE test TESTOPTS=test_dtrace | tee $SRCDIR/testsuite-d.log
    sed -i "$TESTSUITE_SED" $SRCDIR/testsuite-d.log
    # Reset ownership on the python 3 cache directories/files that will have
    # been created owned by root.
    $PFEXEC chown -R "`stat -c %U $SRCDIR`" .
    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf -fi
prep_build
build
strip_install
launch_testsuite
test_dtrace
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
