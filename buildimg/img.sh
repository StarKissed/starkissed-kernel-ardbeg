if cat /etc/issue | grep Ubuntu; then
    BUILDSTRUCT=linux
else
    BUILDSTRUCT=darwin
fi

$BUILDSTRUCT/./mkbootfs $1-ramdisk | gzip > ../skrecovery/ramdisk/$1/ramdisk.cpio.gz