#!/bin/bash

name="$1"
[ -z "$name" ] && name='br0'

#新建网桥
nmcli -g GENERAL.HWADDR device show "$name" || \
nmcli connection add type bridge ifname "$name" con-name "$name"

#关闭stp
nmcli connection modify "$name" bridge.stp no

#设置IP
nmcli connection modify "$name" ipv6.method disabled
nmcli connection modify "$name" ipv4.method disabled

#生效
# nmcli device reapply "$name"
nmcli connection up "$name"
# ifconfig "$name" up

# 查看当前连接
nmcli connection show

exit

