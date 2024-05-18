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
# Copyright (c) 2024 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
###############################################################################
# Pin a new commit to be used for a new release
# More info at https://github.com/openwall/john-packages


FROM=$1
TO=$2
echo -e "================================================================================="
echo -e "== Replacing $FROM"
echo -e "== To $TO"
echo -e "================================================================================="

find . -type f -name "*" -not -path "./.git/*" -not -path "./Releases/*" \
    -exec sed -i "s/$FROM/$TO/g" {} \; \
    -exec sed -i "s/${FROM:0:7}/${TO:0:7}/g" {} \;

cd scripts && sha256sum ./*.sh > ../requirements.hash  && cd - && \
cd patches && sha256sum ./* >> ../requirements.hash && cd -