import socket

HOST = '0.0.0.0'  
PORT = 5000
BUFFSIZE = 1024

def start_server():
    serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serverSocket.bind((HOST, PORT))

    # 접속 대기
    serverSocket.listen()
    print(f"[Server] {HOST}:{PORT} ready")

    try:
        # 접속 수락
        clientSocket, addr = serverSocket.accept()
        print(f"client accept {addr}")

        # 데이터 수신
        data = clientSocket.recv(BUFFSIZE)
        print(f"RECV MSG {data.decode()}")

        # 7. 데이터 송신
        msg = "ACK"
        clientSocket.send(msg.encode())
        print(f"SEND {msg}")

    except Exception as e:
        print(f"ERROR {e}")
    finally:
        # 소켓 정리
        clientSocket.close()
        serverSocket.close()

if __name__ == '__main__':
    start_server()