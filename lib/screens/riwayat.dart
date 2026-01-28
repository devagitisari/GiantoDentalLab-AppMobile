import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// =======================================================
/// ===================== RIWAYAT PAGE =====================
/// =======================================================
class RiwayatPage extends StatefulWidget {
  final String uidPelanggan;
  const RiwayatPage({super.key, required this.uidPelanggan});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
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
                          "Riwayat Layanan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0C3345),
                          ),
                        ),
                      ),
                      const SizedBox(width: 64),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // LIST RIWAYAT
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('order')
                        .where('id_pelanggan', isEqualTo: widget.uidPelanggan)
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      final orders = snapshot.data!.docs;
                      return FutureBuilder<List<Map<String, dynamic>?>>(
                        future: Future.wait(
                          orders.map((order) => _buildRiwayat(order)),
                        ),
                        builder: (context, snap) {
                          if (!snap.hasData) return Container();
                          final dataList = snap.data!
                              .where((e) => e != null)
                              .cast<Map<String, dynamic>>()
                              .toList();
                          if (dataList.isEmpty) return Center(child: Text("Belum ada riwayat layanan"));
                          return ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: dataList.length,
                            itemBuilder: (context, index) {
                              final data = dataList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ModernRiwayatCard(
                                  status: data['statusText'],
                                  statusColor: data['statusColor'],
                                  tanggal: data['tanggal'],
                                  judulLayanan: data['namaLayanan'],
                                  harga: data['harga'],
                                  rating: data['rating'],
                                  isCompleted: data['isCompleted'],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _buildRiwayat(QueryDocumentSnapshot order) async {
    // simulasi loading

    final data = order.data() as Map<String, dynamic>;
    final status = data['status'];
    if (status == 'menunggu') return null;

    String namaLayanan = 'Belum Ditentukan';
    final idLayanan = data['id_layanan'];
    if (idLayanan != null) {
      final snap = await FirebaseFirestore.instance
          .collection('layanan')
          .where('id_layanan', isEqualTo: idLayanan)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) namaLayanan = snap.docs.first['nama_layanan'] ?? '-';
    }

    String tanggal = '-';
    final createdAt = data['created_at'];
    if (createdAt is Timestamp) {
      tanggal = DateFormat('dd/MM/yyyy').format(createdAt.toDate());
    }

    String idKunjungan = '';
    int harga = 0;
    final jadwalSnap = await FirebaseFirestore.instance
        .collection('jadwal')
        .where('id_order', isEqualTo: order.id)
        .limit(1)
        .get();
    if (jadwalSnap.docs.isNotEmpty) {
      final kunjunganSnap = await FirebaseFirestore.instance
          .collection('kunjungan')
          .where('id_jadwal', isEqualTo: jadwalSnap.docs.first.id)
          .limit(1)
          .get();
      if (kunjunganSnap.docs.isNotEmpty) {
        idKunjungan = kunjunganSnap.docs.first.id;
        final catatanSnap = await FirebaseFirestore.instance
            .collection('catatan_kunjungan')
            .where('id_kunjungan', isEqualTo: idKunjungan)
            .limit(1)
            .get();
        if (catatanSnap.docs.isNotEmpty) harga = catatanSnap.docs.first['total_harga'] ?? 0;
      }
    }

    int rating = 0;
    final ulasanSnap = await FirebaseFirestore.instance
        .collection('ulasan')
        .where('id_order', isEqualTo: order.id)
        .limit(1)
        .get();
    if (ulasanSnap.docs.isNotEmpty) rating = (ulasanSnap.docs.first['rating'] ?? 0).clamp(0, 5);

    Color statusColor = Colors.orange;
    String statusText = 'Sedang Berlangsung';
    if (status == 'selesai') {
      statusText = 'Pengajuan Selesai';
      statusColor = Colors.green;
    } else if (status == 'ditolak') {
      statusText = 'Pengajuan Ditolak';
      statusColor = Colors.red;
    } else if (status == 'dibatalkan') {
      statusText = 'Pengajuan Dibatalkan';
      statusColor = Colors.red;
    }

    return {
      'idOrder': order.id,
      'namaLayanan': namaLayanan,
      'tanggal': tanggal,
      'harga': harga,
      'rating': rating,
      'statusText': statusText,
      'statusColor': statusColor,
      'idKunjungan': idKunjungan,
      'isCompleted': status == 'selesai' || status == 'ditolak' || status == 'dibatalkan',
    };
  }
}


/// =======================================================
/// ===================== RIWAYAT CARD =====================
/// =======================================================
class ModernRiwayatCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String tanggal;
  final String judulLayanan;
  final int harga;
  final int rating;
  final bool isCompleted;

  const ModernRiwayatCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.tanggal,
    required this.judulLayanan,
    required this.harga,
    required this.rating,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  tanggal,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              judulLayanan,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C3345),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "Total Harga: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(harga)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  color: i < rating ? Colors.amber : Colors.grey.shade300,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
