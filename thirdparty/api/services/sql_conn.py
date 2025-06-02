import mysql.connector
from mysql.connector import Error

def test_database_connection(data):
    host = data.get('host')
    db_name = data.get('dbName')
    port = data.get('port')
    username = data.get('username')
    password = data.get('password')
    db_type = data.get('dbType')

    if not all([host, db_name, port, username, password, db_type]):
        return {'status': 'failure', 'message': 'Missing connection parameters.'}, 400

    if db_type.lower() not in ['mysql', 'mariadb']:
        return {'status': 'failure', 'message': 'Unsupported database type.'}, 400

    try:
        connection = mysql.connector.connect(
            host=host,
            database=db_name,
            user=username,
            password=password,
            port=port
        )
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT 1;")
            cursor.fetchone()
            connection.close()
            return {'status': 'success', 'message': 'Database connection established.'}, 200
        else:
            return {'status': 'failure', 'message': 'Could not connect to the database.'}, 400
    except Error as e:
        return {'status': 'failure', 'message': f'Connection error: {str(e)}'}, 400
