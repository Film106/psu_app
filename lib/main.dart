import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // เพิ่มเพื่อจัดการสี Status Bar
import 'screens/main_screen.dart';

void main() {
  // ตั้งค่า Status Bar ให้โปร่งใส เพื่อความสวยงาม
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // ไอคอนสีเข้ม (สำหรับพื้นหลังสว่าง)
  ));
  
  runApp(const PSUApp());
}

class PSUApp extends StatelessWidget {
  const PSUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug มุมขวาบน
      title: 'PSU Smart App',
      
      // ตั้งค่า Theme รวมของแอป
      theme: ThemeData(
        fontFamily: 'Roboto', // หรือเปลี่ยนเป็นฟอนต์ไทยที่ชอบ
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // สีพื้นหลังหลัก (เทาอ่อน)
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D59F2), // สีธีมหลัก (น้ำเงิน PSU)
          primary: const Color(0xFF0D59F2),
        ),
        
        // ตั้งค่า AppBar ทั่วไป
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      // เรียกหน้าแรก (ที่มีเมนูด้านล่าง)
      home: const MainScreen(),
    );
  }
}