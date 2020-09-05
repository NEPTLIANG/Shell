#!/bin/bash
echo;
echo --------------------------------------------------------
echo "           指定大小文件生成器"
echo "  Made by Android Bar @NeptLiang"
echo --------------------------------------------------------
#MING到此一游
echo;
echo 块大小可以使用的计量单位表
echo 单元大小                     代码
echo 字节（1B）---------------c
echo 字节（2B）---------------w
echo 块（512B）---------------b
echo 千字节（1024B）------k
echo 兆字节（1024KB）---M
echo 吉字节（1024MB）--G
echo;
read -p "请输入文件大小（请输入符合计量单位表规范的单位）：" s
read -p "请输入文件名：" n
echo;
dd if=/dev/zero of=$n bs=$s count=1
echo;
echo Done
echo;
