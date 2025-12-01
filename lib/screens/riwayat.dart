import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            // ===== HEADER TENGAH =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // TITLE DI TENGAH
                  const Center(
                    child: Text(
                      "Riwayat Layanan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // BACK BUTTON DI KIRI
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 229, 229, 229),
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            // ===== LIST KONTEN =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  RiwayatCard(
                    status: "Pengajuan Tidak Disetujui",
                    statusColor: Colors.red,
                    tanggal: "15/09/2025",
                    judulLayanan: "Pembuatan Gigi Tiruan baru",
                    harga: "Rp 1.000.000",
                  ),
                  SizedBox(height: 18),
                  RiwayatCard(
                    status: "",
                    statusColor: Colors.transparent,
                    tanggal: "20/09/2025",
                    judulLayanan: "Pembuatan Gigi Tiruan baru",
                    harga: "Rp 1.000.000",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// ====================== CARD RIWAYAT LAYANAN ==========================
// ======================================================================

class RiwayatCard extends StatefulWidget {
  final String status;
  final Color statusColor;
  final String tanggal;
  final String judulLayanan;
  final String harga;

  const RiwayatCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.tanggal,
    required this.judulLayanan,
    required this.harga,
  });

  @override
  State<RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<RiwayatCard> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.statusColor,
                ),
              ),
              Text(
                widget.tanggal,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Layanan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(widget.judulLayanan),

          const SizedBox(height: 8),

          const Text(
            "Total Harga",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(widget.harga),

          const SizedBox(height: 10),

          const Text(
            "Ulasan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),

          // ★ RATING BINTANG
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() => rating = index + 1);
                },
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          // ===== TOMBOL LIHAT DETAIL =====
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // AKSI SAAT DIKLIK
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menuju Detail...")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F0FF),
                foregroundColor: const Color(0xFF2D5BD0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Lihat Detail"),
            ),
          )
        ],
      ),
    );
  }
}
