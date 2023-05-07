#!/bin/bash -e

###############################################################################
#        _       _             _   _            _____  _
#       | |     | |           | | | |          |  __ \(_)
#       | | ___ | |__  _ __   | |_| |__   ___  | |__) |_ _ __  _ __   ___ _ __
#   _   | |/ _ \| '_ \| '_ \  | __| '_ \ / _ \ |  _  /| | '_ \| '_ \ / _ \ '__|
#  | |__| | (_) | | | | | | | | |_| | | |  __/ | | \ \| | |_) | |_) |  __/ |
#   \____/ \___/|_| |_|_| |_|  \__|_| |_|\___| |_|  \_\_| .__/| .__/ \___|_|
#                                                       | |   | |
#                                                       |_|   |_|
#
# Copyright (c) 2019-2023 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
###############################################################################

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

if [[ $TARGET_ARCH == *"SOLARIS"* && $2 == "BUILD" ]]; then
    pkg install --accept gcc
fi

TASK_RUNNING="$2"
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/show_info.sh
source show_info.sh

# Build and testing
if [[ $2 == "BUILD" ]]; then

    # Make it a reproducible build
    if [[ -n "$_JUMBO_RELEASE" ]]; then
        echo "Deploying the release $_JUMBO_RELEASE"
        git pull --unshallow
        git checkout "$_JUMBO_RELEASE"
    fi

    if [[ $TARGET_ARCH == *"MacOS"* ]]; then
        brew update
        brew install openssl libpcap libomp gmp coreutils
        ./configure --enable-werror $ASAN $BUILD_OPTS LDFLAGS="-L/usr/local/opt/libomp/lib -lomp" CPPFLAGS="-Xclang -fopenmp -I/usr/local/opt/libomp/include"
    fi

    if [[ $TARGET_ARCH == *"SOLARIS"* ]]; then
        ./configure $BUILD_OPTS
        gmake -sj $(nproc)
    fi

    if [[ $TARGET_ARCH == *"NIX"* || $TARGET_ARCH == *"ARM"* ]]; then
        ./configure $ASAN $BUILD_OPTS #TODO re-enable wError ./configure --enable-werror $ASAN $BUILD_OPTS
    fi

    if [[ $TARGET_ARCH == "x86_64" || $TARGET_ARCH == *"NIX"* || $TARGET_ARCH == *"MacOS"* ]]; then
        if [[ -n "$MAKE_FLAGS" ]]; then
            make "$MAKE_FLAGS"
        else
            make -sj $(nproc)
        fi
    fi
    echo
    echo '-- Build Info --'
    $WINE $JTR --list=build-info

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
