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

if [ -e $JPG_COUNT_FILE ]; then
	rm -rf $JPG_COUNT_FILE
fi

if [ -e $PNG_COUNT_FILE ]; then
	rm -rf $PNG_COUNT_FILE
fi

if [ -e $WEBP_COUNT_FILE ]; then
	rm -rf $WEBP_COUNT_FILE
fi

if [ -e $AVIF_COUNT_FILE ]; then
	rm -rf $AVIF_COUNT_FILE
fi

if [ -e $HEIC_COUNT_FILE ]; then
	rm -rf $HEIC_COUNT_FILE
fi

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function find_img(){
	if [ $COMPRESS_JPG -eq 1 ]; then
		find "$1" -size +$2 -name '*.jpg' -type f -print0 | parallel -0 compress.sh jpg $JPG_QUALITY {};
		find "$1" -size +$2 -name '*.jpeg' -type f -print0 | parallel -0 compress.sh jpg $JPG_QUALITY {};
	fi
    if [ $COMPRESS_PNG -eq 1 ]; then
		find "$1" -size +$2 -name '*.png' -type f -print0 | parallel -0 compress.sh png $PNG_QUALITY {};
	fi
	if [ $COMPRESS_WEBP -eq 1 ]; then
		find "$1" -size +$2 -name '*.webp' -type f -print0 | parallel -0 compress.sh webp $WEBP_QUALITY {};
	fi
	if [ $COMPRESS_AVIF -eq 1 ]; then
		find "$1" -size +$2 -name '*.avif' -type f -print0 | parallel -0 compress.sh avif $AVIF_QUALITY {};
	fi
	if [ $COMPRESS_HEIC -eq 1 ]; then
		find "$1" -size +$2 -name '*.heic' -type f -print0 | parallel -0 compress.sh heic $HEIC_QUALITY {};
	fi
}

function show_config(){
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
	startTime=`date +%Y-%m-%d\ %H:%M:%S`
	startTime_s=`date +%s`
	oldsize=`du -sh "$IMG_PATH" | awk '{print $1}'`
	find_img "$IMG_PATH" $MIN_SIZE
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
	echo -e "\033[32m \n压缩完成！共处理 $jpgCount 张jpg图片、$pngCount 张png图片、$webpCount 张webp图片、$avifCount 张avif图片、$heicCount 张heic图片 ，原始大小：$oldsize，压缩后大小：$nowsize，$startTime -> $endTime 总耗时：$ans\n \033[0m"
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
