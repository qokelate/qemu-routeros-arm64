#!/bin/bash

apt install -y network-manager || exit

systemctl stop systemd-networkd.service
systemctl disable systemd-networkd.service
systemctl mask systemd-networkd.service
systemctl unmask NetworkManager
systemctl enable NetworkManager
systemctl restart NetworkManager

rm -rf /etc/netplan
mkdir -pv /etc/netplan
cat <<EOF >/etc/netplan/99-netcfg.yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    alleths:
      dhcp4: true
      dhcp6: false
EOF

exit


