install-deps:
	./scripts/install_deps.sh

install:
	./scripts/install.sh

start:
	./scripts/uwsgid.sh start

status:
	./scripts/uwsgid.sh status

stop:
	./scripts/uwsgid.sh stop

restart:
	./scripts/uwsgid.sh restart


PROJ_NAME={PROJECT_NAME}
#if need to force update nginx config
NGINX_FORCE_UPDATE="1"

init:
	-test -d /var/log/${PROJ_NAME}/ || sudo mkdir -p /var/log/${PROJ_NAME}/ && sudo chmod a+w /var/log/${PROJ_NAME}/
	-test -f /var/run/${PROJ_NAME}-uwsgi.pid || sudo touch /var/run/${PROJ_NAME}-uwsgi.pid && sudo chmod a+w /var/run/${PROJ_NAME}-uwsgi.pid
	bash -c 'if [[ ${NGINX_FORCE_UPDATE} != "1" && -f /etc/nginx/sites-available/${PROJ_NAME} ]];then echo "nginx ${PROJ_NAME} already exists" && exit 1;fi'
	vi -O scripts/nginx.conf scripts/uwsgi.xml
	sudo cp -fv scripts/nginx.conf /etc/nginx/sites-available/${PROJ_NAME} && sudo ln -sfv /etc/nginx/sites-available/${PROJ_NAME} /etc/nginx/sites-enabled/${PROJ_NAME}
	sudo service nginx restart
