#!/usr/bin/env bash

CONFIGS=$(psec environments path)/configs
set -euxo pipefail

crudini --set ${CONFIGS}/10.0.8.100/wireguard/user1.conf Interface Table off

wg-quick up ${CONFIGS}/10.0.8.100/wireguard/user1.conf

wg

ifconfig user1

ip route add 172.16.0.1/32 dev user1

fping -t 900 -c3 -r3 -Dse 10.0.8.100 172.16.0.1

wg | grep "latest handshake"

host google.com 172.16.0.1

echo "WireGuard tests passed"

wg-quick down ${CONFIGS}/10.0.8.100/wireguard/user1.conf
