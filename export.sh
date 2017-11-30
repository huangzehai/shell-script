#!/bin/bash
# Parameter validation
# Set default size
size=10
city=$1_4G
if [ $# = 0 ];then
    echo Usage:./export.sh city [date] [size] [3G]
    exit 0
elif [ $# = 1 ];then
   hdfs dfs -ls hdfs:///daas/bstl/dpiqixin/$1_4G
   exit 0
elif [ $# = 3 ];then
   if [ $3 = '3G' ];then 
      city=$1
   fi
elif [ $# = 4 ];then
   size=$4
fi

outputDir=/tmp/tt/
hdfs dfs -ls hdfs:///daas/bstl/dpiqixin/$city/$2 | grep hdfs | head -$size
for file in `hdfs dfs -ls hdfs:///daas/bstl/dpiqixin/$city/$2 | grep hdfs| head -$size |awk '{print $8}'`
    do 
    echo Process file: $file
    output=`echo $file | awk -F'/' '{print $9}' | awk -F'.' '{print $2}' | awk -F'_' '{print $1}'`
    outputPath=$outputDir$city'_'$output.log
    echo Copy file to: $outputPath
    hdfs dfs -text $file | awk -F'|' '{print $30}' >> $outputPath 
done
echo Done
