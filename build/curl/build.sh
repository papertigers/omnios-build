#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=curl
VER=7.61.1
PKG=web/curl
SUMMARY="$PROG - command line tool for transferring data with URL syntax"
DESC="$SUMMARY"

DEPENDS_IPS="web/ca-bundle library/libidn"

CONFIGURE_OPTS="--enable-thread --with-ca-bundle=/etc/ssl/cacert.pem"
# curl actually has arch-dependent headers. Boo.
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=$PREFIX/include/amd64"

LIBTOOL_NOSTDLIB=libtool
TESTSUITE_FILTER="^TEST[A-Z]"

# Skip tests when in batch mode as they take a long time
[ -n "$BATCH" ] && SKIP_TESTSUITE=1

export MAKE

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite
make_isa_stub
make_package
clean_up
