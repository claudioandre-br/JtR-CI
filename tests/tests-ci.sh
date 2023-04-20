#!/bin/bash -e

######################################################################
# Copyright (c) 2019-2023 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
######################################################################

# ----------- BUILD -----------
cd src

# Setup testing environment
JTR=../run/john

# Control System Information presentation
if [[ $2 == "TEST" ]]; then
    MUTE_SYS_INFO="Yes"
fi

# The new J2 Docker image does not have wget installed
if [[ "$EXTRA" == "SIMD" ]]; then
    apt-get update
    apt-get -y install wget
fi

TASK_RUNNING="$2"
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/show_info.sh
source show_info.sh

# Build and testing
if [[ $2 == "BUILD" ]]; then

    if [[ $TARGET_ARCH == *"MacOS"* ]]; then
        brew update
        brew install openssl libpcap libomp gmp coreutils
        ./configure --enable-werror $ASAN $BUILD_OPTS LDFLAGS="-L/usr/local/opt/libomp/lib -lomp" CPPFLAGS="-Xclang -fopenmp -I/usr/local/opt/libomp/include"
    fi

    if [[ $TARGET_ARCH == *"NIX"* || $TARGET_ARCH == *"ARM"* ]]; then
        ./configure $ASAN $BUILD_OPTS #TODO re-enable wError ./configure --enable-werror $ASAN $BUILD_OPTS
    fi

    if [[ $TARGET_ARCH == "x86_64" || $TARGET_ARCH == *"NIX"* || $TARGET_ARCH == *"MacOS"* ]]; then
        # Build
        make -sj $(nproc)

        echo
        echo '-- Build Info --'
        $WINE $JTR --list=build-info
    fi

elif [[ $2 == "TEST" ]]; then

    # Required defines
    TEST=";$EXTRA;" # Controls how the test will happen
    arch=$(uname -m)
    JTR_BIN="$WINE $JTR"
    JTR_CL=""

    if [[ $TARGET_ARCH == "DOCKER" ]]; then
        JTR_BIN="/john/run/john-sse2"
    fi

    wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/run_tests.sh
    source run_tests.sh
fi
