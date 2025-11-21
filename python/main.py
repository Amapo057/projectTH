import socket
import random
import json
from enum import IntEnum

HOST = '0.0.0.0'  
PORT = 5000
BUFFSIZE = 1024

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

def start_server():
    # 소켓 생성
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

        deck = Deck()
        
        card1 = deck.draw()
        card2 = deck.draw()

        game_data = {
            "type": "HOLE_CARDS",
            "cards": [card1.to_dict(), card2.to_dict()]
        }

        # 카드 정보 json으로 변경 후 utf-8로 전송
        json_str = json.dumps(game_data)
        clientSocket.send(json_str.encode("utf-8"))


    except Exception as e:
        print(f"ERROR {e}")
    finally:
        # 소켓 정리
        clientSocket.close()
        serverSocket.close()

if __name__ == '__main__':
    start_server()