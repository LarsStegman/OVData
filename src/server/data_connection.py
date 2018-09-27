import psycopg2
from psycopg2.extras import RealDictCursor


class Database:
    """
    Provides methods to interact with the database where the public transit data
    is stored.
    """

    def __init__(self):
        try:
            self.connection = self.connect()
        except:
            self.connection = None
        self.dict_cursor = None

    def connect(self):
        """
        Initiates a connection with the database.
        """
        try:
            connect = psycopg2.connect("""
                dbname=ovdata_db 
                user=larsstegman 
                host=localhost 
                password=password
            """)
            return connect
        except Exception as e:
            return ConnectionError()

    def init_dict_cursor(self):
        self.dict_cursor = self.connection.cursor(
            cursor_factory=RealDictCursor)
        Database.set_search_path(self.dict_cursor)

    def dict_query(self, query, variable_values):
        if self.dict_cursor is None:
            self.init_dict_cursor()

        self.dict_cursor.execute(query, variable_values)
        return self.dict_cursor.fetchall()

    def query(self, query, variable_values={}):
        if self.cursor is None:
            self.init_cursor()

        self.cursor.execute(query, variable_values)
        return self.cursor.fetchall()

    def init_cursor(self):
        self.cursor = self.connection.cursor()
        Database.set_search_path(self.cursor)
        return self.cursor

    def set_search_path(cursor):
        cursor.execute("SET search_path TO ovdata,public")