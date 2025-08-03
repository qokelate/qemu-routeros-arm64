#!/bin/bash


s=`realpath "$0"`
cd "$(dirname "$s")"


logfile='/tmp/qemu-ros.log'
pidfile='/tmp/qemu-ros.pid'


pkill -0 -F "$pidfile" && exit

echo "$(date '+%Y-%m-%d %H:%M:%S') waiting for network-online ..." > "$logfile"
while true; do
    a=`systemctl is-active network-online.target`
    [ "$a" = 'active' ] && break
    sleep 1
done


echo "$(date '+%Y-%m-%d %H:%M:%S') update network temporary ..." >> "$logfile"

nmcli connection modify --temporary \
br-lan1 \
ipv4.method disabled \
ipv6.method disabled \
-ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection up br-lan1


nmcli connection modify --temporary \
br-lan2 \
ipv4.method disabled \
ipv6.method disabled \
-ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection up br-lan2


nmcli connection modify --temporary \
br-wan \
ipv4.method disabled \
ipv6.method disabled \
-ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection up br-wan


nmcli connection modify --temporary br-kvm \
ipv4.method auto ipv6.method disabled \
-ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection up br-kvm


echo "$(date '+%Y-%m-%d %H:%M:%S') permit vlan all ..." >> "$logfile"
bridge vlan add dev br-lan1 self vid 2-4094
bridge vlan add dev br-lan2 self vid 2-4094
bridge vlan add dev br-kvm self vid 2-4094
bridge vlan add dev br-wan self vid 2-4094
bridge vlan add vid 2-4094 dev lan1
bridge vlan add vid 2-4094 dev lan2
bridge vlan add vid 2-4094 dev wan


echo "$(date '+%Y-%m-%d %H:%M:%S') waitting for all ready ..." >> "$logfile"
sleep 5


echo "$(date '+%Y-%m-%d %H:%M:%S') starting qemu-system-aarch64 ..." >> "$logfile"

netopt="queues=4,vhost=on,script=$PWD/ifup.sh,downscript=no"
drvopt="mq=on,vectors=8"

qemu-system-aarch64 -nographic -pidfile "$pidfile" \
-m 512M -M virt -enable-kvm -cpu host \
-bios "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd" \
-netdev "tap,ifname=ros-lan1,id=n1,$netopt" -device "virtio-net-pci,netdev=n1,mac=e8:0a:b9:11:11:11,$drvopt" \
-netdev "tap,ifname=ros-lan2,id=n2,$netopt" -device "virtio-net-pci,netdev=n2,mac=e8:0a:b9:22:22:22,$drvopt" \
-netdev "tap,ifname=ros-wan,id=n3,$netopt" -device "virtio-net-pci,netdev=n3,mac=e8:0a:b9:33:33:33,$drvopt" \
-netdev "tap,ifname=ros-kvm,id=n4,$netopt" -device "virtio-net-pci,netdev=n4,mac=e8:0a:b9:44:44:44,$drvopt" \
-device "nvme,drive=hd0,serial=BDCF8C72-9BE7-4118-B274-EAD8B0982915,bootindex=0" \
-drive "if=none,id=hd0,media=disk,discard=unmap,detect-zeroes=unmap,format=qcow2,file=$PWD/ros-7.16.2-arm64.qcow2"


echo "$(date '+%Y-%m-%d %H:%M:%S') qemu exited, restoring network ..." >> "$logfile"

nmcli connection modify --temporary br-lan1 ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection modify --temporary br-lan2 ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection modify --temporary br-wan ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''
nmcli connection modify --temporary br-kvm ipv4.method auto ipv6.method disabled -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes ''

nmcli connection up br-lan1
nmcli connection up br-lan2
nmcli connection up br-wan

echo "$(date '+%Y-%m-%d %H:%M:%S') all finished, quit ..." >> "$logfile"

exit



