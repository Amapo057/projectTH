from tojson import ToJson
from card import Deck
import threading
import socket

BUFFSIZE = 1024


class Player:
    # 초기화
    def __init__(self, socket, addr):
        self.socket = socket    # 소켓 연결
        self.addr = addr        # 주소 연결
        self.hand = []          # 카드 담을 리스트
        self.chip = 100         # 돈 초기화
        self.isFold = False     # 폴드 여부
        self.turn = False       # 턴여부
    
    # 카드 받아서 핸드에 추가하기
    def recvCard(self, card):
        self.hand.append(card)

    # 연결용 while 반복문
    while True:
        try:
            data = socket.recv(BUFFSIZE)
            if not data:
                continue
            msg = data.decode('utf-8')
            print(msg)
        except ConnectionResetError:
            print(f"disconnect: {addr}")
            break
        except Exception as e:
            print(f"Error: {addr}, {e}")
            break
    # 소켓 종료
    socket.close()

# 전체 게임관리용 클래스
class GameRoom():
    # 필요 정보 초기화
    def __init__(self):
        player = []     # 플레이어 기록용 리스트
        deck = Deck()   # 덱 생성
        deckLock = threading.Lock()     # lock 생성

class Player:
    def __init__(self, socket, addr):
        self.socket = socket      # 통신용 소켓
        self.addr = addr          # 주소 (ID 대용)
        self.hand = []            # [중요] 개인이 가진 카드 리스트 (족보 판정용)
        self.money = 1000         # 가지고 있는 칩 (기본 1000)
        self.is_fold = False      # 다이(Fold) 했는지 여부
        self.action_needed = False # 턴이 돌아와서 행동해야 하는지

    # 카드를 받음
    def add_card(self, card):
        self.hand.append(card)

    # 편의를 위한 전송 함수 (이 플레이어에게만 보내기)
    def send(self, data_dict):
        try:
            self.socket.send(json.dumps(data_dict).encode('utf-8'))
        except:
            pass
2. GameRoom 업그레이드 (소켓 리스트 → 플레이어 리스트)
GameRoom 클래스를 아래와 같이 수정하여, 입장 시 Player 객체를 생성하도록 변경합니다.

Python

class GameRoom:
    def __init__(self):
        self.players = []     # 이제 소켓이 아니라 'Player 객체'들이 들어갑니다.
        self.deck = Deck()
        self.lock = threading.Lock()

    def enter(self, client_socket, addr):
        with self.lock:
            # 1. 플레이어 객체 생성 (소켓 포장)
            new_player = Player(client_socket, addr)
            self.players.append(new_player) # 명부에 등록
            
            # 2. 카드 뽑아서 플레이어 손(hand)에 쥐여주기
            card1 = self.deck.draw()
            card2 = self.deck.draw()
            new_player.add_card(card1) # <-- 핵심! 서버 메모리에 저장됨
            new_player.add_card(card2)

            # 3. 당사자에게 카드 전송
            # (Player 클래스에 만든 send 함수 활용)
            new_player.send({
                "type": "HOLE_CARDS",
                "cards": [card1.to_dict(), card2.to_dict()]
            })
            
            print(f"[{addr}] 입장 및 카드 저장 완료. (핸드: {new_player.hand[0]}, {new_player.hand[1]})")

    # ... (broadcast 등 다른 함수들도 sock 대신 player.socket을 쓰도록 수정 필요)
💡 왜 이렇게 해야 하나요? (Why?)
이렇게 hand 리스트를 Player 객체 안에 저장해두면, 나중에 게임 끝날 때 승자 판정이 정말 쉬워집니다.

Python

# 나중에 작성할 승자 판정 로직 예시
def determine_winner(self):
    best_score = -1
    winner = None

    for p in self.players:
        if p.is_fold: continue # 죽은 사람은 패스
        
        # 여기서 p.hand를 꺼내서 족보 계산기에 넣으면 끝!
        score = HandEvaluator.calculate(p.hand, self.community_cards)
        
        if score > best_score:
            best_score = score
            winner = p
    
    print(f"승자는 {winner.addr} 입니다!")