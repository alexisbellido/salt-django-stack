#!/bin/bash -e
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.ip_nonlocal_bind=1
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
iptables -t mangle -N DIVERT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100
ip route flush cache
