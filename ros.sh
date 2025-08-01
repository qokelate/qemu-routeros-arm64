#!/bin/bash

s=`realpath "$0"`
cd "$(dirname "$s")"


nmcli connection modify --temporary \
br-lan1 \
ipv4.addresses 169.254.0.1/32 \
ipv4.method manual \
ipv6.method disabled
nmcli connection up br-lan1


nmcli connection modify --temporary \
br-lan2 \
ipv4.addresses 169.254.0.2/32 \
ipv4.method manual \
ipv6.method disabled
nmcli connection up br-lan2


nmcli connection modify --temporary \
br-wan \
ipv4.addresses 169.254.0.3/32 \
ipv4.method manual \
ipv6.method disabled
nmcli connection up br-wan



qemu-system-aarch64 -nographic \
-m 512M -M virt -enable-kvm -cpu host \
-bios "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd" \
-netdev 'bridge,br=br-kvm,id=n4' -device 'virtio-net-pci,netdev=n4,mac=d2:67:e2:44:44:44' \
-netdev 'bridge,br=br-lan1,id=n1' -device 'virtio-net-pci,netdev=n1,mac=d2:67:e2:11:11:11' \
-netdev 'bridge,br=br-lan2,id=n2' -device 'virtio-net-pci,netdev=n2,mac=d2:67:e2:22:22:22' \
-netdev 'bridge,br=br-wan,id=n3' -device 'virtio-net-pci,netdev=n3,mac=d2:67:e2:33:33:33' \
-device 'nvme,drive=hd0,serial=BDCF8C72-9BE7-4118-B274-EAD8B0982915,bootindex=0' \
-drive "if=none,id=hd0,media=disk,discard=unmap,detect-zeroes=unmap,file=$PWD/chr-7.16.2-arm64.qcow2"




nmcli connection modify --temporary br-lan1 ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection modify --temporary br-lan2 ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection modify --temporary br-wan ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection modify --temporary br-kvm ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''

nmcli connection up br-lan1
nmcli connection up br-lan2
nmcli connection up br-wan

exit


