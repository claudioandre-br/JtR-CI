#!/bin/bash
######################################################################
# Copyright (c) 2019-2021 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
######################################################################

# AppVeyor build IDs
APPVEYOR_64bits="" # Disabled: I'm using Azure packages
APPVEYOR_32bits="" # Disabled for '-dev' releases

# Flatpak build IDs
FLATPAK="2548426502"
FLATPAK_TEST="2548426503"
# Get pipeline 297118338 info https://gitlab.com/api/v4/projects/12573246/pipelines/297118338
# Get jobs info               https://gitlab.com/api/v4/projects/12573246/pipelines/297118338/jobs

# Azure build ID
# Get the build id from the building environment
AZURE_ID=`cat Build._ID | tr -d '\r'`

FLATPAK=$(curl -s https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/ | \
  grep -o 'build-link">#[0-9]*' | grep -o '[0-9]*' | \
  sed -n '2p')
FLATPAK_TEST=$(curl -s https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/ | \
  grep -o 'build-link">#[0-9]*' | grep -o '[0-9]*' | \
  sed -n '1p')

echo "Deploy de: '$FLATPAK' e '$FLATPAK_TEST'."

# AppVeyor (32 bits) ###########################################################
if [[ -n "$APPVEYOR_32bits"  ]]; then
    wget https://ci.appveyor.com/api/buildjobs/$APPVEYOR_32bits/artifacts/win_x32.7z  -O winX32_1_JtR.7z
    wget https://ci.appveyor.com/api/buildjobs/$APPVEYOR_32bits/log                   -O winX32_2_buildlog.txt
fi

# GitLab (Linux Flatpak app) ###################################################
# The FLATPAK_TEST is used to retrieve package version information
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK/artifacts/download     -O flatpak_1_JtR.zip
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK/raw                    -O flatpak_2_buildlog.txt
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK_TEST/raw               -O /tmp/flatpak_3_testlog.txt

# Azure Windows package log
wget https://dev.azure.com/claudioandre-br/40224313-b91e-465d-852b-fc4ea516f33e/_apis/build/builds/$AZURE_ID/logs/128 -O winX64_2_buildlog.txt

# The release log file information
LOG_FILE="Created-on_$(date +%Y-%m-%d).txt"

GIT_TEXT=$(git ls-remote -q https://github.com/openwall/john.git HEAD | cut -c 1-40)
WIN_TEXT=$(grep -m1 'Version: 1.9.0-jumbo-1+bleeding' winX64_2_buildlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")
FLATPAK_TEXT=$(grep -m1 'Version: 1.9.0-jumbo-1+bleeding' /tmp/flatpak_3_testlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")


# Create the contents of the log file
echo "The release date is $(date). I'm Azure on behalf of Claudio." >  $LOG_FILE
echo "=================================================================================" >> $LOG_FILE
echo "Git bleeding repository is at: $GIT_TEXT" >> $LOG_FILE
echo "Windows is at: $WIN_TEXT" >> $LOG_FILE
echo "Flatpak is at: $FLATPAK_TEXT" >> $LOG_FILE

echo -e "\n=================================================================================" >> $LOG_FILE
echo -e "== Checksums of the packages" >> $LOG_FILE

unzip flatpak_1_JtR.zip
sha256sum *.zip | tee --append $LOG_FILE
sha256sum *.7z  | tee --append $LOG_FILE
sha256sum john.flatpak | tee --append $LOG_FILE

echo -e "\n=================================================================================" >> $LOG_FILE
echo -e "== Values for confirmation" >> $LOG_FILE
grep -woE  '*.{64}  john.flatpak' flatpak_2_buildlog.txt                      >> $LOG_FILE
grep -woE  '*.{64}       C:\\win_x64.7z' winX64_2_buildlog.txt                >> $LOG_FILE
grep -woE  '*.{64}       D:\\a\\1\\JtR\\run\\john.exe' winX64_2_buildlog.txt  >> $LOG_FILE

# Keep only the files that are going to be used by the release
rm -f john.flatpak Build._ID
