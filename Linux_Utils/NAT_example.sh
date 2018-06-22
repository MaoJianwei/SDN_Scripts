
step=3
case $1 in
    -c)
        while true
        do
        	# unknown bug, reset NIC will resolve.
            echo "Config Client..."
            echo password | sudo -S ip route replace default via 10.103.89.170 metric 0
            echo password | sudo -S ip route replace 10.0.0.0/8 via 10.103.89.1 metric 0
            sleep ${step}
        done
    ;;
    -s)
        echo "Config Server 1..."
        echo password | sudo -S iptables -D FORWARD 1 # one line for delete one rule in FORWARD chain
        echo password | sudo -S iptables -D FORWARD 1

        echo password | sudo -S sysctl net.ipv4.ip_forward=1
        echo password | sudo -S iptables -t nat -A POSTROUTING -o ens192 -j MASQUERADE
        echo password | sudo -S iptables -A FORWARD -i ens192 -o ens160 -m state --state RELATED,ESTABLISHED -j ACCEPT
        echo password | sudo -S iptables -A FORWARD -i ens160 -o ens192 -j ACCEPT

        resetNICtime=0
        while true
        do
            echo "Config Server 2..."

            if [ `expr ${resetNICtime} % 180` == 0 ]
            then
                echo "reset NIC..."
                sudo ifconfig ens192 down && sudo ifconfig ens192 up
                sleep ${step}
                resetNICtime=0
            fi

            echo password | sudo -S ip route del default via 10.103.89.1 dev ens192
            echo password | sudo -S ip route replace default via 10.103.89.1 dev ens192 metric 0
            echo password | sudo -S ip route del 10.3.8.211/32 via 10.103.89.1 dev ens192 metric 0
            echo password | sudo -S ip route replace 10.3.8.211/32 via 10.103.89.1 dev ens192 metric 0

            sleep ${step}
            resetNICtime=`expr ${resetNICtime} + ${step}`
        done
    ;;
esac
