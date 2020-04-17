#!/bin/bash

GADGET=keyboard

if [ "$1" == "rm" ]
then

systemctl stop getty@ttyGS0.service 

cd /sys/kernel/config/usb_gadget/${GADGET}

echo "" > UDC

# remove config
rm configs/c.1/hid.usb0
rm configs/c.1/acm.usb0
rmdir   configs/c.1/strings/0x409
rmdir   configs/c.1

# remove function
rmdir functions/hid.usb0
rmdir functions/acm.usb0

# remove string/lang
rmdir strings/0x409

# remove gadget
cd ..
rmdir ${GADGET}

ls -a /sys/kernel/config/usb_gadget
exit 0
fi

# Create gadget
mkdir /sys/kernel/config/usb_gadget/$GADGET
cd /sys/kernel/config/usb_gadget/$GADGET

# Add basic information
echo 0x1d6b > idVendor  # Linux Foundation
echo 0x1347 > idProduct

echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB 2.0

echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
echo 0x40 > bMaxPacketSize0

#echo 0x0104 > idProduct # Multifunction Composite Gadget
#echo 0x0220 > idProduct # Aluminium Keyboard (ANSI)
#echo 0x1d6b > idVendor # Linux Foundation
#echo 0x05ac > idVendor # Apple

# Create English locale
mkdir -p strings/0x409
echo `cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2` > strings/0x409/serialnumber
echo "ZHOU INC"        > strings/0x409/manufacturer
echo "Pi0 Composite Gadget"   > strings/0x409/product

# Create HID function
mkdir functions/hid.usb0
mkdir functions/acm.usb0

echo 1 > functions/hid.usb0/protocol
echo 8 > functions/hid.usb0/report_length # 8-byte reports
echo 1 > functions/hid.usb0/subclass
echo "05010906a101050719e029e71500250175019508810275089501810175019503050819012903910275019505910175089506150026ff00050719002aff008100c0" | xxd -r -ps > functions/hid.usb0/report_desc
#echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.keyboard/report_desc

# Create configuration
mkdir configs/c.1
mkdir configs/c.1/strings/0x409

echo 0x80 > configs/c.1/bmAttributes
echo 200 > configs/c.1/MaxPower # 200 mA
echo "Pi0 usb keyboard" > configs/c.1/strings/0x409/configuration

# Link HID function to configuration
ln -s functions/hid.usb0 configs/c.1
ln -s functions/acm.usb0 configs/c.1

# Enable gadget
ls /sys/class/udc > UDC
ls /sys/kernel/config/usb_gadget
