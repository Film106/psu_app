import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true; // ตัวแปรเช็คว่าโหลดเสร็จยัง

  @override
  void initState() {
    super.initState();
    // ตั้งค่า WebView Controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // อนุญาตให้รัน JS
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true); // เริ่มโหลด ให้หมุนๆ
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false); // โหลดเสร็จ หยุดหมุน
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // สั่งให้โหลด URL ที่ส่งมา
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF0D59F2), // สี PSU
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. ตัวแสดงเว็บ
          WebViewWidget(controller: _controller),
          
          // 2. ตัวหมุนๆ (แสดงเฉพาะตอนกำลังโหลด)
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D59F2)),
            ),
        ],
      ),
    );
  }
}