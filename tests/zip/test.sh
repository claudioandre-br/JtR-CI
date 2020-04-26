#!/bin/bash

######################################################################
# Copyright (c) 2020 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
######################################################################

# ---- Show JtR Build Info ----
if [[ true ]];  then
    JtR="../../run/john"
    Zip2John="../../run/zip2john"
fi

echo "Creating a Wordlist"
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 > guess.txt; echo '' >> guess.txt
for i in `seq 1 100`; do
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c $(cat /dev/urandom | tr -dc '4-9' | fold -w 256 | head -n 1 | head --bytes 1) >> guess.txt
    echo '' >> guess.txt
done
wget https://openwall.info/wiki/_media/john/zip_sample_files.tar
mkdir examples/
tar -xvf zip_sample_files.tar --directory examples/
echo "Running JtR"

echo ""; echo "==> B1 AES"
$Zip2John "AES-B1-2K(w{6f#@rXMd%S9.zip" > aes.hash
for mask in $(cat mask.txt); do $JtR aes.hash --pot=a1.pot --mask="$mask"; done

echo ""; echo "==> Unknown Password"
$Zip2John "hello-world-module.tar.xz.zip" > unknown.hash
$JtR unknown.hash --pot=a1.pot --max-run-time=600 --word=guess.txt --rules=all --format=ZIP-opencl --dev=5,6 --fork=3
$JtR unknown.hash --pot=a1.pot --max-run-time=600 --prince=guess.txt --rules=jumbo --format=ZIP-opencl --dev=5,6 --fork=3

echo ""; echo "==> Wiki Examples plus Not Encrypted"
$Zip2John examples/*.zip > examples.hash
$Zip2John test.zip >> examples.hash
$JtR examples.hash --pot=a1.pot --max-run-time=600 --format=ZIP-opencl --dev=5,6 --fork=3
$JtR examples.hash --pot=a1.pot --max-run-time=600 --format=pkzip

echo ""
echo "--------------------------------- Result ---------------------------------"
$JtR --pot=a1.pot --show aes.hash
$JtR --pot=a1.pot --show unknown.hash
$JtR --pot=a1.pot --show examples.hash

sleep 10
rm -f *.hash guess.txt *.pot zip_sample_files.tar
rm -rf examples/

if [[ false ]]; then
    bestCryptFDE2John="/home/claudio/Downloads/bestCryptFDE2john.py"

    python $bestCryptFDE2John aes.bin >> bcrypt.hash
    python $bestCryptFDE2John aes-v3.bin >> bcrypt.hash
    python $bestCryptFDE2John camellia.bin >> bcrypt.hash
    python $bestCryptFDE2John rc6.bin >> bcrypt.hash
    python $bestCryptFDE2John serpent.bin >> bcrypt.hash
    python $bestCryptFDE2John twofish.bin >> bcrypt.hash

python $bestCryptFDE2John encrypted.raw

    $JtR bcrypt.hash

    rm -f *.hash
fi