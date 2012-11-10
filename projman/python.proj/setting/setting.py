import logging
import logging.config
import os
from ConfigParser import ConfigParser

DEBUG = True
log_conf_path = os.path.dirname(os.path.abspath(__file__))
logging.config.fileConfig(log_conf_path + '/logging.cfg')

logger = logging.getLogger('root') if DEBUG else logging.getLogger('Test')

conf = ConfigParser()
conf.read(log_conf_path + "/project.cfg")



if __name__ == "__main__":
        print conf.get("DEFAULT", "test")
        print conf.defaults()
        print conf.sections()


