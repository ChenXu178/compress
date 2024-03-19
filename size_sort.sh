#!/bin/bash 
###
###文件大小排序工具
###
### 使用:
###
###   size_sort.sh <param> <path>
###
###
### 选项:
###		
###   asc | dsc		asc升序排列，dsc降序排列，默认asc
###   <path>		文件夹路径。
###

SORT="asc"

function echo_help(){
	sed -rn 's/^### ?//;T;p;' "$0"
}

function format(){
	kb=1024
	let mb=kb\*kb
	let gb=mb\*kb
	let tb=gb\*kb
	if [ $1 -ge $tb ]; then
		RESULT=`echo "scale=2;$1/$tb" | bc`
		FORMAT="$RESULT TB"
	elif [ $1 -ge $gb ]; then
		RESULT=`echo "scale=2;$1/$gb" | bc`
		FORMAT="$RESULT GB"
	elif [ $1 -ge $mb ]; then
		RESULT=`echo "scale=2;$1/$mb" | bc`
		FORMAT="$RESULT MB"
	else
		RESULT=`echo "scale=2;$1/$kb" | bc`
		FORMAT="$RESULT KB"
	fi
}

function traverse(){
	if [[ "$FILE_PATH" =~ ^.*\/$ ]]; then
		FILE_PATH=$FILE_PATH*
	else
		FILE_PATH=$FILE_PATH/*
	fi
	index=0
	for file in $FILE_PATH
	do	
		line=`du -sh --time -b "$file"`
		LIST_SIZE[$index]=`echo $line | awk '{print $(1)}'`
		LIST_DATE[$index]=`echo $line | awk '{print $(2)}'`
		LIST_TIME[$index]=`echo $line | awk '{print $(3)}'`
		LIST_PATH[$index]=$file
		let index++
	done
	for (( i=0 ; i < ${#LIST_SIZE[@]} ; i++ ))
	do
		for (( j=0 ; j < ${#LIST_SIZE[@]}-1 ; j++ ))
		do
			if [ ${LIST_SIZE[$j]} -gt ${LIST_SIZE[j+1]} ]; then
				if [ $SORT = 'dsc' ]; then
					continue
				fi
			elif [ ${LIST_SIZE[$j]} -lt ${LIST_SIZE[j+1]} ]; then
				if [ $SORT = 'asc' ]; then
					continue
				fi
			fi
			tmp_size=${LIST_SIZE[j+1]}
			LIST_SIZE[j+1]=${LIST_SIZE[$j]}
			LIST_SIZE[$j]=$tmp_size
			
			tmp_date=${LIST_DATE[j+1]}
			LIST_DATE[j+1]=${LIST_DATE[$j]}
			LIST_DATE[$j]=$tmp_date
			
			tmp_time=${LIST_TIME[j+1]}
			LIST_TIME[j+1]=${LIST_TIME[$j]}
			LIST_TIME[$j]=$tmp_time
			
			tmp_path=${LIST_PATH[j+1]}
			LIST_PATH[j+1]=${LIST_PATH[$j]}
			LIST_PATH[$j]=$tmp_path
		done
	done
	echo -e "\n"
	for(( i=0; i < $index; i++ )) 
	do
		format ${LIST_SIZE[i]}
		printf "%-10s	%-20s	%-40s\n" "$FORMAT" "${LIST_DATE[i]} ${LIST_TIME[i]}" "${LIST_PATH[i]}"
	done;
	echo -e "\n-----------------------------------------------------------------------------\n"
	FILE_PATH=`echo "$FILE_PATH" | sed 's/\*//g'`
	line=`du -sh --time -b "$FILE_PATH"`
	size=`echo $line | awk '{print $(1)}'`
	date=`echo $line | awk '{print $(2)}'`
	time=`echo $line | awk '{print $(3)}'`
	format $size
	printf "%-5d	%-10s	%-20s	%-40s\n\n" $index "$FORMAT" "$date $time" "$FILE_PATH"
}

if [ $# -eq 2 ]; then
	TMP_SORT="$1"
	TMP_PATH="$2"
else
	TMP_PATH="$1"
fi

if [ -z "$1" ]; then
	echo_help
	exit 0
fi

if [[ "$TMP_SORT" = 'asc' || "$TMP_SORT" = 'dsc' ]]; then
    SORT="$TMP_SORT"
else
	echo -e "\033[41;33m 参数错误错误(asc|dsc) \033[0m"
	exit 1
fi 

if [[ -d "$TMP_PATH" || -f "$TMP_PATH" ]]; then
    FILE_PATH="$TMP_PATH"
else
	echo -e "\033[41;33m 文件夹路径错误 \033[0m"
	exit 1
fi 
if [ -f "$FILE_PATH" ]; then
	line=`du -sh --time -b "$FILE_PATH"`
	size=`echo $line | awk '{print $(1)}'`
	date=`echo $line | awk '{print $(2)}'`
	time=`echo $line | awk '{print $(3)}'`
	format $size
	printf "%-10s	%-20s	%-40s\n" "$FORMAT" "$date $time" "$FILE_PATH"
elif [ -d "$FILE_PATH" ]; then
	traverse
fi 