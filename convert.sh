#!/bin/bash 

SOURCE=$1
TARGET=$2
QUALITY=$3
IMG_PATH="$4"
filename=`basename -s .$SOURCE "$IMG_PATH"`
dir=`dirname "$IMG_PATH"`

convert -verbose -quality $QUALITY "$IMG_PATH" "$dir"/"$filename".$TARGET

if [[ -f "$dir"/"$filename".$TARGET ]]; then
	{
		flock -x -w 5 101
		[ $? -eq 1 ] && { exit; }
		count=`cat $CONVERT_COUNT_FILE`
		let count++
		echo $count > $CONVERT_COUNT_FILE
	} 101<>/tmp/convert_count.lock
	rm -rf "$IMG_PATH"
fi 