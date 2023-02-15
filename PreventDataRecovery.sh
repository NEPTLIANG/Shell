# # 反数据恢复脚本 Demo
# ## 通过使用 dd if=/dev/random 覆写空闲空间来降低数据恢复成功几率
# 由于需要往根目录写文件，故需通过 sudo 或 root 用户执行

# ### ToDo:
# * 待实现生成文件后自动删除之
# * 待实现多次覆写以便进一步降低数据恢复成功几率

# 获取根分区及 home 分区剩余空间大小
rootCount=`df -h \
    | grep -e '\s/$' \
    | awk '{print $4}' \
    | sed 's/Gi/G/g' \
`;
homeCount=`df -h \
    | grep -e '\s/home$' \
    | awk '{print $4}' \
    | sed 's/Gi/G/g' \
`;
# rootCount=1G;
# homeCount=`echo 'aaa' | grep -e 'b'`;

# 提示信息
echo "/     分区中的空闲空间大小: $rootCount";
echo "/home 分区中的空闲空间大小: $homeCount";
echo "操作不可逆，且将占用大量磁盘空间，可能引起系统问题，确定要清理吗？"

# 操作确认
echo "如确定要清理请输入以下内容："
correct="YES, I WANT TO CLEAN MY DISK AND KNOW THAT IT'S NOT REVERSIBLE";
read -p "   $correct
并回车：" validator;

# 生成文件
if [ "$validator" == "$correct" ]; then
    echo "为保险起见，已注释生成命令（dd），有需要请先自行取消注释";
    # dd if=/dev/random of=/cleaner bs=$rootCount count=1;
    # dd if=/dev/random of=/home/cleaner bs=$homeCount count=1;
else
    echo "已终止";
fi;