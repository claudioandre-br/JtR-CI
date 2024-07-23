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
# Copyright (c) 2019-2024 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
###############################################################################

#Check to assure we are in the right place
if [[ ! -d src || ! -d run ]] && [[ $1 != "-f" ]]; then
    echo
    echo 'It seems you are in the wrong directory. To ignore this message, add -f to the command line.'
    exit 1
fi

#Changes needed
rm -rf .travis.yml appveyor.yml .travis/ .circleci/ .github/workflows/ci.yml

mkdir -p .azure/
mkdir -p .ci/
mkdir -p .circleci/
mkdir -p .travis/
mkdir -p .github/workflows

# Script that disable formats
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/disable_formats.sh

# AppVeyor CI YAML file
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/appveyor.yml

# Circle CI YAML file
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/config.yml    -P .circleci/

# Cirrus CI YAML file
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/.cirrus.yml
wget https://raw.githubusercontent.com/openwall/john-packages/release/deploy/Mac_ARM-Delivery.yml    -O ->> .cirrus.yml
sed -i 's/---/#---/' .cirrus.yml

# Azure CI YAML files
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure-pipelines.yml
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/checkout.yml                     -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/linux-build-and-test-steps.yml   -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/linux-ci.yml                     -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/linux-system-info.yml            -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-build-and-test-steps.yml -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-ci.yml                   -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-pull-artifacts.yml       -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-push-artifacts.yml       -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-system-info.yml          -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-testing.yml              -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure/windows-variables.yml            -P .azure/
wget https://raw.githubusercontent.com/openwall/john-packages/release/deploy/Windows-Delivery.yml    \
  -O .azure/windows-build-to-delivery.yml

# Travis CI YAML file and scripts
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/.travis.yml
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/CI-tests.sh   -P .travis/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/travis-ci.sh  -P .travis/

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/tests-ci.sh   -P .ci/

# GitHub Actions YAML file and scripts
wget https://raw.githubusercontent.com/openwall/john-packages/release/deploy/Solaris-Delivery.yml   -O .github/workflows/main.yml

chmod +x disable_formats.sh
chmod +x .travis/CI-tests.sh
chmod +x .travis/travis-ci.sh
chmod +x .ci/tests-ci.sh

git add .azure/
git add .ci/
git add .circleci/
git add .cirrus.yml
git add .travis.yml
git add .travis/
git add appveyor.yml
git add azure-pipelines.yml
git add .github/workflows/main.yml

# Ban all problematic formats (disable buggy formats)
# If a formats fails its tests on super, I will burn it.
cd src && ../disable_formats.sh && cd ..
git add run/john-local.conf -f

# Save the resulting state
git commit -a -m "CI: run regular procedures $(date)"

if [[ $1 == '--release' ]]; then
    echo
    echo 'We are going to do a release!'
    sed -i 's/${{ if false }}/${{ if true }}/g' azure-pipelines.yml
    MESSAGE="CI: package for Windows $(date)"
fi

if [[ -n "$MESSAGE" ]]; then
    git commit -a -m "$MESSAGE"
    shift
fi

if [[ $1 == '--test-all-archs' ]]; then
    echo
    echo 'Run extra architectures test!'
    touch run-CI.patch
    git add -f run-CI.patch
    MESSAGE="tests: check on non-X86 $(date)"
fi

if [[ -n "$MESSAGE" ]]; then
    git commit -a -m "$MESSAGE"
fi
# Clean up
rm -f get_tests.sh
rm -f disable_formats.sh
