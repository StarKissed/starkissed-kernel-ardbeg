#!/bin/sh

# Copyright (C) 2011 Twisted Playground

# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $1 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`
KERNELDIR=`pwd`
HANDLE=LoungeKatt
KERNELREPO=$DROPBOX_SERVER/TwistedServer/StarKissed/kernels
TOOLCHAIN_PREFIX=/Volumes/android/android-toolchain-eabi-4.7/bin/arm-eabi-
MODULEOUT=skrecovery/system
KERNELHOST=public_html/shieldtablet
GOOSERVER=upload.goo.im:$KERNELHOST
PUNCHCARD=`date "+%m-%d-%Y_%H.%M"`

zipfile=$HANDLE"_StarKissed-LP50-TN8-Auto.zip"

# CPU_JOB_NUM=`grep processor /proc/cpuinfo|wc -l`
CORES=`sysctl -a | grep machdep.cpu | grep core_count | awk '{print $2}'`
THREADS=`sysctl -a | grep machdep.cpu | grep thread_count | awk '{print $2}'`
CPU_JOB_NUM=$((($CORES * $THREADS) / 2))

echo
echo "Publish Package?"
read package

if [ -e arch/arm/boot/zImage ]; then
    rm arch/arm/boot/zImage
fi

cat config/shieldtablet_defconfig config/starkissed_defconfig > arch/arm/configs/tegra12_android_defconfig

make -j$CPU_JOB_NUM clean CROSS_COMPILE=$TOOLCHAIN_PREFIX
make tegra12_android_defconfig -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
make tegra124-tn8-p1761-1270-a04-e-battery.dtb -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
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

    cp -r arch/arm/boot/dts/tegra124-tn8-p1761-1270-a04-e-battery.dtb buildimg/tegra124-tn8.dtb
    cp -r arch/arm/boot/zImage buildimg/zImage
    for k in $(find skrecovery -name "system"); do
        cp -R buildimg/system/etc "${k}"
    done

    chmod a+r buildimg/tegra124-tn8.dtb
    cat buildimg/zImage buildimg/tegra124-tn8.dtb > skrecovery/binaries/zImage_dtb

    KENRELZIP="StarKissed-LP50_"$PUNCHCARD"-TN8-Auto.zip"
    cd buildimg
    ./img.sh wx_na_wf
    ./img.sh wx_na_do
    ./img.sh wx_un_do
    cd ../skrecovery
    rm *.zip
    zip -r $zipfile *
    cd ../
    if [ -e skrecovery/$zipfile ]; then
        cp -R skrecovery/$zipfile $KERNELREPO/$zipfile
        if [ $package == "y" ]; then
            if [ -e ~/.goo/ ]; then
                rm -r ~/.goo/*
            fi
            cp -R skrecovery/$zipfile ~/.goo/$KENRELZIP
            existing=`ssh upload.goo.im ls $KERNELHOST/StarKissed*Auto*.zip`
            scp ~/.goo/$KENRELZIP  $GOOSERVER
            ssh upload.goo.im rm $existing
        fi
    fi
fi

cd $KERNELDIR
