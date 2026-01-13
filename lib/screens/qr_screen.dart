import 'dart:async';
import 'dart:io';

// --- Flutter Packages ---
import 'package:flutter/material.dart';

// --- Third-Party Packages ---
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// MARK: - Data Model (ข้อมูลนักศึกษา)
// ==========================================
class StudentData {
  static const String id = "1234567890"; // รหัสนักศึกษา (Mock)
  static const String name = "นายสราวุธ ทองทิพย์";
  static const String faculty = "วิทยาศาสตร์ (Computer Science)";
}

// ==========================================
// MARK: - QR Screen (Main)
// ==========================================
class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  // --- Variables ---
  late String _currentTime;
  late Timer _timer;
  File? _profileImage;

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadProfileImage();
    // อัปเดตเวลาทุก 1 วินาที (Real-time Clock)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel(); // ยกเลิก Timer เมื่อออกจากหน้าจอเพื่อคืน Ram
    super.dispose();
  }

  // --- Logic Methods ---
  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('dd MMM yyyy - HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? imagePath = prefs.getString('profile_image_path');
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          if (mounted) setState(() => _profileImage = file);
        }
      }
    } catch (e) {
      debugPrint("Error loading profile image: $e");
    }
  }

  // ==========================================
  // MARK: - Main Build
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // สีพื้นหลังเทาอ่อนสบายตา
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildDigitalPassCard(),
            const SizedBox(height: 30),
            _buildWarningSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MARK: - Component Builders (Sub-Widgets)
  // ==========================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("My QR Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null 
                ? const Icon(Icons.person, size: 40, color: Colors.white) 
                : null,
          ),
        ),
        const SizedBox(height: 10),
        const Text(StudentData.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
        const Text(StudentData.faculty, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDigitalPassCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Header Card (Blue)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0D59F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const Text("PSU SMART PASS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(_currentTime, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          // Content Card
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                // 1. Barcode Section
                const Text("Library & Exams", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                _buildBarcodeImage(),
                const SizedBox(height: 5),
                const Text(StudentData.id, style: TextStyle(fontSize: 16, letterSpacing: 3, fontWeight: FontWeight.w600)),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                ),

                // 2. QR Code Section
                const Text("Payment & Access", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                _buildQRCodeImage(),
                const SizedBox(height: 15),
                const Text("Scan to verify identity", style: TextStyle(color: Color(0xFF0D59F2), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeImage() {
    return Image.network(
      "https://barcode.tec-it.com/barcode.ashx?data=${StudentData.id}&code=Code128&translate-esc=true&hideLink=true",
      height: 80,
      fit: BoxFit.fitWidth,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(height: 80, width: 200, color: Colors.grey[100], child: const Center(child: CircularProgressIndicator()));
      },
      errorBuilder: (context, error, stackTrace) => const SizedBox(height: 80, child: Center(child: Text("Unable to load Barcode", style: TextStyle(color: Colors.red, fontSize: 10)))),
    );
  }

  Widget _buildQRCodeImage() {
    return Image.network(
      "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${StudentData.id}",
      height: 180,
      width: 180,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(height: 180, width: 180, color: Colors.grey[100], child: const Center(child: CircularProgressIndicator()));
      },
      errorBuilder: (context, error, stackTrace) => const SizedBox(height: 180, width: 180, child: Center(child: Icon(Icons.broken_image, color: Colors.grey))),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3), // สีแดงอ่อน
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "QR Code นี้มีข้อมูลส่วนบุคคล\nโปรดระมัดระวังในการเผยแพร่สู่สาธารณะ",
              style: TextStyle(color: Color(0xFFC62828), fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}