import 'package:flutter/material.dart';
import 'notification_detail_screen.dart'; // 🔥 อย่าลืมสร้างไฟล์ในข้อ 2

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลแจ้งเตือนที่ดึงมาจากภาพที่คุณส่งมา
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "🔥 มีไอเดียเจ๋งๆ อย่าเก็บไว้คนเดียว! 💡 จุดฝัน สร้างของจริง!",
        "desc": "โครงการ PSU Young Entrepreneur ปั้นนักศึกษาสู่ผู้ประกอบการนวัตกรรม พร้อมพาคุณจาก 'นักศึกษา' สู่ 'เจ้าของธุรกิจรุ่นใหม่'",
        "time": "19 Dec 2025",
        "views": "448",
        "fullDetails": "เรียนรู้จริงจากผู้ประกอบการตัวจริง ลงมือทำจริงกับทีมที่ปรึกษา และต่อยอดไอเดียให้เกิดเป็นธุรกิจได้จริง...\n\nTimeline โครงการ:\n- เปิดรับสมัคร: วันนี้ - 26 ธ.ค. 68\n- กิจกรรม Boot Camp: 10-11 ม.ค. 69",
        "image": "assets/images/banner.jpg" 
      },
      // สามารถเพิ่มรายการอื่นๆ ต่อได้ตรงนี้
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("การแจ้งเตือน"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFEDF2FF),
              child: Icon(Icons.campaign, color: Color(0xFF0D59F2)),
            ),
            title: Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['desc'], maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // ✅ เมื่อกดแล้วจะส่งข้อมูล 'item' ไปที่หน้ารายละเอียด
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailScreen(data: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}