
# eth0 in LAN, wlan0 in WAN

ip addr add 3::9999/64 dev eth0
sysctl net.ipv6.conf.all.forwarding=1

# Security for Gateway
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

# advertise gateway by ICMPv6 Router Advertisement(RA)
ip6tables -A INPUT -p ipv6-icmp -j ACCEPT

# obtain global IPv6 address by DHCPv6
ip6tables -A INPUT -p udp -m udp --dport 546 -j ACCEPT
ip6tables -A INPUT -p udp -m udp --dport 547 -j ACCEPT

# Stateful NAT66 for Secure access of public IPv6 network
ip6tables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
ip6tables -A POSTROUTING -t nat -o wlan0 -j MASQUERADE
