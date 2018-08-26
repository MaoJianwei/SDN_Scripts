DHCP_MONITOR_DIR="/home/mao/dhcp"
rm $DHCP_MONITOR_DIR/index.html
mkdir -p $DHCP_MONITOR_DIR
cd $DHCP_MONITOR_DIR

count=1


# use apache2 # python -m SimpleHTTPServer 80 > /dev/null &

echo "Start FNL DHCP Monitor..."

while true
do

    # output to console
    
    clear

    echo ""
    echo "FNL private DHCP + NAT, active VMs are as bellow, show times $count :"
    echo ""
    dhcpd-pools --config=/etc/dhcp/dhcpd.conf --leases=/var/lib/dhcp/dhcpd.leases --color=always --format=J | grep macaddress | grep ip
    echo ""
    dhcpd-pools --config=/etc/dhcp/dhcpd.conf --leases=/var/lib/dhcp/dhcpd.leases --color=always --format=J | grep defined | grep used



    # output to Web

    echo '<html><body>' > ./index.html
    echo "FNL private DHCP + NAT, active VMs are as bellow, show times $count :<br/>" >> ./index.html
    echo "<br/>" >> ./index.html
    echo '<table border="0"><tr><td style="vertical-align: top;">' >> ./index.html
    echo '<table border="1"><tr><th style="min-width: 150px;">IP</th><th style="min-width: 200px;">MAC</th></tr>' >> ./index.html
    dhcpd-pools --config=/etc/dhcp/dhcpd.conf --leases=/var/lib/dhcp/dhcpd.leases --color=always --format=J | grep macaddress | grep ip | sed 's|},|}|g'| sed 's|{ "ip":"|<tr><td>|g' | sed 's|" }|</td></tr>|g' | sed 's|", "macaddress":"|</td><td>|g' >> ./index.html
    
    echo '</table></td><td style="vertical-align: top;">' >> ./index.html
    echo '<table border="1"><tr><th style="min-width: 150px;">Status</th><th style="min-width: 200px;">Value</th></tr>' >> ./index.html
    dhcpd-pools --config=/etc/dhcp/dhcpd.conf --leases=/var/lib/dhcp/dhcpd.leases --color=always --format=J | grep defined | grep used | sed 's|, "|</td></tr><tr><td>|g' | sed 's|{ "|<tr><td>|g' | sed 's| }|</td></tr>|g' | sed 's|":"|</td><td>|g' | sed 's|":|</td><td>|g' | sed 's|"||g' >> ./index.html
    
    echo "</table></td></tr></table>" >> ./index.html
    echo "<br/></body></html>" >> ./index.html



    ((count++))

    sleep 1
done
