###
 # @Author: NeptLiang
 # @Date: 2021-05-19 19:07:10
 # @LastEditors: NeptLiang
 # @LastEditTime: 2021-05-19 20:13:15
 # @Description: 获取当前目录及其子目录下所有PHP, Py, HTML, CSS, JS, SQL文件中的代码
###
function getCode() {
	for fileName in *; do  #遍历当前目录下所有文件名
		if [ -d $fileName ]; then  #如果是目录文件，获取其中的代码
			# echo $fileName;
			cd $fileName;
			getCode;  #递归调用本函数，获取该目录下的代码
			cd ..;
		fi
		if [[ $fileName =~ ((.php)$|(.py)$|(.html)$|(.css)$|(.js)$|(.sql)$) ]]; then  #“|”两侧不能有空格否则出错
			# echo "";
			# echo "";
			# echo $fileName;  #打印文件名
			# echo "";
			cat $fileName;  #获取文件内容
		fi
	done
}

getCode
