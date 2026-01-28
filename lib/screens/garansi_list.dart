import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/detail_garansi.dart';

class PengajuanGaransiListPage extends StatefulWidget {
  final String? uid;
  const PengajuanGaransiListPage({super.key, this.uid});

  @override
  State<PengajuanGaransiListPage> createState() =>
      _PengajuanGaransiListPageState();
}

class _PengajuanGaransiListPageState extends State<PengajuanGaransiListPage> {
  late final String idPelanggan;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    idPelanggan = widget.uid ?? currentUser?.uid ?? '';
  }

  Stream<List<Map<String, dynamic>>> getPengajuanGaransi() async* {
    final orderSnapshot = await FirebaseFirestore.instance
        .collection('order')
        .where('id_pelanggan', isEqualTo: idPelanggan)
        .orderBy('created_at', descending: true)
        .get();

    List<Map<String, dynamic>> list = [];

    for (var orderDoc in orderSnapshot.docs) {
      final orderData = orderDoc.data();
      final idOrder = orderDoc.id;

      final garansiSnapshot = await FirebaseFirestore.instance
          .collection('garansi')
          .where('id_order', isEqualTo: idOrder)
          .get();

      if (garansiSnapshot.docs.isNotEmpty) {
        for (var gDoc in garansiSnapshot.docs) {
          final gData = gDoc.data();
          list.add({
            "id_order": idOrder,
            "orderData": orderData,
            "id_garansi": gDoc.id,
            "status": gData['status'] ?? "-",
            "updated_at": gData['updated_at'] ?? null,
          });
        }
      }
    }

    list.sort((a, b) {
      final aTime = a['updated_at'] as Timestamp?;
      final bTime = b['updated_at'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    yield list;
  }

  String formatStatus(String? status) {
    switch (status?.toLowerCase() ?? "") {
      case "menunggu":
        return "Menunggu Persetujuan";
      case "dijadwalkan":
        return "Dijadwalkan";
      case "selesai":
        return "Selesai";
      default:
        return "-";
    }
  }

  Color statusColor(String? status) {
    switch (status?.toLowerCase() ?? "") {
      case "dijadwalkan":
        return Colors.orange;
      case "disetujui":
        return Colors.green;
      case "selesai":
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  String formatTanggal(Timestamp? t) {
    if (t == null) return "-";
    final dt = t.toDate();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: getPengajuanGaransi(),
          builder: (context, snapshot) {
            // Tentukan apakah sedang loading
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            final docs = snapshot.data ?? [];

            return Stack(
              children: [
                // Konten utama: header + list
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 48,
                              height: 48,
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
                          const Expanded(
                            child: Text(
                              'Pengajuan Garansi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0C3345),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: docs.isEmpty
                          ? Center(
                              child: Text(
                                isLoading ? "" : "Tidak ada pengajuan garansi",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              itemCount: docs.length,
                              itemBuilder: (context, i) {
                                final data = docs[i];
                                final nomor = docs.length - i;
                                final status = data['status'] ?? "-";
                                final tgl = formatTanggal(data['updated_at']);
                                final idGaransi = data['id_garansi'];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: SizedBox(
                                    height: 110,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailGaransiPage(
                                                idGaransi: idGaransi,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(18),
                                          height: 110,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF0C3345),
                                                Color(0xFF1D7EAB),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Pengajuan Garansi $nomor",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    tgl,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  formatStatus(status),
                                                  style: TextStyle(
                                                    color: statusColor(status),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.white, // semi-transparent
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0C3345),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
