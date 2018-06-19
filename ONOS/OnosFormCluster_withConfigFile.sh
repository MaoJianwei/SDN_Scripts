
# Recommend to use autoOnosCluster.sh
echo "------  Recommend to use autoOnosCluster.sh  ------"



# Push Cluster Config by REST API
# 
# usage: 
# ./OnosFormCluster.sh < clusterNode.cfg
# 
# or input the IPs of each cluster instance by hand.
#
# Example:
# --- clusterNode.cfg ---
# 172.17.0.2
# 172.17.0.3
# 172.17.0.4
# 172.17.0.5
# 172.17.0.6
# mao
# 
# --- clusterNode.cfg ---
# 
# author: Mao Jianwei @ BUPT FNLab




JSON_HEAD="{\"nodes\": ["
JSON_TAIL="]}"
# JSON_NODE="{\"id\":\"$1\",\"ip\":\"$1\",\"tcpPort\":9876,\"status\":\"ACTIVE\"}"

node_count=0
recent_node=""
INPUT_END="mao"
while [ "${recent_node}" != "${INPUT_END}" ]
do
    let "node_count++"
    read -p "Cluster node ${node_count} IP: " recent_node
    nodes[${node_count}]=${recent_node}
done



json=${JSON_HEAD}

for ((i=1;i<${#nodes[*]};i++))
do
    json+="{\"id\":\"${nodes[$i]}\",\"ip\":\"${nodes[$i]}\",\"tcpPort\":9876,\"status\":\"ACTIVE\"}"
    if (($i!=(${#nodes[*]}-1)))
    then
        json+=","
    fi
done

json+=${JSON_TAIL}
echo ${json}



for ((i=1;i<${#nodes[*]};i++))
do
    curl -u "karaf:karaf" --header "\'Content-Type: application/json\'" --header "\'Accept: application/json\'" -d "${json}" "http://${nodes[$i]}:8181/onos/v1/cluster/configuration" &
done
