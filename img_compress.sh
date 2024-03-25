#!/bin/bash 
###
###图片压缩工具
###
### 使用:
###
###   img_comperess.sh <param> ... <path>
###
###
### 选项:
###
###   <path>			文件夹路径。
###   -f, all jpg png webp avif	文件过滤，默认all即压缩全部图片。
###   -j, 0 - 100			jpg图片压缩率 数值小压缩率越高，默认75。
###   -p, 0 - 100 auto		png图片压缩率 数值大压缩率越高，默认auto。
###   -w, 0 - 100			webp图片压缩率 数值小压缩率越高，默认75。
###   -a, 0 - 100			avif图片压缩率 数值小压缩率越高，默认75。
###   -h, 0 - 100			heic图片压缩率 数值小压缩率越高，默认75。
###   -m,				图片的最低大小，低于这个大小的图片将会被过滤，默认1M。
###   -s,				统计各类型文件数量。
###   -h,				显示帮助信息。
###

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/home/chenxu/downloads/compress
export PATH

export JPG_COUNT_FILE=/tmp/jpg_count
export PNG_COUNT_FILE=/tmp/png_count
export WEBP_COUNT_FILE=/tmp/webp_count
export AVIF_COUNT_FILE=/tmp/avif_count
export HEIC_COUNT_FILE=/tmp/heic_count

export JPG_IGNORE_FILE=/tmp/jpg_ignore
export PNG_IGNORE_FILE=/tmp/png_ignore
export WEBP_IGNORE_FILE=/tmp/webp_ignore
export AVIF_IGNORE_FILE=/tmp/avif_ignore
export HEIC_IGNORE_FILE=/tmp/heic_ignore

ans=
IMG_PATH=
MIN_SIZE=1M
COMPRESS_JPG=1
COMPRESS_PNG=1
COMPRESS_WEBP=1
COMPRESS_AVIF=1
COMPRESS_HEIC=1

JPG_QUALITY=75
PNG_QUALITY=auto
WEBP_QUALITY=75
AVIF_QUALITY=75
HEIC_QUALITY=75

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
	jpgMax=0
	pngMax=0
	webpMax=0
	avifMax=0
	heicMax=0
	if [ $COMPRESS_JPG -eq 1 ]; then
		jpgMax1=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpg' -type f | wc -l`
		jpgMax2=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpeg' -type f | wc -l`
		let jpgMax=jpgMax1+jpgMax2
		echo -e "\033[34m 预计处理jpg图片数量：$jpgMax \033[0m"
	fi
	if [ $COMPRESS_PNG -eq 1 ]; then
		pngMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.png' -type f | wc -l`
		echo -e "\033[34m 预计处理png图片数量：$pngMax \033[0m"
	fi
	if [ $COMPRESS_WEBP -eq 1 ]; then
		webpMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.webp' -type f | wc -l`
		echo -e "\033[34m 预计处理webp图片数量：$webpMax \033[0m"
	fi
	if [ $COMPRESS_AVIF -eq 1 ]; then
		avifMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.avif' -type f | wc -l`
		echo -e "\033[34m 预计处理avif图片数量：$avifMax \033[0m"
	fi
	if [ $COMPRESS_HEIC -eq 1 ]; then
		heicMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.heic' -type f | wc -l`
		echo -e "\033[34m 预计处理heic图片数量：$heicMax \033[0m"
	fi
	let maxCount=jpgMax+pngMax+webpMax+avifMax+heicMax
	export MAX_COUNT=$maxCount
}

function find_img(){
	echo -e "\033[32m 开始压缩图片 \033[0m"
	if [ $COMPRESS_JPG -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpg' -type f -print0 | parallel -0 compress.sh jpg $JPG_QUALITY {};
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpeg' -type f -print0 | parallel -0 compress.sh jpg $JPG_QUALITY {};
	fi
    if [ $COMPRESS_PNG -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.png' -type f -print0 | parallel -0 compress.sh png $PNG_QUALITY {};
	fi
	if [ $COMPRESS_WEBP -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.webp' -type f -print0 | parallel -0 compress.sh webp $WEBP_QUALITY {};
	fi
	if [ $COMPRESS_AVIF -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.avif' -type f -print0 | parallel -0 compress.sh avif $AVIF_QUALITY {};
	fi
	if [ $COMPRESS_HEIC -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.heic' -type f -print0 | parallel -0 compress.sh heic $HEIC_QUALITY {};
	fi
}

function show_config(){
	echo -e "\033[33m 开始处理前请确认拥有文件修改权限！！！ \033[0m"
	if [[  $COMPRESS_JPG -eq 1 && $COMPRESS_PNG -eq 1 && $COMPRESS_WEBP -eq 1 && $COMPRESS_AVIF -eq 1 ]]; then
		echo -e "\033[44;37m 压缩 jpg、png、webp、avif 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m jpg 压缩率：$JPG_QUALITY \033[0m"
		echo -e "\033[44;37m png 压缩率：$PNG_QUALITY \033[0m"
		echo -e "\033[44;37m webp 压缩率：$WEBP_QUALITY \033[0m"
		echo -e "\033[44;37m avif 压缩率：$AVIF_QUALITY \033[0m"
	elif [ $COMPRESS_JPG -eq 1 ]; then
		echo -e "\033[44;37m 压缩 jpg 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$JPG_QUALITY \033[0m"
	elif [ $COMPRESS_PNG -eq 1 ]; then
		echo -e "\033[44;37m 压缩 png 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$PNG_QUALITY \033[0m"
	elif [ $COMPRESS_WEBP -eq 1 ]; then
		echo -e "\033[44;37m 压缩 webp 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$WEBP_QUALITY \033[0m"
	elif [ $COMPRESS_AVIF -eq 1 ]; then
		echo -e "\033[44;37m 压缩 avif 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$AVIF_QUALITY \033[0m"
	elif [ $COMPRESS_HEIC -eq 1 ]; then
		echo -e "\033[44;37m 压缩 heic 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$HEIC_QUALITY \033[0m"
	fi
	echo -e "\033[44;37m 排除大小低于 $MIN_SIZE 的图片 \033[0m"
}

function start_compress(){
	echo "0" > $JPG_COUNT_FILE
	echo "0" > $PNG_COUNT_FILE
	echo "0" > $WEBP_COUNT_FILE
	echo "0" > $AVIF_COUNT_FILE
	echo "0" > $HEIC_COUNT_FILE
	echo "0" > $JPG_IGNORE_FILE
	echo "0" > $PNG_IGNORE_FILE
	echo "0" > $WEBP_IGNORE_FILE
	echo "0" > $AVIF_IGNORE_FILE
	echo "0" > $HEIC_IGNORE_FILE
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
	jpgCount=`cat $JPG_COUNT_FILE`
	pngCount=`cat $PNG_COUNT_FILE`
	webpCount=`cat $WEBP_COUNT_FILE`
	avifCount=`cat $AVIF_COUNT_FILE`
	heicCount=`cat $HEIC_COUNT_FILE`
	
	jpgIgnore=`cat $JPG_IGNORE_FILE`
	pngIgnore=`cat $PNG_IGNORE_FILE`
	webpIgnore=`cat $WEBP_IGNORE_FILE`
	avifIgnore=`cat $AVIF_IGNORE_FILE`
	heicIgnore=`cat $HEIC_IGNORE_FILE`
	let count=jpgCount+pngCount+webpCount+avifCount+heicCount
	let ignore=jpgIgnore+pngIgnore+webpIgnore+avifIgnore+heicIgnore
	echo -e "\033[32m \n压缩完成！共处理 $count 张图片，跳过 $ignore 张图片 ，原始大小：$oldsize，压缩后大小：$nowsize，$startTime -> $endTime 总耗时：$ans\n \033[0m"
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

while getopts ":f:j:p:w:a:h:m:" opt
do
    case $opt in
        f)
			if [[ $OPTARG =~ ^all$|^jpg$|^png$|^webp$|^avif$|^heic$ ]]; then
				if [ $OPTARG = 'jpg' ]; then
					COMPRESS_JPG=1
					COMPRESS_PNG=0
					COMPRESS_WEBP=0
					COMPRESS_AVIF=0
					COMPRESS_HEIC=0
				elif [ $OPTARG = 'png' ]; then
					COMPRESS_JPG=0
					COMPRESS_PNG=1
					COMPRESS_WEBP=0
					COMPRESS_AVIF=0
					COMPRESS_HEIC=0
				elif [ $OPTARG = 'webp' ]; then
					COMPRESS_JPG=0
					COMPRESS_PNG=0
					COMPRESS_WEBP=1
					COMPRESS_AVIF=0
					COMPRESS_HEIC=0
				elif [ $OPTARG = 'avif' ]; then
					COMPRESS_JPG=0
					COMPRESS_PNG=0
					COMPRESS_WEBP=0
					COMPRESS_AVIF=1
					COMPRESS_HEIC=0
				elif [ $OPTARG = 'heic' ]; then
					COMPRESS_JPG=0
					COMPRESS_PNG=0
					COMPRESS_WEBP=0
					COMPRESS_AVIF=0
					COMPRESS_HEIC=1
				fi
			else
				echo -e "\033[41;33m -f 参数错误 \033[0m"
				exit 1
			fi
			;;
        j)
			if [[ $OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100 ]]; then
				JPG_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -j 参数错误 \033[0m"
				exit 1
			fi
			;;
        p)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) || $OPTARG = 'auto' ]]; then
				PNG_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -p 参数错误 \033[0m"
				exit 1
			fi
			;;
		w)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				WEBP_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -p 参数错误 \033[0m"
				exit 1
			fi
			;;
		a)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				AVIF_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -p 参数错误 \033[0m"
				exit 1
			fi
			;;
		h)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				HEIC_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -p 参数错误 \033[0m"
				exit 1
			fi
			;;
		m)
			if [[ $OPTARG =~ ^[1-9]?[0-9]?[0-9]?[0-9][b,c,w,k,M,G]$ ]]; then
				MIN_SIZE=$OPTARG
			else
				echo -e "\033[41;33m -m 参数错误 \033[0m"
				exit 1
			fi
			;;
        ?)
			echo -e "\033[41;33m 参数错误 \033[0m"
			echo_help
			exit 1
			;;
    esac
done

if [ -z "$1" ]; then
	echo_help
	exit 0
else
	if [ -d "${!#}" ]; then
        IMG_PATH="${!#}"
	else
		echo -e "\033[41;33m 文件夹路径错误 \033[0m"
		exit 1
	fi
fi
show_config
read -r -p "确认参数是否正确？[Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
        start_compress
        ;;
    *)
        exit 0
        ;;
esac
