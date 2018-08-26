
# ens192 in LAN, ens160 in WAN

sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE
sudo iptables -A FORWARD -i ens160 -o ens192 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i ens192 -o ens160 -j ACCEPT
