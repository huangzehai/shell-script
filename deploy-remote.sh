#!/bin/bash

#set ENV
export JAVA_HOME=/usr/local/jdk1.8.0_131/

# Load configuration
CONF_DIR=$(dirname "$0")
if [ -e $CONF_DIR/deploy.conf ]
then
	echo Load configuration
        source $CONF_DIR/deploy.conf
else
        echo Configuration file:deploy.conf does not exists
        exit 1
fi

#war_name=adxray-admin.war
#tomcat_name=tomcatXrayAdmin
tomcat_dir=/usr/local/htdocs/$tomcat_name

webappdirpre=webapps-`date +'%Y-%m-%d-%H-%M-%S'`
webappdir=$webappdirpre/ROOT
deploy_dir=$tomcat_dir/$webappdir

#rs_ip=root@dchadoop4
#rs_path=/data8/jenkins/adxray-admin/adxray-web/target/adxray-admin.war

cd $tomcat_dir

echo --------------------------------文件信息，注意看下文件时间--------------------------------------
ssh $rs_ip "stat $rs_path"
echo ------------------------------------------------------------------------------------------------
echo

mkdir -p $deploy_dir

dest=$deploy_dir/$war_name
echo $dest

#copy war from resource server
scp $rs_ip:$rs_path $deploy_dir/

if [ -e $dest ]
then
	echo Copy File Success
else
	echo Not Exists $dest
	exit 1
fi

#stop server
running_size=`ps -ef | grep $tomcat_name| grep java|grep -v grep | wc -l`
if [ $running_size -eq 1 ]
then
        echo Tomcat Is Running,Try to exec shutdown.sh
        $tomcat_dir/bin/shutdown.sh
        sleep 4
        running_size=`ps -ef | grep $tomcat_name|grep java | grep -v grep | wc -l`
        if [ $running_size -eq 1 ]
        then
                echo Stop Failure,Try kill
                pid=`ps -ef | grep $tomcat_name |grep java| grep -v grep  | awk '{print $2}'`
                echo Pid=$pid
                kill -9 $pid
                sleep 3
                running_size=`ps -ef | grep $tomcat_name |grep java| grep -v grep | wc -l`
                if [ $running_size -eq 1 ]
                then
                        echo Kill Tomcat Failure,Pleaze Shutdown Tomcat By Hand
                        exit 1
                else
                        echo Kill Tomcat Success
                fi
        else
                echo Stop Tomcat  Success
        fi
else
        echo Tomcat Not Running
fi


#unzip war 
unzip -q $dest -d $deploy_dir/

#soft link
echo Make Soft Link
rm -rf webapps
ln -s $webappdirpre/ webapps
imgdir=$webappdir/WEB-INF/classes/assets
mkdir -p $imgdir
dirold=`pwd`
cd $imgdir
ln -s /data0/adxray/img/ img
cd $dirold

#Start Tomcat
echo Start Tomcat
$tomcat_dir/bin/startup.sh
echo Check Start Status,Please Wait....
sleep 8
pid=`ps -ef | grep $tomcat_name |grep java | grep -v grep  | awk '{print $2}'`
if [ $pid != '' ]
then
        echo Tomcat Started ! PID is $pid
else
	echo Tomcat maybe not started, check it!
fi
