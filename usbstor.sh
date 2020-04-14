#!/bin/bash 

#6e28

modprobe libcomposite

GADGET=stor

if [ "$1" == "rm" ]
then

systemctl stop getty@ttyGS0

cd /sys/kernel/config/usb_gadget/$GADGET

rm configs/c.2/acm.GS0

rm configs/c.2/mass_storage.0
rm configs/c.2/mass_storage.1

rmdir configs/c.2/strings/0x409/
rmdir configs/c.2/

rmdir functions/acm.GS0
rmdir functions/mass_storage.0/
rmdir functions/mass_storage.1/

rmdir strings/0x409/

cd ..
rmdir $GADGET

exit 0
fi
################ removal end

cd /sys/kernel/config/usb_gadget/
mkdir $GADGET && cd $GADGET

echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget

# for windows
#echo 0x04b3 > idVendor
#echo 0x4010 > idProduct

echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB 2.0

# https://www.usb.org/defined-class-codes
#echo 0xEF > bDeviceClass # Miscellaneous Device
echo 0x00 > bDeviceClass # Defined at Interface level
echo 0x00 > bDeviceSubClass
echo 0x00 > bDeviceProtocol

# for windows
#echo 0xEF > bDeviceClass
#echo 0x02 > bDeviceSubClass
#echo 0x01 > bDeviceProtocol
#echo 0x08 > bMaxPacketSize0

mkdir -p strings/0x409
echo "ZHOUINC0M001" > strings/0x409/serialnumber
echo "ZHOU INC"        > strings/0x409/manufacturer
echo "Pi0 Stor"   > strings/0x409/product

# Serial, sudo systemctl enable getty@ttyGS0.service to enble login
mkdir -p functions/acm.GS0    # serial

#
# Mass Storage
mkdir -p functions/mass_storage.0
echo 1 > functions/mass_storage.0/stall
echo 0 > functions/mass_storage.0/lun.0/cdrom
echo 0 > functions/mass_storage.0/lun.0/ro
echo 0 > functions/mass_storage.0/lun.0/nofua
echo /home/pi/100MB > functions/mass_storage.0/lun.0/file

#mkdir -p functions/mass_storage.0
#echo 1 > functions/mass_storage.0/stall
#echo 1 > functions/mass_storage.0/lun.0/cdrom
#echo 1 > functions/mass_storage.0/lun.0/ro
#echo 1 > functions/mass_storage.0/lun.0/nofua
#echo /home/pi/esxi.iso > functions/mass_storage.0/lun.0/file

mkdir -p functions/mass_storage.1
echo 1 > functions/mass_storage.1/stall
echo 1 > functions/mass_storage.1/lun.0/cdrom
echo 1 > functions/mass_storage.1/lun.0/ro
echo 0 > functions/mass_storage.1/lun.0/nofua
echo /home/pi/esxi.iso > functions/mass_storage.1/lun.0/file

# config c.2 for mass storage and acm
mkdir -p             configs/c.2/strings/0x409
echo "Pi0 Storage" > configs/c.2/strings/0x409/configuration

ln -s functions/mass_storage.0 configs/c.2
ln -s functions/mass_storage.1 configs/c.2

ln -s functions/acm.GS0 configs/c.2

udevadm settle -t 5 || :
ls /sys/class/udc/ > UDC



ls /sys/kernel/config/usb_gadget/

sleep 5
systemctl restart getty@ttyGS0.service 
