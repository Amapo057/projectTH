import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

const String ipS = "192.168.56.1";
const String ipH = '192.168.0.4';

const double CARDSIZE = 70.0;

void main() {
  runApp(const MainApp());
}

class Card {
  // final로 이후 선언 후 수정 불가하도록 설정
  final int suit;
  final int rank;
  // this.suit으로 바로 인자로 받은걸 suit에 넣기
  // 생성자
  Card(this.suit, this.rank);

  // factory로 json을 분리하고 생성자 호출
  // .fromJson으로 이름 붙이기
  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(json['suit'], json['rank']);
  }

  // 값 아이콘으로 변환
  String get toIcon {
    // 스위치문으로 알아서리턴
    return switch (suit) {
      1 => '♠',
      2 => '♥',
      3 => '♦',
      4 => '♣',
      _ => '*',
    };
  }

  // rank 문자로 변환
  String get toFace {
    return switch (rank) {
      11 => "J",
      12 => "Q",
      13 => "K",
      14 => "A",
      _ => rank.toString(),
    };
  }

  // getter함수로 카드 정보 리턴
  String get info {
    return '$toIcon $toFace';
  }

  // 문양에 맞춰 색깔 리턴
  Color get color {
    return switch (suit) {
      1 || 4 => Colors.black,
      2 || 3 => Colors.red,
      _ => Colors.grey,
    };
  }
}

// StatefulWidget으로 변화가능하도록 변경
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  // 명시적인 오버라이드
  @override
  // 실제 상태를관리할 state생성
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // 문자열 선언
  String serverMessage = "Server Connecting...";
  // 소켓 선언, ?로 null 여부 허용
  Socket? channel;
  // 연결 확인용 변수 선언
  bool _isConnected = false;
  // 내 카드 변수
  Card? myCard1;
  Card? myCard2;

  // IP 입력을 위한 컨트롤러
  final _ipController = TextEditingController();

  // 소켓 연결 시도
  // async로 시간이 걸리는 작업의 포함여부 표시
  void _connectToServer(String ip) async {
    try {
      print("try connect server");

      // await으로 비동기 연결
      channel = await Socket.connect(ip, 5000);

      print("connect complete");

      // 연결 성공시 화면 갱신
      setState(() {
        serverMessage = "connect complete ";
        _isConnected = true;
      });

      // 수신 받기
      channel!.listen((Uint8List data) {
        // 메세지 디코드
        String msg = utf8.decode(data);
        print("listen server: $msg");

        try {
          // 서버로부터 받은 json 디코드
          Map<String, dynamic> jsonData = jsonDecode(msg);

          // json의 타입 확인 후 리스트로 나누기
          if (jsonData['type'] == 'HOLE_CARDS') {
            List<dynamic> cards = jsonData['cards'];

            // 생성자 호출해 객체 생성
            Card newCard1 = Card.fromJson(cards[0]);
            Card newCard2 = Card.fromJson(cards[1]);

            setState(() {
              serverMessage = "welcome";
              myCard1 = newCard1;
              myCard2 = newCard2;
            });
          }
        } catch (e) {
          debugPrint("pass");
        }
      });
    } catch (e) {
      print("connect filed: $e");
    }
  }

  // 프로그램 종료시 종료
  @override
  void dispose() {
    channel?.close();
    _ipController.dispose(); // 컨트롤러 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Scaffold 레이아웃 사용
      home: Scaffold(
        // 타이틀 달기
        appBar: AppBar(
          title: Text(serverMessage, style: TextStyle(fontSize: 20)),
        ),
        // 몸통
        body: Stack(
          children: [
            Center(
              // 세로로 배치
              child: Column(
                // 중앙설정
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 연결 전이면 입력 UI를, 연결 후면 빈 컨테이너를 보여줌
                  _isConnected
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _ipController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Server IP',
                                  hintText: '비워두면 기본 IP로 접속',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // 입력된 IP를 가져옴 (앞뒤 공백 제거)
                                  final String inputIP = _ipController.text
                                      .trim();
                                  // 입력값이 비어있으면 기본값(ipS) 사용, 아니면 입력값 사용
                                  final String targetIP = inputIP.isEmpty
                                      ? ipS
                                      : inputIP;
                                  _connectToServer(targetIP);
                                },
                                child: const Text("Connect"),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
            // check 버튼
            Visibility(
              visible: _isConnected,
              child: Align(
                // 왼쪽 아래 배치
                alignment: Alignment.bottomLeft,
                // 여백 배치
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: (){
                          // 버튼 누르면 전송
                          channel?.write("check");
                        }, 
                        child: Text("Check")
                      )
                    ],
                  ),
                ),
              ),
            )

            // Visibillity로 연결된 상태에만 보이도록 설정
            Visibility(
              visible: _isConnected,
              child: Align(
                // 아래 오른쪽에 배치
                alignment: Alignment.bottomRight,
                child: Padding(
                  // 여유 공간 잡기
                  padding: const EdgeInsets.all(16.0),
                  // 내부 요소들 행으로 배치
                  child: Row(
                    // 축 사이즈 작게
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 컨테이너 생성
                      Container(
                        // 컨테이너 크기 고정
                        width: CARDSIZE,
                        height: CARDSIZE,
                        // child 위치 고정
                        alignment: Alignment.center,
                        // 박스 장식 생성
                        decoration: BoxDecoration(
                          // 외각선 설정
                          border: Border.all(
                            color: myCard1?.color ?? Colors.purpleAccent,
                            width: 2.0,
                          ),
                          // 둥글게 깍기
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // 글자 생성
                        child: Text(
                          myCard1?.info ?? 'null',
                          // 스타일로 색상과 굵게 설정
                          style: TextStyle(
                            color: myCard1?.color ?? Colors.purpleAccent,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      // 컨테이너 생성
                      Container(
                        // 컨테이너 크기 고정
                        width: CARDSIZE,
                        height: CARDSIZE,
                        // child 위치 고정
                        alignment: Alignment.center,
                        // 박스 장식 생성
                        decoration: BoxDecoration(
                          // 외각선 설정
                          border: Border.all(
                            color: myCard2?.color ?? Colors.purpleAccent,
                            width: 2.0,
                          ),
                          // 둥글게 깍기
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // 글자 생성
                        child: Text(
                          myCard2?.info ?? "null",
                          // 스타일로 색상과 굵게 설정
                          style: TextStyle(
                            color: myCard2?.color ?? Colors.purpleAccent,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
