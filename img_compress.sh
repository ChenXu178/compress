#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH
imgpath=''
min_size='100k'
ans=''
if [ -z "$imgpath" ]
then
        imgpath=$1
fi
if [ -z "$imgpath" ]
then
        echo "The image path cannot be empty!"
        exit
fi
#......png/jpg/bmp......
function com_img(){
        #......jpegoptim.......jpg
        find "$1" -size +$2 -name '*.jpg' -print0 | parallel -0 -X jpegoptim --strip-all -m ${JPG_QUALITY} {};
        find "$1" -size +$2 -name '*.JPG' -print0 | parallel -0 -X jpegoptim --strip-all -m ${JPG_QUALITY} {};
        find "$1" -size +$2 -name '*.jpeg' -print0 | parallel -0 -X jpegoptim --strip-all -m ${JPG_QUALITY} {};
        find "$1" -size +$2 -name '*.JPEG' -print0 | parallel -0 -X jpegoptim --strip-all -m ${JPG_QUALITY} {};
        #......optipng.......png....bmp
        find "$1" -size +$2 -name '*.png' -print0 | parallel -0 -X optipng -${PNG_QUALITY} {};
        find "$1" -size +$2 -name '*.PNG' -print0 | parallel -0 -X optipng -${PNG_QUALITY} {};
        find "$1" -size +$2 -name '*.bmp' -print0 | parallel -0 -X optipng -${PNG_QUALITY} {};
        find "$1" -size +$2 -name '*.BMP' -print0 | parallel -0 -X optipng -${PNG_QUALITY} {};
}
#..................
swap_seconds ()
{
        SEC=$1
        if [ $SEC -lt 60 ]; then
           ans=`echo ${SEC}s`
        elif [ $SEC -ge 60 ] && [ $SEC -lt 3600 ];then
           ans=`echo $(( SEC / 60 ))m$(( SEC % 60 ))s`
        elif [ $SEC -ge 3600 ]; then
           ans=`echo $(( SEC / 3600 ))h$(( (SEC % 3600) / 60 ))m$(( (SEC % 3600) % 60 ))s`
        fi
}

startTime=`date +%Y-%m-%d\ %H:%M:%S`
startTime_s=`date +%s`
oldsize=`du -sh "$imgpath" | awk '{print $1}'`
com_img "$imgpath" $min_size
nowsize=`du -sh "$imgpath" | awk '{print $1}'`
endTime=`date +%Y-%m-%d\ %H:%M:%S`
endTime_s=`date +%s`
sumTime=$[ $endTime_s - $startTime_s ]
swap_seconds $sumTime
echo -e "\033[32m \ncompress finish! old size=$oldsize, now size=$nowsize, $startTime ---> $endTime Total:$ans\n \033[0m"