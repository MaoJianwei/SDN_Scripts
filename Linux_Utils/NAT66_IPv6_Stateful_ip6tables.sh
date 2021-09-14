
# eth0 in LAN, wlan0 in WAN, with security, obtain global IPv6 address by DHCPv6 (permit DHCPv6 and ICMPv6).

ip addr add 3::9999/64 dev eth0
sysctl net.ipv6.conf.all.forwarding=1

# with security
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

# obtain global IPv6 address by DHCPv6 (permit DHCPv6 and ICMPv6).
ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
ip6tables -A INPUT -p udp -m udp --dport 546 -j ACCEPT

ip6tables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
ip6tables -A POSTROUTING -t nat -o wlan0 -j MASQUERADE
