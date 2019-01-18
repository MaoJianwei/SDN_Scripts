
cd /home/mao/onos      # cd $ONOS_ROOT

ONOS_VERSION="2.1.0-SNAPSHOT"
KARAF_VERSION="4.2.2"


# Author Blog:  www.MaoJianwei.com

# -----------------------------
# Usage:
# 
# First, modify the first three lines of me. Recommend to put ONOS source code in your home directory
# 
# 1. Build and run ONOS:                       ./autoONOS_Bazel.sh -b
# 2. Just run last-built ONOS:                 ./autoONOS_Bazel.sh
# 3. Just build ONOS, not run:                 ./autoONOS_Bazel.sh -jb
# 4. Stop ONOS and Clean all executive files:  ./autoONOS_Bazel.sh -c
# 5. Login ONOS CLI:                           ./autoONOS_Bazel.sh -k
# 
# -----------------------------


case $1 in
    -k)
        /tmp/onos-${ONOS_VERSION}/apache-karaf-${KARAF_VERSION}/bin/client
        exit 0
        ;;
    -c)
        /tmp/onos-${ONOS_VERSION}/apache-karaf-${KARAF_VERSION}/bin/stop
        sleep 3
        /tmp/onos-${ONOS_VERSION}/apache-karaf-${KARAF_VERSION}/bin/status
        rm -rf /tmp/onos*/
        exit 0
        ;;
    -t)
        echo " --- Not support Test with Bazel --- "
        exit 0
        ;;
    -b)
        bazel build onos
        ;;
    -jb)
        bazel build onos
        exit 0
        ;;
    *)
        ;;
esac

echo " --- Updating ONOS... ---"
# git pull origin master

echo " --- Build new ONOS... ---"
# bazel build onos

#echo " --- Config firewall... ---"
#echo $1 | sudo -S iptables -I INPUT -p TCP --dport 8181 -j ACCEPT
#echo $1 | sudo -S iptables -I INPUT -p TCP --dport 6653 -j ACCEPT
#echo $1 | sudo -S iptables -I INPUT -p TCP --dport 6633 -j ACCEPT
#echo ""
shift

echo " --- Run ONOS... ---"
tar -zxf ./bazel-bin/onos.tar.gz -C /tmp/
/tmp/onos-${ONOS_VERSION}/apache-karaf-${KARAF_VERSION}/bin/start debug # Caution! Remote debug is enabled. can delete 'debug' to disable it.
sleep 3
/tmp/onos-${ONOS_VERSION}/apache-karaf-${KARAF_VERSION}/bin/status
exit 0
