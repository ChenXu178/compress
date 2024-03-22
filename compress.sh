#/bin/bash

SOURCE=$1
QUALITY=$2
IMG_PATH="$3"
FILE_NAME=`basename -s .$SOURCE "$IMG_PATH"`
DIR=`dirname "$IMG_PATH"`

if [ $SOURCE = 'jpg' ]; then
	out=`jpegoptim --strip-all -m $QUALITY "$IMG_PATH"`
	echo $out
	value=`echo "$out" | sed 's/(/ /g' | sed 's/%)/ /g' | awk '{print $(NF-2)}'`
	if [[ -n $value && `echo "$value > 1" | bc` -eq 1 ]]; then
		{
			flock -x -w 5 200
			[ $? -eq 1 ] && { exit; }
			count=`cat $JPG_COUNT_FILE`
			let count++
			echo $count > $JPG_COUNT_FILE
		} 200<>/tmp/jpg_count.lock
	fi 
elif [ $SOURCE = 'png' ]; then
	if [ $QUALITY = 'auto' ]; then
		pngquant --skip-if-larger -v -f --ext -ictmp.png "$IMG_PATH"
	else
		pngquant --skip-if-larger -v -f --ext -ictmp.png --quality $QUALITY "$IMG_PATH"
	fi
	if [[ -f "$DIR"/"$FILE_NAME"-ictmp.png ]]; then
		{
			flock -x -w 5 300
			[ $? -eq 1 ] && { exit; }
			count=`cat $PNG_COUNT_FILE`
			let count++
			echo $count > $PNG_COUNT_FILE
		} 300<>/tmp/png_count.lock
		rm -rf "$IMG_PATH"
		mv "$DIR"/"$FILE_NAME"-ictmp.png "$IMG_PATH"
	fi
elif [ $SOURCE = 'webp' ]; then
	cwebp -q $(expr $QUALITY + 0) "$IMG_PATH" -o "$DIR"/"$FILE_NAME"-ictmp.webp
	if [[ -f "$DIR"/"$FILE_NAME"-ictmp.webp ]]; then
		{
			flock -x -w 5 400
			[ $? -eq 1 ] && { exit; }
			count=`cat $WEBP_COUNT_FILE`
			let count++
			echo $count > $WEBP_COUNT_FILE
		} 400<>/tmp/webp_count.lock
		rm -rf "$IMG_PATH"
		mv "$DIR"/"$FILE_NAME"-ictmp.webp "$IMG_PATH"
	fi
elif [[ $SOURCE = 'avif' || $SOURCE = 'heic' ]]; then
	convert -verbose -quality $QUALITY "$IMG_PATH" "$DIR"/"$FILE_NAME"-ictmp.$SOURCE
	if [[ -f "$DIR"/"$FILE_NAME"-ictmp.$SOURCE ]]; then
		{
			flock -x -w 5 500
			[ $? -eq 1 ] && { exit; }
			if [ $SOURCE = 'avif' ]; then
				count=`cat $AVIF_COUNT_FILE`
				let count++
				echo $count > $AVIF_COUNT_FILE
			elif [ $SOURCE = 'heic' ]; then
				count=`cat $HEIC_COUNT_FILE`
				let count++
				echo $count > $HEIC_COUNT_FILE
			fi
		} 500<>/tmp/heif_count.lock
		rm -rf "$IMG_PATH"
		mv "$DIR"/"$FILE_NAME"-ictmp.$SOURCE "$IMG_PATH"
	fi
fi 