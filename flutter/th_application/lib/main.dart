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

  // 소켓 연결 시도
  // async로 시간이 걸리는 작업의 포함여부 표시
  void _connectToServer() async {
    try {
      print("try connect server");

      // await으로 비동기 연결
      channel = await Socket.connect(ipS, 5000);

      print("connect complete");

      // 연결 성공시 화면 갱신
      setState(() {
        serverMessage = "connect complete ";
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
        body: Center(
          child: Column(
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

              // 연결 시도 버튼
              ElevatedButton(
                onPressed: () {
                  print("connect Try");
                  _connectToServer();
                },
                child: const Text("server Connect"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
