#!/bin/bash

help_msg='Parameters: \r\n'\
'\t start: start uwsgi. \r\n'\
'\t stop: stop uwsgi. \r\n'\
'\t restart: restart uwsgi. \r\n'\
'\t help: help information.'



oldpwd=`pwd`
this_file=$0
if [[ -h $0 ]];then
    this_file=`ls -l $0|awk -F"->" '{print $2}'`
fi
ws=`dirname $this_file`
cd $ws
ws=`pwd`



PROJ_NAME={PROJECT_NAME}
CONFIG_PATH=$ws/uwsgi.xml
PID_PATH=/var/run/$PROJ_NAME-uwsgi.pid

test -f $CONFIG_PATH || { echo -e "ERROE: file \`$CONFIG_PATH\` not exist."; exit 1; }
if [[ -f $PID_PATH ]];then
        pid=`tail $PID_PATH`
else
        pid="none"
fi

test $pid == "" && pid="none"


if [ $1 = 'help' ];then
    echo -e $help_msg
elif [ $1 = 'start' ];then
        if [[ `ps ax | awk '{print $1}' | grep $pid` ]]
        then
            echo "uwsgi is running"
        else
            echo "starting uwsgi"
            uwsgi -x $CONFIG_PATH
        fi
elif [ $1 = 'stop' ];then
    uwsgi --stop $PID_PATH
elif [ $1 = 'restart' ];then
    if [[ `ps ax | awk '{print $1}' | grep $pid` ]]
        then
            echo "stopping uwsgi"
            uwsgi --stop $PID_PATH
    fi
    sleep 1.5
    echo "starting uwsgi"
    uwsgi -x $CONFIG_PATH
elif [ $1 = 'status' ];then
    if [[ `ps ax | awk '{print $1}' | grep "$pid"` ]];then
            echo "uwsgi is running"
    else
            echo "uwsgi is not running"
    fi
else
    echo -e $help_msg
fi

cd $oldpwd
exit 0


