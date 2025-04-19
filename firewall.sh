#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
clear

readonly IFACE=$(ip route  | awk '/^default/ {print $5; exit}')
readonly NETWORK=$(ip route | awk -v iface="$IFACE" '$0 ~ iface {print $1; exit}')

if [[ -z "$NETWORK" || -z "$IFACE" ]]; then
    echo "Erro ao obter NETWORK ou IFACE. Saindo..."
    exit 1
fi

iptables -F
iptables -X

iptables -P INPUT   DROP
iptables -P OUTPUT  DROP
iptables -P FORWARD DROP

iptables -N LOGDROP
iptables -A LOGDROP \
    -m limit --limit 5/minute --limit-burst 10 \
    -j LOG --log-prefix "DROP: " --log-level 4
iptables -A LOGDROP -j DROP

iptables -A INPUT  -m conntrack --ctstate INVALID -j DROP
iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP

# loopback
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT \
    -p icmp --icmp-type echo-request \
    -s "$NETWORK" -i "$IFACE" -j ACCEPT

iptables -A INPUT -p tcp -i "$IFACE" --dport 80 -j ACCEPT

iptables -A INPUT -p tcp --dport 22 \
    -m limit --limit 3/minute --limit-burst 5 \
    -j LOG --log-prefix "SSH attempt: " --log-level 4
iptables -A INPUT -p tcp -i "$IFACE" --dport 22 \
    -s "$NETWORK" -j ACCEPT

iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

iptables -A OUTPUT -p udp --dport 68  -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT

iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT  -j LOGDROP
iptables -A OUTPUT -j LOGDROP

exit 0
