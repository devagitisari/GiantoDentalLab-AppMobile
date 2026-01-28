import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/konfirmasi_alamat.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FormPengajuanLanjutan extends StatefulWidget {
  final String uid; // ID order
  final Map<String, dynamic>? existingAlamat;

  const FormPengajuanLanjutan({
    super.key,
    required this.uid,
    this.existingAlamat,
  });

  @override
  State<FormPengajuanLanjutan> createState() => _FormPengajuanLanjutanState();
}

class _FormPengajuanLanjutanState extends State<FormPengajuanLanjutan> {
  final TextEditingController jenisLayananController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController pelayananController = TextEditingController();

  String idPelanggan = "";
  List<String> tanggalList = [];
  List<String> pelayananList = ["Kunjungan ke Lab", "Kunjungan ke Rumah"];
  bool _isLoadingOrder = true;

  final Map<String, String> pelayananID = {
    "Kunjungan ke Lab": "PL01",
    "Kunjungan ke Rumah": "PL02",
  };

  Map<String, dynamic>? alamatRingkas; // Simpan alamat ringkas untuk tampilan

  @override
  void initState() {
    super.initState();
    fetchOrder();
    fetchTanggalJadwal();
    if (widget.existingAlamat != null) {
      alamatRingkas = widget.existingAlamat;
    }
  }

  @override
  void dispose() {
    jenisLayananController.dispose();
    catatanController.dispose();
    tanggalController.dispose();
    pelayananController.dispose();
    super.dispose();
  }

    void showAwesomePopupAutoClose({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.check_circle,
  }) {
     if (!mounted) return; 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        // Auto close dialog setelah 1.2 detik
        Future.delayed(const Duration(milliseconds: 1200), () {
           if (!mounted) return; 
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


  // ===================== FETCH ORDER =====================
  Future<void> fetchOrder() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('order')
          .doc(widget.uid)
          .get();

      if (!mounted || !doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final pelangganId = data['id_pelanggan']?.toString() ?? "";
      final idLayanan = data['id_layanan']?.toString() ?? "";

      String namaLayanan = "";

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

      if (!mounted) return;

      setState(() {
        idPelanggan = pelangganId;
        jenisLayananController.text = namaLayanan;
        catatanController.text = data['catatan_admin']?.toString() ?? "";
        _isLoadingOrder = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingOrder = false);
      showAwesomePopupAutoClose(
        title: "Gagal!",
        message: "Gagal mengambil data order: $e",
        color: Colors.redAccent,
        icon: Icons.error,
      );
    }
  }

  Future<void> fetchTanggalJadwal() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('id_order', isEqualTo: widget.uid)
          .get();

      if (!mounted) return;

      List<String> tempList = [];

      for (var doc in snapshot.docs) {
        final tanggalField = doc['tanggal_usulan'];
        if (tanggalField != null && tanggalField is List) {
          for (var item in tanggalField) {
            if (item is Map<String, dynamic>) {
              final tanggal = item['tanggal']?.toString() ?? "";
              final jamMulai = item['jam_mulai']?.toString() ?? "";
              final jamSelesai = item['jam_selesai']?.toString() ?? "";

              if (tanggal.isNotEmpty) {
                // format dd-MM-yyyy
                DateTime parsedTanggal = DateTime.parse(tanggal);
                String formattedTanggal = DateFormat(
                  'dd/MM/yyyy',
                ).format(parsedTanggal);
                tempList.add("$formattedTanggal, $jamMulai - $jamSelesai WIB");
              }
            }
          }
        }
      }

      tempList = tempList.toSet().toList()
        ..sort((a, b) {
          // sort berdasarkan tanggal
          DateTime aDate = DateFormat('dd/MM/yyyy').parse(a.split(',')[0]);
          DateTime bDate = DateFormat('dd/MM/yyyy').parse(b.split(',')[0]);
          return aDate.compareTo(bDate);
        });

      if (!mounted) return;
      setState(() {
        tanggalList = tempList;
        tanggalController.text = '';
      });
    } catch (e) {
      debugPrint("Gagal mengambil tanggal: $e");
    }
  }

  Future<void> submitForm({Map<String, dynamic>? alamat}) async {
    if (tanggalController.text.isEmpty || pelayananController.text.isEmpty) {
      showAwesomePopupAutoClose(
        title: "Perhatian!",
        message: "Harap pilih tanggal & pelayanan",
        color: Colors.orange, // bisa diganti sesuai kebutuhan
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    try {
      // ================== UPDATE ORDER ==================
      await FirebaseFirestore.instance
          .collection('order')
          .doc(widget.uid)
          .update({
            'id_pelayanan': pelayananID[pelayananController.text] ?? "",
            'status': 'disetujui',
            'updated_at': FieldValue.serverTimestamp(),
            if (alamatRingkas != null) 'alamat_konfirmasi': alamatRingkas!,
          });

      String? selectedJadwalId;

      // ================== UPDATE JADWAL ==================
      final jadwalSnapshot = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('id_order', isEqualTo: widget.uid)
          .get();

      for (var doc in jadwalSnapshot.docs) {
        final data = doc.data();
        final List tanggalUsulan = data['tanggal_usulan'] ?? [];

        for (var item in tanggalUsulan) {
          if (item is Map<String, dynamic>) {
            final tanggalStr = item['tanggal'] ?? "";
            final jamMulai = item['jam_mulai'] ?? "";
            final jamSelesai = item['jam_selesai'] ?? "";

            // parsing tanggalController.text
            final parts = tanggalController.text.split(",");
            final tanggalControllerStr = parts[0].trim(); // dd/MM/yyyy
            final jamControllerStr =
                parts[1].replaceAll("WIB", "").trim();
            final jamParts = jamControllerStr.split("-");
            final jamMulaiController = jamParts[0].trim();
            final jamSelesaiController = jamParts[1].trim();

            final tanggalControllerISO =
                DateFormat('yyyy-MM-dd').format(
              DateFormat('dd/MM/yyyy').parse(tanggalControllerStr),
            );

            if (tanggalStr == tanggalControllerISO &&
                jamMulai == jamMulaiController &&
                jamSelesai == jamSelesaiController) {

              selectedJadwalId = doc.id; // ✅ SIMPAN ID JADWAL

              await doc.reference.update({
                'tanggal_pilihan': tanggalController.text,
                'updated_at': FieldValue.serverTimestamp(),
              });

              break;
            }
          }
        }

        if (selectedJadwalId != null) break;
      }

      // ❗ VALIDASI SETELAH LOOP SELESAI
      if (selectedJadwalId == null) {
        throw Exception("ID Jadwal tidak ditemukan");
      }


      // ================== GENERATE KUNJUNGAN ==================
      final layanan = jenisLayananController.text.trim();
      final parts = tanggalController.text.split(",");
      final tanggalStr = parts[0].trim();
      final jamStr = parts[1].replaceAll("WIB", "").trim();
      final jamParts = jamStr.split("-");
      final jamMulai1 = jamParts[0].trim();
      final jamSelesai1 = jamParts[1].trim();
      final tanggal1 = DateFormat("dd/MM/yyyy").parse(tanggalStr);
      final kunjunganRef = FirebaseFirestore.instance.collection("kunjungan");

      if (layanan == "Pembuatan Baru" || layanan == "Rebasing" || layanan == "Retainer") {
        // Kunjungan 1
        final kunjunganId1 = kunjunganRef.doc().id;
        await kunjunganRef.doc(kunjunganId1).set({
          "id_kunjungan": kunjunganId1,
          "id_jadwal": selectedJadwalId,
          "aktivitas": "Kunjungan 1",
          "keterangan": "Pemeriksaan",
          "jadwal_kunjungan": {
            "tanggal": tanggalStr,
            "jam_mulai": jamMulai1,
            "jam_selesai": jamSelesai1,
          },
          "status": "dijadwalkan",
        });

        // Kunjungan 2 (3 hari setelah kunjungan 1)
        DateTime jamSelesaiDT = DateFormat("HH:mm").parse(jamSelesai1);
        String jamSelesai2 = DateFormat(
          "HH:mm",
        ).format(jamSelesaiDT.add(const Duration(hours: 2)));
        final tanggal2Str = DateFormat(
          'dd/MM/yyyy',
        ).format(tanggal1.add(const Duration(days: 3)));
        final kunjunganId2 = kunjunganRef.doc().id;
        await kunjunganRef.doc(kunjunganId2).set({
          "id_kunjungan": kunjunganId2,
          "id_jadwal": selectedJadwalId,
          "aktivitas": "Kunjungan 2",
          "keterangan": "Pemasangan",
          "jadwal_kunjungan": {
            "tanggal": tanggal2Str,
            "jam_mulai": jamMulai1,
            "jam_selesai": jamSelesai2,
          },
          "status": "dijadwalkan",
        });
      } else {
        // Kunjungan tunggal
        final kunjunganId = kunjunganRef.doc().id;
        await kunjunganRef.doc(kunjunganId).set({
          "id_kunjungan": kunjunganId,
          "id_jadwal": selectedJadwalId,
          "aktivitas": "Kunjungan 1",
          "keterangan": "Pemasangan",
          "jadwal_kunjungan": {
            "tanggal": tanggalStr,
            "jam_mulai": jamMulai1,
            "jam_selesai": jamSelesai1,
          },
          "status": "dijadwalkan",
        });
      }

      showAwesomePopupAutoClose(
        title: "Berhasil!",
        message: "Pengajuan berhasil dikonfirmasi",
        color: Colors.green,
        icon: Icons.check_circle,
      );

      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        Navigator.pop(context);
      });

    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Terjadi Kesalahan",
        message: "$e",
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Stack(
                alignment: Alignment.center,
                children: [
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
                          child: const Icon(Icons.arrow_back, color: Color(0xFF0C3345), size: 28),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Pengajuan Lanjutan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF0C3345),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // JENIS LAYANAN
              TextFormField(
                controller: jenisLayananController,
                readOnly: true,
                decoration: inputDecoration("Jenis Layanan"),
              ),
              const SizedBox(height: 16),

              // CATATAN ADMIN
              TextFormField(
                controller: catatanController,
                readOnly: true,
                maxLines: 3,
                decoration: inputDecoration("Catatan Admin"),
              ),
              const SizedBox(height: 16),

              // TANGGAL
              DropdownButtonFormField<String>(
                value: tanggalController.text.isNotEmpty
                    ? tanggalController.text
                    : null,
                decoration: inputDecoration("Tanggal Pilihan"),
                items: tanggalList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => tanggalController.text = val ?? ""),
                hint: const Text("-- Pilih Tanggal --"),
              ),
              const SizedBox(height: 16),

              // PELAYANAN
              DropdownButtonFormField<String>(
                value: pelayananController.text.isNotEmpty
                    ? pelayananController.text
                    : null,
                decoration: inputDecoration("Pelayanan"),
                items: pelayananList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: _isLoadingOrder
                      ? null
                      : (val) {
                          setState(() => pelayananController.text = val ?? "");

                          if (val == "Kunjungan ke Lab") {
                            setState(() {
                              alamatRingkas = null;
                            });
                          }

                          if (val == "Kunjungan ke Rumah") {
                            Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KonfirmasiAlamat(
                                  uid: idPelanggan,
                                  orderId: widget.uid,
                                ),
                              ),
                            ).then((alamat) {
                              if (!mounted) return;
                              if (alamat != null) {
                                setState(() {
                                  alamatRingkas = alamat;
                                });
                              }
                            });
                          }
                        },

                hint: _isLoadingOrder
                    ? const Text("Memuat data pelanggan...")
                    : const Text("-- Pilih Pelayanan --"),
              ),

              const SizedBox(height: 16),

              // ALAMAT RINGKAS
              if (alamatRingkas != null)
                GestureDetector(
                  onTap: () async {
                    final alamat = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KonfirmasiAlamat(
                          uid: idPelanggan,
                          orderId: widget.uid,
                          existingAlamat: alamatRingkas,
                        ),
                      ),
                    );

                    if (alamat != null) {
                      setState(() {
                        alamatRingkas = {
                          "nama_jalan": alamat['nama_jalan'],
                          "detail_jalan": alamat['detail_jalan'],
                          "kelurahan": alamat['kelurahan'],
                          "kecamatan": alamat['kecamatan'],
                          "kota": alamat['kota'],
                          "provinsi": alamat['provinsi'],
                          "gmaps": {
                            "latitude": alamat['gmaps']?['latitude'],
                            "longitude": alamat['gmaps']?['longitude'],
                            "link": alamat['gmaps']?['link'],
                          },
                        };
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // background tetap abu-abu
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD0D0D0),
                      ), // border sama seperti TextFormField
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${alamatRingkas!['nama_jalan']} (${alamatRingkas!['detail_jalan']}), "
                          "${alamatRingkas!['kelurahan']}, ${alamatRingkas!['kecamatan']}, "
                          "${alamatRingkas!['kota']}, ${alamatRingkas!['provinsi']}.",
                          style: const TextStyle(
                            fontSize: 14, // sama seperti TextFormField
                            fontWeight:
                                FontWeight.w600, // sama seperti TextFormField
                            color: Color(0xFF0C3345), // warna teks konsisten
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                                      style: TextStyle(color: Colors.black54),
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
                                      markerId: MarkerId("lokasi"),
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

              const SizedBox(height: 16),

              // BUTTON KONFIRMASI
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    submitForm(alamat: alamatRingkas);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3345),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
      ),
    );
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0C3345)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
