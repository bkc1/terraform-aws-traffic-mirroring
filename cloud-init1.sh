#! /bin/bash

set -ex

sleep 5

yum -y install nmap-ncat

# Start dummy listener
screen -d -m ncat -vlk 8888

