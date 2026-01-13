import 'dart:io';
import 'package:flutter/cupertino.dart'; // ใช้ CupertinoSwitch ให้ดูพรีเมียม
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- State Variables (จำลองการตั้งค่า) ---
  bool _isNotificationOn = true;
  bool _isBiometricOn = false;
  bool _isDarkMode = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // สีพื้นหลังเทาอ่อนสไตล์ iOS
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            // --- 1. Profile Section ---
            _buildProfileSection(),
            const SizedBox(height: 25),

            // --- 2. Account Settings ---
            _buildSectionHeader("Account"),
            _buildSettingsGroup([
              _buildTile(
                icon: Icons.person_outline, 
                color: Colors.blue, 
                title: "Edit Profile", 
                onTap: () {}
              ),
              _buildTile(
                icon: Icons.lock_outline, 
                color: Colors.orange, 
                title: "Change Password", 
                onTap: () {}
              ),
              _buildTile(
                icon: Icons.language, 
                color: Colors.purple, 
                title: "Language", 
                trailingText: "English",
                onTap: () {}
              ),
            ]),

            const SizedBox(height: 20),

            // --- 3. Preferences ---
            _buildSectionHeader("Preferences"),
            _buildSettingsGroup([
              _buildSwitchTile(
                icon: Icons.notifications_none,
                color: Colors.red,
                title: "Notifications",
                value: _isNotificationOn,
                onChanged: (val) => setState(() => _isNotificationOn = val),
              ),
              _buildSwitchTile(
                icon: Icons.face,
                color: Colors.green,
                title: "Face ID / Touch ID",
                value: _isBiometricOn,
                onChanged: (val) => setState(() => _isBiometricOn = val),
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                color: Colors.black87,
                title: "Dark Mode",
                value: _isDarkMode,
                onChanged: (val) => setState(() => _isDarkMode = val),
              ),
            ]),

            const SizedBox(height: 20),

            // --- 4. Support ---
            _buildSectionHeader("Support"),
            _buildSettingsGroup([
              _buildTile(icon: Icons.help_outline, color: Colors.blueGrey, title: "Help Center", onTap: () {}),
              _buildTile(icon: Icons.policy_outlined, color: Colors.blueGrey, title: "Privacy Policy", onTap: () {}),
            ]),

            const SizedBox(height: 30),

            // --- 5. Logout Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Show Confirm Dialog
                  showDialog(
                    context: context, 
                    builder: (c) => AlertDialog(
                      title: const Text("Log Out"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
                        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Log Out", style: TextStyle(color: Colors.red))),
                      ],
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Version 1.0.0 (Build 2026)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MARK: - Helper Widgets (เพื่อให้โค้ดสะอาด)
  // ==========================================

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Sarawut Thongthip", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("6510210650", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.qr_code, color: Colors.black54),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          // ใส่เส้นคั่นระหว่างรายการ (ยกเว้นตัวสุดท้าย)
          return Column(
            children: [
              child,
              if (idx != children.length - 1)
                const Divider(height: 1, indent: 56, color: Color(0xFFF2F2F7)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // เมนูแบบปกติ (มีลูกศร >)
  Widget _buildTile({required IconData icon, required Color color, required String title, String? trailingText, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          if (trailingText != null) const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // เมนูแบบสวิตช์ (Toggle)
  Widget _buildSwitchTile({required IconData icon, required Color color, required String title, required bool value, required Function(bool) onChanged}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: CupertinoSwitch( // ใช้สวิตช์แบบ iOS สวยกว่า
        value: value,
        activeColor: const Color(0xFF0D59F2),
        onChanged: onChanged,
      ),
    );
  }
}