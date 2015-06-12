#!/bin/bash



oldpwd=`pwd`
this_file=$0
if [[ -h $0 ]];then
    this_file=`ls -l $0|awk -F"->" '{print $2}'`
fi
ws=`dirname $this_file`
cd $ws
ws=`pwd`



echo "------------------restart server----------------"
echo "current dir: `pwd`"
if [[ -f uwsgid.sh ]];then
    sudo ./uwsgid.sh restart
else
    echo "file uwsgid.sh not found."
    exit 1
fi

cd $oldpwd
exit 0



