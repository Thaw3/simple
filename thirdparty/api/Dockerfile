FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y python3 python3-pip
RUN pip3 install flask gunicorn flask-cors mysql-connector-python paho-mqtt requests Flask-SocketIO eventlet
WORKDIR /app
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
