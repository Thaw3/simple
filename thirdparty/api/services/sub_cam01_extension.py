import threading
import datetime
import logging
import json
from flask import Flask
from flask_mqtt import Mqtt

# Logging setup (as before)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)


def mqtt_worker(config, topic_name):
    import time  # Needed for loop_start() fallback if desired

    mqtt_app = Flask(__name__)
    mqtt_app.config['MQTT_BROKER_URL'] = config['host']
    mqtt_app.config['MQTT_BROKER_PORT'] = config['port']
    mqtt_app.config['MQTT_USERNAME'] = config.get('username', '')
    mqtt_app.config['MQTT_PASSWORD'] = config.get('password', '')
    mqtt_app.config['MQTT_KEEPALIVE'] = 5
    mqtt_app.config['MQTT_TLS_ENABLED'] = False

    logger.info(f"MQTT worker received topic_name: {topic_name!r}")

    mqtt = Mqtt()
    
    with mqtt_app.app_context():
        mqtt.init_app(mqtt_app)

        @mqtt.on_connect()
        def handle_connect(client, userdata, flags, rc):
            if rc == 0:
                logger.info("Connected successfully.")
                client.subscribe(topic_name)
                logger.info(f"Subscribed to topic: {topic_name}")
            else:
                logger.error(f"Connection failed with code {rc}")

        @mqtt.on_message()
        def handle_message(client, userdata, msg):
            payload = msg.payload.decode('utf-8', errors='ignore')
            try:
                data = json.loads(payload)
                logger.info(f"MQTT Client: Received JSON message on topic '{msg.topic}': {data}")
            except Exception:
                logger.info(f"MQTT Client: Received non-JSON message on topic '{msg.topic}': {payload}")

        logger.info(f"MQTT worker app context started for topic {topic_name}")
        mqtt.client.loop_forever()


def subscribe_cam01(data, status_dict):
    topic_name = data.get('topicName')
    logger.info(f"Starting MQTT subscription with topic: {topic_name}")
    thread = threading.Thread(target=mqtt_worker, args=(data, topic_name), daemon=True)
    thread.start()
    status_dict['status'] = 'mqtt thread started'

def start_mqtt_subscription(data):
    status_dict = {'status': 'initializing'}
    ## logger received data
    logger.info(f"Starting MQTT subscription with data: {data}")
    subscribe_cam01(data, status_dict)
    logger.info("MQTT worker thread started.")
    return status_dict['status']