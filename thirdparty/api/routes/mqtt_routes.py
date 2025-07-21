from flask import Blueprint, request, jsonify
from services.sub_cam01 import start_mqtt_subscription, received_messages

cam01_bp = Blueprint('sub_cam01', __name__, url_prefix='/api')
mqtt_status = {'initialized': False}
mqtt_config = {}

@cam01_bp.route('/subcam01_request', methods=['POST'])
def sub_cam01():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No JSON received'}), 400


    status = start_mqtt_subscription(data)
    return jsonify({'status': status}), 200

@cam01_bp.route("/messages")
def get_messages():
    return jsonify(received_messages), 200