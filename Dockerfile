FROM ubuntu:20.04 as ziphack
WORKDIR /root
RUN apt-get update
RUN apt-get install unzip
ADD aosp_cf_x86_64_phone-img-6999531.zip /root/aosp_cf_x86_64_phone-img.zip
RUN unzip -q aosp_cf_x86_64_phone-img.zip -d aosp_cf_x86_64_phone-img

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential

# needed for debuild
RUN apt-get install -y devscripts

# build dependencies
RUN apt-get install -y config-package-dev debhelper-compat

# install dependencies
RUN apt-get install -y bridge-utils dnsmasq-base f2fs-tools iptables libarchive-tools libdrm2 libfdt1 libgl1 libusb-1.0-0 libwayland-client0 libwayland-server0 net-tools python2.7

# a syslog is required for crosvm to run
RUN apt-get install -y rsyslog

# user needs to be member of these groups
RUN groupadd cvdnetwork && groupadd kvm && usermod -aG cvdnetwork root && usermod -aG kvm root

# clone cuttlefish
WORKDIR /root
RUN git clone https://github.com/google/android-cuttlefish

# build .deb packages
WORKDIR /root/android-cuttlefish
RUN debuild -i -us -uc -b

# install .deb packages
RUN dpkg -i ../cuttlefish-common_*_amd64.deb
RUN apt-get install -f

# copy root filesystem
WORKDIR /root
COPY --from=ziphack /root/aosp_cf_x86_64_phone-img/ cf/
ADD cvd-host_package.tar.gz cf/

CMD /bin/bash
