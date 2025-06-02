# simple

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
```bash
docker network create simple-net
```
```bash
export APIPWD="/Users/kyawswartun/Dev/proj/simple/thirdparty/api"
```

```bash
docker run -d --name flask_api \
  -p 5000:5000 \
  --network simple-net \
  -v "$APIPWD":/app \
  flask_api:v1
```

```bash
export SQLPWD="/Users/kyawswartun/Dev/proj/simple/thirdparty/sql"
```

### Daemon Mode for mariadb

```bash
docker run -d \
  --name mariadb \
  --network simple-net \
  -e MYSQL_ROOT_PASSWORD=root_password \
  -e MYSQL_DATABASE=simple_db \
  -e MYSQL_USER=flutter \
  -e MYSQL_PASSWORD=password \
  -v "$SQLPWD/simple_db.sql":/docker-entrypoint-initdb.d/simple_db.sql \
  -p 3306:3306 \
  mariadb:v1
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
### BEFORE MQTT
```bash
export MQPWD="/Users/kyawswartun/Dev/proj/simple/thirdparty/mosquitto"
```
### Create Password file for broker connectivity
```bash
docker run \ 
--rm -it -v "$MQPWD/config:/mosquitto/config" eclipse-mosquitto \ 
mosquitto_passwd -c "$MQPWD/config/password_file" flutter
```
### MQTT Container Build & RUN
```bash
# docker build -t eclipse-mosquitto:v0.1 .
```

```bash
docker run -d \
  --name mosquitto \
  --network simple-net \
  -p 1883:1883 \
  -p 9001:9001 \
  -v "$MQPWD/config:/mosquitto/config" \
  -v "$MQPWD/data:/mosquitto/data" \
  -v "$MQPWD/log:/mosquitto/log" \
  eclipse-mosquitto
```