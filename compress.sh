#/bin/bash
if [ $1 = 'jpg' ]; then
	out=`jpegoptim --strip-all -m $2 "$3"`
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
elif [[  $1 = 'png' || $1 = 'PNG'  ]]; then
	if [ $2 = 'auto' ]; then
		pngquant --skip-if-larger -v -f --ext -fs8.png "$3"
	else
		pngquant --skip-if-larger -v -f --ext -fs8.png --quality $2 "$3"
	fi
	filename=`basename -s .$1 "$3"`
	dir=`dirname "$3"`
	if [[ -f "$dir"/"$filename"-fs8.png ]]; then
		{
			flock -x -w 5 300
			[ $? -eq 1 ] && { exit; }
			count=`cat $PNG_COUNT_FILE`
			let count++
			echo $count > $PNG_COUNT_FILE
		} 300<>/tmp/png_count.lock
		rm -rf "$3"
		mv "$dir"/"$filename"-fs8.png "$3"
	fi
elif [[  $1 = 'webp' || $1 = 'WEBP'  ]]; then
	filename=`basename -s .$1 "$3"`
	dir=`dirname "$3"`
	cwebp -q $(expr $2 + 0) "$3" -o "$dir"/"$filename"-compress.webp
	if [[ -f "$dir"/"$filename"-compress.webp ]]; then
		{
			flock -x -w 5 400
			[ $? -eq 1 ] && { exit; }
			count=`cat $WEBP_COUNT_FILE`
			let count++
			echo $count > $WEBP_COUNT_FILE
		} 400<>/tmp/webp_count.lock
		rm -rf "$3"
		mv "$dir"/"$filename"-compress.webp "$3"
	fi
fi 