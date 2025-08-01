#!/bin/bash

set -ex

s=`realpath "$0"`
cd "$(dirname "$s")"


netopt="queues=4,vhost=on"
drvopt="mq=on,vectors=8"

qemu-system-aarch64 -nographic \
-m 512M -M virt -enable-kvm -cpu host \
-bios "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd" \
-netdev "tap,br=br-lan1,id=n1,$netopt" -device "virtio-net-pci,netdev=n1,mac=d2:67:e2:11:11:11,$drvopt" \
-netdev "tap,br=br-lan2,id=n2,$netopt" -device "virtio-net-pci,netdev=n2,mac=d2:67:e2:22:22:22,$drvopt" \
-netdev "tap,br=br-wan,id=n3,$netopt" -device "virtio-net-pci,netdev=n3,mac=d2:67:e2:33:33:33,$drvopt" \
-netdev "tap,br=br-kvm,id=n4,$netopt" -device "virtio-net-pci,netdev=n4,mac=d2:67:e2:44:44:44,$drvopt" \
-device "nvme,drive=hd0,serial=BDCF8C72-9BE7-4118-B274-EAD8B0982915,bootindex=0" \
-drive "if=none,id=hd0,media=disk,discard=unmap,detect-zeroes=unmap,format=qcow2,file=$PWD/ros-7.16.2-arm64.qcow2"


exit


