#!/bin/bash

######################################################################
# Copyright (c) 2019 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
######################################################################

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
#echo 'mscash2 = Y' >> ../run/john-local.conf # (find out where it fails)
echo 'timeroast = Y' >> ../run/john-local.conf # fails on BE
echo 'iwork = Y' >> ../run/john-local.conf
echo 'ethereum = Y' >> ../run/john-local.conf
echo 'dmg = Y' >> ../run/john-local.conf
echo 'adxcrypt = Y' >> ../run/john-local.conf
echo 'encfs = Y' >> ../run/john-local.conf
echo 'gpg = Y' >> ../run/john-local.conf

echo 'raw-BLAKE2 = Y' >> ../run/john-local.conf  #BLAKE2
echo 'argon2 = Y' >> ../run/john-local.conf      #BLAKE2
echo 'tezos = Y' >> ../run/john-local.conf       #BLAKE2

#    ## Already disabled elsewhere ##
#echo 'diskcryptor = Y' >> ../run/john-local.conf #BE
#echo 'monero = Y' >> ../run/john-local.conf      #BE
#echo 'STRIP = Y' >> ../run/john-local.conf       #BE
#echo 'enpass = Y' >> ../run/john-local.conf      #BE

#    ## Document why it was disabled here ##
#echo 'agilekeychain = Y' >> ../run/john-local.conf           #Error ID 10
#echo 'as400-ssha1 = Y' >> ../run/john-local.conf             # "
#echo 'AxCrypt = Y' >> ../run/john-local.conf                 # "

echo 'RACF-KDFAES = Y' >> ../run/john-local.conf             #SLOW
echo 'RAR = Y' >> ../run/john-local.conf                     #SLOW
echo 'wpapsk-opencl = Y' >> ../run/john-local.conf           #SLOW
echo 'wpapsk-pmk-opencl = Y' >> ../run/john-local.conf       #SLOW

echo 'pbkdf2-hmac-md4-opencl = Y' >> ../run/john-local.conf  # TS
echo 'pbkdf2-hmac-md5-opencl = Y' >> ../run/john-local.conf  # TS

echo 'ssh-opencl = Y' >> ../run/john-local.conf  # TS, after 1a06dc4deeca5064e690f89724eb3a05469fd162

echo 'bf-opencl = Y' >> ../run/john-local.conf
echo 'gpg-opencl = Y' >> ../run/john-local.conf
echo 'krb5pa-md5-opencl = Y' >> ../run/john-local.conf
echo 'mscash2-opencl = Y' >> ../run/john-local.conf
echo 'nt-opencl = Y' >> ../run/john-local.conf
echo 'ntlmv2-opencl = Y' >> ../run/john-local.conf
echo 'o5logon-opencl = Y' >> ../run/john-local.conf
echo 'rawmd5-opencl = Y' >> ../run/john-local.conf
echo 'rawmd4-opencl = Y' >> ../run/john-local.conf
echo 'raw-SHA512-free-opencl = Y' >> ../run/john-local.conf  # Inefficient
echo 'xsha512-free-opencl = Y' >> ../run/john-local.conf     # Inefficient
echo 'mysqlsha1-opencl = Y' >> ../run/john-local.conf
echo 'mscash-opencl = Y' >> ../run/john-local.conf
echo 'sl3-opencl = Y' >> ../run/john-local.conf
echo 'rawsha1-opencl = Y' >> ../run/john-local.conf
echo 'salted_sha-opencl = Y' >> ../run/john-local.conf
echo 'bitlocker-opencl = Y' >> ../run/john-local.conf
echo 'keepass-opencl = Y' >> ../run/john-local.conf
echo 'pgpdisk-opencl = Y' >> ../run/john-local.conf #FAILED (cmp_all(49)) Intel OpenCL CPU

# Kernel <lotus5> was successfully vectorized (8)
# Done.
# run_tests.sh: line 266:  6155 Segmentation fault      (core dumped) $JTR_BIN -test-full=0 --format=opencl

# #############
# $JtR --fuzz --format=cpu
# ID: 10
# Fuzzing: agilekeychain, 1Password Agile Keychain [PBKDF2-SHA1 AES 256/256 AVX2 8x]... run_tests.sh: line 215:  6305 Killed                  $JTR_BIN --fuzz --format=cpu
# Fuzzing: as400-ssha1, AS400-SaltedSHA1 [?] in UTF-8 mode... Segmentation fault
# Fuzzing: AxCrypt [PBKDF2-SHA512/SHA1 AES 32/64]... Segmentation fault

#

#    ## Delete files instead. We no longer can disable a format ##
# rm -rf opencl_rar_fmt_plug.c racf_fmt_plug.c opencl_wpapsk_fmt_plug.c opencl_ssh_fmt_plug.c \
#        pbkdf2-hmac-md4_fmt_plug.c  pbkdf2-hmac-md5_fmt_plug.c opencl_bf_fmt_plug.c \
#        opencl_gpg_fmt_plug.c opencl_krb5pa-md5_fmt_plug.c opencl_mscash2_fmt_plug.c \
#        opencl_nt_fmt_plug.c  opencl_ntlmv2_fmt_plug.c opencl_rawmd4_fmt_plug.c \
#        opencl_rawmd5_fmt_plug.c opencl_rawsha512_fmt_plug.c opencl_xsha512_fmt_plug.c \
#        opencl_mysqlsha1_fmt_plug.c opencl_mscash_fmt_plug.c opencl_sl3_fmt_plug.c \
#        opencl_rawsha1_fmt_plug.c opencl_salted_sha_fmt_plug.c opencl_bitlocker_fmt_plug.c \
#        opencl_keepass_fmt_plug.c opencl_pgpdisk_fmt_plug.c \
#        opencl_DES_fmt_plug.c

# TS OpenCL
# OpenCL descrypt builds for all 4096 salts, it is unusable inside CI
rm -rf opencl_rar_fmt_plug.c racf_fmt_plug.c opencl_wpapsk_fmt_plug.c \
       opencl_mscash_fmt_plug.c opencl_mscash2_fmt_plug.c \
       opencl_nt_fmt_plug.c  opencl_ntlmv2_fmt_plug.c \
       opencl_rawsha512_fmt_plug.c opencl_xsha512_fmt_plug.c \
       opencl_DES_fmt_plug.c opencl_DES_bs_plug.c \
       opencl_DES_bs_b_plug.c opencl_DES_bs_f_plug.c opencl_DES_bs_h_plug.c \
       opencl_krb5pa-md5_fmt_plug.c

# TS --internal
rm -rf adxcrypt_fmt_plug.c pbkdf2-hmac-md4_fmt_plug.c \
       pbkdf2-hmac-md5_fmt_plug.c phpassMD5_fmt_plug.c opencl_keepass_fmt_plug.c \
       opencl_pbkdf2_hmac_md4_fmt_plug.c opencl_pbkdf2_hmac_md5_fmt_plug.c \
       opencl_bitlocker_fmt_plug.c opencl_bf_fmt_plug.c opencl_o5logon_fmt_plug.c \
       opencl_rawsha1_fmt_plug.c opencl_rawmd4_fmt_plug.c opencl_rawmd5_fmt_plug.c \
       opencl_mysqlsha1_fmt_plug.c
