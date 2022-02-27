#!/bin/bash

# Script for patching the raspberry pi image
# DO NOT RUN THIS OUTSIDE OF A CONTAINER

set -e

# Keep original copy of the image
#cp /root/2022-01-28-raspios-bullseye-arm64-lite.img /root/zigbee2mqttpi.img
# expand disk image
truncate -s 3G /root/src/zigbee2mqttpi.img
virt-resize --expand /dev/sda2 /root/src/2022-01-28-raspios-bullseye-arm64-lite.img /root/src/zigbee2mqttpi.img

# Guestfish multi-command setup stuff
# See "USING REMOTE CONTROL ROBUSTLY FROM SHELL SCRIPTS"
# https://libguestfs.org/guestfish.1.html#guestfish-commands
# Might be possible to do this with fuse, but I don't think fuse works inside containers
guestfish[0]="guestfish"
guestfish[1]="--listen"
guestfish[2]="--format=raw"
guestfish[3]="-a"
guestfish[4]="/root/src/zigbee2mqttpi.img"
guestfish[5]="-m"
guestfish[6]="/dev/sda2"

GUESTFISH_PID=
eval $("${guestfish[@]}")
if [ -z "$GUESTFISH_PID" ]; then
   echo "error: guestfish didn't start up, see error messages above"
   exit 1
fi

cleanup_guestfish ()
{
   guestfish --remote -- exit >/dev/null 2>&1 ||:
}
trap cleanup_guestfish EXIT ERR

# Note that we can't use guestfish mount-local because that needs fuse
# wget https://github.com/rancher/k3os/releases/download/v0.21.5-k3s2r1/k3os-rootfs-arm64.tar.gz

## Free up space for k3os
#guestfish --remote -- rm-rf /usr/lib/firmware

echo "installing k3os"
tar -xzf /root/src/k3os-rootfs-arm64.tar.gz
guestfish --remote -- copy-in /root/v0.21.5-k3s2r1/k3os /root/v0.21.5-k3s2r1/sbin /
guestfish --remote -- copy-in /root/src/init.preinit /sbin/
guestfish --remote -- copy-in /root/src/init_resize.sh /usr/lib/raspi-config/

echo "installing config and manifests"
# shellcheck disable=SC2034
# use j2cli to template manifests into config.yaml
export manifest="$(base64 -w 0 < /root/src/zigbee2mqtt.yaml)"
j2 /root/src/config.yaml > /root/config.yaml
guestfish --remote -- copy-in /root/config.yaml /k3os/system/

# exit
cleanup_guestfish
