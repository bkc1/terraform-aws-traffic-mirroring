#! /bin/bash

set -ex

sleep 5

yum -y install nmap-ncat

# Start dummy listener
screen -d -m ncat -vlk 8888

# Create VXLAN interface
ip link add vxlan1 type vxlan id 1111 dev eth0 dstport 4789
ip link set vxlan1 up

ifconfig