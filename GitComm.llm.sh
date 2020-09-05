#!/bin/bash
#git add commit push命令集
read -p "请输入commit备注：" B
git add -A
git commit -m "$B"
git push origin master
