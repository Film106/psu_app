import 'dart:io'; // ✅ ต้องมีเพื่อจัดการไฟล์ภาพ
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ต้องมีเพื่อดึง path รูป

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  File? _profileImage; // ตัวแปรเก็บไฟล์รูป

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // โหลดรูปทันทีที่เข้าหน้านี้
  }

  // ฟังก์ชันดึงรูปจากเครื่อง (เหมือนหน้า Home เป๊ะ)
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('profile_image_path');
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _profileImage = file;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("PSU Health", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5), // สีน้ำเงินเข้ม
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ส่วนข้อมูลส่วนตัวด้านบน ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // 🔥 แก้ไขตรงนี้: ให้โชว์รูปโปรไฟล์จริง
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF3F51B5), width: 2), // เพิ่มขอบสีน้ำเงินสวยๆ
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[300],
                      // ถ้ามีรูป ให้โชว์รูปจากไฟล์, ถ้าไม่มี ให้เป็น null
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      // ถ้าไม่มีรูป ให้โชว์ไอคอนคน
                      child: _profileImage == null 
                          ? const Icon(Icons.person, size: 40, color: Colors.white) 
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("สราวุธ ทองทิพย์", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("นักศึกษา", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.help_outline, color: Color(0xFF3F51B5)),
                ],
              ),
            ),

            // --- ส่วนวงกลมจำนวนก้าวและข้อมูลสุขภาพ (เหมือนเดิม) ---
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // วงกลมจำนวนก้าว
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 0.0, // วันนี้เดินไป 0 ก้าว
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
                        ),
                      ),
                      Column(
                        children: const [
                          Text("0", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          Text("/10,000", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("จำนวนก้าว", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  // ข้อมูลร่างกาย
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("อายุ: 19 ปี", style: TextStyle(fontSize: 16)),
                      const Text("น้ำหนัก: 53.0 กก.", style: TextStyle(fontSize: 16)),
                      const Text("ส่วนสูง: 172.0 ซม.", style: TextStyle(fontSize: 16)),
                      const Text("BMI: 17.92", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      TextButton(onPressed: () {}, child: const Text("แก้ไข")),
                    ],
                  ),
                ],
              ),
            ),

            // --- ส่วนอันดับ (Leaderboard) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text("อันดับ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            
            _buildLeaderboardItem(1, "ฤทธิไกร ประดิษฐ์", "101,913", Colors.amber),
            _buildLeaderboardItem(2, "พรศิริ หนูแก้ว", "88,775", Colors.grey),
            _buildLeaderboardItem(3, "นิฟาลิน โตะกานี", "83,491", Colors.brown),
            _buildLeaderboardItem(4, "พนธกร แพทอง", "77,131", Colors.transparent),
            _buildLeaderboardItem(5, "เปรมปกรณ์ ซันทอง", "74,625", Colors.transparent),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String steps, Color medalColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: medalColor != Colors.transparent
                ? Icon(Icons.emoji_events, color: medalColor)
                : Text(rank.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("วิทยาเขตหาดใหญ่", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(steps, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F51B5), fontSize: 16)),
        ],
      ),
    );
  }
}