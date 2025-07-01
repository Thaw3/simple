# Change mqtt user password 
# add user to acl_file

MQPWD="/Users/kyawswartun/Dev/proj/simple/thirdparty/mosquitto"
USERNAME="flutter"
PASSWORD="password"

docker stop mosquitto
docker rm mosquitto

docker run --rm -it -v "$MQPWD/config:/mosquitto/config" eclipse-mosquitto \
  mosquitto_passwd -b -c /mosquitto/config/password_file $USERNAME $PASSWORD

docker run --rm -it -v "$MQPWD/config:/mosquitto/config" eclipse-mosquitto \
  chown root:root /mosquitto/config/password_file