#!/bin/bash 
###
###图片压缩工具
###
### 使用:
###
###   icomperess.sh <param> ... <path>
###
###
### 选项:
###
###   -f 			all/jpg/png/webp/avif，文件过滤，默认all即压缩全部图片。
###   -j 			0 - 100，jpg图片压缩率 数值小压缩率越高，默认75。
###   -p			0 - 100/auto，png图片压缩率 数值大压缩率越高，默认auto。
###   -w			0 - 100，webp图片压缩率 数值小压缩率越高，默认75。
###   -a			0 - 100，avif图片压缩率 数值小压缩率越高，默认75。
###   -h			0 - 100，heic图片压缩率 数值小压缩率越高，默认75。
###   -m,			图片的最低大小，低于这个大小的图片将会被过滤，默认2M。
###   -s,			统计各类型文件数量。
###   -h,			显示帮助信息。
###   <path>		文件夹路径。
###					日志保存在/tmp/compress.log
###

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:$SCRIPTPATH
export PATH

export LOG_FILE=/tmp/compress.log
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
CPU_MAX=`cat /proc/cpuinfo | grep "processor" | wc -l`
CPU_SUITABLE=`echo "scale=0; $CPU_MAX * 0.9 / 1" | bc`
CPU=1
IMG_PATH=
MIN_SIZE=2M
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

if [ $CPU_SUITABLE -gt 1 ]; then
	CPU=$CPU_SUITABLE
fi

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function log () {
	DATE=`date "+%Y-%m-%d %H:%M:%S"`
	if [ $1 = 'r' ]; then
		echo -e "\033[31m$2\033[0m"
		echo "${DATE} $0 [ERROR] $@" >> $LOG_FILE
	elif [ $1 = 'y' ]; then
		echo -e "\033[33m$2\033[0m"
		echo "${DATE} $0 [WARN] $@" >> $LOG_FILE
	elif [ $1 = 'g' ]; then
		echo -e "\033[32m$2\033[0m"
		echo "${DATE} $0 [INFO] $@" >> $LOG_FILE
	elif [ $1 = 'b' ]; then
		echo -e "\033[34m$2\033[0m"
		echo "${DATE} $0 [DEBUG] $@" >> $LOG_FILE
	else
		echo -e "$2"
		echo "${DATE} $0 [VERBOSE] $@" >> $LOG_FILE
	fi
}

function tidy(){
	log 'g' "正在整理图片"
	find "$IMG_PATH" -name "*.JPG" -type f -exec rename ".JPG" ".jpg" {} \;
	find "$IMG_PATH" -name "*.JPEG" -type f -exec rename ".JPEG" ".jpg" {} \;
	find "$IMG_PATH" -name "*.PNG" -type f -exec rename ".PNG" ".png" {} \;
	find "$IMG_PATH" -name "*.WEBP" -type f -exec rename ".WEBP" ".webp" {} \;
	find "$IMG_PATH" -name "*.AVIF" -type f -exec rename ".AVIF" ".avif" {} \;
	find "$IMG_PATH" -name "*.HEIC" -type f -exec rename ".HEIC" ".heic" {} \;
}

function statistics(){
	log 'g' "正在统计图片数量"
	jpgMax=0
	pngMax=0
	webpMax=0
	avifMax=0
	heicMax=0
	if [ $COMPRESS_JPG -eq 1 ]; then
		jpgMax1=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpg' -type f | wc -l`
		jpgMax2=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpeg' -type f | wc -l`
		let jpgMax=jpgMax1+jpgMax2
		log 'b' "jpg图片数量：$jpgMax"
	fi
	if [ $COMPRESS_PNG -eq 1 ]; then
		pngMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.png' -type f | wc -l`
		log 'b' "png图片数量：$pngMax"
	fi
	if [ $COMPRESS_WEBP -eq 1 ]; then
		webpMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.webp' -type f | wc -l`
		log 'b' "webp图片数量：$webpMax"
	fi
	if [ $COMPRESS_AVIF -eq 1 ]; then
		avifMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.avif' -type f | wc -l`
		log 'b' "avif图片数量：$avifMax"
	fi
	if [ $COMPRESS_HEIC -eq 1 ]; then
		heicMax=`find "$IMG_PATH" -size +$MIN_SIZE -name '*.heic' -type f | wc -l`
		log 'b' "heic图片数量：$heicMax"
	fi
	let maxCount=jpgMax+pngMax+webpMax+avifMax+heicMax
	log 'b' "预计总共处理图片 $maxCount 张"
	export MAX_COUNT=$maxCount
}

function find_img(){
	echo -e "\033[32m 开始压缩图片，线程数：$CPU \033[0m"
	#log "开始压缩图片，线程数：$CPU"
	if [ $COMPRESS_JPG -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpg' -type f -print0 | parallel --jobs $CPU -0 compress.sh jpg $JPG_QUALITY {};
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.jpeg' -type f -print0 | parallel --jobs $CPU -0 compress.sh jpg $JPG_QUALITY {};
	fi
    if [ $COMPRESS_PNG -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.png' -type f -print0 | parallel --jobs $CPU -0 compress.sh png $PNG_QUALITY {};
	fi
	if [ $COMPRESS_WEBP -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.webp' -type f -print0 | parallel --jobs $CPU -0 compress.sh webp $WEBP_QUALITY {};
	fi
	if [ $COMPRESS_AVIF -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.avif' -type f -print0 | parallel --jobs $CPU -0 compress.sh avif $AVIF_QUALITY {};
	fi
	if [ $COMPRESS_HEIC -eq 1 ]; then
		find "$IMG_PATH" -size +$MIN_SIZE -name '*.heic' -type f -print0 | parallel --jobs $CPU -0 compress.sh heic $HEIC_QUALITY {};
	fi
}

function show_config(){
	log 'y' "请确认拥有文件修改权限！！！"
	if [[  $COMPRESS_JPG -eq 1 && $COMPRESS_PNG -eq 1 && $COMPRESS_WEBP -eq 1 && $COMPRESS_AVIF -eq 1 ]]; then
		text+="压缩 jpg、png、webp、avif 图片：\n"
		text+="路径：$IMG_PATH\n"
		text+="jpg 压缩率：$JPG_QUALITY\n"
		text+="png 压缩率：$PNG_QUALITY\n"
		text+="webp 压缩率：$WEBP_QUALITY\n"
		text+="avif 压缩率：$AVIF_QUALITY\n"
	elif [ $COMPRESS_JPG -eq 1 ]; then
		text+="压缩 jpg 图片：\n"
		text+="路径：$IMG_PATH\n"
		text+="压缩率：$JPG_QUALITY\n"
	elif [ $COMPRESS_PNG -eq 1 ]; then
		text+="压缩 png 图片：\n"
		text+="路径：$IMG_PATH\n"
		text+="压缩率：$PNG_QUALITY\n"
	elif [ $COMPRESS_WEBP -eq 1 ]; then
		text+="压缩 webp 图片：\n"
		text+="路径：$IMG_PATH\n"
		text+="压缩率：$WEBP_QUALITY\n"
	elif [ $COMPRESS_AVIF -eq 1 ]; then
		text+="压缩 avif 图片：\n"
		text+="路径：$IMG_PATH\n"
		text+="压缩率：$AVIF_QUALITY\n"
	elif [ $COMPRESS_HEIC -eq 1 ]; then
		text+="压缩 heic 图片：\n"
		text+="路径：$IMG_PATH\n"
		text+="压缩率：$HEIC_QUALITY\n"
	fi
	text+="排除大小低于 $MIN_SIZE 的图片"
	log 'b' "$text"
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
	log 'b' "正在计算文件大小"
	oldsize=`du -sh "$IMG_PATH" | awk '{print $1}'`
	find_img
	log 'b' "压缩完成，正在计算文件大小"
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
	let error=maxCount-count-ignore
	log 'g' "\n压缩完成！共处理 $count 张图片，错误 $error 张图片，跳过 $ignore 张图片，原始大小：$oldsize，压缩后大小：$nowsize，$startTime -> $endTime 总耗时：$ans\n"
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
				log 'r' "-f 参数错误"
				exit 1
			fi
			;;
        j)
			if [[ $OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100 ]]; then
				JPG_QUALITY=$OPTARG
			else
				log 'r' "-j 参数错误"
				exit 1
			fi
			;;
        p)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) || $OPTARG = 'auto' ]]; then
				PNG_QUALITY=$OPTARG
			else
				log 'r' "-p 参数错误"
				exit 1
			fi
			;;
		w)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				WEBP_QUALITY=$OPTARG
			else
				log 'r' "-w 参数错误"
				exit 1
			fi
			;;
		a)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				AVIF_QUALITY=$OPTARG
			else
				log 'r' "-a 参数错误"
				exit 1
			fi
			;;
		h)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				HEIC_QUALITY=$OPTARG
			else
				log 'r' "-h 参数错误"
				exit 1
			fi
			;;
		m)
			if [[ $OPTARG =~ ^[1-9]?[0-9]?[0-9]?[0-9][b,c,w,k,M,G]$ ]]; then
				MIN_SIZE=$OPTARG
			else
				log 'r' "-m 参数错误"
				exit 1
			fi
			;;
        ?)
			log 'r' "参数错误"
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
		log 'r' "文件夹路径错误"
		exit 1
	fi
fi

if [ -f $LOG_FILE ]; then
	echo "" > $LOG_FILE
fi
show_config
tidy
statistics
if [ $maxCount -eq 0 ]; then
	exit 0
fi
read -r -p "确认参数是否正确？[Y/n] " input
case $input in
    [yY][eE][sS]|[yY])
        start_compress
        ;;
    *)
        exit 0
        ;;
esac
