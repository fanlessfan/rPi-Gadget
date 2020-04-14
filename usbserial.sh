#!/bin/bash 

#6e28

modprobe libcomposite

GADGET=serial

if [ "$1" == "rm" ]
then

systemctl stop getty@ttyGS0.service 

cd /sys/kernel/config/usb_gadget/${GADGET}

echo "" > UDC

# remove config
rm configs/c.1/acm.GS0
rmdir   configs/c.1/strings/0x409
rmdir   configs/c.1

# remove function
rmdir functions/acm.GS0

# remove string/lang
rmdir strings/0x409

# remove gadget
cd ..
rmdir ${GADGET}

exit 0
fi

cd /sys/kernel/config/usb_gadget/
mkdir  ${GADGET} && cd ${GADGET}

echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget

# Windows id
#echo 0x04b3 > idVendor
#echo 0x4010 > idProduct

echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB 2.0

# https://www.usb.org/defined-class-codes
#echo 0xEF > bDeviceClass # Miscellaneous Device
#echo 0x00 > bDeviceClass # Defined at Interface level
#echo 0x00 > bDeviceSubClass
#echo 0x00 > bDeviceProtocol

# for windows
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
echo 0x08 > bMaxPacketSize0

mkdir -p strings/0x409
echo "ZHOUINC0M001" > strings/0x409/serialnumber
echo "ZHOU INC"        > strings/0x409/manufacturer
echo "Pi0 Serial"  > strings/0x409/product

# Serial, sudo systemctl enable getty@ttyGS0.service to enble login
mkdir -p functions/acm.GS0    # serial


# config c.1 for acm
mkdir -p         configs/c.1/strings/0x409
echo "Pi0 Serial" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower # 250 mA
echo 0x80 > configs/c.1/bmAttributes # Only bus powered


ln -s functions/acm.GS0 configs/c.1


udevadm settle -t 5 || :
ls /sys/class/udc/ > UDC


#systemctl enable getty@ttyGS0.service 
#sleep 5
systemctl start getty@ttyGS0.service 


