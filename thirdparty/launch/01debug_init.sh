#!/bin/bash

APIPWD="/home/myatsu/Proje/simple/thirdparty/api"
SQLPWD="/home/myatsu/Proje/simple/thirdparty/sql"
MQPWD="/home/myatsu/Proje/simple/thirdparty/mosquitto"
docker ps -a
docker rm -f mariadb
docker rm -f mosquitto
docker rm -f flask_api

# Create simple-net network can be call by host
docker network rm simple-net 
docker network create simple-net --driver bridge --subnet 172.18.0.0/16

# Flask API run
docker run -d --name flask_api \
  -p 5000:5000 \
  --network simple-net \
  -v "$APIPWD":/app \
  flask_api:v1

# MariaDB run
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

# Mosquitto MQTT broker run
docker run -d \
  --name mosquitto \
  --network simple-net \
  -p 1883:1883 \
  -p 9001:9001 \
  -v "$MQPWD/config:/mosquitto/config" \
  -v "$MQPWD/data:/mosquitto/data" \
  -v "$MQPWD/log:/mosquitto/log" \
  eclipse-mosquitto

# Wait for services to start
sleep 3
# Check if Flask API is running
if curl -s http://localhost:5000/ | grep -q "ROM"; then
  echo "Flask API is running."
else
  echo "Flask API failed to start."
  exit 1
fi
echo "#########################################################################################################"
docker logs flask_api
echo "#########################################################################################################"
docker logs mariadb
echo "#########################################################################################################"
docker logs mosquitto
echo "#########################################################################################################"
docker ps -a