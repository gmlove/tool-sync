import MySQLdb

_connections = {}
conn = None

def configdb(host, user, password, db, port = 3306):
        global conn
        conn = _get_connection(host, user, password, db, port)

def _get_connection(host, user, password, db, port):
        key = host + "@" + db
        conn = None
        if key in _connections:
                conn = _connections[key]
        else:
                conn = MySQLdb.connect(host, user, password, db, port = port)
                conn.set_character_set('utf8')
                _connections[key] = conn
        return conn

