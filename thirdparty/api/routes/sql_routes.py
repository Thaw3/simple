from flask import Blueprint, request, jsonify
from services.sql_conn import test_database_connection

sql_bp = Blueprint('sql', __name__, url_prefix='/api')

@sql_bp.route('/databaseconnrequest', methods=['POST'])
def database_conn_request():
    data = request.get_json()

    if not data:
        return jsonify({'error': 'No JSON received'}), 400

    response, status = test_database_connection(data)
    return jsonify(response), status
