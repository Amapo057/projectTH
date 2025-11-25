from enum import IntEnum
import random

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
    # 문자카드 변환
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
    # 카드 정보 딕셔너리로 변환해서 반환
    def to_dict(self):
        # suit.value로 Suit의 값 꺼냄
        return {"suit":self.suit.value, "rank":self.rank}

# 덱 클래스
class Deck:
    # 덱용 리스트 만들고 덱 만들면서 초기화
    def __init__(self):
        # 클래스 만들며 리스트 생성
        self.cards = []        
        self._make_deck()
    
    # 덱 생성
    def _make_deck(self):
        # 리스트에 카드 만들어 삽입
        # 리스트 초기화
        self.cards = []
        # 상수용 Suit는 반복 가능
        for i in Suit:
            for j in range(2, 15):
                card = Card(i, j)
                self.cards.append(card)
        self._shuffle()

    # 카드 섞기
    def _shuffle(self):
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