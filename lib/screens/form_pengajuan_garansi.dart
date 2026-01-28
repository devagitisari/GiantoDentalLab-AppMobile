import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team_project/screens/konfirmasi_alamat.dart';

class FormPengajuanGaransi extends StatefulWidget {
  final String idOrder;
  final String idPelanggan;

  const FormPengajuanGaransi({
    super.key,
    required this.idOrder,
    required this.idPelanggan,
  });

  @override
  State<FormPengajuanGaransi> createState() => _FormPengajuanGaransiState();
}

class _FormPengajuanGaransiState extends State<FormPengajuanGaransi> {
  final TextEditingController namaGaransiController = TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  final TextEditingController pelayananController = TextEditingController();

  Map<String, String> pelayananID = {
    "Kunjungan ke Lab": "PL01",
    "Kunjungan ke Rumah": "PL02",
  };

  Map<String, dynamic>? alamatRingkas;
  bool _isLoading = true;
  Map<String, dynamic>? dataOrder;

  @override
  void initState() {
    super.initState();
    fetchDataOrder();
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

  void showAwesomePopupAutoCloseAndBack({
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
          // tutup dialog
          if (Navigator.canPop(context)) Navigator.pop(context);
          // balik ke halaman sebelumnya
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

  Future<void> fetchDataOrder() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('order')
          .doc(widget.idOrder)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      dataOrder = data;

      // Ambil nama layanan
      String namaLayanan = "";
      final idLayanan = data['id_layanan'] ?? "";
      if (idLayanan.isNotEmpty) {
        final layananQuery = await FirebaseFirestore.instance
            .collection('layanan')
            .where('id_layanan', isEqualTo: idLayanan)
            .limit(1)
            .get();
        if (layananQuery.docs.isNotEmpty) {
          namaLayanan = layananQuery.docs.first.data()['nama_layanan'] ?? "";
        }
      }

      // Set nama garansi otomatis
      namaGaransiController.text = "Garansi $namaLayanan";

      // Ambil alamat konfirmasi dari order
      if (data.containsKey('alamat_konfirmasi')) {
        alamatRingkas = Map<String, dynamic>.from(data['alamat_konfirmasi']);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Gagal fetch order: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> submitForm() async {
    if (keluhanController.text.isEmpty || pelayananController.text.isEmpty) {
      showAwesomePopupAutoClose(
        title: "Perhatian",
        message: "Harap isi keluhan & pelayanan",
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );

      return;
    }

    if (pelayananController.text == "Kunjungan ke Rumah" &&
        alamatRingkas == null) {
      showAwesomePopupAutoClose(
        title: "Perhatian",
        message: "Harap pilih alamat untuk Kunjungan ke Rumah",
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final garansiRef = FirebaseFirestore.instance.collection('garansi').doc();
      await garansiRef.set({
        'id_garansi': garansiRef.id,
        'id_order': widget.idOrder,
        'nama_garansi': namaGaransiController.text,
        'keluhan': keluhanController.text,
        'id_pelayanan': pelayananID[pelayananController.text] ?? "",
        'status': 'menunggu',
        'alamat_konfirmasi': alamatRingkas ?? {},
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      showAwesomePopupAutoCloseAndBack(
        title: "Berhasil",
        message: "Garansi berhasil diajukan!",
        color: Colors.green,
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Gagal submit: $e",
        color: Colors.red,
        icon: Icons.error_outline,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0C3345),
      ),
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0C3345)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: false,

    // 🔑 samain tinggi header body (48 button + napas atas bawah)
    toolbarHeight: 72,

    // 🔑 samain padding kiri body (20)
    leadingWidth: 68, // 48 + 20
    leading: Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Center(
        child: GestureDetector(
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
      ),
    ),

    // 🔑 supaya title bener-bener center visual
    titleSpacing: 0,
    title: const Text(
      " Form Garansi",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0C3345),
        fontFamily: 'Poppins',
      ),
    ),
  ),



      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0C3345),
                strokeWidth: 3, // ganti sesuai tema
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: namaGaransiController,
                    readOnly: true,
                    decoration: inputDecoration("Nama Garansi"),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: keluhanController,
                    maxLines: 5,
                    decoration: inputDecoration("Keluhan"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: pelayananController.text.isNotEmpty
                        ? pelayananController.text
                        : null,
                    items: pelayananID.keys
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) async {
                      setState(() => pelayananController.text = val ?? "");
                      if (val == "Kunjungan ke Rumah") {
                        final alamat =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KonfirmasiAlamat(
                                  uid: widget.idPelanggan,
                                  orderId: widget.idOrder,
                                  existingAlamat: alamatRingkas,
                                ),
                              ),
                            );
                        if (alamat != null)
                          setState(() => alamatRingkas = alamat);
                      } else {
                        setState(() => alamatRingkas = null);
                      }
                    },
                    hint: const Text("-- Pilih Pelayanan --"),
                    decoration: inputDecoration("Pelayanan"),
                  ),
                  const SizedBox(height: 16),

                  if (alamatRingkas != null &&
                      pelayananController.text == "Kunjungan ke Rumah")
                    GestureDetector(
                      onTap: () async {
                        final alamat =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KonfirmasiAlamat(
                                  uid: widget.idPelanggan,
                                  orderId: widget.idOrder,
                                  existingAlamat: alamatRingkas,
                                ),
                              ),
                            );
                        if (alamat != null) {
                          setState(() => alamatRingkas = alamat);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD0D0D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${alamatRingkas!['nama_jalan']} (${alamatRingkas!['detail_jalan']}), "
                              "${alamatRingkas!['kelurahan']}, ${alamatRingkas!['kecamatan']}, "
                              "${alamatRingkas!['kota']}, ${alamatRingkas!['provinsi']}.",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0C3345),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Builder(
                                  builder: (context) {
                                    final double lat =
                                        double.tryParse(
                                          alamatRingkas!['gmaps']?['latitude']
                                                  ?.toString() ??
                                              "",
                                        ) ??
                                        0.0;
                                    final double lng =
                                        double.tryParse(
                                          alamatRingkas!['gmaps']?['longitude']
                                                  ?.toString() ??
                                              "",
                                        ) ??
                                        0.0;

                                    if (lat == 0.0 && lng == 0.0) {
                                      return Container(
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Koordinat belum tersedia",
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      );
                                    }

                                    return GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(lat, lng),
                                        zoom: 16,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId("lokasi"),
                                          position: LatLng(lat, lng),
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      liteModeEnabled: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Koordinat: ${alamatRingkas!['gmaps']['latitude']} , ${alamatRingkas!['gmaps']['longitude']}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3345),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Konfirmasi Pengajuan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
