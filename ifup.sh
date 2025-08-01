#!/bin/bash

#echo "$@" >> /tmp/up.txt

dev="$1"
ip link set "$dev" up
brctl addif "br-${dev:4}" "$dev"

exit

