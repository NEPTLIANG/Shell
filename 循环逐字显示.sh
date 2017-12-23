#/bin/bash
read -p "你想显示的是命令还是字符？命令选A，字符选B：" A
if [ $A = 'A' ]
then
{
	read -p "请输入你想要显示的命令:" B
	while true
	do
	{
		$B | pv -qL 10
	}
	done
}
elif [ $A = 'B' ]
then
{
	read -p "请输入你想要显示的字符：" C
	while true
	do
	{
		echo $C | pv -qL 10
	}
	done
}
else
{
	echo 你输入的啥玩意？
}
fi
