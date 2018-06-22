
# # --- clear legacy configuration ---
echo password | sudo -S ifconfig eno16777728 0 # outside
# echo password | sudo -S ifconfig h288-eth1 0 # inside
echo password | sudo -S ip tunnel del greMao

echo password | sudo -S iptables -D FORWARD 1 # one line for delete one rule in FORWARD chain
echo password | sudo -S iptables -D FORWARD 1

# --- GRE ---
# echo password | sudo -S ifconfig eno16777728 10.0.0.1 netmask 255.255.0.0
# echo password | sudo -S ip tunnel add greMao mode gre remote 10.1.0.1 local 10.0.0.1 ttl 123
# echo password | sudo -S ip link set greMao up
# echo password | sudo -S ip addr add 10.3.0.1/16 dev greMao
# echo password | sudo -S ip route add 10.1.0.0/16 via 10.0.0.1 dev eno16777728

echo password | sudo -S ifconfig eno16777728 10.117.2.62 netmask 255.255.255.224
echo password | sudo -S ip route add default via 10.117.2.33 dev eno16777728
echo password | sudo -S ip tunnel add greMao mode gre remote 10.117.2.47 local 10.117.2.62 ttl 123
echo password | sudo -S ip link set greMao up
# echo password | sudo -S ip addr add 192.168.1.1/24 dev greMao
# echo password | sudo -S ip route add 192.168.2.0/24 via 192.168.1.1 dev greMao
echo password | sudo -S ip route add 192.168.1.0/24 dev greMao




# --- NAT --- eth0:outside --- eth1:inside
# echo password | sudo -S sysctl net.ipv4.ip_forward=1
# echo password | sudo -S iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# echo password | sudo -S iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
# echo password | sudo -S iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT



# echo password | sudo -S ifconfig h288-eth1 192.168.2.1 netmask 255.255.255.0
echo password | sudo -S sysctl net.ipv4.ip_forward=1
echo password | sudo -S iptables -t nat -A POSTROUTING -o eno16777728 -j MASQUERADE
echo password | sudo -S iptables -A FORWARD -i eno16777728 -o h288-eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo password | sudo -S iptables -A FORWARD -i h288-eth1 -o eno16777728 -j ACCEPT
