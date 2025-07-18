# This is mqtt client for subscribing to a topic
# Import necessary libraries
import paho.mqtt.client as mqtt
import datetime
import os
import threading
import logging

# --- Logging Configuration ---
# Set up a logger for the application
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO) # Set the minimum level to log for the app

# Create handlers
# StreamHandler for console output (important for Docker logs)
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO) # Output INFO level and higher to console

# Formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
stream_handler.setFormatter(formatter)

# Add handlers to the logger
logger.addHandler(stream_handler)

logger.info("Application starting up and logging configured.")




# Callback when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logger.info("Connected successfully.")
        client.subscribe(userdata['topic_name'])
    else:
        logger.error(f"Connection failed with code {rc}")


received_messages = [] # This global list stores the messages


def on_message(client, userdata, msg):
 
    payload = msg.payload.decode('utf-8', errors='ignore')

    timestamp = datetime.datetime.utcnow().isoformat() + "Z"
    message_data = {
        'topic': msg.topic,       # The MQTT topic the message was published to
        'payload': payload,       # The decoded message content
        'timestamp': timestamp    # The time the message was received by this client
    }
    received_messages.append(message_data)
    logger.info(f"MQTT Client: Received message on topic '{msg.topic}'. Payload preview: {payload[:100]}{'...' if len(payload) > 100 else ''}")

def get_received_messages():
    logger.info("API: Fetching received messages.")
    return received_messages

def subscribe_cam01(data, status_dict):
    host = data.get('host')
    topic_name = data.get('topic_name')
    port = data.get('port')
    username = data.get('username')
    password = data.get('password')

    userdata = {'topic_name': topic_name}
    client = mqtt.Client(userdata=userdata)
    if username and password:
        client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.on_message = on_message

    try:
        client.connect(host, port, 60)
        print(f"Subscribing to topic '{topic_name}' on {host}:{port}...")
        status_dict['status'] = 'connected'
        client.loop_forever()
    except Exception as e:
        print(f"Connection error: {e}")
        status_dict['status'] = f'error: {e}'
    except KeyboardInterrupt:
        print("Disconnected from broker.")
        client.disconnect()
        status_dict['status'] = 'disconnected'


def start_mqtt_subscription(data):
    status_dict = {'status': 'initializing'}
    thread = threading.Thread(target=subscribe_cam01, args=(data, status_dict))
    thread.daemon = True
    thread.start()
    logger.info("MQTT subscription thread started.")
    return status_dict['status']