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
# Copyright (c) 2019-2024 Claudio André <dev at claudioandre.slmail.me>
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
wget https://raw.githubusercontent.com/openwall/john-packages/release/scripts/show_info.sh -O show_info.sh
source show_info.sh

function do_TS_Setup(){
    echo
    echo '-- Test Suite set up --'

    # Prepare environment
    cd .. || exit 1
    git clone --depth 1 https://github.com/openwall/john-tests tests
    cd tests || exit 1

    export PERL_MM_USE_DEFAULT=1
    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)| sudo cpan
    sudo cpan install Digest::MD5
}

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
    wget https://raw.githubusercontent.com/openwall/john-packages/release/scripts/package_version.sh
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

    if [[ $TARGET_ARCH == *"macOS"* ]]; then
        SYSTEM_WIDE=''
        REGULAR="$SYSTEM_WIDE $ASAN $BUILD_OPTS"
        NO_OPENMP="--disable-openmp $SYSTEM_WIDE $ASAN $BUILD_OPTS"

        #Libraries and Includes
        if [[ $TARGET_ARCH == *"macOS X86"* ]]; then
            MAC_LOCAL_PATH="usr/local/opt"
        else
            MAC_LOCAL_PATH="opt/homebrew/opt"
        fi
        LDFLAGS_ssl="-L/$MAC_LOCAL_PATH/openssl/lib"
        LDFLAGS_gmp="-L/$MAC_LOCAL_PATH/gmp/lib"
        LDFLAGS_omp="-L/$MAC_LOCAL_PATH/libomp/lib -lomp"

        CFLAGS_ssl="-I/$MAC_LOCAL_PATH/openssl/include"
        CFLAGS_gmp="-I/$MAC_LOCAL_PATH/gmp/include"
        CFLAGS_omp="-I/$MAC_LOCAL_PATH/libomp/include"

        brew update
        brew install openssl libpcap libomp gmp coreutils p7zip

        if [[ $TARGET_ARCH == *"macOS ARM"* ]]; then
            brew link openssl --force
        fi

        if [[ $TARGET_ARCH == *"macOS X86"* ]]; then
            ./configure $NO_OPENMP --enable-simd=avx && do_build ../run/john-avx
            ./configure $REGULAR   --enable-simd=avx  LDFLAGS="$LDFLAGS_omp" CPPFLAGS="-Xclang -fopenmp $CFLAGS_omp -DOMP_FALLBACK_BINARY=\"\\\"john-avx\\\"\" " && do_build ../run/john-avx-omp
            ./configure $NO_OPENMP --enable-simd=avx2 && do_build ../run/john-avx2
            ./configure $REGULAR   --enable-simd=avx2 LDFLAGS="$LDFLAGS_omp" CPPFLAGS="-Xclang -fopenmp $CFLAGS_omp -DOMP_FALLBACK_BINARY=\"\\\"john-avx2\\\"\" -DCPU_FALLBACK_BINARY=\"\\\"john-avx-omp\\\"\" " && do_build ../run/john-avx2-omp
            BINARY="john-avx2-omp"
        else
            ./configure $NO_OPENMP LDFLAGS="$LDFLAGS_ssl $LDFLAGS_gmp" CPPFLAGS="$CFLAGS_ssl $CFLAGS_gmp"  && do_build "../run/john-$arch"
            ./configure $REGULAR   LDFLAGS="$LDFLAGS_ssl $LDFLAGS_gmp $LDFLAGS_omp" CPPFLAGS="-Xclang -fopenmp $CFLAGS_ssl $CFLAGS_gmp $CFLAGS_omp -DOMP_FALLBACK_BINARY=\"\\\"john-$arch\\\"\" "  && do_build ../run/john-omp
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
    JTR_BIN="$WINE$JTR"
    JTR_CL=""

    if [[ $TARGET_ARCH == "DOCKER" ]]; then
        JTR_BIN="/john/run/john-avx"
    fi

    wget https://raw.githubusercontent.com/openwall/john-packages/release/scripts/run_tests.sh -O run_tests.sh
    source run_tests.sh

elif [[ "$TEST" == *"TS"* ]]; then
    # Test Suite set up
    do_TS_Setup

    if [[ "$TEST" == *";OPENCL;"* ]]; then
        # Show OpenCL info
        ../run/john --list=opencl-devices
    fi
    ../run/john --list=build-info

    if [[ "$TEST" == *"TS --restore;"* ]]; then
        ./jtrts.pl --restore

    elif [[ "$TEST" == *"TS --internal;"* ]]; then
        ./jtrts.pl -noprelims -internal enabled
    else
        if [[ "$TEST" != *";OPENCL;"* ]]; then
            ./jtrts.pl -dynamic none
        else
            ./jtrts.pl -noprelims -type opencl
        fi
    fi
fi
