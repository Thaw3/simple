# simple
<<<<<<< HEAD

A new Funny Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```bash
docker build -t flask_api:v1 .
```

```bash
docker build -t mariadb:v1 . 
```

### Testing API POST methods 
```bash
curl -X POST http://localhost:5000/receive \
  -H "Content-Type: application/json" \
  -d '{"host":"localhost","dbName":"test","port":"3306","username":"user","password":"pass","dbType":"mysql"}'
```

### Testing mariadb is running or not
```bash
docker exec -it mariadb bash
```
```bash
mariadb -u flutter -p
```

### MQTT Container Build & RUN

```bash
docker exec -it mosquitto bash
```

### Testing MQTT pub/sub

```bash
mosquitto_sub -q 2 -h localhost -t simple/topic -u flutter -P yourpassword
```

```bash
mosquitto_pub -q 2 -h localhost -t simple/topic -m "Hello MQTT" -u flutter -P yourpassword
```
```bash
app.config['MQTT_KEEPALIVE'] = 5  # Set the time interval for sending a ping to the broker
```

Paho MQTT is not Flask-aware or Flask-synchronized.
Flask-MQTT is built to bridge Flask and MQTT, but is best used in the main Flask app context, not in background threads.

If you want Flask and MQTT to "talk" to each other, use Flask-MQTT in your main app.
If you want a background MQTT worker, use Paho MQTT directly.
=======
test
>>>>>>> 60a0eb0152cfb49cb9f2e1e4465129bcc5a0a8fc
