#!/bin/bash

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

#########################################################################
# Disable all problematic formats, so they don't disturb testing
#
#########################################################################

# Disable clueless formats
echo '[Local:Disabled:Formats]' >> ../run/john-local.conf

echo 'RACF-KDFAES = Y' >> ../run/john-local.conf             #SLOW
echo 'RAR = Y' >> ../run/john-local.conf                     #SLOW
echo 'wpapsk-opencl = Y' >> ../run/john-local.conf           #SLOW
echo 'wpapsk-pmk-opencl = Y' >> ../run/john-local.conf       #SLOW

# Let's say these are fragile
echo 'krb5pa-md5-opencl = Y' >> ../run/john-local.conf
echo 'o5logon-opencl = Y' >> ../run/john-local.conf
echo 'mscash-opencl = Y' >> ../run/john-local.conf
echo 'salted_sha-opencl = Y' >> ../run/john-local.conf

echo 'bitlocker-opencl = Y' >> ../run/john-local.conf # Very slow format
echo 'pgpdisk-opencl = Y' >> ../run/john-local.conf #FAILED (cmp_all(49)) Intel OpenCL CPU

# Formats failing Intel OpenCL CPU driver
# See https://github.com/openwall/john/issues/5379
echo 'krb5tgs-opencl = Y' >> ../run/john-local.conf
echo 'pfx-opencl = Y' >> ../run/john-local.conf

#Testing: mscash2-opencl, MS Cache Hash 2 (DCC2) [PBKDF2-SHA1 OpenCL]... run_tests.sh: line 304:  6634 Segmentation fault
#      (core dumped) "$JTR_BIN" -test-full=0 --format=opencl
echo 'mscash2-opencl = Y' >> ../run/john-local.conf

# Intel OpenCL CPU driver
echo 'argon2-opencl = Y' >> ../run/john-local.conf # Very slow format

# SunMD5 on aarch64 and M1
# :: Testing: SunMD5 [MD5 128/128 ASIMD 4x2]... (4xOMP) *** stack smashing detected ***: terminated
# :: *** stack smashing detected ***: terminated
# :: *** stack smashing detected ***: terminated
# :: run_tests.sh: line 97: 24449 Aborted                 (core dumped) "$JTR_BIN" -test-full=0 --format=cpu
if [[ "$(uname -m)" == "aarch64" ]]; then
       echo 'SunMD5 = Y' >> ../run/john-local.conf
fi

# OpenCL Intel CPU on Azure
# Testing: streebog256crypt-opencl, Astra Linux $gost12256hash$ (rounds=5000) [GOST R 34.11-2012 OpenCL]... run_tests.sh: line 304:  6476 Killed                  "$JTR_BIN" -test-full=0 --format=opencl
echo 'streebog256crypt-opencl = Y' >> ../run/john-local.conf
echo 'streebog512crypt-opencl = Y' >> ../run/john-local.conf
echo 'gost94crypt-opencl = Y' >> ../run/john-local.conf
