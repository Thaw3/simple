
#!/bin/bash


docker ps -a
docker rm -f mariadb
docker rm -f mosquitto
docker rm -f flask_api

# Create simple-net network can be call by host
docker network rm simple-net 
