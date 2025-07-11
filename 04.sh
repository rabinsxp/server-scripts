# nano /etc/sysconfig/network-scripts/ifcfg-eth0

#Add the file 
cp ifcfg-eth0 /etc/sysconfig/network-scripts/

# sudo systemctl restart network // this has been depracated so use the following

sudo systemctl restart NetworkManager

#or the following

nmcli connection reload
nmcli connection up br0

