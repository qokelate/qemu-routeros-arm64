#!/bin/bash

apt install -y qemu-system-x86 qemu-utils bridge-utils ethtool network-manager unzip net-tools
apt install -y qemu-system-arm qemu-kvm qemu-efi-aarch64

mkdir -pv '/etc/qemu'
echo 'allow all'>/etc/qemu/bridge.conf

exit


