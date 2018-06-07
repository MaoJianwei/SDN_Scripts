#!/bin/bash
# -----------------------------------------------------------------------------
#
# Forms ONOS cluster using REST API of each separate instance.
#
# Author Blog:    www.MaoJianwei.com
#
# Simple usage:   ./autoOnosCluster.sh ip1 ip2 ip3
# 
# Example:        ./autoOnosCluster.sh 192.168.0.1 192.168.0.2 192.168.0.3 192.168.0.4 192.168.0.5
#
# -----------------------------------------------------------------------------

function usage() {
    echo "usage: ./autoOnosCluster.sh ip1 ip2 ip3 ..." && exit 1
}

# Scan arguments for user/password or other options...
while getopts u:p:s: o; do
    case "$o" in
        u) user=$OPTARG;;
        p) password=$OPTARG;;
        s) partitionsize=$OPTARG;;
        *) usage;;
    esac
done
# ONOS_WEB_USER=${ONOS_WEB_USER:-onos} # ONOS WEB User defaults to 'onos'
# ONOS_WEB_PASS=${ONOS_WEB_PASS:-rocks} # ONOS WEB Password defaults to 'rocks'
user=${user:-"karaf"}
password=${password:-"karaf"}
# let OPC=$OPTIND-1
# shift $OPC

[ $# -lt 2 ] && usage

ip=$1
shift
nodes=$*

ipPrefix=${ip%.*}

aux=/tmp/maoOnosCluster.json
trap "rm -f $aux" EXIT

echo "{ \"nodes\": [ { \"ip\": \"$ip\" }" > $aux
for node in $nodes; do
    echo ", { \"ip\": \"$node\" }" >> $aux
done
echo "], \"ipPrefix\": \"$ipPrefix.*\"" >> $aux
if ! [ -z ${partitionsize} ]; then
    echo ", \"partitionSize\": $partitionsize" >> $aux
fi
echo " }" >> $aux


cat $aux
echo $user
echo $password
for node in $ip $nodes; do
    echo "Forming cluster on $node..."
 
     curl --user $user:$password -X POST \
         http://$node:8181/onos/v1/cluster/configuration -d @$aux
done
