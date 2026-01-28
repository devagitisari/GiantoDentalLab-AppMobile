import 'package:flutter/material.dart';
import 'package:team_project/screens/detail_pengajuan.dart';
import 'package:team_project/screens/form_pengajuan_kunjungan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/tahapan_pengajuan.dart';
import 'package:team_project/screens/home_page.dart';

class PengajuanKunjunganListPage extends StatefulWidget {
  final String? uid;
  const PengajuanKunjunganListPage({super.key, this.uid});

  @override
  State<PengajuanKunjunganListPage> createState() =>
      _PengajuanKunjunganListPageState();
}

class _PengajuanKunjunganListPageState
    extends State<PengajuanKunjunganListPage> {
  late final String idPelanggan;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    idPelanggan = widget.uid ?? currentUser?.uid ?? '';
  }

  Stream<QuerySnapshot> getPengajuanStream() {
    return FirebaseFirestore.instance
        .collection('order')
        .where('id_pelanggan', isEqualTo: idPelanggan)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  String formatStatus(String status) {
    switch (status) {
      case "menunggu":
        return "Menunggu Persetujuan";
      case "dibatalkan":
        return "Dibatalkan";
      case "diproses":
        return "diproses";
      case "disetujui":
        return "Disetujui";
      case "ditolak":
        return "Ditolak";
      case "selesai":
        return "Selesai";
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "dibatalkan":
        return Colors.red;
      case "diproses":
        return Colors.blue;
      case "disetujui":
        return Colors.blue;
      case "ditolak":
        return const Color(0xFFFF2626);
      case "selesai":
        return const Color(0xFF43A047);
      default:
        return Colors.black;
    }
  }

  String formatTanggal(Timestamp? t) {
    if (t == null) return "-";
    final dt = t.toDate();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  void showAwesomePopupAutoClose({
    required BuildContext context,
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.check_circle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(icon, color: color, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAwesomePopup({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.check_circle,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool autoClose = true,
    int autoCloseMilliseconds = 1200,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        if (autoClose) {
          Future.delayed(Duration(milliseconds: autoCloseMilliseconds), () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (buttonText != null && onButtonPressed != null)
                      ElevatedButton(
                        onPressed: () {
                          onButtonPressed();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(buttonText),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(icon, color: color, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> showAwesomePopupConfirm({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.cancel,
    Color color = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Tidak",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            "Ya, Batalkan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(icon, color: color, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0C3345),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormPengajuanKunjungan(uid: idPelanggan),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage(uid: idPelanggan)),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7E7E7),
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
                  const Text(
                    'Pengajuan Kunjungan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C3345),
                    ),
                  ),
                ],
              ),
            ),

            // List Pengajuan
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getPengajuanStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0C3345),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada pengajuan',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final nomor =
                          docs.length - i; // nomor urut terbaru di atas
                      final status = formatStatus(data['status']);
                      final tgl = formatTanggal(data['created_at']);
                      final idOrder = docs[i].id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: SizedBox(
                          height: 110,
                          child: Dismissible(
                            key: Key(idOrder),
                            direction: DismissDirection.horizontal,
                            background: data['status'] == 'dibatalkan'
                                ? Container(
                                    color: Colors.transparent,
                                  ) // gantikan null
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Batalkan",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Detail",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              final currentStatus = data['status'];

                              if (direction == DismissDirection.startToEnd) {
                                if (currentStatus == "dibatalkan" ||
                                    currentStatus == "ditolak" ||
                                    currentStatus == "selesai") {
                                  showAwesomePopupAutoClose(
                                    context: context,
                                    title: "Tidak Bisa Dibatalkan",
                                    message:
                                        "Pengajuan ini tidak dapat dibatalkan.",
                                    color: Colors.orange,
                                    icon: Icons.info_outline,
                                  );
                                  return false;
                                }

                                final confirm = await showAwesomePopupConfirm(
                                  context: context,
                                  title: "Batalkan Pengajuan?",
                                  message:
                                      "Apakah kamu yakin ingin membatalkan pengajuan ini?",
                                  icon: Icons.cancel,
                                  color: Colors.red,
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection("order")
                                      .doc(idOrder)
                                      .update({"status": "dibatalkan"});
                                  showAwesomePopupAutoClose(
                                    context: context,
                                    title: "Berhasil",
                                    message: "Pengajuan berhasil dibatalkan.",
                                    color: Colors.green,
                                    icon: Icons.check_circle,
                                  );
                                  return false;
                                }

                                return false;
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailPengajuanKunjunganPage(
                                          uid: idPelanggan,
                                          orderId: idOrder,
                                        ),
                                  ),
                                );
                                return false;
                              }

                              return false;
                            },

                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () async {
                                  final statusDb = data['status'];

                                  if (statusDb == "disetujui" ||
                                      statusDb == "selesai" ||
                                      statusDb == "proses") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TahapanPengajuan(orderId: idOrder),
                                      ),
                                    );
                                  } else if (statusDb == "menunggu") {
                                    showAwesomePopup(
                                      title: "Menunggu",
                                      message:
                                          "Pengajuan kamu sedang menunggu persetujuan admin.",
                                      icon: Icons
                                          .hourglass_top, // ikon sesuai konteks
                                      color: Colors
                                          .orange, // warna sesuai status menunggu
                                      buttonText: "OK",
                                      onButtonPressed: () {
                                        // bisa ditambahkan aksi lain jika perlu
                                        Navigator.pop(
                                          context,
                                        ); // popup akan close saat tombol ditekan
                                      },
                                      autoClose:
                                          false, // biar tidak auto-close, tunggu tombol OK
                                    );
                                  } else if (statusDb == "ditolak") {
                                    final doc = await FirebaseFirestore.instance
                                        .collection("order")
                                        .doc(idOrder)
                                        .get();
                                    final alasan =
                                        doc.data()?['catatan_admin'] ??
                                        "Tidak ada catatan.";
                                    showAwesomePopup(
                                      title: "Pengajuan Ditolak",
                                      message:
                                          "Mohon maaf, pengajuan anda ditolak karena $alasan.\n\nSilahkan ajukan kembali.",
                                      icon: Icons.cancel,
                                      color: Colors.red,
                                      autoClose:
                                          false, // biar popup tetap muncul sampai tombol ditekan
                                      buttonText: "OK",
                                      onButtonPressed: () {
                                        Navigator.pop(
                                          context,
                                        ); // tutup popup saat tombol ditekan
                                      },
                                    );
                                  }
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
                                    borderRadius: BorderRadius.circular(10),
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
                                            "Pengajuan $nomor",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            tgl,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor(data['status']),
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
