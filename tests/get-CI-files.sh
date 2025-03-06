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
# Obtain packages for GitHub Release
# More info at https://github.com/openwall/john-packages

# Flatpak build IDs
# Get pipeline 297118338 info https://gitlab.com/api/v4/projects/12573246/pipelines/297118338
# Get jobs info               https://gitlab.com/api/v4/projects/12573246/pipelines/297118338/jobs

# Azure build ID
# Get the build id from the building environment
AZURE_JOB=$(cat Build._ID | tr -d '\r')
AZURE_PAGE="123"
AZURE_UID="40224313-b91e-465d-852b-fc4ea516f33e"

# Flatpak
GITLAB_JOB=$(curl -s https://gitlab.com/api/v4/projects/12573246/pipelines/ | \
   grep -o -m1 '{"id":[0-9]*' | grep -o '[0-9]*'| head -1)
FLATPAK=$(curl -s https://gitlab.com/api/v4/projects/12573246/pipelines/$GITLAB_JOB/jobs | \
   jq '.[] | select(.name == "cpu-job" and .status == "success") .id')

echo "###############################################################################"
echo "Deploy de: '$FLATPAK'."
echo "###############################################################################"

# GitLab (Linux Flatpak app) ###################################################
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK/artifacts/download     -O flatpak_1_JtR.zip
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK/raw                    -O flatpak_2_buildlog.txt

# Azure Windows package log
TLOG1=$(curl -s https://dev.azure.com/claudioandre-br/$AZURE_UID/_apis/build/builds/$AZURE_JOB/logs/ \ |
  jq '.value[] | select(.id == 123) .lineCount')
TLOG2=$(curl -s https://dev.azure.com/claudioandre-br/$AZURE_UID/_apis/build/builds/$AZURE_JOB/logs/ \ |
  jq '.value[] | select(.id == 128) .lineCount')
TLOG3=$(curl -s https://dev.azure.com/claudioandre-br/$AZURE_UID/_apis/build/builds/$AZURE_JOB/logs/ \ |
  jq '.value[] | select(.id == 129) .lineCount')

if [[ $TLOG2 > $TLOG1 || $TLOG2 > $TLOG3 ]]; then
      AZURE_PAGE="128"
fi

if [[ $TLOG3> $TLOG1 || $TLOG3 > $TLOG2 ]]; then
      AZURE_PAGE="129"
fi
wget https://dev.azure.com/claudioandre-br/$AZURE_UID/_apis/build/builds/$AZURE_JOB/logs/$AZURE_PAGE -O winX64_2_buildlog.txt

# macOS package
wget https://api.cirrus-ci.com/v1/artifact/github/claudioandre-br/JohnTheRipper/macOS%20M2/binaries/JtR-macArm.7z  -O macOS-ARM_1_JtR.7z
wget https://api.cirrus-ci.com/v1/artifact/github/claudioandre-br/JohnTheRipper/macOS%20M2/binaries/JtR-macArm.zip -O macOS-ARM_1_JtR.zip

GH_ID_RUN="13809836813"
GH_ID_ARTIFACT="2736942789"

curl -L --output /tmp/macOS-Intel_1_JtR.zip \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_PERSONAL_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/claudioandre-br/john-packages/actions/artifacts/$GH_ID_ARTIFACT/zip

curl -L --output /tmp/macOS-Intel_2_buildlog.zip \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_PERSONAL_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/claudioandre-br/john-packages/actions/runs/$GH_ID_RUN/logs

unzip /tmp/macOS-Intel_1_JtR.zip JtR-macX86.7z; mv JtR-macX86.7z macOS-Intel_1_JtR.7z
unzip /tmp/macOS-Intel_1_JtR.zip JtR-macX86.zip; mv JtR-macX86.zip macOS-Intel_1_JtR.zip
unzip /tmp/macOS-Intel_2_buildlog.zip 0_build.txt; mv 0_build.txt macOS-Intel_2_buildlog.txt

wget https://api.cirrus-ci.com/v1/artifact/github/claudioandre-br/JohnTheRipper/macOS%20M2/id/Build._ID          -O Build._ID
CIRRUS_JOB_ID=$(cat Build._ID | tr -d '\r')
wget https://api.cirrus-ci.com/v1/task/$CIRRUS_JOB_ID/logs/build.log                                             -O macOS-ARM_2_buildlog.txt      # Real log
wget https://api.cirrus-ci.com/v1/task/$CIRRUS_JOB_ID/logs/package.log                                           -O /tmp/macOS-ARM_2_buildlog.txt # Checksum

# The release log file information
LOG_FILE="Created-on_$(date +%Y-%m-%d).txt"

# Get the version string
ID=$(curl -s https://raw.githubusercontent.com/openwall/john-packages/release/deploy/Release.ID 2>/dev/null | tr -d '\n')

BINARY_ID="2.0.0 [a-f0-9]\{10\}"
BINARY_ID="1.9.1-ce [a-f0-9]\{10\}"
BINARY_ID="1.9.0-jumbo-1+bleeding-[a-f0-9]\{10\}"

GIT_TEXT=$(git ls-remote -q https://github.com/openwall/john.git HEAD | cut -c 1-40)
JOHN_PACKAGES_GIT=$(git ls-remote -q https://github.com/openwall/john-packages.git HEAD | cut -c 1-40)
WINDOWS_TEXT=$(grep -m1 --text "$BINARY_ID" winX64_2_buildlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")
FLATPAK_TEXT=$(grep -m1 --text "$BINARY_ID" flatpak_2_buildlog.txt | sed -e "s|.*Ripper \(.*\).*|\1|" | cut -f1-4 -d' ')
MACOSM1_TEXT=$(grep -m1 --text "$BINARY_ID" macOS-ARM_2_buildlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")
MACOSIntel_TEXT=$(grep -m1 --text "$BINARY_ID" macOS-Intel_2_buildlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")

# Create the contents of the log file
echo "The release date is $(date). I'm Azure on behalf of Claudio." >  $LOG_FILE
echo "=================================================================================" >> $LOG_FILE
echo "Upstream git repository is at: $GIT_TEXT" >> $LOG_FILE
echo "Upstream john-packages is at: $JOHN_PACKAGES_GIT" >> $LOG_FILE
echo "Windows is at: $WINDOWS_TEXT" >> $LOG_FILE
echo "Mac ARM is at: $MACOSM1_TEXT" >> $LOG_FILE
echo "Mac Intel is : $MACOSIntel_TEXT" >> $LOG_FILE
echo "Flatpak is at: $FLATPAK_TEXT" >> $LOG_FILE
echo "Release ID is: $ID" >> $LOG_FILE

echo -e "\n=================================================================================" >> $LOG_FILE
echo -e "== Checksums of the packages" >> $LOG_FILE

unzip flatpak_1_JtR.zip
sha256sum *.zip | tee --append $LOG_FILE
sha256sum *.7z  | tee --append $LOG_FILE
sha256sum john.flatpak | tee --append $LOG_FILE

echo -e "\n=================================================================================" >> $LOG_FILE
echo -e "== Values obtained from the logs, for confirmation"                  >> $LOG_FILE
grep -woE  '*.{64}       C:\\win_x64.7z' winX64_2_buildlog.txt                >> $LOG_FILE
grep -woE  '*.{64}       C:\\win_x64.zip' winX64_2_buildlog.txt               >> $LOG_FILE
grep -woE  '*.{64}       D:\\a\\1\\JtR\\run\\john.exe' winX64_2_buildlog.txt  >> $LOG_FILE
grep -woE  '*.{64}  john.flatpak' flatpak_2_buildlog.txt                      >> $LOG_FILE
grep -woE  --text '*.{64}  JtR-macArm.7z' /tmp/macOS-ARM_2_buildlog.txt       >> $LOG_FILE
grep -woE  --text '*.{64}  JtR-macArm.zip' /tmp/macOS-ARM_2_buildlog.txt      >> $LOG_FILE
grep -woE  --text '*.{64}  JtR-macX86.7z' macOS-Intel_2_buildlog.txt          >> $LOG_FILE
grep -woE  --text '*.{64}  JtR-macX86.zip' macOS-Intel_2_buildlog.txt         >> $LOG_FILE

# Keep only the files that are going to be used by the release
rm -f john.flatpak Build._ID
