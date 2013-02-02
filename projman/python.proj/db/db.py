import MySQLdb
from setting.setting import conf, logger
from util.ThreadLocal import ThreadLocal

log = logger
connections = None

def _create_connection(host, user, password, db, port = 3306):
    conn = MySQLdb.connect(host, user, password, db, port)
    conn.set_character_set('utf8')
    return conn

def get_connection():
    def create_connection():
        return _create_connection(
                              conf.get('mysql', 'host'), 
                              conf.get('mysql', 'username'), 
                              conf.get('mysql', 'password'),
                              conf.get('mysql', 'db'),
                              int(conf.get('mysql', 'port'))
                              )
    global connections
    if not connections:
        connections = ThreadLocal(create_connection)
    return connections.get()


def transaction(func):
    def wrapped_func(*args, **kwargs):
        conn = get_connection()
        try:
            r = func(*args, **kwargs)
            conn.commit()
            return r
        except Exception as e: 
            conn.rollback()
            raise e
        
    return wrapped_func
    



class Test(object):
    def __init__(self):
        pass
    
    
    def new(self, detail, pic):

        return self
        
    @staticmethod
    @transaction
    def test():
        conn = get_connection()
        sql = "select %s"
        c = conn.cursor();
        r = c.execute(sql,(1,))
        print r
        
        
    
    

