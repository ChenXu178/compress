#!/bin/bash 

SOURCE=$1
TARGET=$2
QUALITY=$3
IMG_PATH="$4"
FILE_NAME=`basename -s .$SOURCE "$IMG_PATH"`
DIR=`dirname "$IMG_PATH"`
RESULT=0

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
	echo -e "\033[34m $text \033[0m"
	echo -e "\n"
}

convert -verbose -quality $QUALITY "$IMG_PATH" "$DIR"/"$FILE_NAME".$TARGET

if [[ -f "$DIR"/"$FILE_NAME".$TARGET ]]; then
	RESULT=1
	rm -rf "$IMG_PATH"
fi 
{
	flock -x -w 5 101
	[ $? -eq 1 ] && { exit; }
	count=`cat $CONVERT_COUNT_FILE`
	ignore=`cat $CONVERT_IGNORE_FILE`
	if [ $RESULT -eq 1 ]; then
		let count++
		echo $count > $CONVERT_COUNT_FILE
	else
		let ignore++
		echo $ignore > $CONVERT_IGNORE_FILE
	fi
	let progress=count+ignore
	progress_bar $MAX_COUNT $progress
} 101<>/tmp/convert_count.lock
