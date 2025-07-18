# This is mqtt client for subscribing to a topic
# Import necessary libraries
import paho.mqtt.client as mqtt
import os
import threading
import socketio

# Callback when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    sio = userdata.get('socketio')
    topic = userdata.get('topic_name')
    if rc == 0:
        print("Connected successfully.")
        if sio:
            sio.emit('mqtt_status', {'status': 'broker_connected', 'topic': topic})
        client.subscribe(topic)
    else:
        print(f"Connection failed with code {rc}")
        if sio:
            sio.emit('mqtt_status', {'status': f'broker_connection_failed', 'code': rc})

# Callback when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    # Emit to Socket.IO
    sio = userdata.get('socketio')
    message = {
        'topic': msg.topic,
        'payload': msg.payload.decode(),
        'timestamp': datetime.utcnow().isoformat()
    }
    if sio:
        sio.emit('mqtt_message', message)
    # Save to MongoDB
    mongo_collection = userdata.get('mongo_collection')
    if mongo_collection:
        mongo_collection.insert_one(message)
    print(f"Received and forwarded: {message}")
    
def subscribe_cam01(data, status_dict):
    host = data.get('host')
    topic_name = data.get('topic_name')
    port = data.get('port')
    username = data.get('username')
    password = data.get('password')
    log_file = data.get('log_file', 'mqtt_cam01.log')
    sio = socketio.Client()
    sio.connect('http://127.0.0.1:5001')  # Changed to port 5001 for socket.io server

    userdata = {'topic_name': topic_name, 'log_file': log_file, 'socketio': sio}
    client = mqtt.Client(userdata=userdata)
    if username and password:
        client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.on_message = on_message

    try:
        client.connect(host, port, 60)
        print(f"Subscribing to topic '{topic_name}' on {host}:{port}...")
        status_dict['status'] = 'connected'
        sio.emit('mqtt_status', {'status': 'api_connected', 'topic': topic_name})
        client.loop_forever()
    except Exception as e:
        print(f"Connection error: {e}")
        status_dict['status'] = f'error: {e}'
        sio.emit('mqtt_status', {'status': 'api_connection_error', 'error': str(e)})
    except KeyboardInterrupt:
        print("Disconnected from broker.")
        client.disconnect()
        status_dict['status'] = 'disconnected'
        sio.emit('mqtt_status', {'status': 'api_disconnected'})


def start_mqtt_subscription(data):
    status_dict = {'status': 'initializing'}
    thread = threading.Thread(target=subscribe_cam01, args=(data, status_dict))
    thread.daemon = True
    thread.start()
    return status_dict['status']