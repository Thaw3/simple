from flask import Blueprint, request, jsonify
from services.sub_cam01 import start_mqtt_subscription

cam01_bp = Blueprint('sub_cam01', __name__, url_prefix='/api')

@cam01_bp.route('/subcam01_request', methods=['POST'])
def sub_cam01():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No JSON received'}), 400

    start_mqtt_subscription(data)
    return jsonify({'status': 'MQTT subscription started'}), 200
