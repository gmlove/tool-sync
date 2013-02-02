#!/bin/bash
#===============================================================================
#
#          FILE:  deploy.sh
# 
#         USAGE:  ./deploy.sh 
# 
#   DESCRIPTION:  release and deploy the project
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  gmliao, 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  04/25/2012 02:51:53 PM CST
#      REVISION:  ---
#===============================================================================

#add debug information to output
function enable_debug
{
        export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '
        set -x
}

#save the current pwd, and will recover late.
oldpwd=`pwd`
this_file=$0
if [[ -h $0 ]];then
    this_file=`ls -l $0|awk -F"->" '{print $2}'`
fi
ws=`dirname $this_file`
cd $ws
ws=`pwd`


src_dir=".."
proj_name=
function get_proj_name
{
        cd $src_dir
        proj_name=$(basename `pwd`)        
        echo "get_pro_name: $proj_name"
        cd $ws
}
get_proj_name
root="deploy"
dates=`date '+%Y-%m-%d_%H%M%S'`
deproot="$root/${proj_name}.$dates"
mode="online"
install_deps="0"

#when create a new project you may modify these value.
#these value should not depend on the variables set above.
uhost="ubuntu@ec2-analyser1"
pemfile=$dep/beluga.pem
auth="-i $pemfile"
tarexclu="TempStatsStore cscope.*"
installfile="scripts/install.sh"
install_deps_file="scripts/install_deps.sh"


#configure the target system.
#this is absolutely need to change due to dirrent project.
function sys_conf 
{
    local conf_dir="$deproot/config"
        pemcheck
	ssh $auth $uhost "mkdir -pv $conf_dir"
        scp $auth ./config/* $uhost:$conf_dir
	scp $auth install_cloudera.sh $uhost:$deproot
}


#copy online configuration file
function proj_conf
{
        if [[ $mode == "local" ]];then
                echo "will do local deploy."
                return 0
        else
                echo "will do $mode deploy."
        fi
        echo "find $src_dir -name *.$mode | sed 's/\(.*\)\(.$mode\)/\1 \1.local/' | xargs -n 2 cp -fv"
        find $src_dir -name *.$mode | sed "s/\(.*\)\(.$mode\)/\1 \1.local/" | xargs -n 2 cp -fv
        echo "find $src_dir -name *.$mode | sed 's/\(.*\)\(.$mode\)/& \1/' | xargs -n 2 cp -fv"
        find $src_dir -name *.$mode | sed "s/\(.*\)\(.$mode\)/& \1/" | xargs -n 2 cp -fv
}
function prof_deconf
{
        if [[ $mode != "local" ]];then
                find $src_dir -name *.$mode | sed "s/\(.*\)\(.$mode\)/\1.local \1/" | xargs -n 2 cp -fv
        fi
}


tarfile=${proj_name}.tar.gz
#tar the source file.
function tar_
{
        proj_conf
	cd ${src_dir}/../
        local ex=""
        for e in $tarexclu; do
                ex="${ex} --exclude=$proj_name/$e"
        done
        echo "tar cvf $ws/$tarfile --exclude=${proj_name}/test --exclude=$proj_name/release $ex --exclude-backups $proj_name/"
        tar cvf $ws/$tarfile --exclude ${proj_name}/test --exclude $proj_name/release $ex --exclude-backups $proj_name/
        cd $ws
        prof_deconf
}


function pemcheck
{
        if [[ ${auth:$((${#auth}-${#pemfile})):${#auth}} != $pemfile ]];then echo "no check"; return;
        fi
        if [[ ! -f $pemfile ]];then
                echo "pemfile: $pemfile not exist."
                exit 0
        fi
        chmod 400 $pemfile
}

function scp_
{
    pemcheck
	ssh $auth $uhost "mkdir -pv $deproot"
	scp $auth $tarfile $uhost:$deproot
}


function scp_sync
{
    pemcheck
	scp $auth $uhost:$deproot/config/* ./config/
}


function dep_
{
    tar_
    scp_
    if [[ $install_deps == "1" ]];then
        ssh -t $auth $uhost "cd $deproot && tar xvf $tarfile && cd $proj_name && ./$install_deps_file && ./$installfile"
    else
        ssh -t $auth $uhost "cd $deproot && tar xvf $tarfile && cd $proj_name && ./$installfile"
    fi
    echo "done."
}



#backup project deploy example.
function dep_backup
{
    pemcheck
	cd $src_dir
	tar cvf $ws/backup.tar.gz Backup/
	cd $ws
	ssh $auth $uhost "mkdir -p deploy/Backup"
	scp $auth backup.tar.gz $uhost:deploy/
}

function usage
{
	echo "usage: ./deploy.sh task user@host [auth:'-i key'] [mode: local|online] [deps]"
    echo "options:"
    echo "   task:"
    echo "      tar|scp|scpsync|dep. task to execute. dep means deploy."
    echo "   user@host:"
    echo "      this is just as it says."
    echo "   auth:"
    echo "      just use '-i key'."
    echo "   mode:"
    echo "      local|online. deploy mode, default: online. the script will use *.local or *.online as the final configuration file."
    echo ""
    echo "   eg: ./deploy.sh tar ubuntu@ec2-analyser1 '-i /auth.pem'"
    echo "   eg: ./deploy.sh dep ubuntu@ec2-analyser1 '-i /auth.pem'"
    echo "   eg: ./deploy.sh dep namenode ' '"
    echo "   eg: ./deploy.sh tar'"
}


if [[ -n $2 ]]; then
	uhost=$2
fi

if [[ -n $3 ]]; then
        auth=$3
fi

if [[ -n $4 ]];then
        mode=$4
fi

if [[ -n $5 ]];then
    install_deps="1"
fi

echo "uhost: "$uhost
echo "auth: ###$auth###"


if [[ -z $1 ]]; then usage
elif [[ $1 == "tar" ]]; then tar_;
elif [[ $1 == "scp" ]]; then scp_;
elif [[ $1 == "scpsync" ]]; then scp_sync;
elif [[ $1 == "depbak" ]]; then dep_backup;
elif [[ $1 == "dep" ]]; then dep_;
else usage
fi





cd $oldpwd
exit 0


