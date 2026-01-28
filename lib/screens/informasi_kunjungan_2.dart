import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/tips_perawatan.dart';
import 'package:team_project/screens/form_pengajuan_garansi.dart';

class InformasiKunjungan2 extends StatefulWidget {
  final String idKunjungan;
  final String orderId;
  const InformasiKunjungan2({
    super.key,
    required this.idKunjungan,
    required this.orderId,
  });

  @override
  State<InformasiKunjungan2> createState() => _InformasiKunjungan2State();
}

class _InformasiKunjungan2State extends State<InformasiKunjungan2> {
  Map<String, dynamic>? existingUlasan;
  Map<String, dynamic>? data;
  Map<String, dynamic>? dataPelanggan;
  bool loading = true;

  int rating = 0;
  bool isLoading = false;
  String? idPelanggan;

  bool sudahAjukanGaransi = false;

  final TextEditingController catatanController = TextEditingController();
  final TextEditingController kritikController = TextEditingController();

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

  Future<void> loadData() async {
    try {
      String tanggal = "-";
      String namaLayanan = "-"; // default

      // Ambil data kunjungan
      final kunjunganDoc = await FirebaseFirestore.instance
          .collection("kunjungan")
          .doc(widget.idKunjungan)
          .get();

      if (kunjunganDoc.exists) {
        final kunjunganData = kunjunganDoc.data();
        final jk = kunjunganData?['jadwal_kunjungan'];

        if (jk is Map) {
          tanggal = jk['tanggal'] ?? "-";
        } else if (jk is String) {
          tanggal = jk;
        }
      }

      // Ambil id_layanan dari order
      String? idLayanan;
      final orderDoc = await FirebaseFirestore.instance
          .collection("order")
          .doc(widget.orderId)
          .get();

      final orderData = orderDoc.data()!;
      idPelanggan = orderData['id_pelanggan'] ?? "";

      // 2️⃣ Ambil data pelanggan
      final pelangganDoc = await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(idPelanggan)
          .get();

      if (pelangganDoc.exists) {
        dataPelanggan = pelangganDoc.data();
      }

      if (orderDoc.exists) {
        final orderData = orderDoc.data();
        idLayanan = orderData?['id_layanan'] as String?;
      }

      // Ambil nama layanan dari collection "layanan" sesuai id_layanan
      if (idLayanan != null && idLayanan.isNotEmpty) {
        final layananQuery = await FirebaseFirestore.instance
            .collection("layanan")
            .where("id_layanan", isEqualTo: idLayanan)
            .limit(1)
            .get();

        if (layananQuery.docs.isNotEmpty) {
          final docData =
              layananQuery.docs.first.data() as Map<String, dynamic>?;
          if (docData != null) {
            namaLayanan = docData['nama_layanan'] ?? namaLayanan;
          }
        }
      }

      // Ambil ulasan
      final ulasanSnapshot = await FirebaseFirestore.instance
          .collection("ulasan")
          .where("id_order", isEqualTo: widget.orderId)
          .limit(1)
          .get();

      if (ulasanSnapshot.docs.isNotEmpty) {
        existingUlasan = ulasanSnapshot.docs.first.data();
        rating = existingUlasan!['rating'] ?? 0;
        catatanController.text = existingUlasan!['catatan_kepuasan'] ?? "";
        kritikController.text = existingUlasan!['kritik_saran'] ?? "";
      }

      // Ambil catatan kunjungan
      final catatanSnapshot = await FirebaseFirestore.instance
        .collection("catatan_kunjungan")
        .where("id_kunjungan", isEqualTo: widget.idKunjungan) // filter kunjungan tertentu
        .where("aktivitas", isEqualTo: "Kunjungan 2") // filter kunjungan 2
        .limit(1)
        .get();

      Map<String, dynamic> catatanData = {};
      if (catatanSnapshot.docs.isNotEmpty) {
        catatanData = catatanSnapshot.docs.first.data();
      }
      
      final garansiSnapshot = await FirebaseFirestore.instance
          .collection('garansi')
          .where('id_order', isEqualTo: widget.orderId)
          .limit(1)
          .get();

      if (garansiSnapshot.docs.isNotEmpty) {
        sudahAjukanGaransi = true;
      }
      
      setState(() {
        data = {
          "tanggal": tanggal,
          "jumlah_gigi": catatanData['jumlah_gigi']?.toString() ?? "0",
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
      if (mounted) {
        setState(() => loading = false);
      }
    }
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

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: existingUlasan != null
          ? null
          : () => setState(() => rating = index),
      child: Icon(
        Icons.star,
        size: 40,
        color: (rating >= index) ? Colors.amber : Colors.grey,
      ),
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white, // biar tidak hitam
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0C3345),
            strokeWidth: 3, // ganti dengan warna yang kamu mau
          ),
        ),
      );
    }

    if (data == null) return const Center(child: Text("Data tidak ditemukan"));

    bool isUlasanSubmitted = existingUlasan != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                  const Expanded(
                    child: Text(
                      "Informasi Kunjungan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C3345),
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),

              // Card Utama
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(data!["tanggal"]),
                    ),
                    const SizedBox(height: 10),
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
                    const Text("Keterangan"),
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
                        "Jumlah : ${data!["jumlah_gigi"]} Gigi\nWarna  : ${data!["warna_gigi"]}\nBahan  : Akrilik",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Harga"),
                        Text("Rp ${data!["total_harga"]}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Uang Muka"),
                        Text("Rp ${data!["terbayar"]}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sisa Pembayaran"),
                        Text("Rp ${data!["sisa_pembayaran"]}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status Pembayaran"),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                data!["status_pembayaran"].toLowerCase() ==
                                    "lunas"
                                ? Colors.green[300]
                                : Colors.orange[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${data!["status_pembayaran"]}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Garansi
              SizedBox(
                width: double.infinity,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sudahAjukanGaransi
                        ? null // 🔒 tombol mati
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormPengajuanGaransi(
                                  idOrder: widget.orderId,
                                  idPelanggan: idPelanggan!,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudahAjukanGaransi
                          ? Colors.grey // warna disabled
                          : const Color(0xFF0C3345),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      sudahAjukanGaransi
                          ? "Garansi Sudah Diajukan"
                          : "Ajukan Kunjungan Garansi",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                      ),
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
                      MaterialPageRoute(builder: (_) => TipsPerawatanPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF0C3345)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tips Perawatan",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C3345),
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Berikan Ulasan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => buildStar(i + 1)),
              ),
              const SizedBox(height: 15),

              // Catatan kepuasan
              TextField(
                controller: catatanController,
                maxLines: 3,
                readOnly: isUlasanSubmitted,
                decoration: _inputDecorationUlasan(
                  "Catatan Kepuasan Pelanggan",
                  hint: "Tulis catatan kepuasan...",
                  readOnly: isUlasanSubmitted,
                ),
              ),
              const SizedBox(height: 10),

              // Kritik & saran
              TextField(
                controller: kritikController,
                maxLines: 3,
                readOnly: isUlasanSubmitted,
                decoration: _inputDecorationUlasan(
                  "Kritik & Saran",
                  hint: "Tulis kritik dan saran...",
                  readOnly: isUlasanSubmitted,
                ),
              ),
              const SizedBox(height: 20),

              // Tombol kirim ulasan
              if (!isUlasanSubmitted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitUlasan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3345),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Kirim Ulasan",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
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
