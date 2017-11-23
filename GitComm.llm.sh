#!/bin/bash
#git add commit push命令集
read -p "请输入commit备注" B
read -p "请输入GitHub用户名" U
read -p "请输入仓库名" R
git add -A
git commit -m "$B"
git push origin master