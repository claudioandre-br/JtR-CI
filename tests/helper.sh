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

function do_Install_OpenCL(){
    echo
    echo '-- Test Suite set up --'

    wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        | sudo tee /etc/apt/sources.list.d/oneAPI.list
    sudo apt-get update -qq
    sudo apt-get install -y \
        intel-oneapi-runtime-opencl intel-basekit
}

function do_Edit_Configuration(){
    sed -i 's/time make $j check/# ==> /g' .ci/run-build-and-tests.sh
    sed -i 's/if git status --porcelain |grep ^.;/if false;/g' .ci/run-build-and-tests.sh
}

function do_Disable_Formats(){
    tasks="$1"
    echo '[Local:Disabled:Formats]' > run/john-local.conf

    # CPU formats => Error processing POT
    # OpenCL formats => Expected count(s)
    if [[ "$tasks" == *"internal"* ]]; then
        disable_list="
            adxcrypt
            as400-des
            bcrypt
            descrypt
            lm
            net-ah
            nethalflm
            netlm
            pst
            racf
            rvary
            sapb
            tripcode
            vnc
            argon2-opencl
            bcrypt-opencl
            descrypt-opencl
            krb5tgs-opencl
            lm-opencl
            o5logon-opencl
            pgpdisk-opencl
            pfx-opencl
            sha256crypt-opencl
            zip-opencl
        "
    fi
    for i in $disable_list; do
        echo "$i = Y" >> run/john-local.conf
    done

    # OpenCL descrypt builds for all 4096 salts, it is unusable inside CI
    if [[ "$tasks" == *"opencl"* ]]; then
        disable_list="
            bcrypt-opencl
            descrypt-opencl
            krb5pa-md5-opencl
            lm-opencl
            mscash-opencl
            nt-opencl
            ntlmv2-opencl
            o5logon-opencl
            sha256crypt-opencl
            zip-opencl
        "
    fi
    for i in $disable_list; do
        echo "$i = Y" >> run/john-local.conf
    done

    # Failures => Expected count(s)
    if [[ "$tasks" == *"regular"* ]]; then
        disable_list="
            descrypt
            lm
            netlm
            pst
            sapB
            vnc
        "
    fi
    for i in $disable_list; do
        echo "$i = Y" >> run/john-local.conf
    done
}
