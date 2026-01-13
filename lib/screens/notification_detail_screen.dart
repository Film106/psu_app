import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotificationDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดกิจกรรม"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนภาพ (อ้างอิงจาก Screenshot ที่ส่งมา)
            Image.asset(
              data['image'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("News", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(data['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(data['time'], style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.visibility, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(data['views'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(data['fullDetails'], style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 30),
                  // ปุ่มปิด/รับทราบ
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D59F2)),
                      child: const Text("ตกลง", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}