#!/bin/bash 
###
###图片转换工具
###
### 使用:
###
###   convert.sh <param> <path>
###
###
### 选项:
###
###   png jpg		png和jpg图片互相转换，参数表示最终输出文件格式。		
###   <path>		文件夹路径。
###

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function start_convert(){
	if [ $IMG_FORMAT = 'png' ]; then
		find "$IMG_PATH" -name '*.jpg' -print0 | parallel -0 'convert -verbose {.}.jpg {.}.png && rm {}'
		find "$IMG_PATH" -name '*.JPG' -print0 | parallel -0 'convert -verbose {.}.JPG {.}.png && rm {}'
		find "$IMG_PATH" -name '*.jpeg' -print0 | parallel -0 'convert -verbose {.}.jpeg {.}.png && rm {}'
		find "$IMG_PATH" -name '*.JPEG' -print0 | parallel -0 'convert -verbose {.}.JPEG {.}.png && rm {}'
	elif [ $IMG_FORMAT = 'jpg' ]; then
		find "$IMG_PATH" -name '*.png' -print0 | parallel -0 'convert -verbose {.}.png {.}.jpg && rm {}'
		find "$IMG_PATH" -name '*.PNG' -print0 | parallel -0 'convert -verbose {.}.PNG {.}.jpg && rm {}'
	fi
}

if [[ -z "$1" || -z "$2" ]]; then
	echo_help
	exit 0
fi

if [[ $1 = 'png' ||  $1 = 'jpg' ]]; then
	IMG_FORMAT=$1
else
	echo -e "\033[41;33m 目标格式错误 \033[0m"
fi

if [ -d "${2}" ]; then
    IMG_PATH="${2}"
else
	echo -e "\033[41;33m 文件夹路径错误 \033[0m"
	exit 1
fi 
if [ $IMG_FORMAT = 'png' ]; then
	echo -e "\033[44;37m 把 jpg 格式图片转换为 png 格式，路径：$IMG_PATH \033[0m"
elif [ $IMG_FORMAT = 'jpg' ]; then
	echo -e "\033[44;37m 把 png 格式图片转换为 jpg 格式，路径：$IMG_PATH \033[0m"
fi
read -r -p "确认参数是否正确？[Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
        start_convert
        ;;
    *)
        exit 0
        ;;
esac