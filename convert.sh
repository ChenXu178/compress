#!/bin/bash 
###
###图片转换工具
###
### 使用:
###
###   convert.sh <type> <quality> <path>
###
###
### 选项:
###
###   png jpg webp		png、jpg、webp图片互相转换，参数表示最终输出文件格式。
###   0 - 100		转换成webp格式的质量，默认100 (其他格式此项无效)
###   <path>		文件夹路径。
###

QUALITY=100

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function start_convert(){
	if [ $IMG_FORMAT = 'png' ]; then
		find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 "convert -verbose {.}.jpg {.}.png && rm {}"
		find "$IMG_PATH" -name "*.JPG" -type f -print0 | parallel -0 "convert -verbose {.}.JPG {.}.png && rm {}"
		find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 "convert -verbose {.}.jpeg {.}.png && rm {}"
		find "$IMG_PATH" -name "*.JPEG" -type f -print0 | parallel -0 "convert -verbose {.}.JPEG {.}.png && rm {}"
		find "$IMG_PATH" -name "*.webp" -type f -print0 | parallel -0 "convert -verbose {.}.webp {.}.png && rm {}"
		find "$IMG_PATH" -name "*.WEBP" -type f -print0 | parallel -0 "convert -verbose {.}.WEBP {.}.png && rm {}"
	elif [ $IMG_FORMAT = "jpg" ]; then
		find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 "convert -verbose {.}.png {.}.jpg && rm {}"
		find "$IMG_PATH" -name "*.PNG" -type f -print0 | parallel -0 "convert -verbose {.}.PNG {.}.jpg && rm {}"
		find "$IMG_PATH" -name "*.webp" -type f -print0 | parallel -0 "convert -verbose {.}.webp {.}.jpg && rm {}"
		find "$IMG_PATH" -name "*.WEBP" -type f -print0 | parallel -0 "convert -verbose {.}.WEBP {.}.jpg && rm {}"
	elif [ $IMG_FORMAT = "webp" ]; then
		if [ $QUALITY -eq 100 ]; then
			find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 "convert -verbose {.}.jpg {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.JPG" -type f -print0 | parallel -0 "convert -verbose {.}.JPG {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 "convert -verbose {.}.jpeg {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.JPEG" -type f -print0 | parallel -0 "convert -verbose {.}.JPEG {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 "convert -verbose {.}.png {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.PNG" -type f -print0 | parallel -0 "convert -verbose {.}.PNG {.}.webp && rm {}"
		else
			find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 "cwebp -q $(expr $QUALITY + 0) {.}.jpg -o {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.JPG" -type f -print0 | parallel -0 "cwebp -q $(expr $QUALITY + 0) {.}.JPG -o {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 "cwebp -q $(expr $QUALITY + 0) {.}.jpeg -o {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.JPEG" -type f -print0 | parallel -0 "cwebp -q $(expr $QUALITY + 0) {.}.JPEG -o {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 "cwebp -q $(expr $QUALITY + 0) {.}.png -o {.}.webp && rm {}"
			find "$IMG_PATH" -name "*.PNG" -type f -print0 | parallel -0 "cwebp -q $(expr $QUALITY + 0) {.}.PNG -o {.}.webp && rm {}"
		fi
	fi
}

if [[ -z "$1" || -z "$2" ]]; then
	echo_help
	exit 0
fi

if [[ $1 = 'png' ||  $1 = 'jpg' ||  $1 = 'webp' ]]; then
	IMG_FORMAT=$1
else
	echo -e "\033[41;33m 目标格式错误 \033[0m"
fi
if [ $# -eq 2 ]; then
	if [ -d "${2}" ]; then
		IMG_PATH="${2}"
	else
		echo -e "\033[41;33m 文件夹路径错误 \033[0m"
		exit 1
	fi 
elif [ $# -eq 3 ]; then
	if [[ $2 =~ ^[01]?[0-9]?[0-9]$ && $2 -le 100 ]]; then
		QUALITY=$2
	else
		echo -e "\033[41;33m 转换质量错误 \033[0m"
		exit 1
	fi 
	if [ -d "${3}" ]; then
		IMG_PATH="${3}"
	else
		echo -e "\033[41;33m 文件夹路径错误 \033[0m"
		exit 1
	fi
else
	echo -e "\033[41;33m 参数错误 \033[0m"
	exit 1
fi

if [ $IMG_FORMAT = 'png' ]; then
	echo -e "\033[44;37m jpg/webp 格式图片转换为 png 格式，路径：$IMG_PATH \033[0m"
elif [ $IMG_FORMAT = 'jpg' ]; then
	echo -e "\033[44;37m png/webp 格式图片转换为 jpg 格式，路径：$IMG_PATH \033[0m"
elif [ $IMG_FORMAT = 'webp' ]; then
	echo -e "\033[44;37m jpg/png 格式图片转换为 webp 格式，质量 $QUALITY ，路径：$IMG_PATH \033[0m"
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