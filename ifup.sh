#!/bin/bash

#echo "$@" >> /tmp/up.txt

dev="$1"
ip link set "$dev" up
brctl addif "br-${dev:4}" "$dev"
bridge vlan add vid 2-4094 dev "$dev"

exit

