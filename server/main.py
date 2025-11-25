import socket
import random
import json
import threading
from player import GameRoom

HOST = '0.0.0.0'  
PORT = 5000

def start_server():
    # 소켓 생성
    serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serverSocket.bind((HOST, PORT))
    # 접속 대기
    serverSocket.listen()
    print(f"[Server] {HOST}:{PORT} ready")

    # 서버 유지용 while 반복문
    while True:
        try:
            # 접속자 클라이언트 소켓 생성
            clientSocket, addr = serverSocket.accept()

            # 스레드 생성 후 시작
            thread = threading.Thread(target=clientHandler, args=(clientSocket, addr, deck, deckLock))
            thread.start()
        
        # 종료용 예외
        except KeyboardInterrupt:
            print("end?")
            break

        # 에러 발생시 알리고 서버는 지속
        except Exception as e:
            print(f"ERROR {e}")
            continue

    # 소켓 정리
    serverSocket.close()

if __name__ == '__main__':
    start_server()