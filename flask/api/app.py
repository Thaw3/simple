from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
CORS(app)
# Enable CORS for all routes
# This allows cross-origin requests, which is useful for APIs consumed by web applications
# and other services.
# You can restrict CORS to specific origins by passing the `origins` parameter to CORS(app, origins=['http://example.com'])
# or by using the `@cross_origin` decorator on specific routes.
@app.route('/')
def hello_rom():
    return "ROM Dynamics API ROOT URL's working!"

@app.route('/databaseconnrequest', methods=['POST'])
def database_conn_request():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No JSON received'}), 400

    # Extract connection parameters
    host = data.get('host')
    db_name = data.get('dbName')
    port = data.get('port')
    username = data.get('username')
    password = data.get('password')
    db_type = data.get('dbType')

    if not all([host, db_name, port, username, password, db_type]):
        return jsonify({'status': 'failure', 'message': 'Missing connection parameters.'}), 400

    if db_type.lower() not in ['mysql', 'mariadb']:
        return jsonify({'status': 'failure', 'message': 'Unsupported database type.'}), 400

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
            return jsonify({'status': 'success', 'message': 'Database connection established.'}), 200
        else:
            return jsonify({'status': 'failure', 'message': 'Could not connect to the database.'}), 400
    except Error as e:
        return jsonify({'status': 'failure', 'message': f'Connection error: {str(e)}'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0')
