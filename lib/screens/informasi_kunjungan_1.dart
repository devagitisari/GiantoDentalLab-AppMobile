import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/form_pengajuan_garansi.dart';
import 'package:team_project/screens/tips_perawatan.dart';

class InformasiKunjungan1 extends StatefulWidget {
  final String idKunjungan;
  final String orderId;
  const InformasiKunjungan1({
    super.key,
    required this.idKunjungan,
    required this.orderId,
  });

  @override
  State<InformasiKunjungan1> createState() => _InformasiKunjungan1State();
}

class _InformasiKunjungan1State extends State<InformasiKunjungan1> {
  Map<String, dynamic>? existingUlasan;
  Map<String, dynamic>? dataPelanggan;
  bool sudahAjukanGaransi = false;
  String? idPelanggan;
  bool isLoading = false;
  int rating = 0;

  final TextEditingController catatanController = TextEditingController();
  final TextEditingController kritikController = TextEditingController();

  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

    void showAwesomePopupAutoClose({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.check_circle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        // Auto close dialog setelah 1.2 detik
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
                    const SizedBox(height: 10),
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

  Future<void> loadData() async {
    try {
      String tanggal = "-";
      String namaLayanan = "-";
      Map<String, dynamic> catatanData = {};
      String? idPelanggan;

      // 1️⃣ Ambil data order
      final orderDoc = await FirebaseFirestore.instance
          .collection("order")
          .doc(widget.orderId)
          .get();

      if (!orderDoc.exists) {
        if (!mounted) return;
        setState(() => loading = false);
        return;
      }

      final orderData = orderDoc.data()!;
      idPelanggan = orderData['id_pelanggan'] as String?;
      final String? idLayanan = orderData['id_layanan'] as String?;

      // 2️⃣ Ambil id_jadwal dari collection "jadwal" sesuai id_order
      String? idJadwal;
      final jadwalQuery = await FirebaseFirestore.instance
          .collection("jadwal")
          .where("id_order", isEqualTo: widget.orderId)
          .limit(1)
          .get();

      if (jadwalQuery.docs.isNotEmpty) {
        idJadwal = jadwalQuery.docs.first.data()['id_jadwal'] as String?;
      }

      // 3️⃣ Ambil data kunjungan sesuai id_jadwal
      String? idKunjungan;
      if (idJadwal != null && idJadwal.isNotEmpty) {
        final kunjunganQuery = await FirebaseFirestore.instance
            .collection("kunjungan")
            .where("id_jadwal", isEqualTo: idJadwal)
            .limit(1)
            .get();

        if (kunjunganQuery.docs.isNotEmpty) {
          final kunjungan = kunjunganQuery.docs.first.data();
          idKunjungan = kunjungan['id_kunjungan'] as String?;
          final jk = kunjungan['jadwal_kunjungan'];
          if (jk is Map) tanggal = jk['tanggal'] ?? "-";
        }
      }

      // 4️⃣ Ambil catatan kunjungan sesuai id_kunjungan
      if (idKunjungan != null && idKunjungan.isNotEmpty) {
        final catatanSnapshot = await FirebaseFirestore.instance
            .collection("catatan_kunjungan")
            .where("id_kunjungan", isEqualTo: idKunjungan)
            .limit(1)
            .get();

        if (catatanSnapshot.docs.isNotEmpty) {
          catatanData = catatanSnapshot.docs.first.data();
        }
      }

      // 5️⃣ Ambil data pelanggan
      if (idPelanggan != null && idPelanggan.isNotEmpty) {
        final pelangganDoc = await FirebaseFirestore.instance
            .collection('pelanggan')
            .doc(idPelanggan)
            .get();
        if (pelangganDoc.exists) dataPelanggan = pelangganDoc.data();
      }

      // 6️⃣ Ambil nama layanan
      if (idLayanan != null && idLayanan.isNotEmpty) {
        final layananQuery = await FirebaseFirestore.instance
            .collection("layanan")
            .where("id_layanan", isEqualTo: idLayanan)
            .limit(1)
            .get();

        if (layananQuery.docs.isNotEmpty) {
          final docData = layananQuery.docs.first.data();
          namaLayanan = docData['nama_layanan'] ?? namaLayanan;
        }
      }

      // 7️⃣ Ambil ulasan
      final ulasanSnapshot = await FirebaseFirestore.instance
          .collection("ulasan")
          .where("id_order", isEqualTo: widget.orderId)
          .limit(1)
          .get();

      if (ulasanSnapshot.docs.isNotEmpty) {
        existingUlasan = ulasanSnapshot.docs.first.data();
        rating = existingUlasan?['rating'] ?? 0;
        catatanController.text = existingUlasan?['catatan_kepuasan'] ?? "";
        kritikController.text = existingUlasan?['kritik_saran'] ?? "";
      }

      // 8️⃣ Ambil status garansi
      final garansiSnapshot = await FirebaseFirestore.instance
          .collection('garansi')
          .where('id_order', isEqualTo: widget.orderId)
          .limit(1)
          .get();

      sudahAjukanGaransi = garansiSnapshot.docs.isNotEmpty;

      // 9️⃣ Update state
      if (!mounted) return;
      setState(() {
        data = {
          "tanggal": tanggal,
          "id_bahan": catatanData['id_bahan'] ?? "-",
          "jumlah_gigi": catatanData['jumlah_gigi'] ?? "0",
          "warna_gigi": catatanData['warna_gigi'] ?? "-",
          "total_harga": catatanData['total_harga'] ?? 0,
          "terbayar": catatanData['terbayar'] ?? 0,
          "sisa_pembayaran": catatanData['sisa_pembayaran'] ?? 0,
          "status_pembayaran": catatanData['status_pembayaran'] ?? "-",
          "nama_layanan": namaLayanan,
        };
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      print("ERROR loadData: $e");
    }
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

  InputDecoration _inputDecorationUlasan(
    String label, {
    String? hint,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Color(0xFF0C3345),
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        fontFamily: 'Poppins',
        color: Color(0xFF999999),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD0D0D0)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD0D0D0)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0C3345)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      filled: true,
      fillColor: readOnly ? Colors.grey[200] : Colors.white,
    );
  }

  Future<void> submitUlasan() async {
    if (rating == 0) {
      showAwesomePopupAutoClose(
        title: "Perhatian",
        message: "Pilih rating terlebih dahulu",
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final docRef = await FirebaseFirestore.instance.collection("ulasan").add({
        "id_order": widget.orderId,
        "rating": rating,
        "catatan_kepuasan": catatanController.text.trim(),
        "kritik_saran": kritikController.text.trim(),
        "tanggal": DateTime.now(),
      });

      await docRef.update({"id_ulasan": docRef.id});

      showAwesomePopupAutoClose(
        title: "Berhasil",
        message: "Ulasan berhasil dikirim!",
        color: Colors.green,
        icon: Icons.check_circle_rounded,
      );
      await loadData();
    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Gagal mengirim ulasan: $e",
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0C3345),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (data == null) return const Center(child: Text("Data tidak ditemukan"));

    // Cek apakah tombol action boleh ditampilkan
    bool showActionButtons = false;
    final namaLayanan = (data!["nama_layanan"] ?? "").toString().toLowerCase();
    if (namaLayanan.contains("repair") ||
        namaLayanan.contains("retainer")) {
      showActionButtons = true;
    }



    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + back button
              Row(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Informasi Kunjungan",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C3345),
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Berikut ini adalah informasi kunjungan Anda.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),

              // Card utama
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          data!["tanggal"],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Layanan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          data!["nama_layanan"] ?? "-",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Keterangan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Jumlah : ${data!["jumlah_gigi"]} Gigi\n"
                          "Warna  : ${data!["warna_gigi"]}\n"
                          "Bahan  : Akrilik",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Total Harga dan Status Pembayaran
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Harga",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "Rp ${data!["total_harga"]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Uang Muka",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "Rp ${data!["terbayar"]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sisa Pembayaran",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "Rp ${data!["sisa_pembayaran"]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Status Pembayaran",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      data!["status_pembayaran"]
                                              .toString()
                                              .toLowerCase() ==
                                          "lunas"
                                      ? Colors.green[300]
                                      : Colors.orange[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${data!["status_pembayaran"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Hanya tampilkan tombol jika nama_layanan Repair/Retainer
                          if (showActionButtons) ...[
                            // Tombol Garansi
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (sudahAjukanGaransi) {
                                    showAwesomePopup(
                                      title: "Pengajuan Garansi",
                                      message:
                                          "Anda sudah mengajukan kunjungan garansi.\nSilakan menunggu proses dari admin.",
                                      color: Colors.orange,
                                      icon: Icons.info,
                                      buttonText: "OK",
                                      onButtonPressed: () {},
                                      autoClose: false,
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FormPengajuanGaransi(
                                          idOrder: widget.orderId,
                                          idPelanggan: idPelanggan!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C3345),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  sudahAjukanGaransi
                                      ? "Garansi Sudah Diajukan"
                                      : "Ajukan Kunjungan Garansi",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Tombol Tips Perawatan
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TipsPerawatanPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFF0C3345),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Tips Perawatan",
                                  style: TextStyle(
                                    color: Color(0xFF0C3345),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // UI Ulasan
                            const Text(
                              "Berikan Ulasan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                (i) => GestureDetector(
                                  onTap: existingUlasan != null
                                      ? null
                                      : () => setState(() => rating = i + 1),
                                  child: Icon(
                                    Icons.star,
                                    size: 40,
                                    color: rating >= i + 1
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: catatanController,
                              maxLines: 3,
                              readOnly: existingUlasan != null,
                              decoration: _inputDecorationUlasan(
                                "Catatan Kepuasan Pelanggan",
                                hint: "Tulis catatan kepuasan...",
                                readOnly: existingUlasan != null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: kritikController,
                              maxLines: 3,
                              readOnly: existingUlasan != null,
                              decoration: _inputDecorationUlasan(
                                "Kritik & Saran",
                                hint: "Tulis kritik dan saran...",
                                readOnly: existingUlasan != null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (existingUlasan == null)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : submitUlasan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0C3345),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Kirim Ulasan",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ],
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
