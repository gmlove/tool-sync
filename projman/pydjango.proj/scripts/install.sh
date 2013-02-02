#!/bin/bash
#
# This scripts is used to install the application.
# This scripts is required for all projects.
#
#
# Author : kunli
#



SCRIPT_DIR=`dirname $0`

if [ "$1" = "checkdeps" ] ; then

    if [ -f "${SCRIPT_DIR}/install_deps.sh" ]; then
        ${SCRIPT_DIR}/install_deps.sh
    fi
    
    shift 
fi 

if [ -f "${SCRIPT_DIR}/setup_conf.sh" ]; then
    ${SCRIPT_DIR}/setup_conf.sh
fi

