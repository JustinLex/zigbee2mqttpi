#!/bin/bash

# Script for patching the raspberry pi image
# DO NOT RUN THIS OUTSIDE OF A CONTAINER

# Copy source img
cp /root/src/fedora-coreos-36.20220522.3.0-metal.aarch64.img /root/src/z2m.img

# Install hybrid MBR table for compatibility with Raspberry Pi 3
dd if=/root/src/hybrid-mbr.img of=/root/src/z2m.img bs=512 count=1 conv=notrunc


set -e

# Keep original copy of the image
#cp /root/2022-01-28-raspios-bullseye-arm64-lite.img /root/zigbee2mqttpi.img
## expand disk image
#truncate -s 2G /root/src/zigbee2mqttpi.img
#virt-resize --expand /dev/sda2 /root/src/2022-04-04-raspios-bullseye-arm64-lite.img /root/src/zigbee2mqttpi.img

# Guestfish multi-command setup stuff
# See "USING REMOTE CONTROL ROBUSTLY FROM SHELL SCRIPTS"
# https://libguestfs.org/guestfish.1.html#guestfish-commands
# Might be possible to do this with fuse, but I don't think fuse works inside containers
guestfish[0]="guestfish"
guestfish[1]="--listen"
guestfish[2]="--format=raw"
guestfish[3]="-a"
guestfish[4]="/root/src/z2m.img"
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
#
#
#echo "installing k3os"
#tar -xzf /root/src/k3os-rootfs-arm64.tar.gz
#guestfish --remote -- copy-in /root/v0.21.5-k3s2r1/k3os /root/v0.21.5-k3s2r1/sbin /
#guestfish --remote -- copy-in /root/src/growpart /k3os/system/
#guestfish --remote -- copy-in /root/src/init.preinit /sbin/
#guestfish --remote -- copy-in /root/src/init_resize.sh /usr/lib/raspi-config/
#
## Append nfs to fstab
#guestfish --remote -- write-append /etc/fstab 'freenas.home.jlh.name:/mnt/solid/k8s/zigbee2mqtt /mnt nfs rw,hard,intr 0 0'
#
## Install zigbee2mqtt as a pod and have it start on startup
#guestfish --remote -- copy-in /root/src/zigbee2mqtt.yaml /root/
#guestfish --remote -- copy-in /root/src/zigbee2mqtt.service /lib/systemd/system/

wget https://github.com/pftf/RPi3/releases/download/v1.37/RPi3_UEFI_Firmware_v1.37.zip
mkdir efi
unzip RPi3_UEFI_Firmware_v1.37.zip -d efi
guestfish --remote -- copy-in /root/efi/* /

# exit
cleanup_guestfish
