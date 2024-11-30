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
###   -c,			指定CPU线程数。
###   -h,			显示帮助信息。
###   <path>		文件夹路径。
###			日志保存在/tmp/compress.log
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

export COMPRESS_FILE_SIZE=/tmp/compress_file_size

ANS=
SIZE_FORMAT=
CPU_MAX=`cat /proc/cpuinfo | grep "processor" | wc -l`
CPU_SUITABLE=`echo "scale=0; $CPU_MAX * 0.6 / 1" | bc`
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

function statistics_file(){
	oldIFS=$IFS
	IFS=$'\n'
	for file in `find "$IMG_PATH" -size +$MIN_SIZE -name "*.$1" -type f`
	do
		let TOTAL_COUNT++
		let TOTAL_SIZE+=`wc -c < "$file"`
	done
	IFS=$oldIFS
}

function statistics(){
	TOTAL_COUNT=0
	TOTAL_SIZE=0
	log 'g' "正在统计图片数量"
	tmp=$TOTAL_COUNT
	if [ $COMPRESS_JPG -eq 1 ]; then
		statistics_file jpg
		statistics_file jpeg
		let jpgMax=TOTAL_COUNT-tmp
		log 'b' "jpg图片数量：$jpgMax"
	fi
	tmp=$TOTAL_COUNT
	if [ $COMPRESS_PNG -eq 1 ]; then
		statistics_file png
		let pngMax=TOTAL_COUNT-tmp
		log 'b' "png图片数量：$pngMax"
	fi
	tmp=$TOTAL_COUNT
	if [ $COMPRESS_WEBP -eq 1 ]; then
		statistics_file webp
		let webpMax=TOTAL_COUNT-tmp
		log 'b' "webp图片数量：$webpMax"
	fi
	tmp=$TOTAL_COUNT
	if [ $COMPRESS_AVIF -eq 1 ]; then
		statistics_file avif
		let avifMax=TOTAL_COUNT-tmp
		log 'b' "avif图片数量：$avifMax"
	fi
	tmp=$TOTAL_COUNT
	if [ $COMPRESS_HEIC -eq 1 ]; then
		statistics_file heic
		let heicMax=TOTAL_COUNT-tmp
		log 'b' "heic图片数量：$heicMax"
	fi
	format_size $TOTAL_SIZE
	log 'b' "预计总共处理图片 $TOTAL_COUNT 张，共 $SIZE_FORMAT"
	export MAX_COUNT=$TOTAL_COUNT
}

function find_img(){
	echo -e "\033[32m 开始压缩图片 \033[0m"
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
	text+="排除大小低于 $MIN_SIZE 的图片\n"
	text+="并行线程数：$CPU"
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
	echo "0" > $COMPRESS_FILE_SIZE
	startTime=`date +%Y-%m-%d\ %H:%M:%S`
	startTime_s=`date +%s`
	log 'b' "正在计算文件大小"
	oldsize=$SIZE_FORMAT
	find_img
	endTime=`date +%Y-%m-%d\ %H:%M:%S`
	endTime_s=`date +%s`
	let sumTime=endTime_s-startTime_s
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

	format_size `cat $COMPRESS_FILE_SIZE`
	nowsize=$SIZE_FORMAT
	let count=jpgCount+pngCount+webpCount+avifCount+heicCount
	let ignore=jpgIgnore+pngIgnore+webpIgnore+avifIgnore+heicIgnore
	let error=MAX_COUNT-count-ignore
	log 'g' "\n压缩完成！共处理 $count 张图片，错误 $error 张图片，跳过 $ignore 张图片，原始大小：$oldsize，已压缩文件大小：$nowsize，$startTime -> $endTime 总耗时：$ANS\n"
}

function swap_seconds ()
{
    SEC=$1
    if [ $SEC -lt 60 ]; then
       ANS=`echo ${SEC} 秒`
    elif [ $SEC -ge 60 ] && [ $SEC -lt 3600 ]; then
       ANS=`echo $(( SEC / 60 )) 分 $(( SEC % 60 )) 秒`
    elif [ $SEC -ge 3600 ]  && [ $SEC -lt 86400 ]; then
       ANS=`echo $(( SEC / 3600 )) 时 $(( (SEC % 3600) / 60 )) 分 $(( (SEC % 3600) % 60 )) 秒`
    elif [ $SEC -ge 86400 ]; then
       ANS=`echo $(( SEC / 86400 )) 天 $(( (SEC % 86400) / 3600 )) 时 $(( (SEC % 3600) / 60 )) 分 $(( (SEC % 3600) % 60 )) 秒`
    fi
}

function format_size ()
{
    totalsize=$1
    if [ $totalsize -lt 1048576 ]; then
       SIZE_FORMAT=`echo "scale=2; a = $totalsize / 1024 ; if (length(a)==scale(a)) print 0;print a" | bc `
       SIZE_FORMAT="$SIZE_FORMAT KB"
    elif [ $totalsize -ge 1048576 ] && [ $totalsize -lt 1073741824 ]; then
       SIZE_FORMAT=`echo "scale=2; a = $totalsize / 1048576 ; if (length(a)==scale(a)) print 0;print a" | bc `
       SIZE_FORMAT="$SIZE_FORMAT MB"
    elif [ $totalsize -ge 1073741824 ]  && [ $totalsize -lt 1099511627776 ]; then
       SIZE_FORMAT=`echo "scale=2; a = $totalsize / 1073741824 ; if (length(a)==scale(a)) print 0;print a" | bc `
       SIZE_FORMAT="$SIZE_FORMAT GB"
    elif [ $totalsize -ge 1099511627776 ]; then
       SIZE_FORMAT=`echo "scale=2; a = $totalsize / 1099511627776 ; if (length(a)==scale(a)) print 0;print a" | bc `
       SIZE_FORMAT="$SIZE_FORMAT TB"
    fi
}

while getopts ":f:j:p:w:a:h:m:c:" opt
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
		c)
			if [[ ($OPTARG =~ ^[01]?[0-9]?[0-9]$ && $OPTARG -le 100) ]]; then
				CPU=$OPTARG
			else
				log 'r' "-c 参数错误"
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
tidy
statistics
show_config
if [ $TOTAL_COUNT -eq 0 ]; then
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
