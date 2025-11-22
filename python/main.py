import socket
import random
import json
from enum import IntEnum
import threading

HOST = '0.0.0.0'  
PORT = 5000
BUFFSIZE = 1024

# 상수 선언
class Suit(IntEnum):
    SPADE = 1
    HEART = 2
    DIAMOND = 3
    CLUB = 4

class Card:
    # 초기화, 형 힌트
    def __init__(self, suit: Suit, rank: int):
        # 무늬 초기화
        self.suit = suit
        self.rank = rank
    def __str__(self):
        # 만약 수가 문양이라면 문양으로 바꿔서 출력
        displayRank = str(self.rank)
        if self.rank == 11:
            displayRank = 'J'
        elif self.rank == 12:
            displayRank = 'Q'
        elif self.rank == 13:
            displayRank = 'K'
        elif self.rank == 14:
            displayRank = 'A'
        # suit.name으로 Suit의 이름 꺼냄
        return f"{self.suit.name} {displayRank}"
    def to_dict(self):
        # 딕셔너리로 변환해 반환
        # suit.value로 Suit의 값 꺼냄
        return {"suit":self.suit.value, "rank":self.rank}

class Deck:
    def __init__(self):
        # 클래스 만들며 리스트 생성
        self.cards = []        
        self.make_deck()
    
    # 덱 생성
    def make_deck(self):
        # 리스트에 카드 만들어 삽입
        # 리스트 초기화
        # self.cards = []
        # suit는 반복 가능
        for i in Suit:
            for j in range(2, 15):
                card = Card(i, j)
                self.cards.append(card)
        self.shuffle()

    # 카드 섞기
    def shuffle(self):
        random.shuffle(self.cards)
    
    # 카드 뽑기
    def draw(self):
        if len(self.cards) > 0:
            return self.cards.pop()
        else:
            self.make_deck()
            return self.cards.pop()
    
    # 길이 반환
    def __len__(self):
        return len(self.cards)

# 스레드용 함수 선언
# 덱과 경쟁상태를 막기위한 lock인자로 받음
def clientHandler(clientSocket, addr, deck, deckLock):
    print(f"new client: {addr}")

    # 카드 준비
    card1 = None
    card2 = None

    # with로 lock 사용시 반환
    # 카드 뽑기
    with deckLock:
        card1 = deck.draw()
        card2 = deck.draw()

    # 카드 전송
    # 카드 딕셔너리로 만들어서 josn 규격으로 변환
    gameData = {
        "type" : "HOLE_CARDS",
        "cards" : [card1.to_dict(), card2.to_dict()]
    }
    # json 변환
    jsonStr = json.dumps(gameData)
    # 소켓을 통해 전송
    clientSocket.send(jsonStr.encode("utf-8"))

    # 연결용 while 반복문
    while True:
        try:
            data = clientSocket.recv(BUFFSIZE)
            if not data:
                continue
            msg = data.decode('utf-8')
        except ConnectionResetError:
            print(f"disconnect: {addr}")
            break
        except Exception as e:
            print(f"Error: {addr}, {e}")
            break
    # 소켓 종료
    clientSocket.close()
def start_server():
    # 소켓 생성
    serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serverSocket.bind((HOST, PORT))
    # 접속 대기
    serverSocket.listen()
    print(f"[Server] {HOST}:{PORT} ready")

    # 덱 생성
    deck = Deck()
    # lock 생성
    # 경쟁상태 방지
    deckLock = threading.Lock()

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
            break

        # 에러 발생시 알리고 서버는 지속
        except Exception as e:
            print(f"ERROR {e}")
            continue

    # 소켓 정리
    serverSocket.close()

if __name__ == '__main__':
    start_server()