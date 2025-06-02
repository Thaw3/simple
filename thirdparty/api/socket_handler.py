import socket

def send_data(message):
    HOST = '127.0.0.1'  # or your target IP
    PORT = 65432        # your port

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(message.encode())
        data = s.recv(1024)
    
    return data.decode()
