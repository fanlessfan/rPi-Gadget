#!/bin/bash 

#6e28

if [ $# -eq  0 ]
then
  echo "$0 os"
  echo "os=win or mac"
  exit 1
else
  OS=$1
fi
#echo $#
#echo $@
echo $OS

modprobe libcomposite

GADGET=ether


if [ $OS == "mac" ]
then

if [ "$2" == "rm" ]
then

cd /sys/kernel/config/usb_gadget/$GADGET
echo "" > UDC

rm configs/c.1/acm.GS0
rm configs/c.1/ecm.usb0

rmdir configs/c.1/strings/0x409/
rmdir configs/c.1/

rmdir functions/acm.GS0/
rmdir functions/ecm.usb0/

rmdir strings/0x409/

cd ..
rmdir $GADGET

exit 0
fi
############### end of remeval

cd /sys/kernel/config/usb_gadget/
mkdir  $GADGET && cd $GADGET

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
echo "Pi0 Stor"   > strings/0x409/product

# Serial, sudo systemctl enable getty@ttyGS0.service to enble login
mkdir -p functions/acm.GS0    # serial

# ECM
mkdir -p functions/ecm.usb0  # network
SELF="5A:48:4F:55:6e:28" # "BadUSB"
HOST="5A:48:4F:55:6e:29" # "HostPC"
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF > functions/ecm.usb0/dev_addr

# config c.1 for ecm, rndis 
mkdir -p         configs/c.1/strings/0x409
echo "Pi0 Ether" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower # 250 mA
echo 0x80 > configs/c.1/bmAttributes # Only bus powered

# for macOS only MacOs, since version 10.11, it's no longer to load the CDC ECM configuration if it isn't the first one!
ln -s functions/ecm.usb0 configs/c.1

ln -s functions/acm.GS0 configs/c.1

fi 

###MACMACMACMAC# end of mac

if [ $OS == "win" ]
then

if [ "$2" == "rm" ]
then

cd /sys/kernel/config/usb_gadget/$GADGET
echo "" > UDC

rm configs/c.1/acm.GS0
rm configs/c.1/rndis.usb0
rm os_desc/c.1


rmdir configs/c.1/strings/0x409/
rmdir configs/c.1/

rmdir functions/acm.GS0/

rmdir functions/rndis.usb0/os_desc/interface.rndis/Icons
rmdir functions/rndis.usb0/os_desc/interface.rndis/Label
rmdir functions/rndis.usb0/

rmdir strings/0x409/

cd ..
rmdir $GADGET

exit 0
fi
############### end of remeval

cd /sys/kernel/config/usb_gadget/
mkdir  $GADGET && cd $GADGET

#echo 0x1d6b > idVendor  # Linux Foundation
#echo 0x0104 > idProduct # Multifunction Composite Gadget

# Windows id
echo 0x04b3 > idVendor
echo 0x4010 > idProduct

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
echo "Pi0 Stor"   > strings/0x409/product

# Serial, sudo systemctl enable getty@ttyGS0.service to enble login
mkdir -p functions/acm.GS0    # serial

# RNDIS
mkdir -p functions/rndis.usb0  
HOST="5A:48:4F:55:6e:2a" # "HostPC"
SELF="5A:48:4F:55:6e:2b" # "BadUSB"
echo $HOST > functions/rndis.usb0/host_addr
echo $SELF > functions/rndis.usb0/dev_addr

echo RNDIS   > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
echo 5162001 > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id

mkdir -p functions/rndis.usb0/os_desc/interface.rndis/Icons
echo 2 > functions/rndis.usb0/os_desc/interface.rndis/Icons/type
echo "%SystemRoot%\system32\shells32.dll,-233" > functions/rndis.usb0/os_desc/interface.rndis/Icons/data
mkdir -p           functions/rndis.usb0/os_desc/interface.rndis/Label
echo 1           > functions/rndis.usb0/os_desc/interface.rndis/Label/type
echo "Pi0 RNDIS" > functions/rndis.usb0/os_desc/interface.rndis/Label/data

# config c.1 for ecm, rndis 
mkdir -p         configs/c.1/strings/0x409
echo "Pi0 Ether" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower # 250 mA
echo 0x80 > configs/c.1/bmAttributes # Only bus powered

# OS descriptors, more compatible with Windows
echo 0xcd    > os_desc/b_vendor_code
echo MSFT100 > os_desc/qw_sign
echo 1       > os_desc/use
ln -s configs/c.1 os_desc

# for Windows only
ln -s functions/rndis.usb0 configs/c.1

ln -s functions/acm.GS0 configs/c.1


fi
###WINWINWINWINWINWIN# end of win


udevadm settle -t 5 || :
ls /sys/class/udc/ > UDC

#ifup usb0
#ifup usb1
service dnsmasq restart


ls /sys/kernel/config/usb_gadget/

