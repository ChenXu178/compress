#/bin/bash

SOURCE=$1
QUALITY=$2
IMG_PATH="$3"
FILE_NAME=`basename -s .$SOURCE "$IMG_PATH"`
DIR=`dirname "$IMG_PATH"`
RESULT=0
OUT=

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

function progress_bar(){
	max=$1
	current=$2
	progress=`echo "scale=0;100*$current/$max" | bc`
	progress_f=`echo "scale=2;100*$current/$max" | bc`
	let lack="100-$progress"
	text="["
	for (( i=0; i < $progress; i++ ))  
	do   
		text+="#"
	done
	for (( i=0; i < $lack; i++ ))  
	do   
		text+="-"
	done
	text+="] [$progress_f%] $current/$max"
	log 'b' "$text"
}
log 'g' "\n$IMG_PATH"
if [ $SOURCE = 'jpg' ]; then
	OUT=`jpegoptim --strip-all -m $QUALITY "$IMG_PATH"`
	log 'w' "$OUT"
	value=`echo "$OUT" | sed 's/(/ /g' | sed 's/%)/ /g' | awk '{print $(NF-2)}'`
	if [[ -n $value && `echo "$value > 1" | bc` -eq 1 ]]; then
		RESULT=1
	fi
	{
		flock -x -w 5 200
		[ $? -eq 1 ] && { exit; }
		if [ $RESULT -eq 1 ]; then
			count=`cat $JPG_COUNT_FILE`
			let count++
			echo $count > $JPG_COUNT_FILE
		else
			count=`cat $JPG_IGNORE_FILE`
			let count++
			echo $count > $JPG_IGNORE_FILE
		fi
	} 200<>/tmp/jpg_count.lock
elif [ $SOURCE = 'png' ]; then
	if [ $QUALITY = 'auto' ]; then
		OUT=`pngquant --skip-if-larger -v -f --ext -ictmp.png "$IMG_PATH"`
	else
		OUT=`pngquant --skip-if-larger -v -f --ext -ictmp.png --quality $QUALITY "$IMG_PATH"`
	fi
	log 'w' "$OUT"
	if [[ -f "$DIR"/"$FILE_NAME"-ictmp.png ]]; then
		RESULT=1
		rm -rf "$IMG_PATH"
		mv "$DIR"/"$FILE_NAME"-ictmp.png "$IMG_PATH"
	fi
	{
		flock -x -w 5 300
		[ $? -eq 1 ] && { exit; }
		if [ $RESULT -eq 1 ]; then
			count=`cat $PNG_COUNT_FILE`
			let count++
			echo $count > $PNG_COUNT_FILE
		else
			count=`cat $PNG_IGNORE_FILE`
			let count++
			echo $count > $PNG_IGNORE_FILE
		fi
	} 300<>/tmp/png_count.lock
elif [ $SOURCE = 'webp' ]; then
	OUT=`cwebp -q $(expr $QUALITY + 0) "$IMG_PATH" -o "$DIR"/"$FILE_NAME"-ictmp.webp`
	log 'w' "$OUT"
	if [[ -f "$DIR"/"$FILE_NAME"-ictmp.webp ]]; then
		RESULT=1
		rm -rf "$IMG_PATH"
		mv "$DIR"/"$FILE_NAME"-ictmp.webp "$IMG_PATH"
	fi
	{
		flock -x -w 5 400
		[ $? -eq 1 ] && { exit; }
		if [ $RESULT -eq 1 ]; then
			count=`cat $WEBP_COUNT_FILE`
			let count++
			echo $count > $WEBP_COUNT_FILE
		else
			count=`cat $WEBP_IGNORE_FILE`
			let count++
			echo $count > $WEBP_IGNORE_FILE
		fi
	} 400<>/tmp/webp_count.lock
elif [[ $SOURCE = 'avif' || $SOURCE = 'heic' ]]; then
	OUT=`convert -verbose -quality $QUALITY "$IMG_PATH" "$DIR"/"$FILE_NAME"-ictmp.$SOURCE`
	log 'w' "$OUT"
	if [[ -f "$DIR"/"$FILE_NAME"-ictmp.$SOURCE ]]; then
		RESULT=1
		rm -rf "$IMG_PATH"
		mv "$DIR"/"$FILE_NAME"-ictmp.$SOURCE "$IMG_PATH"
	fi
	{
		flock -x -w 5 500
		[ $? -eq 1 ] && { exit; }
		if [ $SOURCE = 'avif' ]; then
			if [ $RESULT -eq 1 ]; then
				count=`cat $AVIF_COUNT_FILE`
				let count++
				echo $count > $AVIF_COUNT_FILE
			else
				count=`cat $AVIF_IGNORE_FILE`
				let count++
				echo $count > $AVIF_IGNORE_FILE
			fi
		elif [ $SOURCE = 'heic' ]; then
			if [ $RESULT -eq 1 ]; then
				count=`cat $HEIC_COUNT_FILE`
				let count++
				echo $count > $HEIC_COUNT_FILE
			else
				count=`cat $HEIC_IGNORE_FILE`
				let count++
				echo $count > $HEIC_IGNORE_FILE
			fi
		fi
	} 500<>/tmp/heif_count.lock
fi 
{
	flock -x -w 5 100
	[ $? -eq 1 ] && { exit; }
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
	
	let progress=jpgCount+pngCount+webpCount+avifCount+heicCount+jpgIgnore+pngIgnore+webpIgnore+avifIgnore+heicIgnore
	progress_bar $MAX_COUNT $progress
} 100<>/tmp/progress_bar.lock

