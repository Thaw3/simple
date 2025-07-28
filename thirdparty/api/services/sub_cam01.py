import threading
import logging
import datetime
import json
import paho.mqtt.client as paho

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)
received_messages = []

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logger.info("Connected successfully.")
        client.subscribe(userdata['topic_name'], qos=0)
        logger.info(f"Subscribed to topic: {userdata['topic_name']}")
    else:
        logger.error(f"Connection failed with code {rc}")


def on_message(client, userdata, msg):
    payload = msg.payload.decode('utf-8', errors='ignore')
    timestamp = datetime.datetime.utcnow().isoformat() + "Z"
    # Remove deduplication logic so all messages are appended
    try:
        data = json.loads(payload)
        logger.info(f"MQTT Client: Received JSON message on topic '{msg.topic}': {data}")
        received_messages.append({
            "topic": msg.topic,
            "payload": data,
            "timestamp": timestamp
        })
    except Exception:
        logger.info(f"MQTT Client: Received non-JSON message on topic '{msg.topic}': {payload}")
        received_messages.append({
            "topic": msg.topic,
            "payload": payload,
            "timestamp": timestamp
        })

def mqtt_worker(config, topic_name):
    client = paho.Client(userdata={'topic_name': topic_name})
    client.username_pw_set(config.get('username', ''), config.get('password', ''))
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(config['host'], config['port'], keepalive=5)
    logger.info(f"MQTT worker started for topic {topic_name}")
    client.loop_forever()

def subscribe_cam01(data, status_dict):
    topic_name = data.get('topicName')
    logger.info(f"Starting MQTT subscription with topic: {topic_name}")
    thread = threading.Thread(target=mqtt_worker, args=(data, topic_name), daemon=True)
    thread.start()
    status_dict['status'] = 'mqtt thread started'

def start_mqtt_subscription(data):
    status_dict = {'status': 'initializing'}
    logger.info(f"Starting MQTT subscription with data: {data}")
    subscribe_cam01(data, status_dict)
    logger.info("MQTT worker thread started.")
    return status_dict['status']