# $1 NIC name
NIC_INFO=$(ifconfig $1)
NIC_RX_OLD=$(echo $(expr "${NIC_INFO}" : ".*\(RX packets \([0-9]\)*  bytes \([0-9]\)* \).*") | awk '{print $5}')
NIC_TX_OLD=$(echo $(expr "${NIC_INFO}" : ".*\(TX packets \([0-9]\)*  bytes \([0-9]\)* \).*") | awk '{print $5}')

NIC_RX_NEW=
NIC_TX_NEW=

# save in the current directory of interactive CLI
RecordFilename="$(pwd)/$1_$(date +"%H_%M_%S").csv"
echo "Moment(seconds),RX(Mbps),TX(Mbps)" > $RecordFilename

momentCount=0
while true
do
    sleep 1

    NIC_INFO=$(ifconfig $1)
    NIC_RX_NEW=$(echo $(expr "${NIC_INFO}" : ".*\(RX packets \([0-9]\)*  bytes \([0-9]\)* \).*") | awk '{print $5}')
    NIC_TX_NEW=$(echo $(expr "${NIC_INFO}" : ".*\(TX packets \([0-9]\)*  bytes \([0-9]\)* \).*") | awk '{print $5}')


    NIC_RX_Rate=`echo "scale=6; (${NIC_RX_NEW}-${NIC_RX_OLD})*8/1000/1000" | bc`
    NIC_TX_Rate=`echo "scale=6; (${NIC_TX_NEW}-${NIC_TX_OLD})*8/1000/1000" | bc`

    # todo - record
    echo "${momentCount},${NIC_RX_Rate},${NIC_TX_Rate}" >> ${RecordFilename}
    let 'momentCount++'

    NIC_RX_OLD=${NIC_RX_NEW}
    NIC_TX_OLD=${NIC_TX_NEW}

    clear
    echo 
    echo "Record Data File: ${RecordFilename}"
    echo ""
    echo "----------------------------------------"
    echo ""
    echo ${NIC_INFO}
    echo ""
    echo "----------------------------------------"
    echo ""
    echo "$1_Rx_bytes: ${NIC_RX_NEW}"
    echo ""
    echo "$1_Tx_bytes: ${NIC_TX_NEW}"
    echo ""
    echo "----------------------------------------"
    echo ""
    echo "$1_Rx_Mbps:  ${NIC_RX_Rate}"
    echo ""
    echo "$1_Tx_Mbps:  ${NIC_TX_Rate}"
done
