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

            String suit1 = cards[0]['suit'];
            int rank1 = cards[0]['rank'];

            setState(() {
              serverMessage = "recv card!\n $suit1 $rank1";
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
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Card 1"),
                    SizedBox(width: 8),
                    Text("Card 2"),
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
