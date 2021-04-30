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

# Directory names and folders
APPVEYOR_64bits="" # Disabled: I'm using Azure packages
APPVEYOR_32bits="" # Disabled for '-dev' releases
FLATPAK="1207046569"
FLATPAK_TEST="1207046570"
AZURE_ID="312"

# AppVeyor (Windows 64 and 32 bits) ############################################
# I am no longer using the AppVeyor package
# wget https://ci.appveyor.com/api/buildjobs/$APPVEYOR_64bits/artifacts/win_x64.7z      -O winX64_1_JtR.7z
# wget https://ci.appveyor.com/api/buildjobs/$APPVEYOR_64bits/log                       -O winX64_2_buildlog.txt

if [[ -n "$APPVEYOR_32bits"  ]]; then
    wget https://ci.appveyor.com/api/buildjobs/$APPVEYOR_32bits/artifacts/win_x32.7z  -O winX32_1_JtR.7z
    wget https://ci.appveyor.com/api/buildjobs/$APPVEYOR_32bits/log                   -O winX32_2_buildlog.txt
fi

# GitLab (Linux Flatpak app) ###################################################
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK/artifacts/download     -O flatpak_1_JtR.zip
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/$FLATPAK/raw                    -O flatpak_2_buildlog.txt

# Azure Windows package
wget https://dev.azure.com/claudioandre-br/40224313-b91e-465d-852b-fc4ea516f33e/_apis/build/builds/$AZURE_ID/logs/115 -O winX64_2_buildlog.txt

if [[ "$1" == "LOG_FILES"  ]]; then
    # Download log files, to commit them in the git repo

    # Launchpad (Linux Snap app, various archs)
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557702/+files/buildlog_snap_ubuntu_xenial_armhf_john-the-ripper_BUILDING.txt.gz
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557699/+files/buildlog_snap_ubuntu_xenial_i386_john-the-ripper_BUILDING.txt.gz
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557703/+files/buildlog_snap_ubuntu_xenial_arm64_john-the-ripper_BUILDING.txt.gz
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557701/+files/buildlog_snap_ubuntu_xenial_amd64_john-the-ripper_BUILDING.txt.gz
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557704/+files/buildlog_snap_ubuntu_xenial_ppc64el_john-the-ripper_BUILDING.txt.gz
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557700/+files/buildlog_snap_ubuntu_xenial_powerpc_john-the-ripper_BUILDING.txt.gz
    wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557705/+files/buildlog_snap_ubuntu_xenial_s390x_john-the-ripper_BUILDING.txt.gz

    # GitLab (Linux Flatpak app)
    wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/FLATPAK_TEST/raw      -O flatpak_3_testlog.txt

    # GitHub (Linux Docker image)
    wget https://api.travis-ci.org/v3/job/605181618/log.txt                     -O docker_buildlog.txt
fi

# Deprecated ###################################################################
#wget https://ci.appveyor.com/api/buildjobs/6xi3fnryax6hkvk9/artifacts/optional.7z    -O winX64_3_optional.7z
#wget https://ci.appveyor.com/api/buildjobs/dq1hp9jbkmyo0sc4/artifacts/optional.zip   -O winX32_optional.zip
################################################################################

# Mac Experimental #############################################################
# wget https://www.drivehq.com/file/DFPublishFile.aspx/FileID7940025352/Keytseyh9kd91bb/MacX64_1_JtR.7z  -O MacX64_1_JtR-experimental.7z

LOG_FILE="0-Created_$(date +%Y-%m-%d).txt"

# Save a note to inform the "Build Date" and packages version
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/FLATPAK_TEST/raw         -O /tmp/flatpak_3_testlog.txt

GIT_TEXT=$(git ls-remote -q https://github.com/openwall/john.git HEAD | cut -c 1-40)
WIN_TEXT=$(grep -m1 'Version: 1.9.0-jumbo-1+bleeding' winX64_2_buildlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")
FLATPAK_TEXT=$(grep -m1 'Version: 1.9.0-jumbo-1+bleeding' /tmp/flatpak_3_testlog.txt | sed -e "s|.*Version: \(.*\).*|\1|")

echo "The release date is $(date). I'm Azure on behalf of Claudio." >  $LOG_FILE
echo "=================================================================================" >> $LOG_FILE
echo "Git bleeding repository is at: $GIT_TEXT" >> $LOG_FILE
echo "Windows is at: $WIN_TEXT" >> $LOG_FILE
echo "Flatpak is at: $FLATPAK_TEXT" >> $LOG_FILE

echo -e "\n=================================================================================" >> $LOG_FILE

unzip flatpak_1_JtR.zip
sha256sum *.zip | tee --append $LOG_FILE
sha256sum *.7z  | tee --append $LOG_FILE
sha256sum john.flatpak | tee --append $LOG_FILE

# Keep only the zipped file
rm -f john.flatpak

