import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/form_pengajuan_lanjutan.dart';
import 'package:team_project/screens/informasi_kunjungan_1.dart';
import 'package:team_project/screens/informasi_kunjungan_2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class TahapanPengajuan extends StatefulWidget {
  final String orderId;
  const TahapanPengajuan({super.key, required this.orderId});

  @override
  State<TahapanPengajuan> createState() => _TahapanPengajuanState();
}

class _TahapanPengajuanState extends State<TahapanPengajuan> {
  Map<String, String> jamMulai = {};
  Map<String, String> jamSelesai = {};
  String? idJadwal;
  String? tanggalPilihan; // <--- baru
  String orderStatus = "";
  String namaLayanan = "";
  String idPelayanan = "";
  StreamSubscription? _kunjunganSub;
  StreamSubscription? _ulasanSub;
  String? kunjungan1Id;
  String? kunjungan2Id;

  bool loading = true;

  List<String> kunjunganIds = [];
  Map<String, DateTime> kunjunganDates = {};
  Map<String, String> statusKunjungan = {};
  Map<String, List<String>> aktivitasKunjungan = {};
  bool adaUlasan = false;

  @override
  void initState() {
    super.initState();
    loadDataRealtime();
  }

  @override
  void dispose() {
    _kunjunganSub?.cancel();
    _ulasanSub?.cancel();
    super.dispose();
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
                        child: Text(buttonText, style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          ),
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

  void showReminderPopup({
    required BuildContext context,
    required String title,
    required String contentText,
    String? tanggal,
    String? jamMulai,
    String? jamSelesai,
    Color color = Colors.blue,
    IconData icon = Icons.info,
    Future<void> Function()? openMap,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
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
                      contentText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    if (tanggal != null)
                      Text(
                        "📅 $tanggal",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    if (jamMulai != null || jamSelesai != null)
                      Text(
                        "⏰ ${jamMulai ?? "--:--"} - ${jamSelesai ?? "--:--"} WIB",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (openMap != null) {
                          await openMap();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  String _namaBulan(int bulan) {
    const namaBulan = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return namaBulan[bulan];
  }

  Widget jadwalKunjunganView(String id) {
    final tanggal = kunjunganDates[id];
    final jm = jamMulai[id];
    final js = jamSelesai[id];

    if (tanggal == null && jm == null && js == null) {
      return const SizedBox.shrink();
    }

    String formatTanggal(DateTime d) {
      return "${d.day} ${_namaBulan(d.month)} ${d.year}";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tanggal != null)
            Text(
              "📅 ${formatTanggal(tanggal)}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0C3345),
                fontFamily: 'Poppins',
              ),
            ),
          if (jm != null || js != null)
            Text(
              "⏰ ${jm ?? "--:--"} - ${js ?? "--:--"} WIB",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0C3345),
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
  }

  bool get isPembuatanBaru =>
      ["pembuatan baru", "rebasing", "retainer"].contains(namaLayanan);

  void loadDataRealtime() async {
    _kunjunganSub?.cancel();
    _ulasanSub?.cancel();

    setState(() => loading = true);

    // ORDER & LAYANAN (sekali saja)
    final orderDoc = await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.orderId)
        .get();

    if (!orderDoc.exists || orderDoc.data() == null) return;

    final data = orderDoc.data()!;
    orderStatus = (data['status'] ?? "").toString().toLowerCase().trim();

    idPelayanan = (data['id_pelayanan'] ?? "").toString().trim().toUpperCase();

    final layananSnapshot = await FirebaseFirestore.instance
        .collection('layanan')
        .where(
          'id_layanan',
          isEqualTo: (data['id_layanan'] ?? "").toString().trim().toUpperCase(),
        )
        .get();

    if (layananSnapshot.docs.isNotEmpty) {
      namaLayanan = (layananSnapshot.docs.first['nama_layanan'] ?? "")
          .toString()
          .toLowerCase()
          .trim();
    }

    final jadwalSnap = await FirebaseFirestore.instance
        .collection('jadwal')
        .where('id_order', isEqualTo: widget.orderId)
        .limit(1)
        .get();

    if (jadwalSnap.docs.isNotEmpty) {
      final jadwalDoc = jadwalSnap.docs.first;
      idJadwal = jadwalDoc.id;
      final dataJadwal = jadwalDoc.data();
      final rawTanggal = dataJadwal['tanggal_pilihan'];

      tanggalPilihan =
          (rawTanggal == null ||
              rawTanggal.toString().trim().isEmpty ||
              rawTanggal.toString().toLowerCase() == "null")
          ? null
          : rawTanggal.toString().trim();
    } else {
      idJadwal = null;
      tanggalPilihan = null;
    }

    // 🔥 LISTENER KUNJUNGAN
    _kunjunganSub = FirebaseFirestore.instance
        .collection('kunjungan')
        .where('id_jadwal', isEqualTo: idJadwal)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          setState(() {
            loading = false;
            kunjunganIds.clear();
            kunjunganDates.clear();
            statusKunjungan.clear();
            aktivitasKunjungan.clear();
            jamMulai.clear();
            jamSelesai.clear();

            for (var doc in snapshot.docs) {
              final d = doc.data();
              kunjunganIds.add(doc.id);
              statusKunjungan[doc.id] = (d['status'] ?? "")
                  .toString()
                  .toLowerCase()
                  .trim();
              final tgl = d['jadwal_kunjungan']?['tanggal'];
              if (tgl != null) {
                final p = tgl.split('/');
                kunjunganDates[doc.id] = DateTime(
                  int.parse(p[2]),
                  int.parse(p[1]),
                  int.parse(p[0]),
                );
              }

              final jadwal = d['jadwal_kunjungan'];
              if (jadwal is Map) {
                if (jadwal['jam_mulai'] != null) {
                  jamMulai[doc.id] = jadwal['jam_mulai'].toString();
                }
                if (jadwal['jam_selesai'] != null) {
                  jamSelesai[doc.id] = jadwal['jam_selesai'].toString();
                }
              }

          
              final akt = d['aktivitas'];
              aktivitasKunjungan[doc.id] = (akt == null)
                  ? []
                  : (akt is String ? [akt] : List<String>.from(akt))
                      .map((e) => e.toLowerCase().trim())
                      .toList();


            }

            kunjunganIds.sort(
              (a, b) => (kunjunganDates[a] ?? DateTime(2100)).compareTo(
                kunjunganDates[b] ?? DateTime(2100),
              ),
            );

            final k1 = kunjunganIds.firstWhere(
              (id) => aktivitasKunjungan[id]?.contains("kunjungan 1") ?? false,
              orElse: () => "",
            );
            kunjungan1Id = k1.isEmpty ? null : k1;

            final k2 = kunjunganIds
                .where(
                  (id) =>
                      aktivitasKunjungan[id]?.contains("kunjungan 2") ?? false,
                )
                .toList();
            kunjungan2Id = k2.isEmpty ? null : k2.first;
          });
        });

    _ulasanSub = FirebaseFirestore.instance
        .collection('ulasan')
        .where('id_order', isEqualTo: widget.orderId)
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          setState(() {
            loading = false;
            adaUlasan = snap.docs.isNotEmpty;
          });
        });
  }

  DateTime today() => DateTime.now();

  // Helper: warna step
  Color stepColor(int step) {
    final now = today();
    final isPembuatanBaruOrRebasing = [
      "pembuatan baru",
      "rebasing",
      "retainer",
    ].contains(namaLayanan);

    bool isToday(DateTime? date) {
      if (date == null) return false;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }

    if (isPembuatanBaruOrRebasing) {
      // 5 step: 0=Form, 1=Kunjungan1, 2=Proses Pembuatan, 3=Kunjungan2, 4=Selesai
      switch (step) {
        case 0: // Form Pengajuan Lanjutan
          if (tanggalPilihan == null || tanggalPilihan!.trim().isEmpty) {
            return const Color(0xFF1D7EAB); // biru muda
          }
          return const Color(0xFF0C3345); // biru tua

        case 1: // Kunjungan 1
          if (kunjungan1Id == null) return Colors.grey;

          final status = (statusKunjungan[kunjungan1Id!] ?? "")
              .toLowerCase()
              .trim();

          final aktivitas = (aktivitasKunjungan[kunjungan1Id!] ?? [])
              .map((e) => e.toLowerCase().trim())
              .toList();

          final tanggal = kunjunganDates[kunjungan1Id!];

          if (status == "selesai" && aktivitas.contains("kunjungan 1")) {
            return const Color(0xFF0C3345); // 🔵 biru tua
          }

          if (status == "dijadwalkan" &&
              aktivitas.contains("kunjungan 1") &&
              isToday(tanggal)) {
            return const Color(0xFF1D7EAB); // 🔵 biru muda (HARI INI)
          }

          return Colors.grey;

        case 2: // Proses Pembuatan
          if (kunjungan1Id == null) return Colors.grey;
          final status1 = (statusKunjungan[kunjungan1Id!] ?? "")
              .toLowerCase()
              .trim();
          if (status1 != "selesai") return Colors.grey;

          if (kunjungan2Id != null) {
            final status2 = (statusKunjungan[kunjungan2Id!] ?? "")
                .toLowerCase()
                .trim();
            final tanggal2 = kunjunganDates[kunjungan2Id!];
            return (status2 == "selesai" || isToday(tanggal2))
                ? const Color(0xFF0C3345)
                : const Color(0xFF1D7EAB);
          }
          return const Color(0xFF1D7EAB);

        case 3: // Kunjungan 2
          if (kunjungan2Id == null) return Colors.grey;
          final status3 = (statusKunjungan[kunjungan2Id!] ?? "")
              .toLowerCase()
              .trim();
          final aktivitas3 = (aktivitasKunjungan[kunjungan2Id!] ?? [])
              .map((e) => e.toLowerCase().trim())
              .toList();
          final tanggal3 = kunjunganDates[kunjungan2Id!];

          if (status3 == "selesai" && aktivitas3.contains("kunjungan 2"))
            return const Color(0xFF0C3345);
          if (status3 == "dijadwalkan" &&
              aktivitas3.contains("kunjungan 2") &&
              isToday(tanggal3)) {
            return const Color(0xFF1D7EAB);
          }
          return Colors.grey;

        case 4: // Selesai / Ulasan
          return adaUlasan ? const Color(0xFF0C3345) : Colors.grey;

        default:
          return Colors.grey;
      }
    } else {
      // selain pembuatan baru / rebashing: 3 step: 0=Form, 1=Kunjungan1, 2=Selesai
      switch (step) {
        case 0: // Form Pengajuan Lanjutan
          if (tanggalPilihan == null || tanggalPilihan!.trim().isEmpty) {
            return const Color(0xFF1D7EAB);
          }
          return const Color(0xFF0C3345);

        case 1: // Kunjungan 1
          if (kunjungan1Id == null) return Colors.grey;

          final status = (statusKunjungan[kunjungan1Id!] ?? "")
              .toLowerCase()
              .trim();

          final aktivitas = (aktivitasKunjungan[kunjungan1Id!] ?? [])
              .map((e) => e.toLowerCase().trim())
              .toList();

          final tanggal = kunjunganDates[kunjungan1Id!];

          if (status == "selesai" && aktivitas.contains("kunjungan 1")) {
            return const Color(0xFF0C3345); // 🔵 biru tua
          }

          if (status == "dijadwalkan" &&
              aktivitas.contains("kunjungan 1") &&
              isToday(tanggal)) {
            return const Color(0xFF1D7EAB); // 🔵 biru muda (HARI INI)
          }

          return Colors.grey;

        case 2: // Selesai / Ulasan
          return adaUlasan ? const Color(0xFF0C3345) : Colors.grey;

        default:
          return Colors.grey;
      }
    }
  }

  bool isClickableColor(Color c) {
    return c == const Color(0xFF1D7EAB) || // biru muda
        c == const Color(0xFF0C3345);     // biru tua
  }

  bool canTap(int step) {
    final isPembuatanBaruOrRebasing = [
      "pembuatan baru",
      "rebasing",
      "retainer",
    ].contains(namaLayanan);

    bool isToday(DateTime? date) {
      if (date == null) return false;
      final now = today();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }

    if (isPembuatanBaruOrRebasing) {
      // 5 step
      switch (step) {
        case 0: // Form
          return (tanggalPilihan == null || tanggalPilihan!.isEmpty);

        case 1: // Kunjungan 1
          if (kunjungan1Id == null) return false;
          final status = (statusKunjungan[kunjungan1Id!] ?? "")
              .toLowerCase()
              .trim();
          final tanggal = kunjunganDates[kunjungan1Id!];
          return (status == "dijadwalkan" && isToday(tanggal)) ||
              status == "selesai";

        case 2: // Proses Pembuatan
          if (kunjungan1Id == null) return false;
          final status1 = (statusKunjungan[kunjungan1Id!] ?? "")
              .toLowerCase()
              .trim();
          if (status1 != "selesai") return false;
          if (kunjungan2Id != null) {
            final status2 = (statusKunjungan[kunjungan2Id!] ?? "")
                .toLowerCase()
                .trim();
            final tanggal2 = kunjunganDates[kunjungan2Id!];
            return (status2 == "dijadwalkan" && isToday(tanggal2)) ||
                status2 == "selesai";
          }
          return true; // Biru muda → tunggu proses pembuatan

        case 3: // Kunjungan 2
          if (kunjungan2Id == null) return false;
          final status2 = (statusKunjungan[kunjungan2Id!] ?? "")
              .toLowerCase()
              .trim();
          final tanggal2 = kunjunganDates[kunjungan2Id!];
          return (status2 == "dijadwalkan" && isToday(tanggal2)) ||
              status2 == "selesai";

        case 4: // Selesai / Ulasan
          return adaUlasan;

        default:
          return false;
      }
    } else {
      // selain pembuatan baru / rebasing → 3 step
      switch (step) {
        case 0: // ✅ FORM PENGAJUAN (SELALU BOLEH)
          return (tanggalPilihan == null || tanggalPilihan!.isEmpty);

        case 1: // Kunjungan 1 (pakai kunjungan 2 secara teknis)
          if (kunjungan1Id == null) return false;
          final status = (statusKunjungan[kunjungan1Id!] ?? "")
              .toLowerCase()
              .trim();
          final tanggal = kunjunganDates[kunjungan1Id!];
          return (status == "dijadwalkan" && isToday(tanggal)) ||
              status == "selesai";

        case 2: // Selesai / Ulasan
          return adaUlasan;

        default:
          return false;
      }
    }
  }

  Widget kunjunganPage(int index) {
    if (index >= kunjunganIds.length)
      return const Scaffold(body: Center(child: Text("Belum ada catatan")));
    return index == 0
        ? InformasiKunjungan1(
            idKunjungan: kunjunganIds[index],
            orderId: widget.orderId,
          )
        : InformasiKunjungan2(
            idKunjungan: kunjunganIds[index],
            orderId: widget.orderId,
          );
  }

  Future<void> _openMap() async {
    const url = "https://maps.app.goo.gl/SfK5z36pNtFQvFgu5?g_st=aw";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
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

    final steps = isPembuatanBaru
        ? [
            {"label": "Form Pengajuan Lanjutan", "icon": Icons.edit_document},
            {"label": "Kunjungan 1", "icon": Icons.search},
            {"label": "Proses Pembuatan", "icon": Icons.build},
            {"label": "Kunjungan 2", "icon": Icons.handyman},
            {"label": "Selesai", "icon": Icons.star},
          ]
        : [
            {"label": "Form Pengajuan Lanjutan", "icon": Icons.edit_document},
            {"label": "Kunjungan 1", "icon": Icons.handyman},
            {"label": "Selesai", "icon": Icons.star},
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Tahapan Pengajuan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C3345),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 32),
              Column(
                children: List.generate(steps.length, (i) {
                  final color = stepColor(i);
                  return GestureDetector(
                    onTap: isClickableColor(stepColor(i))
                        ? () async {
                            if (i == 0) {
                              // BELUM pilih tanggal → boleh isi form
                              if (tanggalPilihan == null ||
                                  tanggalPilihan!.isEmpty) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormPengajuanLanjutan(
                                      uid: widget.orderId, // sesuai kode kamu
                                    ),
                                  ),
                                );

                                loadDataRealtime(); // refresh setelah balik
                              } else {
                                // SUDAH isi tanggal
                                showAwesomePopup(
                                  title: "Form Pengajuan Lanjutan",
                                  message:
                                      "Form Pengajuan sudah diisi. Silakan menunggu proses berikutnya.",
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  buttonText: "OK",
                                  onButtonPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                              }
                            } else if (i == 1) {
                              String? id = kunjunganIds.firstWhere(
                                (kid) => (aktivitasKunjungan[kid] ?? []).any(
                                  (e) =>
                                      e.toLowerCase().trim() == "kunjungan 1",
                                ),
                                orElse: () => "",
                              );

                              final status = statusKunjungan[id] ?? "";
                              final aktivitasList =
                                  aktivitasKunjungan[id] ?? [];

                              bool aktivitas1 = aktivitasList.any(
                                (e) => e.toLowerCase().trim() == "kunjungan 1",
                              );

                              final tanggal = kunjunganDates[id];
                              final now = today();

                              bool isToday =
                                  tanggal != null &&
                                  tanggal.year == now.year &&
                                  tanggal.month == now.month &&
                                  tanggal.day == now.day;

                              // ABU-ABU → tidak bisa ditekan
                              if (status.toLowerCase() == "dijadwalkan" &&
                                  aktivitas1 &&
                                  !isToday)
                                return;

                              // Biru muda → popup
                              if (status.toLowerCase() == "dijadwalkan" &&
                                  aktivitas1 &&
                                  isToday) {
                                final tanggalStr =
                                    kunjunganDates[kunjungan1Id!] != null
                                    ? "${kunjunganDates[kunjungan1Id!]!.day} "
                                          "${_namaBulan(kunjunganDates[kunjungan1Id!]!.month)} "
                                          "${kunjunganDates[kunjungan1Id!]!.year}"
                                    : "Tanggal belum tersedia";

                                final jamStr =
                                    (jamMulai[kunjungan1Id!] != null &&
                                        jamSelesai[kunjungan1Id!] != null)
                                    ? "${jamMulai[kunjungan1Id!]} - ${jamSelesai[kunjungan1Id!]} WIB"
                                    : "Jam belum tersedia";

                                final mainText = idPelayanan == "PL02"
                                    ? "Siapkan diri Anda untuk dikunjungi oleh Gianto Dental Lab.\n\n📅 $tanggalStr\n⏰ $jamStr"
                                    : "Silahkan buka link Maps untuk melihat lokasi Gianto Dental Lab.\n\n📅 $tanggalStr\n⏰ $jamStr";

                                showReminderPopup(
                                  context: context,
                                  title: "Reminder Kunjungan 1",
                                  contentText: mainText,
                                  color: Colors.blue,
                                  icon: Icons.info,
                                  openMap: idPelayanan == "PL01"
                                      ? _openMap
                                      : null,
                                );

                                return;
                              }

                              // Biru tua → buka halaman informasi meskipun belum ada kunjungan 2
                              if (status.toLowerCase() == "selesai") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InformasiKunjungan1(
                                      idKunjungan: kunjungan1Id!,
                                      orderId: widget.orderId,
                                    ),
                                  ),
                                );
                              }
                            } else if (i == 2) {
                              final now = today();

                              if (kunjungan2Id != null) {
                                final tgl2 = kunjunganDates[kunjungan2Id];
                                final status2 =
                                    statusKunjungan[kunjungan2Id] ?? "";
                                final aktivitas2 =
                                    aktivitasKunjungan[kunjungan2Id] ?? [];

                                final isToday =
                                    tgl2 != null &&
                                    now.year == tgl2.year &&
                                    now.month == tgl2.month &&
                                    now.day == tgl2.day;

                                // 1️⃣ Biru tua → Kunjungan 2 hari ini atau sudah selesai
                                if ((isToday &&
                                        aktivitas2.any(
                                          (e) =>
                                              e.toLowerCase().trim() ==
                                              "kunjungan 2",
                                        )) ||
                                    status2 == "selesai") {
                                  showAwesomePopup(
                                    title: "Proses Pembuatan Selesai",
                                    message: status2 == "selesai"
                                        ? "Proses Pembuatan telah selesai."
                                        : "Gianto Dental Lab akan melakukan kunjungan 2 hari ini.",
                                    buttonText: "OK",
                                    onButtonPressed: () {
                                      // Tutup popup
                                      Navigator.pop(context);
                                    },
                                    autoClose:
                                        false, // karena kita pakai tombol OK
                                    icon: Icons
                                        .check_circle, // bisa diganti sesuai tema
                                    color: const Color(
                                      0xFF0C3345,
                                    ), // sesuai warna tema
                                  );
                                  return;
                                }
                              }

                              // 2️⃣ Biru muda → Kunjungan 1 selesai tapi belum ada Kunjungan 2 / belum hari kunjungan 2
                              if (kunjungan1Id != null) {
                                showAwesomePopup(
                                  title: "Proses Pembuatan",
                                  message:
                                      "Proses Pembuatan berlangsung selama 3 hari, mohon tunggu...",
                                  buttonText: "OK",
                                  onButtonPressed: () {
                                    Navigator.pop(context);
                                  },
                                  autoClose:
                                      false, // karena kita pakai tombol OK
                                  icon: Icons
                                      .hourglass_top, // bisa ganti ikon sesuai tema
                                  color: Colors.blue,
                                  // sesuai warna tema
                                );
                              }
                            } else if (i == 3) {
                              final id = kunjungan2Id!;
                              final status = statusKunjungan[id] ?? "";
                              final aktivitas = aktivitasKunjungan[id] ?? [];
                              final tgl = kunjunganDates[id];

                              final now = today();
                              final isToday =
                                  tgl != null &&
                                  tgl.year == now.year &&
                                  tgl.month == now.month &&
                                  tgl.day == now.day;

                              final isAktivitas = aktivitas.any(
                                (e) => e.toLowerCase().trim() == "kunjungan 2",
                              );

                              // 🔵 BIRU MUDA → popup
                              if (status.toLowerCase() == "dijadwalkan" &&
                                  isAktivitas &&
                                  isToday) {
                                final tanggalStr =
                                    kunjunganDates[kunjungan2Id!] != null
                                    ? (kunjunganDates[kunjungan2Id!]!)
                                    : "Tanggal belum tersedia";

                                final jamStr =
                                    (jamMulai[kunjungan2Id!] != null &&
                                        jamSelesai[kunjungan2Id!] != null)
                                    ? "${jamMulai[kunjungan2Id!]} - ${jamSelesai[kunjungan2Id!]} WIB"
                                    : "Jam belum tersedia";

                                final mainText = idPelayanan == "PL02"
                                    ? "Siapkan diri Anda untuk dikunjungi oleh Gianto Dental Lab.\n📅 $tanggalStr\n⏰ $jamStr"
                                    : "Silahkan buka link Maps untuk melihat lokasi Gianto Dental Lab.\n📅 $tanggalStr\n⏰ $jamStr";

                                showReminderPopup(
                                  context: context,
                                  title: "Reminder Kunjungan 2",
                                  contentText: mainText,
                                  color: Colors.orange,
                                  icon: Icons.info,
                                  openMap: idPelayanan == "PL01"
                                      ? _openMap
                                      : null,
                                );

                                return;
                              }

                              // 🔵 BIRU TUA → buka halaman
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InformasiKunjungan2(
                                    idKunjungan: kunjungan2Id!,
                                    orderId: widget.orderId,
                                  ),
                                ),
                              );
                            } else if (i == 4 && adaUlasan) {}
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  steps[i]["icon"] as IconData,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              if (i != steps.length - 1)
                                Container(
                                  width: 3,
                                  height: 50,
                                  color: Colors.grey[300],
                                ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  steps[i]["label"] as String,
                                  style: TextStyle(
                                    color: const Color(0xFF0C3345),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),
                                // 👇 Keterangan step
                                Builder(
                                  builder: (_) {
                                    String getKeteranganStep(int i) {

                                      // Step 0 → Form Pengajuan Lanjutan
                                      if (i == 0) {
                                        if (tanggalPilihan == null || tanggalPilihan!.isEmpty) {
                                          return "Silahkan isi pengajuan lanjutan terlebih dahulu.";
                                        } else {
                                          return "Pengajuan telah diisi, silakan menunggu proses berikutnya.";
                                        }
                                      }

                                      // Step 1 → Kunjungan 1
                                      if (i == 1) {
                                        if (kunjungan1Id == null) return "";
                                        final status1 = statusKunjungan[kunjungan1Id!] ?? "";
                                        if (status1.toLowerCase() == "dijadwalkan") return "Kunjungan 1 dijadwalkan:";
                                        if (status1.toLowerCase() == "selesai") return "Kunjungan 1 selesai.";
                                        return "";
                                      }

                                      if (i == 2 && isPembuatanBaru) {
                                        // ❌ belum ada kunjungan 1
                                        if (kunjungan1Id == null) return "";

                                        final status1 = statusKunjungan[kunjungan1Id!] ?? "";
                                        if (status1.toLowerCase() != "selesai") return "";

                                        // ✅ kunjungan 2 selesai
                                        if (kunjungan2Id != null) {
                                          final status2 = statusKunjungan[kunjungan2Id!] ?? "";
                                          if (status2.toLowerCase() == "selesai") {
                                            return "Proses pembuatan selesai, siap dipasang.";
                                          }
                                        }

                                        // ✅ kunjungan 1 sudah selesai → proses pembuatan dimulai
                                        return "Proses pembuatan sedang berjalan.";
                                      }

                                      // Step 3 → Kunjungan 2
                                      if (i == 3) {
                                        if (kunjungan2Id == null) return "";
                                        final status3 = statusKunjungan[kunjungan2Id!] ?? "";
                                        if (status3.toLowerCase() == "dijadwalkan") return "Kunjungan 2 dijadwalkan:";
                                        if (status3.toLowerCase() == "selesai") return "Kunjungan 2 selesai.";
                                        return "";
                                      }

                                      // Step 4 → Selesai / Ulasan
                                      if (i == 4) {
                                        if (!adaUlasan) return "";
                                        return "Kunjungan berhasil dilakukan.";
                                      }
                                      
                                      // Step 2 untuk kondisi adaUlasan
                                      if (i == 2) {
                                        if (!adaUlasan) return "";
                                        return "Kunjungan berhasil dilakukan.";
                                      }

                                      return ""; // default kosong
                                    }

                                    String keterangan = getKeteranganStep(i);

                                    if (keterangan.isEmpty)
                                      return const SizedBox.shrink();
                                    return Text(
                                      keterangan,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                    );
                                  },
                                ),

                                // 👇 tampilkan jadwal kalau step kunjungan
                                if (i == 1 && kunjungan1Id != null)
                                  jadwalKunjunganView(kunjungan1Id!),
                                if (i == 3 && kunjungan2Id != null)
                                  jadwalKunjunganView(kunjungan2Id!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
