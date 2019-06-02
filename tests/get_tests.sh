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

#Check to assure we are in the right place
if [[ ! -d src || ! -d run ]] && [[ $1 != "-f" ]]; then
    echo
    echo 'It seems you are in the wrong directory. To ignore this message, add -f to the command line.'
    exit 1
fi

#Changes needed
rm -rf .travis.yml buggy.sh appveyor.yml .travis/ .circleci/

mkdir -p .azure/
mkdir -p .ci/
mkdir -p .circleci/
mkdir -p .travis/

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/buggy.sh

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/appveyor.yml

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/azure-pipelines.yml
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/linux-system-info.yml            -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/windows-system-info.yml          -P .azure/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/linux-build-and-test-steps.yml   -P .azure/

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/.travis.yml
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/CI-tests.sh   -P .travis/
wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/travis-ci.sh  -P .travis/

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/config.yml    -P .circleci/

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/tests-ci.sh   -P .ci/

wget https://raw.githubusercontent.com/claudioandre-br/JtR-CI/master/tests/.cirrus.yml

chmod +x buggy.sh
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

# Ban all problematic formats (disable buggy formats)
# If a formats fails its tests on super, I will burn it.
./buggy.sh disable

# Save the resulting state
git commit -a -m "CI: test and package for Windows $(date)"

# Clean up
rm -f buggy.sh
rm -f get_tests.sh
