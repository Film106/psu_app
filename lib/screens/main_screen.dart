import 'package:flutter/material.dart';

// --- Import Screens (นำเข้าไฟล์หน้าจอต่างๆ) ---
import 'home_screen.dart';
import 'profile_screen.dart';
import 'qr_screen.dart';
import 'settings_screen.dart'; // 🔥 ต้องมีบรรทัดนี้ครับ ถึงจะโชว์หน้า Settings ได้

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 🔥 รายชื่อหน้าจอ (เรียงลำดับให้ตรงกับเมนูด้านล่าง)
  final List<Widget> _pages = [
    const HomeScreen(),      // Index 0: หน้าหลัก
    const ProfileScreen(),   // Index 1: หน้าโปรไฟล์
    const QRScreen(),        // Index 2: หน้า QR
    const SettingsScreen(),  // Index 3: หน้าตั้งค่า (✅ แก้จาก Text เป็นหน้าจอจริงแล้ว)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนแสดงผลหน้าจอ
      body: _pages[_selectedIndex],

      // เมนูบาร์ด้านล่าง (Material 3 Style)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        elevation: 2, // เพิ่มเงาเล็กน้อยให้ดูแยกชั้นกับเนื้อหา
        indicatorColor: const Color(0xFFDCE2F9), // สีวงกลมพื้นหลังตอนเลือก
        
        destinations: const [
          // 1. Home
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_filled, color: Color(0xFF0D59F2)), // เปลี่ยนสีไอคอนตอนเลือก
            label: 'Home',
          ),
          
          // 2. Profile
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF0D59F2)),
            label: 'Profile',
          ),
          
          // 3. My QR
          NavigationDestination(
            icon: Icon(Icons.qr_code),
            selectedIcon: Icon(Icons.qr_code_2, color: Color(0xFF0D59F2)),
            label: 'My QR',
          ),
          
          // 4. Settings
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF0D59F2)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}