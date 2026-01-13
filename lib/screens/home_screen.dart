import 'dart:io';
import 'dart:ui'; // For Glassmorphism Effect
import 'dart:convert';

// --- Flutter Packages ---
import 'package:flutter/material.dart';

// --- Third-Party Packages ---
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

// --- Local Screens ---
import 'youtube_screen.dart';
import 'webview_screen.dart';
import 'notification_screen.dart';
import 'health_screen.dart';

// ==========================================
// MARK: - Data Model (Mock Data)
// ==========================================
class AppData {
  // ข้อมูลตารางเรียน
  static final List<Map<String, dynamic>> scheduleData = [
    {
      "title": "Computer Programming",
      "time": "08:30 - 10:30",
      "location": "ตึก CS201",
      "badge": "Now",
      "colors": [const Color(0xFF0052D4), const Color(0xFF4364F7)]
    },
    {
      "title": "Calculus I",
      "time": "13:00 - 15:00",
      "location": "ตึก LH301",
      "badge": "13:00",
      "colors": [const Color(0xFFff9966), const Color(0xFFff5e62)]
    },
    {
      "title": "English for Comm.",
      "time": "15:30 - 17:30",
      "location": "ตึก LA102",
      "badge": "15:30",
      "colors": [const Color(0xFF11998e), const Color(0xFF38ef7d)]
    },
  ];

  // ข้อมูลข่าวประชาสัมพันธ์
  static final List<Map<String, dynamic>> newsData = [
    {
      "title": "PSU YOUNG ENTREPRENEUR รุ่นที่ 3",
      "desc": "โครงการบ่มเพาะผู้ประกอบการรุ่นใหม่...",
      "date": "9 Jan 2026",
      "image": "assets/images/news/banner.jpg",
      "url": "https://www.youtube.com/watch?v=ScMzIvxBSi4",
      "type": "youtube"
    },
    {
      "title": "ประกาศตารางสอบปลายภาค 2/2568",
      "desc": "นักศึกษาสามารถตรวจสอบตารางสอบได้ที่...",
      "date": "8 Jan 2026",
      "image": "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=800&q=80",
      "url": "https://reg.psu.ac.th",
      "type": "web"
    },
    {
      "title": "กิจกรรม Freshy Night 2026",
      "desc": "ขอเชิญน้องๆ ปี 1 ร่วมสนุกกับกิจกรรม...",
      "date": "7 Jan 2026",
      "image": "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80",
      "url": "https://www.psu.ac.th",
      "type": "web"
    },
  ];
}

// ==========================================
// MARK: - Main Screen
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- State Variables ---
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late String _currentDate;

  // Weather Data State
  Map<String, dynamic> _realWeatherData = {
    "temp": "--",
    "condition": "Loading...",
    "location": "PSU Hat Yai",
    "pm25": "--",
    "pmLevel": "Check",
    "icon": Icons.cloud_sync,
  };

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _loadProfileImage();
    _currentDate = DateFormat('EEEE d MMMM yyyy').format(DateTime.now());
    _fetchRealWeather();
  }

  // ==========================================
  // MARK: - Logic & API Functions
  // ==========================================

  // ดึงข้อมูลสภาพอากาศจาก API
  Future<void> _fetchRealWeather() async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=7.0084&longitude=100.4767&current_weather=true&hourly=pm2_5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currentWeather = data['current_weather'];
        final double temp = currentWeather['temperature'];
        final int weatherCode = currentWeather['weathercode'];

        String conditionText = "Clear";
        IconData conditionIcon = Icons.wb_sunny_rounded;

        // Map Weather Codes
        if (weatherCode == 0) {
          conditionText = "Clear Sky";
          conditionIcon = Icons.wb_sunny_rounded;
        } else if (weatherCode >= 1 && weatherCode <= 3) {
          conditionText = "Cloudy";
          conditionIcon = Icons.cloud_rounded;
        } else if (weatherCode >= 51 && weatherCode <= 67) {
          conditionText = "Rainy";
          conditionIcon = Icons.beach_access_rounded;
        } else if (weatherCode >= 95) {
          conditionText = "Thunderstorm";
          conditionIcon = Icons.flash_on_rounded;
        }

        if (mounted) {
          setState(() {
            _realWeatherData = {
              "temp": "${temp.round()}°",
              "condition": conditionText,
              "location": "PSU Hat Yai",
              "pm25": "25", // Mock PM2.5 data
              "pmLevel": "Good",
              "icon": conditionIcon,
            };
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      if (mounted) {
        setState(() {
          _realWeatherData = {
            "temp": "30°",
            "condition": "No Internet",
            "location": "PSU Hat Yai",
            "pm25": "-",
            "pmLevel": "-",
            "icon": Icons.signal_wifi_off,
          };
        });
      }
    }
  }

  // จัดการการเปลี่ยนหน้า (Navigation)
  void _openWebView(String title, String url) {
    if (url.isEmpty || url.contains('ใส่ลิ้งค์')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ยังไม่มีลิงก์สำหรับเมนูนี้ครับ")),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen(url: url, title: title)));
  }

  void _openNews(Map<String, dynamic> newsItem) {
    if (newsItem['type'] == 'youtube') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => YouTubeScreen(videoUrl: newsItem['url'], title: newsItem['title'])));
    } else {
      _openWebView(newsItem['title'], newsItem['url']);
    }
  }

  // จัดการรูปโปรไฟล์ (Image Picker & Cropper)
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) _cropImage(pickedFile.path);
    } catch (e) {
      debugPrint("Pick Image Error: $e");
    }
  }

  Future<void> _cropImage(String sourcePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'ปรับรูปโปรไฟล์', toolbarColor: const Color(0xFF0D59F2), toolbarWidgetColor: Colors.white, lockAspectRatio: true),
          IOSUiSettings(title: 'ปรับรูปโปรไฟล์', aspectRatioLockEnabled: true),
        ],
      );
      if (croppedFile != null) _saveImageToDevice(croppedFile.path);
    } catch (e) {
      debugPrint("Crop Image Error: $e");
    }
  }

  Future<void> _saveImageToDevice(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = '${directory.path}/$fileName';
    final File localImage = await File(tempPath).copy(newPath);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', localImage.path);
    if (mounted) setState(() => _profileImage = localImage);
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(leading: const Icon(Icons.photo_library), title: const Text('เลือกจากคลังภาพ'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
              ListTile(leading: const Icon(Icons.photo_camera), title: const Text('ถ่ายภาพใหม่'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // MARK: - Main UI Build Method
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Layer (Watermark)
          _buildBackgroundWatermark(),

          // 2. Foreground Content Layer
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 15),
                  _buildWeatherSection(),
                  const SizedBox(height: 20),
                  _buildScheduleSection(),
                  const SizedBox(height: 20),
                  _buildStatusDots(),
                  const SizedBox(height: 10),
                  _buildHealthSection(),
                  const SizedBox(height: 25),
                  _buildNewsSection(),
                  const SizedBox(height: 25),
                  _buildMenuSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MARK: - Sub-Widget Builders (แยกส่วน UI)
  // ==========================================

  // ส่วนพื้นหลังลายน้ำ
  Widget _buildBackgroundWatermark() {
    return Positioned.fill(
      child: Center(
        child: Image.asset(
          'assets/images/logos/psu_logo.png',
          width: 300,
          fit: BoxFit.contain,
          color: Colors.grey.withOpacity(0.1),
          colorBlendMode: BlendMode.srcIn, // ตัดขอบใสให้เนียน
          errorBuilder: (c, e, s) => const Icon(Icons.school, size: 200, color: Colors.grey),
        ),
      ),
    );
  }

  // ส่วนหัว (วันที่ + โปรไฟล์)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentDate, style: const TextStyle(color: Color(0xFF44474F), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text("สวัสดี สราวุธ", style: TextStyle(color: Color(0xFF1A1C1E), fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Image.asset('assets/images/logos/psu.png', width: 45, height: 45, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 40, color: Colors.grey)),
              const SizedBox(width: 5),
              IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black54, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))),
              GestureDetector(
                onTap: () => _showPickerOptions(context),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]),
                  child: CircleAvatar(radius: 20, backgroundColor: Colors.grey[300], backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null, child: _profileImage == null ? const Icon(Icons.person, color: Colors.white) : null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ส่วนสภาพอากาศ (Glassmorphism)
  Widget _buildWeatherSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: _buildGlassWeatherCard(),
    );
  }

  // ส่วนตารางเรียน
  Widget _buildScheduleSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSectionHeader("Your Schedule", "See All", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleScreen()))),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.none,
          child: Row(
            children: AppData.scheduleData.map((subject) {
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: _buildScheduleCard(subject['title'], subject['time'], subject['location'], subject['badge'], subject['colors'], width: 280),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // จุดสถานะ (Status Dots)
  Widget _buildStatusDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusDot("LMS status"),
          const SizedBox(width: 50),
          _buildStatusDot("SIS status"),
        ],
      ),
    );
  }

  // ส่วน PSU Health
  Widget _buildHealthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: _buildGlassHealthCard(),
    );
  }

  // ส่วนข่าวประชาสัมพันธ์
  Widget _buildNewsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSectionHeader("PSU News", "View all", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewsScreen(onOpenNews: _openNews)))),
        ),
        const SizedBox(height: 10),
        CarouselSlider(
          options: CarouselOptions(height: 160.0, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.9),
          items: AppData.newsData.map((news) {
            return _buildBannerItem(imagePath: news['image'], onTap: () => _openNews(news));
          }).toList(),
        ),
      ],
    );
  }

  // ส่วนเมนูเครื่องมือต่างๆ (Grid Menus)
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildSectionHeader("PSU Tools", "View all", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllToolsScreen(category: "PSU Tools")))),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGlassMenuIcon("SIS", "assets/images/logos/sis.png", onTap: () => _openWebView("ระบบ SIS", "https://sis.psu.ac.th")),
              _buildGlassMenuIcon("Passport", "assets/images/logos/psupassport_logo.png", onTap: () => _openWebView("PSU Passport", "https://passport.psu.ac.th")),
              _buildGlassMenuIcon("LMS2", "assets/images/logos/lms_logo.png", onTap: () => _openWebView("LMS2", "https://lms2.psu.ac.th")),
              _buildGlassMenuIcon("Smart Campus", "assets/images/logos/smartcampus.png", onTap: () => _openWebView("Smart Campus", "https://psu.smart-campus.app")),
            ],
          ),
          const SizedBox(height: 25),
          const Align(alignment: Alignment.centerLeft, child: Text("PSU Online Course", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildGlassMenuIcon("SCB Academy", "assets/images/logos/scb_logo.png", onTap: () => _openWebView("SCB Academy", "https://learning.kaorag.com/general")),
              const SizedBox(width: 25),
              _buildGlassMenuIcon("PSU MOOC", "assets/images/logos/psumooc_logo.png", onTap: () => _openWebView("PSU MOOC", "https://mooc.psu.ac.th")),
            ],
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("PSU Life", "View all", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllToolsScreen(category: "PSU Life")))),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGlassMenuIcon("vcard", "assets/images/logos/vcard_logo.png", onTap: () => _openWebView("VCard", "https://vcard.psu.ac.th")),
              _buildGlassMenuIcon("Internet", "", icon: Icons.wifi, color: Colors.red, onTap: () => _openWebView("PSU WiFi", "https://wifi.psu.ac.th")),
              _buildGlassMenuIcon("Connext", "assets/images/logos/psu_connext_logo.png", onTap: () => _openWebView("PSU Connext", "https://connext.psu.ac.th")),
              _buildGlassMenuIcon("DIIS", "assets/images/logos/dIIs.png", onTap: () => _openWebView("DIIS", "https://diis.psu.ac.th")),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // MARK: - Reusable UI Components
  // ==========================================

  Widget _buildGlassWeatherCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                    child: Icon(_realWeatherData['icon'], size: 30, color: const Color(0xFF0D59F2)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_realWeatherData['temp'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1A1C1E))),
                      Text(_realWeatherData['condition'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_realWeatherData['location'], style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.air, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text("PM ${_realWeatherData['pm25']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassHealthCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthScreen()));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.6)),
              boxShadow: [BoxShadow(color: const Color(0xFF0D59F2).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shield, size: 55, color: Colors.black),
                    Container(width: 7, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                    Container(width: 20, height: 7, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                  ],
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("PSU Health", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 2),
                    Text("วันนี้คุณเดินไปแล้ว 0 ก้าว", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMenuIcon(String label, String imagePath, {IconData? icon, Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65, height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: icon != null
                  ? Icon(icon, color: color, size: 30)
                  : Image.asset(imagePath, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(width: 75, child: Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 11, color: Color(0xFF44474F), fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(String title, String time, String location, String badge, List<Color> gradientColors, {double width = 320}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12))),
              const Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          Row(children: [Icon(Icons.access_time, color: Colors.white70, size: 16), const SizedBox(width: 5), Text(time, style: const TextStyle(color: Colors.white)), const SizedBox(width: 15), Icon(Icons.location_on, color: Colors.white70, size: 16), const SizedBox(width: 5), Text(location, style: const TextStyle(color: Colors.white))]),
        ],
      ),
    );
  }

  Widget _buildBannerItem({required String imagePath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imagePath.startsWith('http')
              ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)))
              : Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(onTap: onTap, child: Text(action, style: const TextStyle(color: Color(0xFF0D59F2), fontWeight: FontWeight.w500, fontSize: 12))),
      ],
    );
  }

  Widget _buildStatusDot(String text) {
    return Row(children: [Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(width: 4), Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))]);
  }
}

// ==========================================
// MARK: - Sub-Screens (Schedule, News, Tools)
// ==========================================

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("Your Schedule"), backgroundColor: const Color(0xFF0D59F2), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Today, 9 Jan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 15),
          ...AppData.scheduleData.map((subject) => Column(children: [_buildClassCard(subject['title'], subject['time'], subject['location'], subject['colors'][0]), const SizedBox(height: 15)])),
          const SizedBox(height: 15),
          const Text("Tomorrow, 10 Jan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 15),
          _buildClassCard("General Physics", "09:00 - 12:00", "ตึก LH301", Colors.purple),
        ],
      ),
    );
  }

  Widget _buildClassCard(String title, String time, String location, Color color) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border(left: BorderSide(color: color, width: 5)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(time, style: const TextStyle(color: Colors.grey)), const SizedBox(width: 20), const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(location, style: const TextStyle(color: Colors.grey))])]));
  }
}

class NewsScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onOpenNews;
  const NewsScreen({super.key, required this.onOpenNews});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("PSU News"), backgroundColor: const Color(0xFF0D59F2), foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: AppData.newsData.length,
        itemBuilder: (context, index) {
          final news = AppData.newsData[index];
          return GestureDetector(
            onTap: () => onOpenNews(news),
            child: Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: news['image'].startsWith('http') ? Image.network(news['image'], height: 160, width: double.infinity, fit: BoxFit.cover) : Image.asset(news['image'], height: 160, width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(news['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Text(news['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 13)), const SizedBox(height: 10), Row(children: [Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]), const SizedBox(width: 5), Text(news['date'], style: TextStyle(color: Colors.grey[400], fontSize: 11))])]))])),
          );
        },
      ),
    );
  }
}

class AllToolsScreen extends StatelessWidget {
  final String category;
  const AllToolsScreen({super.key, required this.category});
  static final List<Map<String, dynamic>> _allMenus = [
    {"label": "SIS", "image": "assets/images/logos/sis.png", "url": "https://sis.psu.ac.th", "type": "PSU Tools"},
    {"label": "Passport", "image": "assets/images/logos/psupassport_logo.png", "url": "https://passport.psu.ac.th", "type": "PSU Tools"},
    {"label": "LMS2", "image": "assets/images/logos/lms_logo.png", "url": "https://lms2.psu.ac.th", "type": "PSU Tools"},
    {"label": "Smart Campus", "image": "assets/images/logos/smartcampus.png", "url": "https://psu.smart-campus.app", "type": "PSU Tools"},
    {"label": "VCard", "image": "assets/images/logos/vcard_logo.png", "url": "", "type": "PSU Life"},
    {"label": "Internet", "icon": Icons.wifi, "color": Colors.red, "url": "", "type": "PSU Life"},
    {"label": "Connext", "image": "assets/images/logos/psu_connext_logo.png", "url": "", "type": "PSU Life"},
    {"label": "DIIS", "image": "assets/images/logos/dIIs.png", "url": "", "type": "PSU Life"},
  ];
  @override
  Widget build(BuildContext context) {
    final filteredMenus = _allMenus.where((menu) => menu['type'] == category).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text(category), backgroundColor: const Color(0xFF0D59F2), foregroundColor: Colors.white),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85),
        itemCount: filteredMenus.length,
        itemBuilder: (context, index) {
          final menu = filteredMenus[index];
          return GestureDetector(
            onTap: () {
              if (menu['url'] != null && menu['url'].toString().isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen(url: menu['url'], title: menu['label'])));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ยังไม่มีลิงก์")));
              }
            },
            child: Column(children: [Expanded(child: Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: Center(child: menu.containsKey('image') ? Image.asset(menu['image'], fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)) : Icon(menu['icon'], color: menu['color'], size: 35)))), const SizedBox(height: 8), Text(menu['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2)]),
          );
        },
      ),
    );
  }
}