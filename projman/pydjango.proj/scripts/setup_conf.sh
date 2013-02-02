#!/bin/bash

PROJ_NAME={PROJECT_NAME}

LOGROOT=/var/log/$PROJ_NAME
INSTALL_DIR=/var/app/enabled
INSTALL_PROJ_DIR="${INSTALL_DIR}/$PROJ_NAME"
echo -----make source code folder-------
if [ ! -d $INSTALL_PROJ_DIR ]
then
	sudo mkdir -p $INSTALL_PROJ_DIR
fi

echo -----Copy source code to site folder-------

sudo mv -v ${INSTALL_PROJ_DIR} ${INSTALL_PROJ_DIR}_bak
sudo cp -rf ../../ ${INSTALL_PROJ_DIR}

echo -----ensure log path-------
if [ ! -d $LOGROOT ]
then
	sudo mkdir -p $LOGROOT
	sudo touch $LOGROOT/info.log
	sudo touch $LOGROOT/error.log
	sudo chmod -R go+w $LOGROOT
fi
