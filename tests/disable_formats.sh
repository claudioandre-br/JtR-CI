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

echo 'pbkdf2-hmac-md4 = Y' >> ../run/john-local.conf
echo 'pbkdf2-hmac-md5 = Y' >> ../run/john-local.conf
echo 'OpenBSD-SoftRAID = Y' >> ../run/john-local.conf
echo 'dpapimk = Y' >> ../run/john-local.conf
echo 'iwork = Y' >> ../run/john-local.conf
echo 'ethereum = Y' >> ../run/john-local.conf
echo 'dmg = Y' >> ../run/john-local.conf
echo 'adxcrypt = Y' >> ../run/john-local.conf
echo 'encfs = Y' >> ../run/john-local.conf

echo 'RACF-KDFAES = Y' >> ../run/john-local.conf             #SLOW
echo 'RAR = Y' >> ../run/john-local.conf                     #SLOW
echo 'wpapsk-opencl = Y' >> ../run/john-local.conf           #SLOW
echo 'wpapsk-pmk-opencl = Y' >> ../run/john-local.conf       #SLOW

echo 'pbkdf2-hmac-md4-opencl = Y' >> ../run/john-local.conf  # TS
echo 'pbkdf2-hmac-md5-opencl = Y' >> ../run/john-local.conf  # TS

echo 'ssh-opencl = Y' >> ../run/john-local.conf  # TS, after 1a06dc4deeca5064e690f89724eb3a05469fd162

echo 'bf-opencl = Y' >> ../run/john-local.conf
echo 'krb5pa-md5-opencl = Y' >> ../run/john-local.conf
echo 'mscash2-opencl = Y' >> ../run/john-local.conf
echo 'o5logon-opencl = Y' >> ../run/john-local.conf
echo 'raw-SHA512-free-opencl = Y' >> ../run/john-local.conf  # Inefficient
echo 'xsha512-free-opencl = Y' >> ../run/john-local.conf     # Inefficient
echo 'mscash-opencl = Y' >> ../run/john-local.conf
echo 'salted_sha-opencl = Y' >> ../run/john-local.conf
echo 'bitlocker-opencl = Y' >> ../run/john-local.conf # Very slow format
echo 'keepass-opencl = Y' >> ../run/john-local.conf
echo 'pgpdisk-opencl = Y' >> ../run/john-local.conf #FAILED (cmp_all(49)) Intel OpenCL CPU

# Formats failing Intel OpenCL CPU driver
# See https://github.com/openwall/john/issues/5379
echo 'krb5tgs-opencl = Y' >> ../run/john-local.conf
echo 'pfx-opencl = Y' >> ../run/john-local.conf

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

#########################################################################
# TS OpenCL
# OpenCL descrypt builds for all 4096 salts, it is unusable inside CI
# rm -rf opencl_rar_fmt_plug.c racf_fmt_plug.c opencl_wpapsk_fmt_plug.c \
#        opencl_mscash_fmt_plug.c opencl_mscash2_fmt_plug.c \
#        opencl_rawsha512_fmt_plug.c opencl_xsha512_fmt_plug.c \
#        opencl_DES_fmt_plug.c opencl_DES_bs_plug.c \
#        opencl_DES_bs_b_plug.c opencl_DES_bs_f_plug.c opencl_DES_bs_h_plug.c \
#        opencl_krb5pa-md5_fmt_plug.c

# # TS --internal
# rm -rf adxcrypt_fmt_plug.c pbkdf2-hmac-md4_fmt_plug.c \
#        pbkdf2-hmac-md5_fmt_plug.c phpassMD5_fmt_plug.c opencl_keepass_fmt_plug.c \
#        opencl_pbkdf2_hmac_md4_fmt_plug.c opencl_pbkdf2_hmac_md5_fmt_plug.c \
#        opencl_bitlocker_fmt_plug.c opencl_bf_fmt_plug.c opencl_o5logon_fmt_plug.c \
#        opencl_rawsha1_fmt_plug.c opencl_rawmd4_fmt_plug.c opencl_rawmd5_fmt_plug.c \
#        opencl_mysqlsha1_fmt_plug.c
# #########################################################################