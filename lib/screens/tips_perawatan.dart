import 'package:flutter/material.dart';

class TipsPerawatanPage extends StatelessWidget {
  const TipsPerawatanPage({super.key});

  final List<Map<String, dynamic>> tips = const [
    {
      "icon": Icons.water,
      "text": "Cuci gigi tiruan setelah makan dengan air mengalir untuk menghilangkan sisa makanan."
    },
    {
      "icon": Icons.brush,
      "text": "Gunakan sikat khusus dan sabun ringan atau pasta gigi khusus, bukan pasta gigi biasa karena dapat merusak permukaan gigi tiruan."
    },
    {
      "icon": Icons.nights_stay,
      "text": "Saat tidur, rendam gigi tiruan dalam air bersih atau larutan pembersih khusus agar tidak kering dan berubah bentuk."
    },
    {
      "icon": Icons.warning,
      "text": "Jangan gunakan air panas, pemutih, atau alkohol untuk membersihkan."
    },
    {
      "icon": Icons.no_food,
      "text": "Hindari menggigit makanan yang keras atau lengket seperti dodol dan tulang."
    },
    {
      "icon": Icons.handshake,
      "text": "Pasang dan lepas dengan hati-hati, jangan dipaksa."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER BACK DAN JUDUL
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7E7E7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0C3345),
                        size: 28
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Tips Perawatan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C3345),
                      ),
                    ),
                  ),
                  const SizedBox(width: 64), // placeholder
                ],
              ),
              const SizedBox(height: 30),

              // List Tips
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F0FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                tip["icon"],
                                color: const Color(0xFF0C3345),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip["text"],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),

              // Tips khusus Gianto Dental Lab dengan warning
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.orange[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "Jika terasa longgar atau tidak nyaman, segera konsultasi dengan ",
                                ),
                                TextSpan(
                                  text: "Gianto Dental Lab",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ", jangan coba perbaiki sendiri atau dengan ahli gigi lain.",
                                ),
                              ],
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
