###############################################################################
#       _       _             _   _            _____  _
#       | |     | |           | | | |          |  __ \(_)
#       | | ___ | |__  _ __   | |_| |__   ___  | |__) |_ _ __  _ __   ___ _ __
#   _   | |/ _ \| '_ \| '_ \  | __| '_ \ / _ \ |  _  /| | '_ \| '_ \ / _ \ '__|
#  | |__| | (_) | | | | | | | | |_| | | |  __/ | | \ \| | |_) | |_) |  __/ |
#   \____/ \___/|_| |_|_| |_|  \__|_| |_|\___| |_|  \_\_| .__/| .__/ \___|_|
#                                                       | |   | |
#                                                       |_|   |_|
#
# Copyright (c) 2017-2023 Claudio André <claudioandre.br at gmail.com>
#
# This program comes with ABSOLUTELY NO WARRANTY; express or implied.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, as expressed in version 2, seen at
# http://www.gnu.org/licenses/gpl-2.0.html
###############################################################################

FROM ubuntu:23.04
LABEL maintainer Claudio André (c) 2017-2023 1.0.OpenCL
LABEL software CI for John the Ripper

RUN apt-get update -qq && \
    apt-get install -y \
        build-essential libssl-dev yasm libgmp-dev libpcap-dev pkg-config debhelper libnet1-dev \
        libbz2-dev wget llvm libomp-dev zlib1g-dev git clang afl zzuf \
        libpocl-dev ocl-icd-opencl-dev ocl-icd-libopencl1 pocl-opencl-icd opencl-headers && \
    useradd -U -m JtR

# USER JtR => it is much better to use root on Travis
ENV BASE ubuntu
CMD /bin/bash
