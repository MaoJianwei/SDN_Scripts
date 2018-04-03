cd /home/mao/onos

case $1 in
    -c)
        /tmp/onos-1.13.0-SNAPSHOT/apache-karaf-3.0.8/bin/stop
        sleep 3
        /tmp/onos-1.13.0-SNAPSHOT/apache-karaf-3.0.8/bin/status
        rm -rf /tmp/onos*/
        exit 0
        ;;
    *)
        ;;
esac

echo " --- Updating ONOS... ---"
git pull origin master

echo " --- Build new ONOS... ---"
./tools/build/onos-buck build onos --show-output

#echo " --- Config firewall... ---"
#echo $1 | sudo -S iptables -I INPUT -p TCP --dport 8181 -j ACCEPT
#echo $1 | sudo -S iptables -I INPUT -p TCP --dport 6653 -j ACCEPT
#echo $1 | sudo -S iptables -I INPUT -p TCP --dport 6633 -j ACCEPT
#echo ""
shift

echo " --- Run ONOS... ---"
tar -zxf ./buck-out/gen/tools/package/onos-package/onos.tar.gz -C /tmp/
/tmp/onos-1.13.0-SNAPSHOT/apache-karaf-3.0.8/bin/start debug # Caution! Remote debug is enabled. can delete 'debug' to disable it.
sleep 3
/tmp/onos-1.13.0-SNAPSHOT/apache-karaf-3.0.8/bin/status
exit 0
