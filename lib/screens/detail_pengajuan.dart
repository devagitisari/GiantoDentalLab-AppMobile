import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/home_page.dart';

class DetailPengajuanKunjunganPage extends StatelessWidget {
  final String uid;
  final String orderId;

  const DetailPengajuanKunjunganPage({
    super.key,
    required this.uid,
    required this.orderId,
  });

   Future<bool?> showAwesomePopupConfirm({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.location_off_rounded,
    Color color = Colors.orange,
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
                        // BATAL
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // AKTIFKAN GPS
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            "Iya",
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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
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


  Future<Map<String, dynamic>> _getOrderWithUser() async {
    final firestore = FirebaseFirestore.instance;

    // 1. ambil data order
    final orderSnap = await firestore.collection('order').doc(orderId).get();
    if (!orderSnap.exists) return {};
    final orderData = orderSnap.data()!;

    // 2. ambil id_pelanggan
    final idPelanggan = orderData['id_pelanggan'] as String?;

    String nama = '-';
    String telepon = '-';

    // 3. ambil data pelanggan
    if (idPelanggan != null) {
      final userSnap = await firestore
          .collection('pelanggan')
          .doc(idPelanggan)
          .get();
      if (userSnap.exists) {
        final userData = userSnap.data()!;
        nama = userData['nama_pelanggan'] ?? '-';
        telepon = userData['no_telp'] ?? '-';
      }
    }

    return {...orderData, 'nama': nama, 'telepon': telepon};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage(uid: uid)),
                    ),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7E7E7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                      "Detail Pengajuan",
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

            // Body content
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getOrderWithUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                      color: Color(0xFF0C3345),
                      strokeWidth: 3,));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Data pengajuan tidak ditemukan'),
                    );
                  }

                  final data = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Nama', data['nama']),
                              _infoRow('No Telepon', data['telepon']),
                              const SizedBox(height: 10),
                              const Text(
                                'Foto',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF0C3345),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7E7E7),
                                  borderRadius: BorderRadius.circular(15),
                                  image:
                                      (data['foto'] != null &&
                                          data['foto'] != '')
                                      ? DecorationImage(
                                          image: NetworkImage(data['foto']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child:
                                    (data['foto'] == null || data['foto'] == '')
                                    ? const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _infoRow(
                                'Pemakaian Jasa',
                                data['pemakaian_jasa'],
                              ),
                              _infoRow('Catatan', data['keluhan']),

                              // Tampilkan info dibatalkan dengan tampilan menarik
                              // STATUS PENGAJUAN (SELESAI / DITOLAK / DIBATALKAN)
                            if (data['status'] == 'selesai' ||
                                data['status'] == 'ditolak' ||
                                data['status'] == 'dibatalkan' ||
                                data['status'] == 'menunggu')
                              _statusPengajuanBox(data['status']),

                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (data['status'] != 'dibatalkan' &&
                            data['status'] != 'ditolak' && data['status'] != 'selesai')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                bool? confirm = await showAwesomePopupConfirm(
                                  context: context,
                                  title: 'Batalkan Kunjungan?',
                                  message: 'Apakah kamu yakin ingin membatalkan kunjungan ini?',
                                  icon: Icons.cancel,
                                  color: Colors.red,
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('order')
                                      .doc(orderId)
                                      .update({'status': 'dibatalkan'});
                                  showAwesomePopupAutoClose(
                                    context: context,
                                    title: 'Dibatalkan',
                                    message: 'Pengajuan kunjungan berhasil dibatalkan',
                                    icon: Icons.cancel,
                                    color: Colors.red,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C3345),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Batalkan Kunjungan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(120),
          1: FixedColumnWidth(8),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0C3345),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0C3345),
                ),
              ),
              Text(
                value ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0C3345),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPengajuanBox(String status) {
    late String title;
    late String message;
    late IconData icon;
    late Color color;

    switch (status) {
      case 'selesai':
        title = 'Pengajuan Selesai';
        message = 'Pengajuan kunjungan telah selesai. ';
        icon = Icons.check_circle;
        color = Colors.green;
        break;

      case 'ditolak':
        title = 'Pengajuan Ditolak';
        message = 'Pengajuan kunjungan ditolak oleh admin.';
        icon = Icons.cancel;
        color = Colors.red;
        break;

      case 'dibatalkan':
        title = 'Pengajuan Dibatalkan';
        message = 'Pengajuan kunjungan telah dibatalkan.';
        icon = Icons.remove_circle;
        color = Colors.red;
        break;

      case 'menunggu':
        title = 'Pengajuan sedang diproses';
        message = 'Pengajuan sedang diproses, Harap tunggu sampai disetujui.';
        icon = Icons.remove_circle;
        color = Colors.grey;
        break;

      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
