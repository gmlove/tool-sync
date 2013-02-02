
PROJ_PATH=/dev/null
PROJ_NAME=

init-pydjango:
	test -d ${PROJ_PATH} && cp -rv pydjango.proj/* ${PROJ_PATH} && sed -i'' 's/{PROJECT_NAME}/${PROJ_NAME}/g' ${PROJ_PATH}/scripts/*

