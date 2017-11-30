#!/bin/bash
# Parameter validation
if [ $# = 0 ];then
    echo Usage:./uid.sh file[*]
    exit 0
fi

echo +------Select domain and platform-------+
echo 1: Baidu[iOS]
echo q: Quit

read option

if [ $option = 1 ];then
   grep 'mbd.baidu.com/searchbox'  $@  |  grep 'osbranch=i0' | awk -F'uid=' '{print $2}' | awk -F'&' '{printf $1" "}'
else
   echo Quit
fi
