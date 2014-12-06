#!/sbin/sh
/tmp/mkbootimg --kernel /tmp/zImage_dtb --ramdisk /tmp/ramdisk.cpio.gz --cmdline 'no_console_suspend=1 console=null' --base 0x10000000 --pagesize 2048 --ramdisk_offset 0x11000000 --tags_offset 0x10f00000 --output /tmp/boot.img

