#!/bin/bash 

# add dtoverlay=dwc2 to /boot/firmware/config.txt 
# Add dtoverlay=dwc2 to the /boot/config.txt file
# Add modules-load=dwc2 to the end of /boot/cmdline.txt file
# Add libcomposite to the end of the /etc/modules file

# modprobe libcomposite

cd /sys/kernel/config/usb_gadget/
mkdir composite && cd composite

echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB 2.0

# https://www.usb.org/defined-class-codes
#echo 0xEF > bDeviceClass # Miscellaneous Device
echo 0x00 > bDeviceClass # Defined at Interface level
echo 0x00 > bDeviceSubClass
echo 0x00 > bDeviceProtocol
echo 0x08 > bMaxPacketSize0

mkdir -p strings/0x409
echo `cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2` > strings/0x409/serialnumber
echo "ZHOU INC"        > strings/0x409/manufacturer
echo "rPi NCM+ACM"   > strings/0x409/product

# NCM
mkdir -p functions/ncm.usb0  # network
# HOST MAC ZHOUH:last two digi of serail number
# SELF MAC ZHOUS:last two digi of serail number
HOST="5A:48:4F:55:48:83" # "HostPC"
SELF="5A:48:4F:55:53:83" # "BadUSB"
echo $HOST > functions/ncm.usb0/host_addr
echo $SELF > functions/ncm.usb0/dev_addr

# Serial, sudo systemctl enable getty@ttyGS0.service to enble login
# screen /dev/tty.usbmodem14101 115200
# CTL-a d
mkdir -p functions/acm.gs0    # serial

# config c.1 for ncm and acm
mkdir -p         configs/c.1/strings/0x409
echo "rPi NCM+ACM" > configs/c.1/strings/0x409/configuration
echo 1000 > configs/c.1/MaxPower # 1000 mA
echo 0x80 > configs/c.1/bmAttributes # Only bus powered

ln -s functions/acm.gs0 configs/c.1
ln -s functions/ncm.usb0 configs/c.1

udevadm settle -t 5 || :
ls /sys/class/udc/ > UDC

# Create /etc/network/interfaces.d/usb0 with the following content
# auto usb0
# allow-hotplug usb0
# iface usb0 inet static
#   address 192.168.168.1
#   netmask 255.255.255.0

# Create /etc/dnsmasq.d/usb with following content
# interface=usb0
# dhcp-range=192.168.168.2,192.168.168.6,255.255.255.0,1h
# dhcp-option=3
# leasefile-ro

# service dnsmasq restart
