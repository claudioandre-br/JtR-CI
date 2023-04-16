#!/bin/bash

######################################################################
# Copyright (c) 2019-2022 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
######################################################################

#########################################################################
# Get the package version from git
#
#########################################################################

# It might be outside a git repository. A git describe will not work.
git_tag=$(cat My_VERSION.TXT)

# View package version
echo "1.9J1+$git_tag"   #TODO: edit before release (JUMBO_RELEASE)
#echo "roll+$git_tag"   #TODO: edit before release (JUMBO_RELEASE)

# Release example
# 1.9J2-07f7216a

# Develepment example (post Jumbo 2)
# 1.9J2+c9825e6S
