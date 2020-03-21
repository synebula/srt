#!/bin/bash
JAR=${*#./}

if [ -n "$JAR" ];then
	echo "deploy jar $JAR"
	PID=$(ps aux|grep "$JAR"|grep -vE '(ssh|bash|grep)'|awk '{print $2}')
	if [ -n "$PID" ];then
		echo "kill $JAR old jar $PID"	
		kill -9 $PID
	fi

	nohup java -jar $JAR > /dev/null & 
else
	echo "please input jar name"
fi
