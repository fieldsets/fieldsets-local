from flask import g, current_app
import psycopg2
import pandas as pd

def get_connection():
    if ('db' not in g):
        pl_host = current_app.config.get('PL_DB_HOST')
        pl_db = current_app.config.get('PL_DB_DATABASE')
        pl_user = current_app.config.get('PL_DB_USER')
        pl_password = current_app.config.get('PL_DB_PW')
        g.db = psycopg2.connect(host=pl_host, port=5432, dbname=pl_db, user=pl_user, password=pl_password)
    
    return g.db

# Fetch a raw Pandas DataFrame object from the DB for a given SQL query.
def fetch_dataframe(query, query_var=None):
    db_connection = get_connection()

    # Manage cursor conext and ensure cursor closes after leaving context but allow connection to remain open.
    with db_connection.cursor() as cursor:
    
        cursor_list = list()
        if (query_var):
            if (type(query_var) is list):
                cursor_list.extend(query_var)
            else:
                cursor_list.append(query_var)

        try:
            cursor.execute(query, cursor_list)
        except Exception:
            raise
        else:
            rows = cursor.fetchall()

        colnames = [desc[0] for desc in cursor.description]
        result = pd.DataFrame(rows, columns=colnames)
        cursor.close()
        return result

