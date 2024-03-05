#!/bin/bash
##########      name:..................                                 ##########
##########      author:xiaoz<xiaoz93@outlook.com>       ##########
##########      Blog:https://www.xiaoz.me/                      ##########
##########      update:2019-08-23                                       ##########
#..................
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH
#........................
imgpath=''
#...............................................................
min_size='100k'
#..............................
if [ -z "$imgpath" ]
then
        imgpath=$1
fi
if [ -z "$imgpath" ]
then
        echo 'The image path cannot be empty!'
        exit
fi
#......png/jpg/bmp......
function com_img(){
        #......jpegoptim.......jpg
        find "$1" -size +$2 -name '*.jpg' -exec jpegoptim --strip-all -m ${JPG_QUALITY} {} \;
        find "$1" -size +$2 -name '*.JPG' -exec jpegoptim --strip-all -m ${JPG_QUALITY} {} \;
        find "$1" -size +$2 -name '*.jpeg' -exec jpegoptim --strip-all -m ${JPG_QUALITY} {} \;
        find "$1" -size +$2 -name '*.JPEG' -exec jpegoptim --strip-all -m ${JPG_QUALITY} {} \;
        #......optipng.......png....bmp
        find "$1" -size +$2 -name '*.png' -exec optipng -${PNG_QUALITY} {} \;
        find "$1" -size +$2 -name '*.PNG' -exec optipng -${PNG_QUALITY} {} \;
        find "$1" -size +$2 -name '*.bmp' -exec optipng -${PNG_QUALITY} {} \;
        find "$1" -size +$2 -name '*.BMP' -exec optipng -${PNG_QUALITY} {} \;
}
#..................
oldsize=`du -sh "$imgpath" | awk '{print $1}'`
com_img "$imgpath" $min_size
nowsize=`du -sh "$imgpath" | awk '{print $1}'`
echo "compress finish! old size=$oldsize, now size=$nowsize"
