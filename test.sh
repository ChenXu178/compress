#!/bin/bash 

while [ 1 ]    
do    
    a=$(ifconfig eth0 | grep 'RX pac' | awk '{print $3}' | awk -F: '{print $NF}')    
    echo -ne "$a\r"  #不换行刷新数据 
	sleep 1
done 