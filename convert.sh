#!/bin/bash 

SOURCE=$1
TARGET=$2
QUALITY=$3
IMG_PATH="$4"
FILE_NAME=`basename -s .$SOURCE "$IMG_PATH"`
DIR=`dirname "$IMG_PATH"`

convert -verbose -quality $QUALITY "$IMG_PATH" "$DIR"/"$FILE_NAME".$TARGET

if [[ -f "$DIR"/"$FILE_NAME".$TARGET ]]; then
	{
		flock -x -w 5 101
		[ $? -eq 1 ] && { exit; }
		count=`cat $CONVERT_COUNT_FILE`
		let count++
		echo $count > $CONVERT_COUNT_FILE
	} 101<>/tmp/convert_count.lock
	rm -rf "$IMG_PATH"
fi 