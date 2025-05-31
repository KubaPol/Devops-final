#!/bin/bash

# check rights
if [ "$(id -u)" != "0" ]; then
    echo "Start with sudo" >&2
    exit 1
fi

# check args
if [ $# -ne 3 ]; then
    echo "Usage: $0 <interface> <protocol> <port>" >&2
    echo "Example: $0 eth0 udp 1194" >&2
    exit 1
fi

INTERFACE=$1
PROTOCOL=$2
PORT=$3

# check is exist int
if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
    echo "Error: Interface $INTERFACE does not exist" >&2
    exit 1
fi

# check protocol
if [ "$PROTOCOL" != "udp" ] && [ "$PROTOCOL" != "tcp" ]; then
    echo "Error: Protocol must be 'udp' or 'tcp'" >&2
    exit 1
fi

# check port
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "Error: Port must be a number between 1 and 65535" >&2
    exit 1
fi

# Is tun exist
if ! ip link show tun0 > /dev/null 2>&1; then
    echo "Warning: tun interface not found. Rules will apply once OpenVPN creates the interface."
fi

iptables -F

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 22 -s 37.204.51.172 -j ACCEPT
iptables -A INPUT -i "$INTERFACE" -m state --state NEW -p "$PROTOCOL" --dport "$PORT" -j ACCEPT || { echo "Failed to set INPUT rule for $INTERFACE" >&2; exit 1; }

iptables -A INPUT -i tun+ -j ACCEPT || echo "Warning: INPUT rule for tun+ may not apply until tun interface exists"
iptables -A FORWARD -i tun+ -j ACCEPT || echo "Warning: FORWARD rule for tun+ may not apply until tun interface exists"
iptables -A FORWARD -i tun+ -o "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT || echo "Warning: FORWARD rule for tun+ to $INTERFACE may not apply until tun interface exists"
iptables -A FORWARD -i "$INTERFACE" -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT || echo "Warning: FORWARD rule for $INTERFACE to tun+ may not apply until tun interface exists"

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$INTERFACE" -j MASQUERADE || { echo "Failed to set NAT rule for $INTERFACE" >&2; exit 1; }
MY_IP="91.132.92.115"
MY_IP2="37.204.51.172"
iptables -A INPUT -p tcp --dport 9093 -s "$MY_IP2" -j ACCEPT || { echo "Failed to open port 9093" >&2; exit 1; }
iptables -A INPUT -p tcp --dport 9093 -s "$MY_IP" -j ACCEPT || { echo "Failed to open port 9093" >&2; exit 1; }

iptables -A INPUT -p tcp --dport 9176 -s 127.0.0.1 -j ACCEPT || { echo "Failed to open port 9176" >&2; exit 1; }

iptables -A INPUT -p tcp --dport 9090 -s "$MY_IP2" -j ACCEPT || { echo "Failed to open port 9090" >&2; exit 1; }
iptables -A INPUT -p tcp --dport 9090 -s "$MY_IP" -j ACCEPT || { echo "Failed to open port 9090" >&2; exit 1; }

iptables -A INPUT -p tcp --dport 3000 -s "$MY_IP2" -j ACCEPT || { echo "Failed to open port 3000" >&2; exit 1; }
iptables -A INPUT -p tcp --dport 3000 -s "$MY_IP" -j ACCEPT || { echo "Failed to open port 3000" >&2; exit 1; }

iptables -A INPUT -p tcp --dport 9100 -s 127.0.0.1 -j ACCEPT || { echo "Failed to open port 9100" >&2; exit 1; }
iptables -A INPUT -j DROP
iptables-save > /etc/iptables/rules.v4
echo "iptables rules applied successfully"
exit 0
