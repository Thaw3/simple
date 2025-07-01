# This is mqtt client for subscribing to a topic
# Import necessary libraries
import paho.mqtt.client as mqtt
import os
import threading

# Callback when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected successfully.")
        client.subscribe(userdata['topic_name'])
    else:
        print(f"Connection failed with code {rc}")

# Callback when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    log_file = userdata['log_file']
    with open(log_file, 'a') as f:
        f.write(f"{msg.topic}: {msg.payload.decode()}\n")
    print(f"Received message on {msg.topic}: {msg.payload.decode()}")

def subscribe_cam01(data):
    host = data.get('host')
    topic_name = data.get('topic_name')
    port = data.get('port', 1883)
    username = data.get('username')
    password = data.get('password')
    log_file = data.get('log_file', 'mqtt_cam01.log')

    userdata = {'topic_name': topic_name, 'log_file': log_file}
    client = mqtt.Client(userdata=userdata)
    if username and password:
        client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect(host, port, 60)
    print(f"Subscribing to topic '{topic_name}' on {host}:{port}...")
    try:
        client.loop_forever()
    except KeyboardInterrupt:
        print("Disconnected from broker.")
        client.disconnect()

def start_mqtt_subscription(data):
    thread = threading.Thread(target=subscribe_cam01, args=(data,))
    thread.daemon = True
    thread.start()
    return thread

