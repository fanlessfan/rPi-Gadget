#!/bin/bash 

#modprobe libcomposite

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
echo "ZHOUINC0M001" > strings/0x409/serialnumber
echo "ZHOU INC"        > strings/0x409/manufacturer
echo "Pi0 Composite Gadgets"   > strings/0x409/product

# ECM
mkdir -p functions/ecm.usb  # network
HOST="5A:48:4F:55:51:81" # "HostPC"
SELF="5A:48:4F:55:51:80" # "BadUSB"
echo $HOST > functions/ecm.usb/host_addr
echo $SELF > functions/ecm.usb/dev_addr

# RNDIS
mkdir -p functions/rndis.usb  
HOST="5A:48:4F:55:51:83" # "HostPC"
SELF="5A:48:4F:55:51:82" # "BadUSB"
echo $HOST > functions/rndis.usb/host_addr
echo $SELF > functions/rndis.usb/dev_addr

# OS descriptors, more compatible with Windows

echo RNDIS   > functions/rndis.usb/os_desc/interface.rndis/compatible_id
echo 5162001 > functions/rndis.usb/os_desc/interface.rndis/sub_compatible_id
mkdir -p functions/rndis.usb/os_desc/interface.rndis/Icons
echo 2 > functions/rndis.usb/os_desc/interface.rndis/Icons/type
echo "%SystemRoot%\system32\shells32.dll,-233" > functions/rndis.usb/os_desc/interface.rndis/Icons/data
mkdir -p           functions/rndis.usb/os_desc/interface.rndis/Label
echo 1           > functions/rndis.usb/os_desc/interface.rndis/Label/type
echo "Pi0 RNDIS" > functions/rndis.usb/os_desc/interface.rndis/Label/data

# Serial, sudo systemctl enable getty@ttyGS0.service to enble login
mkdir -p functions/acm.GS0    # serial

# HID Keyboard
mkdir functions/hid.keyboard
echo 1 > functions/hid.keyboard/protocol
echo 8 > functions/hid.keyboard/report_length # 8-byte reports
echo 1 > functions/hid.keyboard/subclass # 1: Keyboard 2: Mouse
#echo "05010906a101050719e029e71500250175019508810275089501810175019503050819012903910275019505910175089506150026ff00050719002aff008100c0" | xxd -r -ps > functions/hid.keyboard/report_desc
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.keyboard/report_desc

# Mass Storage
mkdir -p functions/mass_storage.0
echo 1 > functions/mass_storage.0/stall
echo 0 > functions/mass_storage.0/lun.0/cdrom
echo 0 > functions/mass_storage.0/lun.0/ro
echo 0 > functions/mass_storage.0/lun.0/nofua
echo /home/pi/100MB > functions/mass_storage.0/lun.0/file
#echo /dev/mmcblk0p1 > functions/mass_storage.0/lun.0/file

# config c.1 for ecm, rndis and acm
#mkdir -p         configs/c.1/strings/0x409
#echo "Pi0 Ether" > configs/c.1/strings/0x409/configuration
#echo 250 > configs/c.1/MaxPower # 250 mA
#echo 0x80 > configs/c.1/bmAttributes # Only bus powered

#ln -s functions/acm.GS0 configs/c.1

# for macOS only
#ln -s functions/ecm.usb configs/c.1

# for Windows only
#ln -s functions/rndis.usb configs/c.1
#echo 0xcd    > os_desc/b_vendor_code
#echo MSFT100 > os_desc/qw_sign
#echo 1       > os_desc/use
#ln -s configs/c.1 os_desc

# config c.2 for mass storage and acm
mkdir -p             configs/c.2/strings/0x409
echo "Pi0 Storage" > configs/c.2/strings/0x409/configuration

ln -s functions/mass_storage.0 configs/c.2
ln -s functions/acm.GS0 configs/c.2

# config c.3 for hid and acm
mkdir -p configs/c.3/strings/0x409
echo "Pi0 Keyboard" > configs/c.3/strings/0x409/configuration
echo 250 > configs/c.3/MaxPower # 250 mA
echo 0x80 > configs/c.3/bmAttributes # Only bus powered

ln -s functions/hid.keyboard configs/c.3/
ln -s functions/acm.GS0 configs/c.3/

udevadm settle -t 5 || :
ls /sys/class/udc/ > UDC

#ifup usb0
#ifup usb1
service dnsmasq restart

