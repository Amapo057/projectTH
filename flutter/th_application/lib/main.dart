import 'package:flutter/material.dart';

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
              Text(serverMessage, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  print("connect Try");
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
