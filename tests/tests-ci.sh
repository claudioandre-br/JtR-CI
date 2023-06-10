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
arch=$(uname -m)

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

function do_build () {
    set -e

    if [[ -n "$MAKE_CMD" ]]; then
        MAKE=$MAKE_CMD
    else
        MAKE=make
    fi

    if [[ -z "$MAKE_FLAGS" ]]; then
        MAKE_FLAGS="-sj $(nproc)"
    fi

    if [[ -n "$1" ]]; then
        $MAKE -s clean && $MAKE $MAKE_FLAGS && mv ../run/john "$1"
    else
        $MAKE -s clean && $MAKE $MAKE_FLAGS
    fi
    set +e
}

function do_release () {
    set -e

    #Create a 'john' executable
    cd ../run
    ln -s "$1" john
    cd -

    # Save information about how the binaries were built
    echo "[Build Configuration]" > ../run/Defaults
    echo "System Wide Build=No" >> ../run/Defaults
    echo "Architecture=$arch" >> ../run/Defaults
    echo "OpenMP=No" >> ../run/Defaults
    echo "OpenCL=Yes" >> ../run/Defaults
    echo "Optional Libraries=Yes" >> ../run/Defaults
    echo "Regex, OpenMPI, Experimental Code, ZTEX=No" >> ../run/Defaults

    # The script that computes the package version
    wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/package_version.sh
    chmod +x package_version.sh
    echo "Version=$(./package_version.sh)" >> ../run/Defaults

    set +e
}

# Build and testing
if [[ $2 == "BUILD" ]]; then

    # Make it a reproducible build
    if [[ -n "$_JUMBO_RELEASE" ]]; then
        echo "Deploying the release $_JUMBO_RELEASE"
        git pull --unshallow
        git checkout "$_JUMBO_RELEASE"
    fi

    if [[ $TARGET_ARCH == *"MacOS"* ]]; then
        SYSTEM_WIDE=''
        REGULAR="$SYSTEM_WIDE $ASAN $BUILD_OPTS"
        NO_OPENMP="--disable-openmp $SYSTEM_WIDE $ASAN $BUILD_OPTS"

        brew update
        brew install openssl libpcap libomp gmp coreutils p7zip

        if [[ $TARGET_ARCH == *"MacOS ARM"* ]]; then
            brew link openssl --force
        fi

        if [[ $TARGET_ARCH == *"MacOS X86"* ]]; then
            ./configure $NO_OPENMP --enable-simd=avx && do_build ../run/john-avx
            ./configure $REGULAR   --enable-simd=avx  LDFLAGS="-L/usr/local/opt/libomp/lib -lomp" CPPFLAGS="-Xclang -fopenmp -I/usr/local/opt/libomp/include -DOMP_FALLBACK_BINARY=\"\\\"john-avx\\\"\" " && do_build ../run/john-avx-omp
            ./configure $NO_OPENMP --enable-simd=avx2 && do_build ../run/john-avx2
            ./configure $REGULAR   --enable-simd=avx2 LDFLAGS="-L/usr/local/opt/libomp/lib -lomp" CPPFLAGS="-Xclang -fopenmp -I/usr/local/opt/libomp/include -DOMP_FALLBACK_BINARY=\"\\\"john-avx2\\\"\" -DCPU_FALLBACK_BINARY=\"\\\"john-avx-omp\\\"\" " && do_build ../run/john-avx2-omp
            BINARY="john-avx2-omp"
        else
            ./configure $NO_OPENMP LDFLAGS="-L/opt/homebrew/opt/openssl/lib -L/opt/homebrew/opt/gmp/lib" CPPFLAGS="-I/opt/homebrew/opt/openssl/include -I/opt/homebrew/opt/gmp/include"  && do_build "../run/john-$arch"
            ./configure $REGULAR   LDFLAGS="-L/opt/homebrew/opt/openssl/lib -L/opt/homebrew/opt/libomp/lib -lomp -L/opt/homebrew/opt/gmp/lib" CPPFLAGS="-Xclang -fopenmp -I/opt/homebrew/opt/openssl/include -I/opt/homebrew/opt/libomp/include -I/opt/homebrew/opt/gmp/include -DOMP_FALLBACK_BINARY=\"\\\"john-$arch\\\"\" "  && do_build ../run/john-omp
            BINARY="john-omp"
        fi
        do_release $BINARY
    fi

    if [[ $TARGET_ARCH == *"SOLARIS"* ]]; then
        ./configure $ASAN $BUILD_OPTS
        export MAKE_CMD=gmake
        do_build
    fi

    if [[ $TARGET_ARCH == *"NIX"* ]]; then
        ./configure $ASAN $BUILD_OPTS
        do_build
    fi
    echo
    echo '-- Build Info --'
    $WINE $JTR --list=build-info || true

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
