import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

String ipS = "192.168.56.1";
String ipH = '192.168.0.4';

void main() {
  runApp(const MainApp());
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
  String myCard1 = "empty";
  String myCard2 = "empty";

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

      channel!.listen((Uint8List data) {
        String msg = utf8.decode(data);
        print("listen server: $msg");

        try {
          // 서버로부터 받은 json 디코드
          Map<String, dynamic> jsonData = jsonDecode(msg);

          // json의 타입 확인 후 리스트로 나누기
          if (jsonData['type'] == 'HOLE_CARDS') {
            List<dynamic> cards = jsonData['cards'];

            String suit1 = toIcon(cards[0]['suit']);
            int rank1 = cards[0]['rank'];

            String suit2 = toIcon(cards[1]['suit']);
            int rank2 = cards[1]['rank'];

            setState(() {
              serverMessage = "connect success";
              myCard1 = "$suit1 $rank1";
              myCard2 = "$suit2 $rank2";
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

  // 값 아이콘으로 변환
  String toIcon(int suit) {
    // 스위치문으로 알아서리턴
    return switch (suit) {
      1 => '♠',
      2 => '♥',
      3 => '♦',
      4 => '♣',
      _ => '*',
    };
  }

  // 프로그램 종료시 종료
  @override
  void dispose() {
    channel?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Scaffold 레이아웃 사용
      home: Scaffold(
        // 타이틀 달기
        appBar: AppBar(title: const Text("Project TH build")),
        // 몸통
        body: Stack(
          children: [
            Center(
              // 세로로 배치
              child: Column(
                // 중앙설정
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      serverMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // _isConnected가 참이면 빈 컨테이너, 거짓이면 버튼 출력
                  _isConnected
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 버튼 만들기
                            ElevatedButton(
                              // 눌렀을 때
                              onPressed: () {
                                print("connect Home");
                                // 서버 연결버튼 호출
                                _connectToServer(ipH);
                              },
                              // 버튼에 텍스트 넣기
                              child: const Text("Connect Home"),
                            ),
                            // 여백 만들기
                            const SizedBox(width: 20),
                            ElevatedButton(
                              // 람다함수같은 문법
                              onPressed: () {
                                print("connect try to study");
                                _connectToServer(ipS);
                              },
                              child: const Text("Connect School"),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Align(
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
                      width: 110.0,
                      height: 180.0,
                      // child 위치 고정
                      alignment: Alignment.center,
                      // 박스 장식 생성
                      decoration: BoxDecoration(
                        // 외각선 설정
                        border: Border.all(color: Colors.blue, width: 2.0),
                        // 둥글게 깍기
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // 글자와 공간 여백 설정
                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: 16.0,
                      //   vertical: 50.0,
                      // ),
                      // 글자 생성
                      child: Text(
                        myCard1,
                        // 스타일로 색상과 굵게 설정
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    // 컨테이너 생성
                    Container(
                      // 컨테이너 크기 고정
                      width: 110.0,
                      height: 180.0,
                      // child 위치 고정
                      alignment: Alignment.center,
                      // 박스 장식 생성
                      decoration: BoxDecoration(
                        // 외각선 설정
                        border: Border.all(color: Colors.red, width: 2.0),
                        // 둥글게 깍기
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // 글자 생성
                      child: Text(
                        myCard2,
                        // 스타일로 색상과 굵게 설정
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
