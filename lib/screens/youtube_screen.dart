import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const YouTubeScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<YouTubeScreen> createState() => _YouTubeScreenState();
}

class _YouTubeScreenState extends State<YouTubeScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF0D59F2),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF0D59F2),
          handleColor: Colors.amberAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // พื้นหลังสีเทาอ่อน ดูสะอาด
          appBar: AppBar(
            title: const Text("รายละเอียดกิจกรรม"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Column(
            children: [
              // --- 1. ส่วนวิดีโอ (ติดขอบบน) ---
              Container(
                color: Colors.black,
                child: player,
              ),

              // --- 2. ส่วนเนื้อหา (Scroll ได้) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ส่วนหัวข้อและเนื้อหาหลัก
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                "News",
                                style: TextStyle(color: Color(0xFF0D59F2), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // หัวข้อใหญ่
                            const Text(
                              "🔥 มีไอเดียเจ๋งๆ อย่าเก็บไว้คนเดียว! 💡 จุดฝัน สร้างของจริง!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1C1E),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // วันที่และยอดวิว
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                const SizedBox(width: 5),
                                const Text("19 Dec 2025", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const Spacer(),
                                const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 5),
                                const Text("448 views", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Divider(),
                            const SizedBox(height: 15),

                            // เนื้อหาเกริ่นนำ
                            const Text(
                              "จาก \"ไอเดีย\" สู่ \"ธุรกิจนวัตกรรม\" มาปั้นให้เป็นธุรกิจกับ PSU Young Entrepreneur ทุกธุรกิจยิ่งใหญ่... เริ่มจากไอเดียเล็กๆ\n\n"
                              "🚀 ถ้าคุณมีฝัน อยากสร้างนวัตกรรม หรืออยากเริ่มธุรกิจของตัวเอง นี่คือ \"ก้าวแรก\" ที่จะเปลี่ยนอนาคตของคุณ\n\n"
                              "✨ ได้เรียนรู้จากเมนเทอร์สายสตาร์ทอัพ\n"
                              "✨ สมัครในรูปแบบเดี่ยว และทีม 3-5 คน",
                              style: TextStyle(fontSize: 15, color: Color(0xFF44474F), height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 10),

                      // --- 3. ส่วน Timeline (Design เป็น Card) ---
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📅 Timeline โครงการ",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D59F2)),
                            ),
                            const SizedBox(height: 15),
                            _buildTimelineItem("วันนี้ - 26 ธ.ค. 68", "เปิดรับสมัคร (จำนวนจำกัด!)"),
                            _buildTimelineItem("29 ธ.ค. 68", "ประกาศรายชื่อผ่านกลุ่มไลน์"),
                            _buildTimelineItem("10-11 ม.ค. 69", "กิจกรรม Boot Camp ณ ม.อ.หาดใหญ่"),
                            _buildTimelineItem("8 ก.พ. 69", "Fast Track เข้าร่วม Pitching \nStartup Thailand League 2569", isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --- 4. ส่วนรางวัล (Highlight) ---
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)], // สีทองอ่อนๆ
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("ชิงเงินรางวัลรวมมูลค่า", style: TextStyle(fontSize: 14, color: Colors.black87)),
                                    Text("12,000 บาท", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFB00020))),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.black12),
                            const SizedBox(height: 10),
                            Row(
                              children: const [
                                Icon(Icons.verified, color: Colors.green),
                                SizedBox(width: 10),
                                Expanded(child: Text("รับเกียรติบัตร พร้อมทรานสคริปกิจกรรม (ประเภทเสริมสมรรถนะฯ 12 ชั่วโมง)", style: TextStyle(fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 5. ส่วน Contact (ด้านล่างสุด) ---
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("สอบถามเพิ่มเติม", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            _buildContactRow(Icons.phone, "061-5152559 (พลอย)"),
                            _buildContactRow(Icons.facebook, "facebook.com/psuseda"),
                            _buildContactRow(Icons.chat, "Line id: @pseda"),
                            
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  // ใส่ action สมัคร
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D59F2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text("สมัครเข้าร่วมกิจกรรม", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget สำหรับสร้าง Timeline แต่ละบรรทัด
  Widget _buildTimelineItem(String date, String desc, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(color: Color(0xFF0D59F2), shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // Widget สำหรับ Contact
  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}