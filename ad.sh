#!/bin/bash
cp /sdcard/netease/cloudmusic/Ad/image/* /sdcard/ad/aad
cd /sdcard/ad
ls aad > ad.txt
head -n 1 ad.txt | tail -n 1 > 1.txt
$1 = `cat 1.txt`
mv ad $1
