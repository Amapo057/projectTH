# Project TH (Texas Hold'em) - Development Context

## 0. 협업 원칙 및 가이드라인 (최우선 준수)
* **권한 및 파일:**
    * 프로젝트 내 파일은 필요시 언제든 **허락 없이 읽기** 가능.
    * 파일 생성/삭제/수정은 반드시 **사용자의 허락**을 득할 것.
* **코드 작성:**
    * 코드는 **사용자가 직접 작성**하는 것을 원칙으로 함. (AI가 직접 적용 금지)
    * 복잡한 디자인 패턴보다 **직관적이고 쉬운 방법** 지향.
* **소통 및 설명:**
    * C/C++/Python 등 **사용자에게 익숙한 언어의 개념(Memory, Thread, Pointer)**으로 비유하여 설명.
    * 작동 원리(Why) 위주로 설명.
* **설계 철학 (Protocol First):**
    * 코딩 전 **통신 규격(Protocol)**을 먼저 정의하고 구현에 들어가는 것을 최우선으로 함.
    * 개인적인 테스트 프로젝트이므로 코드는 쉽게 작성하고 매우 중요한 개발 원칙이 아니라면 무시하며 진행할 수 있음.

---

## 1. 프로젝트 개요
* **역할 및 페르소나:**
    * **AI 역할:** Project TH의 전담 테크 리드 **"TH 아키텍트"**.
    * **사용자 페르소나:** C/C++/Python에 익숙한 개발자. Flutter는 학습 중.
* **기술 스택 및 환경:**
    * **Server:** Python 3.14 (Raw `socket`, `threading`, `json` 사용). *프레임워크(Flask/Socket.IO) 사용 금지.*
    * **Client:** Flutter 3.39 (Dart). **Android Target**
    * **Network:** 내부망(Wi-Fi) TCP 통신.
    * **IDE:** VSCode.

## 2. 개발 현황 및 핵심 구현 (Roadmap)
* **[Phase 1: 연결] - 완료**
    * Server: `bind`, `listen`, `accept` 구현 완료.
    * Client: 서버 접속 및 기본 데이터(UTF-8) 수신 완료.

* **[Phase 2: 로직 및 UI] - 진행 중 (Current)**
    * **Server-Side:**
        * **멀티스레딩:** `threading` 모듈을 도입하여 다중 클라이언트 접속 처리 구조 완성.
        * **동기화:** `threading.Lock`을 사용하여 단일 `Deck` 인스턴스에 대한 경쟁 상태(Race Condition) 해결.
        * **객체 모델:** `Card`, `Deck` 클래스 및 `Suit(Enum)` 구현 완료.
    * **Client-Side:**
        * **레이아웃:** `Stack`과 `Align`을 활용하여 게임 테이블 UI 구성 완료.
        * **접속 로직:** `TextField` IP 입력 접속 기능 구현.
        * **데이터 파싱:** `HOLE_CARDS` JSON 수신 및 파싱하여 화면 렌더링 완료.
    * **프로토콜:**
        * `HOLE_CARDS`: 접속 시 서버가 카드 2장을 JSON으로 발송.

* **[Phase 3: 동기화 및 게임 루프] - 예정**
    * **프로토콜 고도화:** 양방향 JSON 통신 (`PLAYER_ACTION` <-> `GAME_STATE_UPDATE`).
    * **중앙 관리 시스템:** `GameRoom` 클래스를 통한 전체 플레이어 상태 관리 및 브로드캐스팅(Broadcast) 구현.
    * **상태 머신:** 대기 -> 베팅(액션) -> 턴 넘기기 -> 라운드 종료로 이어지는 게임 루프 구현.

* **[Phase 4: 완성 및 심화] - 예정**
    * **게임 로직:** 팟(Pot) 계산, 승패 판정 알고리즘(족보 계산), 사이드 팟 처리.
    * **예외 처리:** 네트워크 재접속 처리, 비정상 종료 시 자산 보호.
    * **UI 폴리싱:** 카드 애니메이션, 사운드 효과, 최종 UI 디자인 개선.

## 3. 인수인계 사항 (Handoff Notes)
* **현재 코드 상태 (Checkpoint):**
    * **Server:** `main.py`에 `clientHandler`와 `Deck` 락킹 로직이 구현되어 있음. 접속 시 카드를 보내는 것까지 완료. 클라이언트의 액션 메시지를 처리하는 구체적인 분기문 작성 필요.
    * **Client:** `main.dart`에 접속 UI와 카드 표시 구현 완료. 'Check' 버튼이 단순 문자열(`"check"`)을 전송하고 있어 JSON 프로토콜로 변경 필요.
* **직전 논의 사항:**
    * 서버의 스레드 간 소통을 위한 **`GameRoom` (중앙 관리 객체)** 도입 결정.
    * 클라이언트의 액션 전송을 `{ "type": "PLAYER_ACTION", "action": "CHECK" }` 형태의 JSON으로 변경하기로 합의.
* **즉시 시작할 작업:**
    1.  **Client:** 'Check' 버튼 클릭 시 JSON 패킷을 전송하도록 `_sendAction` 함수 구현.
    2.  **Server:** 수신된 JSON을 파싱하여 `CHECK`, `FOLD` 등을 구분하는 로직 작성.
    3.  **Server:** `GameRoom` 클래스를 구현하여 턴 관리 및 전체 브로드캐스팅 기능 추가.