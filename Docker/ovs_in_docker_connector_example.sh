#!/bin/bash

sudo ls


PID_A=`sudo docker inspect -f '{{.State.Pid}}' "ovsAccess3"`
PID_C=`sudo docker inspect -f '{{.State.Pid}}' "ovsCore"`




echo 1
sudo ip link add testMaoA3 type veth peer name testMaoC3
echo 2
sudo ip link set testMaoA3 netns $PID_A
sudo ip link set testMaoC3 netns $PID_C
echo 3
sudo docker exec ovsAccess3 ip link set dev testMaoA3 name testMaoA3
sudo docker exec ovsAccess3 ovs-vsctl add-port ovsAccess3 testMaoA3
sudo docker exec ovsAccess3 ip link set testMaoA3 up
echo 4
sudo docker exec ovsCore ip link set dev testMaoC3 name testMaoC3
sudo docker exec ovsCore ovs-vsctl add-port ovsCore testMaoC3
sudo docker exec ovsCore ip link set testMaoC3 up
echo 5
