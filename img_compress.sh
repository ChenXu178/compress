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
###   -f, all jpg png webp		文件过滤，默认all即压缩全部图片。
###   -j, 0 - 100			jpg图片压缩率 数值小压缩率越高，默认从环境变量中读取，如果未设置则默认75。
###   -p, 0 - 100 auto		png图片压缩率 数值大压缩率越高，默认从环境变量中读取，如果未设置则默认auto。
###   -w, 0 - 100			webp图片压缩率 数值小压缩率越高，默认从环境变量中读取，如果未设置则默认75。
###   -m,				图片的最低大小，低于这个大小的图片将会被过滤，默认1M。
###   -h,				显示帮助信息。
###

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/home/chenxu/downloads/compress
export PATH
ans=
IMG_PATH=
MIN_SIZE=1M
COMPRESS_JPG=1
COMPRESS_PNG=1
COMPRESS_WEBP=1
export JPG_COUNT_FILE=/tmp/jpg_count
export PNG_COUNT_FILE=/tmp/png_count
export WEBP_COUNT_FILE=/tmp/webp_count

if [[ -z "${JPG_QUALITY}" ]]; then
  MY_JPG_QUALITY=75
else
  MY_JPG_QUALITY=${JPG_QUALITY}
fi

if [[ -z "${PNG_QUALITY}" ]]; then
  MY_PNG_QUALITY=auto
else
  MY_PNG_QUALITY=${PNG_QUALITY}
fi

if [[ -z "${WEBP_QUALITY}" ]]; then
  MY_WEBP_QUALITY=75
else
  MY_WEBP_QUALITY=${WEBP_QUALITY}
fi

if [ -e $JPG_COUNT_FILE ]; then
	rm -rf $JPG_COUNT_FILE
fi

if [ -e $PNG_COUNT_FILE ]; then
	rm -rf $PNG_COUNT_FILE
fi

if [ -e $WEBP_COUNT_FILE ]; then
	rm -rf $WEBP_COUNT_FILE
fi

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function find_img(){
	if [ $COMPRESS_JPG -eq 1 ]; then
		#......jpegoptim.......jpg
		find "$1" -size +$2 -name '*.jpg' -type f -print0 | parallel -0 compress.sh jpg $MY_JPG_QUALITY {};
		find "$1" -size +$2 -name '*.JPG' -type f -print0 | parallel -0 compress.sh jpg $MY_JPG_QUALITY {};
		find "$1" -size +$2 -name '*.jpeg' -type f -print0 | parallel -0 compress.sh jpg $MY_JPG_QUALITY {};
		find "$1" -size +$2 -name '*.JPEG' -type f -print0 | parallel -0 compress.sh jpg $MY_JPG_QUALITY {};
	fi
    if [ $COMPRESS_PNG -eq 1 ]; then
		#......pngquant.......png
		find "$1" -size +$2 -name '*.png' -type f -print0 | parallel -0 compress.sh png $MY_PNG_QUALITY {};
		find "$1" -size +$2 -name '*.PNG' -type f -print0 | parallel -0 compress.sh PNG $MY_PNG_QUALITY {};
	fi
	if [ $COMPRESS_WEBP -eq 1 ]; then
		#......cwebp.......webp
		find "$1" -size +$2 -name '*.webp' -type f -print0 | parallel -0 compress.sh webp $MY_WEBP_QUALITY {};
		find "$1" -size +$2 -name '*.WEBP' -type f -print0 | parallel -0 compress.sh WEBP $MY_WEBP_QUALITY {};
	fi
}
function show_config(){
	if [[  $COMPRESS_JPG -eq 1 && $COMPRESS_PNG -eq 1 && $COMPRESS_WEBP -eq 1 ]]; then
		echo -e "\033[44;37m 压缩 jpg、png 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m jpg 压缩率：$MY_JPG_QUALITY \033[0m"
		echo -e "\033[44;37m png 压缩率：$MY_PNG_QUALITY \033[0m"
		echo -e "\033[44;37m webp 压缩率：$MY_WEBP_QUALITY \033[0m"
	elif [ $COMPRESS_JPG -eq 1 ]; then
		echo -e "\033[44;37m 压缩 jpg 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$MY_JPG_QUALITY \033[0m"
	elif [ $COMPRESS_PNG -eq 1 ]; then
		echo -e "\033[44;37m 压缩 png 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$MY_PNG_QUALITY \033[0m"
	elif [ $COMPRESS_WEBP -eq 1 ]; then
		echo -e "\033[44;37m 压缩 webp 图片： \033[0m"
		echo -e "\033[44;37m 路径：$IMG_PATH \033[0m"
		echo -e "\033[44;37m 压缩率：$MY_WEBP_QUALITY \033[0m"
	fi
	echo -e "\033[44;37m 排除大小低于 $MIN_SIZE 的图片 \033[0m"
}

function start_compress(){
	echo "0" > $JPG_COUNT_FILE
	echo "0" > $PNG_COUNT_FILE
	echo "0" > $WEBP_COUNT_FILE
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
	echo -e "\033[32m \n压缩完成！共处理 $jpgCount 张jpg图片、$pngCount 张png图片、$webpCount 张webp图片 ，原始大小：$oldsize，压缩后大小：$nowsize，$startTime -> $endTime 总耗时：$ans\n \033[0m"
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

while getopts ":f:j:p:w:m:" opt
do
    case $opt in
        f)
			if [[ $OPTARG =~ ^all$|^jpg$|^png$|^webp$ ]]; then
				if [ $OPTARG = 'jpg' ]; then
					COMPRESS_JPG=1
					COMPRESS_PNG=0
					COMPRESS_WEBP=0
				elif [ $OPTARG = 'png' ]; then
					COMPRESS_JPG=0
					COMPRESS_PNG=1
					COMPRESS_WEBP=0
				elif [ $OPTARG = 'webp' ]; then
					COMPRESS_JPG=0
					COMPRESS_PNG=0
					COMPRESS_WEBP=1
				fi
			else
				echo -e "\033[41;33m -f 参数错误 \033[0m"
				exit 1
			fi
			;;
        j)
			if [[ $OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100 ]]; then
				MY_JPG_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -j 参数错误 \033[0m"
				exit 1
			fi
			;;
        p)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) || $OPTARG = 'auto' ]]; then
				MY_PNG_QUALITY=$OPTARG
			else
				echo -e "\033[41;33m -p 参数错误 \033[0m"
				exit 1
			fi
			;;
		w)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				MY_WEBP_QUALITY=$OPTARG
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
