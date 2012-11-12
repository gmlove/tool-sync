#!/bin/bash
#===============================================================================
#
#          FILE:  configure.sh
# 
#         USAGE:  ./configure.sh 
# 
#   DESCRIPTION:  auto config vim
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:   (), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  05/02/2012 08:36:30 PM CST
#      REVISION:  ---
#===============================================================================


function ln_pathogen_plugins
{
        cd plugins
        local plugins=`ls | grep -v pathogen`
        local dir=~/.vim/bundle
        for p in $plugins
        do
                if [[ ! -e $dir/$p ]];then
                        ln -sv `pwd`/$p $dir/$p
                        if [[ $p == "pyflakes-vim" ]];then
                                cd .. && pyflake_init && cd plugins
                        fi
                        if [[ $p == "ropevim-0.4" ]];then
                                cd .. && ropevim_init && cd plugins
                        fi
                fi
        done
        cd ..
}


pyflake_init ()
{
        cd plugins/pyflakes-vim
        sudo apt-get install pyflakes
        git submodule init
        git submodule update
        cd ../../
}	# ----------  end of function pyflake_init  ----------


function ropevim_init ()
{
        if pip help 1>/dev/null 2>&1; then
            :
        else
            curl http://python-distribute.org/distribute_setup.py | sudo python
            curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py |sudo python
        fi

        local ws1=`pwd`
        cd $ws/packages/ropevim-0.4/
        sudo python setup.py install
        cd $ws1
}

function download_plugin
{
        cd plugins
        local git_plugins=( delimitMate syntastic vcscommand pyflakes-vim supertab pysource.vim cocoa.vim xmledit )
        local git_repos=( https://github.com/Raimondi/delimitMate.git https://github.com/scrooloose/syntastic.git git://repo.or.cz/vcscommand.git git://github.com/kevinw/pyflakes-vim.git https://github.com/ervandew/supertab.git https://github.com/cwood/pysource.vim.git git://github.com/msanders/cocoa.vim.git https://github.com/sukima/xmledit.git )
        local i=0
        while [[ $i -lt ${#git_plugins[@]} ]]
        do
                local p=${git_repos[$i]}
                if [[ `ls ${git_plugins[$i]} 2>/dev/null | wc -l` == "0" ]]; then
                        #echo "ls ${git_plugins[$i]} 2>/dev/null | wc -l"
                        #ls ${git_plugins[$i]} 2>/dev/null | wc -l
                        echo "git clone $p"
                        git clone $p
                fi   
                i=$(( $i + 1 ))
        done
        cd ..
}


function remove_mac_unspport()
{
        if [[ $PLATFORM == "mac" ]];then
                rm -v ~/.vim/bundle/pysource.vim
                rm -v ~/.vim/bundle/ropevim-0.4
        fi
}

function set_sys_platform()
{
        local plat=$(python -c 'import sys;print sys.platform')
        if [[ $plat == "darwin" ]];then
                PLATFORM="mac"
        elif echo $plat | grep linux 1>/dev/null 2>&1;then
                PLATFORM="linux"
        fi
}


function config
{
        set_sys_platform

        if apt-get -v 2>/dev/null 1>&2; then
                sudo apt-get install vim exuberant-ctags git python doxygen
        elif port help 2>/dev/null 1>&2; then
                sudo port install MacVim ctags python doxygen
        else
                echo "can not find a package manager." && exit 1
        fi


        #sudo apt-get install vim vim-addon-manager vim-doc vim-common vim-scripts exuberant-ctags doxygen
        #vim-addons install bufexplorer matchit doxygen-toolkit  matchit project python-indent supertab taglist vimplate winmanager xmledit
        find ~/.vimrc && mv -fv ~/.vimrc ~/.vimrc.old
        ln -sv `pwd`/.vimrc ~/.vimrc
        mkdir -p ~/.vim/autoload ~/.vim/bundle
        if [[ ! -f plugins/vim-pathogen/autoload/pathogen.vim ]];then
                cd plugins
                git clone https://github.com/tpope/vim-pathogen.git
                cd ..
        fi
        local pathogenln=~/.vim/autoload/pathogen.vim
        if [[ -e $pathogenln ]];then
                rm $pathogenln
        fi
        ln -sv `pwd`/plugins/vim-pathogen/autoload/pathogen.vim $pathogenln 

        download_plugin
        ln_pathogen_plugins
        remove_mac_unspport
}


oldpwd=`pwd`
ws=`dirname $0`
cd $ws
ws=`pwd`

config

cd $oldpwd
exit 0


