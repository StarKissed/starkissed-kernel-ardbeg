if cat /etc/issue | grep Ubuntu; then

BUILDSTRUCT=linux

else

BUILDSTRUCT=darwin

fi

chmod a+r tegra124-tn8.dtb
cat zImage tegra124-tn8.dtb > zImage_dtb
$BUILDSTRUCT/./mkbootfs boot.img-ramdisk | gzip > newramdisk.cpio.gz
$BUILDSTRUCT/./mkbootimg --cmdline 'no_console_suspend=1 console=null' --kernel zImage_dtb --ramdisk newramdisk.cpio.gz -o boot.img --base 0x10000000 --pagesize 2048 --ramdisk_offset 0x11000000 --tags_offset 0x10f00000