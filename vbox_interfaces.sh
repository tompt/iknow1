#!/bin/bash
echo "configuracao automatica de interfaces";
texto=”enp0s”;

for x in {1..17}
do
echo “dhclient -r interface enps0s$x”;
dhclient -r enp0s$x;

#echo “dhclient enp0s$x”;
dhclient enp0s$x;
done

ifconfig | grep inet

echo "configuracao inicial:";
echo "4 adaptadaores de rede: 1-NAT, 2-Bridge Intel ethernet I217-LM, 3-host-only vbox_ether_adp3, 4-host-only vbox_ether_adp2";
echo "ferramentas";
echo "eth1 automatico (169.254.113.131/16), eth2 manual (192.168.3.1/24),eth3 manual(10.0.32.50/24)";

#wget hhttps://raw.githubusercontent.com/tompt/iknow1/master/vbox_interfaces.sh && sh ./vbox_interfaces.sh
