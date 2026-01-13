import 'dart:io';
import 'dart:math';

// --- Flutter Packages ---
import 'package:flutter/material.dart';

// --- Third-Party Packages ---
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// ==========================================
// MARK: - Data Model (ข้อมูลนักศึกษา)
// ==========================================
class StudentData {
  static const String id = "1234567890"; // รหัสนักศึกษา
  static const String prefix = "นาย";
  static const String firstNameTH = "สราวุธ";
  static const String lastNameTH = "ทองทิพย์";
  static const String fullNameEN = "SARAWUT THONGTHIP";
  static const String faculty = "Science"; // คณะ
  static const String major = "COMPUTER SCIENCE"; // สาขา
  static const String level = "ปริญญาตรี";
  static const String campus = "Songklanakarin University"; // วิทยาเขต
}

// ==========================================
// MARK: - Profile Screen (Main)
// ==========================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  // --- Variables ---
  File? _profileImage;
  
  // Animation Variables
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true; 

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _setupFlipAnimation();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  // --- Initialization Logic ---
  void _setupFlipAnimation() {
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('profile_image_path');
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        if (mounted) setState(() => _profileImage = file);
      }
    }
  }

  // --- User Actions ---
  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _navigateToQR() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyQRScreen()));
  }

  // ==========================================
  // MARK: - Main Build
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackgroundWatermark(), // ลายน้ำพื้นหลัง
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildCardSection(),      // ส่วนบัตรนักศึกษา
                const SizedBox(height: 40),
                _buildStudentInfoSection(), // ส่วนข้อมูลรายละเอียด
                const SizedBox(height: 30),
                _buildActionButtons(),    // ปุ่มต่างๆ
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MARK: - Sub-Widgets (Component Builders)
  // ==========================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBackgroundWatermark() {
    return Positioned.fill(
      child: Center(
        child: Image.asset(
          'assets/images/logos/psu_logo.png',
          width: 300, 
          fit: BoxFit.contain,
          color: Colors.grey.withOpacity(0.1), 
          colorBlendMode: BlendMode.srcIn, 
          errorBuilder: (c,e,s) => const Icon(Icons.school, size: 200, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _flipAnimation.value < 0.5 
                ? _buildFrontCard()
                : Transform( 
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi), 
                    child: _buildBackCard(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildStudentInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, "Student ID", StudentData.id),
          _buildDivider(),
          _buildInfoRow(Icons.person_outline, "Full Name", "${StudentData.prefix}${StudentData.firstNameTH} ${StudentData.lastNameTH}"),
          _buildDivider(),
          _buildInfoRow(Icons.school_outlined, "Faculty", StudentData.faculty),
          _buildDivider(),
          _buildInfoRow(Icons.computer_outlined, "Major", "Computer Science"),
          _buildDivider(),
          _buildInfoRow(Icons.location_on_outlined, "Campus", StudentData.campus),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _navigateToQR,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D59F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFF0D59F2).withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.white),
            SizedBox(width: 10),
            Text("My QR Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // --- Card Widgets ---

  Widget _buildFrontCard() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2027), // Deep Blue/Black
            Color(0xFF203A43), // Dark Teal
            Color(0xFF2C5364), // Blue Grey
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2C5364).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Background Shimmer (PSU Watermark)
          Positioned.fill(
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.05),
              highlightColor: Colors.white.withOpacity(0.15),
              period: const Duration(seconds: 4),
              child: Stack(
                children: [
                  Positioned(top: -20, right: -20, child: Icon(Icons.school, size: 200, color: Colors.white)),
                  const Center(child: Text("PSU", style: TextStyle(fontSize: 120, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic))),
                ],
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Logo + Tag)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logos/psu.png', width: 45), // Original Color Logo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Text("STUDENT CARD", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    )
                  ],
                ),
                
                const Spacer(),

                // Info & Photo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(StudentData.fullNameEN, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("${StudentData.prefix}${StudentData.firstNameTH} ${StudentData.lastNameTH}", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 8),
                          Text(StudentData.id, style: TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Courier')),
                          SizedBox(height: 4),
                          Text("Faculty of ${StudentData.faculty}", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    _buildPhotoFrame(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoFrame() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        image: DecorationImage(
          image: _profileImage != null 
              ? FileImage(_profileImage!) as ImageProvider
              : const AssetImage('assets/images/profile_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1A1A1A), // Matte Black
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(height: 50, width: double.infinity, color: Colors.black), // Magnetic Strip
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 40,
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("Authorized Signature", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 20),
              Container(width: 50, height: 40, color: Colors.white24), // Security Box
              const SizedBox(width: 20),
            ],
          ),
          const Spacer(),
          const Text("PRINCE OF SONGKLA UNIVERSITY", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF0D59F2), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.1), height: 1, indent: 50);
  }
}

// ==========================================
// MARK: - Sub-Screens (My QR)
// ==========================================
class MyQRScreen extends StatelessWidget {
  const MyQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D59F2),
      appBar: AppBar(
        title: const Text("My QR Code", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Scan to Verify", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D59F2))),
              const SizedBox(height: 20),
              // QR Code with StudentData ID
              Image.network("https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${StudentData.id}", width: 220),
              const SizedBox(height: 20),
              const Text("${StudentData.prefix}${StudentData.firstNameTH} ${StudentData.lastNameTH}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text(StudentData.id, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}