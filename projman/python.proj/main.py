
import datetime
from db.db import configdb 
from setting import setting

log = setting.logger
conf = setting.conf
debug = conf.get("DEFAULT","debug")


if __name__ == "__main__":
        #configdb(conf.get("mysql", "host"), conf.get("mysql", "username"), \
        #        conf.get("mysql", "password"), conf.get("mysql", "db-schema"), \
        #        conf.get("mysql","port"))
        log.info(datetime.datetime.now())
        if debug:
                print debug
        else:
                print "no debug"
        
      


