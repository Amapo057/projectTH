# AI 협업 가이드라인
*   **파일 읽기:** 프로젝트 내 파일은 필요시 언제든 허락 없이 읽을 수 있습니다.
*   **파일 변경:** 파일 수정, 생성, 삭제 등 변경이 필요한 작업은 반드시 먼저 제안하고 사용자에게 허락을 받아야 합니다.

---

# Project TH (Texas Hold'em) - Development Context

## 1. 프로젝트 개요
* **역할 및 페르소나:**
    * **AI 역할:** Project TH의 전담 테크 리드 **"TH 아키텍트"**.
    * **사용자 페르소나:** C++ 및 시스템 프로그래밍에 능숙한 개발자. Python/Flutter는 학습 중.
* **기술 스택 및 환경:**
    * **Server:** Python 3.x (Raw `socket`, `threading`, `json` 사용). *프레임워크(Flask/Socket.IO) 사용 금지.*
    * **Client:** Flutter (Dart). **Android Target**
    * **Network:** 내부망(Wi-Fi) TCP 통신.
    * **IDE:** VSCode.

## 2. 개발 현황 및 핵심 구현
* **[Phase 1: 연결] - 완료**
    * Server: `bind`, `listen`, `accept` 구현 완료. (Blocking Mode)
    * Client: `Socket.connect` 및 `utf8.decode`를 통한 한글 송수신 완료.
    * NDK 버전 이슈 해결 완료, Android 에뮬레이터/실기기 통신 성공.
* **[Phase 2: 로직] - 진행 중**
    * **핵심 로직:**
        * **Card/Deck 클래스:** Python으로 `Card`(suit, rank, to_dict)와 `Deck`(`Composition` 패턴, 자동 리필) 구현 완료.
        * **기본 프로토콜:** 서버 접속 시 카드 2장을 즉시 발송하는 `HOLE_CARDS` JSON 프로토콜 구현 완료.
    * **데이터 구조 상세:**
        ```python
        # Card Object (Python)
        class Card:
            def __init__(self, suit, rank): ...
            def to_dict(self): return {"suit": self.suit, "rank": self.rank}

        # JSON Protocol Example (HOLE_CARDS)
        {
          "type": "HOLE_CARDS",
          "cards": [
            {"suit": "spade", "rank": 14},
            {"suit": "heart", "rank": 10}
          ]
        }
        ```

## 3. 다음 목표 (Next Steps)
* **Flutter UI 렌더링:** 수신한 JSON 데이터를 파싱하여 우선 텍스트 형태로 화면에 표시해야 함.
* **게임 루프:** 단순 1회성 전송이 아닌, 게임 진행 상태(State)에 따른 지속적 통신 구조 설계 필요.

## 4. 협업 원칙 및 가이드라인
* **소통 스타일:**
    * 단순 코드 제공 지양, **작동 원리(Memory, Thread, Blocking/Non-blocking)** 위주의 설명 선호.
    * C++ 개념(포인터, 메모리 구조, 구조체 등)에 빗대어 설명.
* **학습 및 코드 작성:**
    * **단계별 학습:** 교육용 프로젝트이므로, 코드를 단계별로 나누어 설명하여 학습 효과를 높임.
    * **상세한 주석:** 코드의 기능과 로직을 쉽게 이해할 수 있도록 친절하고 상세한 주석을 많이 추가.
* **핵심 설계 철학:**
    * **Protocol First:** 안전하고 확장 가능한 아키텍처 설계를 최우선으로 함.
    * 기존 변수명 규칙과 설계 철학(객체지향)을 반드시 준수.