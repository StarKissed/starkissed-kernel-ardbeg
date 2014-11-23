#!/bin/sh

# Copyright (C) 2011 Twisted Playground

# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $1 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=LoungeKatt
KERNELREPO=$DROPBOX_SERVER/TwistedServer/Playground/kernels
TOOLCHAIN_PREFIX=/Volumes/android/android-toolchain-eabi-4.7/bin/arm-eabi-
MODULEOUT=buildimg/boot.img-ramdisk
GOOSERVER=loungekatt@upload.goo.im:public_html
PUNCHCARD=`date "+%m-%d-%Y_%H.%M"`

zipfile=$HANDLE"_StarKissed-LP50-Ardberg.zip"

# CPU_JOB_NUM=`grep processor /proc/cpuinfo|wc -l`
CORES=`sysctl -a | grep machdep.cpu | grep core_count | awk '{print $2}'`
THREADS=`sysctl -a | grep machdep.cpu | grep thread_count | awk '{print $2}'`
CPU_JOB_NUM=$((($CORES * $THREADS) / 2))

if [ -e buildimg/boot.img ]; then
rm -R buildimg/boot.img
fi
if [ -e buildimg/newramdisk.cpio.gz ]; then
rm -R buildimg/newramdisk.cpio.gz
fi
if [ -e buildimg/zImage ]; then
rm -R buildimg/zImage
fi

make -j$CPU_JOB_NUM clean CROSS_COMPILE=$TOOLCHAIN_PREFIX
make tegra12_android_defconfig -j$CPU_JOB_NUM -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
make tegra124-ardbeg.dtb -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

if [ -e arch/arm/boot/zImage ]; then

    if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then

        find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

        if [ ! -d $MODULEOUT ]; then
            mkdir $MODULEOUT
        fi
        if [ ! -d $MODULEOUT/lib ]; then
            mkdir $MODULEOUT/lib
        fi
        if [ ! -d $MODULEOUT/lib/modules ]; then
            mkdir $MODULEOUT/lib/modules
        else
            rm -r $MODULEOUT/lib/modules
            mkdir $MODULEOUT/lib/modules
        fi

        for j in $(find . -name "*.ko"); do
            cp -R "${j}" $MODULEOUT/lib/modules
        done

    fi

    cp -r arch/arm/boot/dts/tegra124-ardbeg.dtb buildimg/tegra124-ardbeg.dtb
    cp -r arch/arm/boot/zImage buildimg/zImage

    cd buildimg
    ./img.sh
    cd ../

    IMAGEFILE=boot-lp.$PUNCHCARD.img
    KENRELZIP="StarKissed-LP50_$PUNCHCARD-Ardberg.zip"

    cp -r  buildimg/boot.img $KERNELREPO/shieldtablet/boot-50.img
    cp -r  $KERNELREPO/shieldtablet/boot-50.img ~/.goo/$IMAGEFILE
    scp ~/.goo/$IMAGEFILE $GOOSERVER/shieldtablet/kernel
    rm -R ~/.goo/$IMAGEFILE

    echo "building boot package"
    cp -R buildimg/boot.img starkissed
    cd starkissed
    rm *.zip
    zip -r $zipfile *
    cd ../
    cp -R starkissed/$zipfile $KERNELREPO/$zipfile
    if [ -e $KERNELREPO/$zipfile ]; then
        cp -R $KERNELREPO/$zipfile ~/.goo/$KENRELZIP
        scp ~/.goo/$KENRELZIP  $GOOSERVER/shieldtablet
        rm -r ~/.goo/*
    fi

fi
