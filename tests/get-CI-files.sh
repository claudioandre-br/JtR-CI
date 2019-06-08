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

# Launchpad (Linux Snap app, various archs)
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557702/+files/buildlog_snap_ubuntu_xenial_armhf_john-the-ripper_BUILDING.txt.gz
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557699/+files/buildlog_snap_ubuntu_xenial_i386_john-the-ripper_BUILDING.txt.gz
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557703/+files/buildlog_snap_ubuntu_xenial_arm64_john-the-ripper_BUILDING.txt.gz
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557701/+files/buildlog_snap_ubuntu_xenial_amd64_john-the-ripper_BUILDING.txt.gz
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557704/+files/buildlog_snap_ubuntu_xenial_ppc64el_john-the-ripper_BUILDING.txt.gz
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557700/+files/buildlog_snap_ubuntu_xenial_powerpc_john-the-ripper_BUILDING.txt.gz
# Disable for '-dev': wget https://launchpad.net/~claudioandre.br/+snap/john-the-ripper/+build/557705/+files/buildlog_snap_ubuntu_xenial_s390x_john-the-ripper_BUILDING.txt.gz

# AppVeyor (Windows 64 and 32 bits)
wget https://ci.appveyor.com/api/buildjobs/6xi3fnryax6hkvk9/artifacts/win_x64.7z     -O winX64_1_JtR.7z
wget https://ci.appveyor.com/api/buildjobs/6xi3fnryax6hkvk9/artifacts/optional.7z    -O winX64_3_optional.7z
wget https://ci.appveyor.com/api/buildjobs/6xi3fnryax6hkvk9/log                      -O winX64_2_buildlog.txt

# Disable for '-dev': wget https://ci.appveyor.com/api/buildjobs/dq1hp9jbkmyo0sc4/artifacts/win_x32.zip     -O winX32.zip
# Disable for '-dev': wget https://ci.appveyor.com/api/buildjobs/dq1hp9jbkmyo0sc4/artifacts/optional.zip    -O winX32_optional.zip
# Disable for '-dev': wget https://ci.appveyor.com/api/buildjobs/dq1hp9jbkmyo0sc4/log                       -O winX32_buildlog.txt

# GitLab (Linux Flatpak app)
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/227581967/artifacts/download  -O bundle_1_JtR.zip
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/227581967/raw                 -O bundle_2_buildlog.txt
wget https://gitlab.com/claudioandre-br/JtR-CI/-/jobs/227581974/raw                 -O bundle_3_testlog.txt

# GitHub (Linux Docker image)
# Disable for '-dev': wget https://api.travis-ci.org/v3/job/532480502/log.txt                               -O docker_buildlog.txt

unzip bundle_1_JtR.zip
sha256sum *.zip
sha256sum *.7z
sha256sum john.flatpak

# Keep only the zipped file
rm -f john.flatpak
