#!/bin/bash 
###
###图片转换工具 (暂不支持avif/webp之间相互转换)
###
### 使用:
###
###   img_convert.sh <type> <quality> <path>
###
###
### 选项:
###
###   <type>	目标格式，支持png/jpg/webp/avif/png/jpg/webp/avif/heic，total 统计目录内各文件数量 
###   0 - 100	转换质量，默认99
###   <path>	文件夹路径。
###

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/home/chenxu/downloads/compress
export PATH

ans=
QUALITY=99

export CONVERT_COUNT_FILE=/tmp/convert_count
export CONVERT_IGNORE_FILE=/tmp/ignore_count

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function tidy(){
	echo -e "\033[32m 开始整理图片 \033[0m"
	find "$IMG_PATH" -name "*.JPG" -type f -exec rename ".JPG" ".jpg" {} \;
	find "$IMG_PATH" -name "*.JPEG" -type f -exec rename ".JPEG" ".jpg" {} \;
	find "$IMG_PATH" -name "*.PNG" -type f -exec rename ".PNG" ".png" {} \;
	find "$IMG_PATH" -name "*.WEBP" -type f -exec rename ".WEBP" ".webp" {} \;
	find "$IMG_PATH" -name "*.AVIF" -type f -exec rename ".AVIF" ".avif" {} \;
	find "$IMG_PATH" -name "*.HEIC" -type f -exec rename ".HEIC" ".heic" {} \;
}

function statistics(){
	echo -e "\033[32m 开始统计图片数量 \033[0m"

	jpgMax1=`find "$IMG_PATH" -name '*.jpg' -type f | wc -l`
	jpgMax2=`find "$IMG_PATH" -name '*.jpeg' -type f | wc -l`
	pngMax=`find "$IMG_PATH" -name '*.png' -type f | wc -l`
	webpMax=`find "$IMG_PATH" -name '*.webp' -type f | wc -l`
	avifMax=`find "$IMG_PATH" -name '*.avif' -type f | wc -l`
	heicMax=`find "$IMG_PATH" -name '*.heic' -type f | wc -l`
	let jpgMax=jpgMax1+jpgMax2
	if [ $IMG_FORMAT = 'png' ]; then
		let maxCount=jpgMax+webpMax+avifMax+heicMax
	elif [ $IMG_FORMAT = "jpg" ]; then
		let maxCount=pngMax+webpMax+avifMax+heicMax
	elif [ $IMG_FORMAT = "webp" ]; then
		let maxCount=jpgMax+pngMax+avifMax+heicMax
	elif [ $IMG_FORMAT = "avif" ]; then
		let maxCount=jpgMax+pngMax+webpMax+heicMax
	elif [ $IMG_FORMAT = "heic" ]; then
		let maxCount=jpgMax+pngMax+webpMax+avifMax
	fi
	export MAX_COUNT=$maxCount
	echo -e "\033[34m 预计转换图片数量：$jpgMax \033[0m"
}

function find_img(){
	echo -e "\033[32m 开始转换图片 \033[0m"
	if [ $IMG_FORMAT = 'png' ]; then
		find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 convert.sh jpg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 convert.sh jpeg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.webp" -type f -print0 | parallel -0 convert.sh webp $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.avif" -type f -print0 | parallel -0 convert.sh avif $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.heic" -type f -print0 | parallel -0 convert.sh heic $IMG_FORMAT $QUALITY {};
	elif [ $IMG_FORMAT = "jpg" ]; then
		find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 convert.sh png $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.webp" -type f -print0 | parallel -0 convert.sh webp $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.avif" -type f -print0 | parallel -0 convert.sh avif $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.heic" -type f -print0 | parallel -0 convert.sh heic $IMG_FORMAT $QUALITY {};
	elif [ $IMG_FORMAT = "webp" ]; then
		find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 convert.sh jpg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 convert.sh jpeg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 convert.sh png $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.avif" -type f -print0 | parallel -0 convert.sh avif $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.heic" -type f -print0 | parallel -0 convert.sh heic $IMG_FORMAT $QUALITY {};
	elif [ $IMG_FORMAT = "avif" ]; then
		find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 convert.sh jpg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 convert.sh jpeg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 convert.sh png $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.webp" -type f -print0 | parallel -0 convert.sh webp $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.heic" -type f -print0 | parallel -0 convert.sh heic $IMG_FORMAT $QUALITY {};
	elif [ $IMG_FORMAT = "heic" ]; then
		find "$IMG_PATH" -name "*.jpg" -type f -print0 | parallel -0 convert.sh jpg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.jpeg" -type f -print0 | parallel -0 convert.sh jpeg $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.png" -type f -print0 | parallel -0 convert.sh png $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.webp" -type f -print0 | parallel -0 convert.sh webp $IMG_FORMAT $QUALITY {};
		find "$IMG_PATH" -name "*.avif" -type f -print0 | parallel -0 convert.sh avif $IMG_FORMAT $QUALITY {};
	fi
}

function start_convert(){
	echo "0" > $CONVERT_COUNT_FILE
	echo "0" > $CONVERT_IGNORE_FILE
	startTime=`date +%Y-%m-%d\ %H:%M:%S`
	startTime_s=`date +%s`
	oldsize=`du -sh "$IMG_PATH" | awk '{print $1}'`
	tidy
	statistics
	find_img
	nowsize=`du -sh "$IMG_PATH" | awk '{print $1}'`
	endTime=`date +%Y-%m-%d\ %H:%M:%S`
	endTime_s=`date +%s`
	sumTime=$[ $endTime_s - $startTime_s ]
	swap_seconds $sumTime
	convertCount=`cat $CONVERT_COUNT_FILE`
	ignoreCount=`cat $CONVERT_IGNORE_FILE`
	echo -e "\033[32m \n转换完成！共处理 $convertCount 张图片，失败 $ignoreCount 张，原始大小：$oldsize，转换后大小：$nowsize，$startTime -> $endTime 总耗时：$ans\n \033[0m"
}

function swap_seconds ()
{
    SEC=$1
    if [ $SEC -lt 60 ]; then
       ans=`echo ${SEC} 秒`
    elif [ $SEC -ge 60 ] && [ $SEC -lt 3600 ]; then
       ans=`echo $(( SEC / 60 )) 分 $(( SEC % 60 )) 秒`
    elif [ $SEC -ge 3600 ]  && [ $SEC -lt 86400 ]; then
       ans=`echo $(( SEC / 3600 )) 时 $(( (SEC % 3600) / 60 )) 分 $(( (SEC % 3600) % 60 )) 秒`
    elif [ $SEC -ge 86400 ]; then
       ans=`echo $(( SEC / 86400 )) 天 $(( (SEC % 86400) / 3600 )) 时 $(( (SEC % 3600) / 60 )) 分 $(( (SEC % 3600) % 60 )) 秒`
    fi
}

if [[ -z "$1" || -z "$2" ]]; then
	echo_help
	exit 0
fi

if [[ $1 = 'png' ||  $1 = 'jpg' ||  $1 = 'webp' ||  $1 = 'avif' ||  $1 = 'heic' ||  $1 = 'total' ]]; then
	IMG_FORMAT=$1
else
	echo -e "\033[41;33m 目标格式错误 \033[0m"
	exit 1
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

if [ $IMG_FORMAT = 'total' ]; then
	find "$IMG_PATH" -type f -name "*.*" | awk -F. '{print $NF}' | sort | uniq -c -i
	exit 0
fi

echo -e "\033[44;37m 图片转换为 $IMG_FORMAT 格式，质量 $QUALITY ，路径：$IMG_PATH \033[0m"
read -r -p "确认参数是否正确？[Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
        start_convert
        ;;
    *)
        exit 0
        ;;
esac