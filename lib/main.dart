import 'package:flutter/material.dart';
import 'pages/webview_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 跳转到第二页
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WebViewApp()),
            );
          },
          child: Text('去webview页面'),
        ),
      ),
    );
  }
}

