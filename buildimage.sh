#!/bin/bash
##  this assumes you've checked out this git repository via github using
# git clone https://github.com/lexlapax/dockerfile-tiny-nodejs-wiki
# cd dockerfile-tiny-nodejs-wiki
## and you're running this script ./buildimage.sh from that directory
## after you've done chmod +x buildimage.sh

export IMAGENAME=tiny-nodejs-wiki
export BUILDROOTVER=2014.05


CURDIR=`pwd`

mkdir src-buildroot
cd src-buildroot

wget -c http://buildroot.uclibc.org/downloads/buildroot-$BUILDROOTVER.tar.gz
tar -xzvf buildroot-$BUILDROOTVER.tar.gz
cp -r $CURDIR/buildroot.config buildroot-$BUILDROOTVER/.config
cd buildroot-$BUILDROOTVER
make all
# wait a really long time while it builds everything including the toolchain
# 


# quoted from the docker buildroot blog post
#
# You should see a small, lean, rootfs.tar file, containing the image to be imported 
# in Docker. But it’s not quite ready yet. We need to fix a few things. 
# 
# Docker sets the DNS configuration by bind-mounting over /etc/resolv.conf. 
# This means that /etc/resolv.conf has to be a standard file. By default, 
# buildroot makes it a symlink. We have to replace that 
# symlink with a file (an empty file will do). 
# 
# Likewise, Docker “injects” itself within containers by bind-mounting over /sbin/init. 
# This means that /sbin/init should be a regular file as well. By default, 
# buildroot makes it a symlink to busybox. We will change that, too.


mkdir -p output/images/fixup/sbin output/images/fixup/etc 
touch output/images/fixup/sbin/init output/images/fixup/etc/resolv.conf
# add nodejs and wiki specific stuff here

cd output/images
cp rootfs.tar fixup.tar
tar rvf fixup.tar -C fixup .

cp fixup.tar $CURDIR/$IMAGENAME.tar

cd $CURDIR
# docker steps
docker build -t $IMAGENAME . 

