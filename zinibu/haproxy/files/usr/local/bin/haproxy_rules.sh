#!/bin/bash -e
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.ip_nonlocal_bind=1

sysctl -w net.ipv4.conf.default.rp_filter=2
sysctl -w net.ipv4.conf.all.rp_filter=2
sysctl -w net.ipv4.conf.eth0.rp_filter=0

iptables -t mangle -N DIVERT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

#iptables -t mangle -A DIVERT -j MARK --set-mark 111
#ip rule add fwmark 111 lookup 100
#ip route flush cache

#iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
