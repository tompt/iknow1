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

ifconfig | grep 192.168.3
