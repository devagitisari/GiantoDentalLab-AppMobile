import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/pengajuan_list.dart';
import 'package:team_project/screens/profil_pengguna.dart';
import 'package:team_project/screens/garansi_list.dart';
import 'package:team_project/screens/jadwal_kunjungan.dart';
import 'package:team_project/screens/riwayat.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Banner config
  List<Map<String, dynamic>> _jadwalList = [];
  bool _isJadwalInitialized = false;

  late final PageController _jadwalController = PageController(initialPage: _loopStart);

  Timer? _jadwalAutoTimer;

  int get currentJadwalIndex {
    return (_jadwalController.hasClients ? (_jadwalController.page?.round() ?? 0) : 0) % _jadwalList.length;
  }



  static const int _totalBanners = 3;
  static const int _loopStart = 10000;
  late final PageController _bannerController = PageController(
    viewportFraction: 1.0,
    initialPage: _loopStart,
  );

  int _currentBanner = _loopStart;
  Timer? _bannerTimer;
  bool _isUserSwiping = false;

  // USER DISPLAY NAME
  String? userName;
  String? fotoProfile;
  bool isLoadingUser = true;

  @override
  void initState() {
      super.initState();
      _loadUserName();
      _autoScrollBanner();
      _listenBannerPage();
      _listenJadwalStream();
  }

  Future<void> _loadUserName() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        final snap = await FirebaseFirestore.instance
            .collection('pelanggan')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final data = Map<String, dynamic>.from(snap.docs.first.data());
          setState(() {
            userName = data['nama_pelanggan'] ?? "Pelanggan";
            fotoProfile = data['foto_profile']; // ambil foto profile
            isLoadingUser = false;
          });
        } else {
          setState(() {
            userName = "Pelanggan";
            isLoadingUser = false;
          });
        }
      } else {
        setState(() {
          userName = "Pelanggan";
          isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Pelanggan";
        isLoadingUser = false;
      });
    }
  }

  void _listenJadwalStream() {
    streamJadwal().listen((data) {
      final visibleJadwal = data
          .where((item) =>
              (item['status'] ?? '').toString().toLowerCase() != 'selesai')
          .toList();

      if (visibleJadwal.isEmpty) return;

      setState(() {
        _jadwalList = visibleJadwal;
      });

      if (!_isJadwalInitialized) {
        _isJadwalInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_jadwalController.hasClients) {
            _startJadwalAutoScroll();
          }
        });
      }
    });
  }


  Widget _buildJadwalPageView() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamJadwal(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0C3345),
              strokeWidth: 3, // ganti warna sesuai tema
            ),
          );
        }
        
        final visibleJadwal = snapshot.data!
            .where((item) => (item['status'] ?? '').toLowerCase() != 'selesai')
            .toList();

        if (visibleJadwal.isEmpty) return _emptyJadwalCard();

        return SizedBox(
          height: 180,
          child: PageView.builder(
            key: ValueKey(visibleJadwal.length), // <--- ini penting supaya PageView rebuild
            scrollDirection: Axis.vertical,
            controller: _jadwalController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (_) {
              _jadwalAutoTimer?.cancel();
              _startJadwalAutoScroll();
            },
            itemCount: visibleJadwal.length,
            itemBuilder: (context, index) {
              final item = visibleJadwal[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JadwalKunjunganPage(
                        idPelanggan: widget.uid,
                        selectedJadwal: item,
                      ),
                    ),
                  );
                },
                child: jadwalCard(item),
              );
            },
          ),
        );
      },
    );
  }



  void _startJadwalAutoScroll() {
    if (_jadwalList.length <= 1) return;
    if (!_jadwalController.hasClients) return;

    _jadwalAutoTimer?.cancel();

    _jadwalAutoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_jadwalController.hasClients) return;

      final currentPage = _jadwalController.page?.round() ?? 0;
      int nextPage = currentPage + 1;

      if (nextPage >= _jadwalList.length) {
        // ⬇️ BUKAN animate
        _jadwalController.jumpToPage(0);
        return;
      }

      _jadwalController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _autoScrollBanner() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_bannerController.hasClients && !_isUserSwiping) {
        _bannerController.animateToPage(
          _currentBanner + 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _listenBannerPage() {
    _bannerController.addListener(() {
      int rounded = _bannerController.page?.round() ?? _currentBanner;
      if (rounded != _currentBanner) {
        setState(() => _currentBanner = rounded);
      }
    });
  }

  Stream<List<Map<String, dynamic>>> streamJadwal() async* {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      // Ambil semua order milik pelanggan
      final orderSnap = await firestore
          .collection('order')
          .where('id_pelanggan', isEqualTo: widget.uid)
          .get();

      if (orderSnap.docs.isEmpty) {
        yield [];
        return;
      }

      final listOrders = orderSnap.docs;

      // Prefetch layanan & pelayanan
      final layananSnap = await firestore.collection('layanan').get();
      final pelayananSnap = await firestore.collection('pelayanan').get();

      final layananMap = {
        for (var doc in layananSnap.docs) doc['id_layanan']: doc['nama_layanan']
      };
      final pelayananMap = {
        for (var doc in pelayananSnap.docs)
          doc['id_pelayanan']: doc['nama_pelayanan']
      };

      // Stream snapshots dari collection 'kunjungan'
      yield* firestore.collection('kunjungan').snapshots().asyncMap(
        (kunjunganSnap) async {
          List<Map<String, dynamic>> result = [];

          for (var orderDoc in listOrders) {
            final orderData = orderDoc.data();
            final idOrder = orderDoc.id;
            final idPelayanan = orderData['id_pelayanan'] ?? "";
            final idLayanan = orderData['id_layanan'] ?? "";

            // Ambil jadwal untuk order

          final jadwalSnap = await firestore
              .collection('jadwal')
              .where('id_order', isEqualTo: idOrder)
              .get();

          for (var jadwalDoc in jadwalSnap.docs) {
            final idJadwal = jadwalDoc.id;

            // Ambil kunjungan terkait jadwal
            final kunjunganForJadwal = kunjunganSnap.docs
                .where((k) => k.data()['id_jadwal'] == idJadwal);

            for (var kunjunganDoc in kunjunganForJadwal) {
              final kunjunganData = kunjunganDoc.data();
              
              // Ambil status order dan status kunjungan
              final statusOrder = (orderData['status'] ?? '').toString().toLowerCase();
              final statusKunjungan = (kunjunganData['status'] ?? '').toString().toLowerCase();

              // Skip kalau order dibatalkan atau ditolak
              if (statusOrder == 'dibatalkan' || statusOrder == 'ditolak') continue;

              // Skip juga kalau jadwal kunjungan selesai
              if (statusKunjungan == 'selesai') continue;

              final Map<String, dynamic> jadwalKunjungan =
                  kunjunganData['jadwal_kunjungan'] ?? {};

              final rawTanggal = jadwalKunjungan['tanggal'] ?? '';
              final jamMulai = jadwalKunjungan['jam_mulai'] ?? '00:00';
              final jamSelesai = jadwalKunjungan['jam_selesai'] ?? '00:00';

              DateTime tanggal;
              try {
                tanggal = DateFormat("dd/MM/yyyy").parse(rawTanggal);
              } catch (_) {
                tanggal = DateTime.now();
              }

              if (tanggal.isBefore(today)) continue;

              result.add({
                "tanggal": tanggal,
                "jam": "$jamMulai - $jamSelesai WIB",
                "judul": kunjunganData['aktivitas'] ?? orderData['aktivitas'] ?? 'Kunjungan',
                "deskripsi": kunjunganData['keterangan'] ?? '',
                "status": kunjunganData['status'] ?? orderData['status'] ?? 'Dijadwalkan',
                "nama_pelayanan": idPelayanan != "" ? (pelayananMap[idPelayanan] ?? "") : "",
                "nama_layanan": idLayanan != "" ? (layananMap[idLayanan] ?? "") : "",
              });
            }
          }

          }

          // Urutkan dari tanggal terdekat
          result.sort((a, b) =>
              (a['tanggal'] as DateTime).compareTo(b['tanggal'] as DateTime));

          return result;
        },
      );
    } catch (e) {
      print("Error streamJadwal: $e");
      yield [];
    }
  }


  Widget jadwalCard(Map<String, dynamic> item) {
    final tanggal = item["tanggal"] as DateTime;
    final formattedDate = DateFormat("d MMMM yyyy", "id_ID").format(tanggal);
    final jam = item["jam"] ?? "00:00 - 00:00 WIB";
    final judul = item["judul"] ?? "-";
    final deskripsi = item["deskripsi"] ?? "-";
    final namaLayanan = item["nama_layanan"] ?? "-";
    final namaPelayanan = item["nama_pelayanan"] ?? "-";
    final status = item["status"] ?? "Dijadwalkan";

    Color statusColor;
    switch (status.toLowerCase()) {
      case "dijadwalkan":
        statusColor = Colors.orange.shade400;
        break;
      case "selesai":
        statusColor = Colors.green.shade400;
        break;
      default:
        statusColor = Colors.grey.shade400;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C3345), Color(0xFF1D7EAB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Konten utama card
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded( // ⬅️ INI KUNCINYA
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 17,
                            color: Color(0xFF0C3345),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Color(0xFF0C3345),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Spacer(), // ⬅️ bikin kanan benar-benar mentok
                          const Icon(
                            Icons.access_time,
                            size: 17,
                            color: Color(0xFF0C3345),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            jam,
                            style: const TextStyle(
                              color: Color(0xFF0C3345),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "$judul  ",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextSpan(
                      text: deskripsi,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                maxLines: 1, // batasi satu baris
                overflow: TextOverflow.ellipsis, // teks panjang dipotong dengan ...
              ),


              const SizedBox(height: 6),
              // Layanan | Pelayanan
              Row(
                children: [
                  Text(
                    namaLayanan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      "|",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Text(
                    namaPelayanan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ), // beri space supaya status tidak tumpang tindih
            ],
          ),

          // Status badge di kanan bawah
          Positioned(
            bottom: 0, // bawah
            right: 0, // kanan
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _jadwalAutoTimer?.cancel();
    _jadwalController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerWidth = screenWidth - 40;
    final double bannerHeight = bannerWidth * 0.65;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             // HEADER MODERN MINIMALIS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Teks Halo + Nama
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, ${isLoadingUser ? "..." : userName} 👋",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0C3345),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Selamat datang kembali!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),

                    // Avatar kecil dengan shadow tipis
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilPengguna(uid: widget.uid),
                          ),
                        ).then((_) => _loadUserName());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: fotoProfile != null && fotoProfile!.isNotEmpty
                                  ? Image.network(
                                      fotoProfile!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return const Icon(Icons.person,
                                            size: 24, color: Colors.black54);
                                      },
                                    )
                                  : const Icon(Icons.person,
                                      size: 24, color: Colors.black54),
                            ),
                          )

                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // BANNER
              _buildBanner(bannerWidth, bannerHeight),

              const SizedBox(height: 18),

              // Jadwal Hari Ini
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Agenda Kunjungan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildJadwalPageView(),
                  ],
                ),
              ),


              const SizedBox(height: 20),

              // Layanan / Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildCardOption(
                      Icons.assignment_add,
                      "Pengajuan Kunjungan",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PengajuanKunjunganListPage(uid: widget.uid),
                          ),
                        );
                      },
                    ),
                    _buildCardOption(Icons.schedule, "Jadwal Kunjungan", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JadwalKunjunganPage(idPelanggan: widget.uid),
                        ),
                      );
                    }),
                    _buildCardOption(Icons.shield, "Garansi & Keluhan", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PengajuanGaransiListPage(uid: widget.uid),
                        ),
                      );
                    }),
                    _buildCardOption(Icons.history, "Riwayat Layanan", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RiwayatPage(uidPelanggan: widget.uid),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyJadwalCard() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          "Tidak ada jadwal yang akan datang",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(double width, double height) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9, // atau sesuaikan ratio banner di Figma
          child: Listener(
            onPointerDown: (_) => _isUserSwiping = true,
            onPointerUp: (_) => _isUserSwiping = false,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: 999999,
              itemBuilder: (context, index) {
                int realIndex = index % _totalBanners;
                double value = 1.0;
                if (_bannerController.position.haveDimensions) {
                  final page =
                      _bannerController.page; // <-- tambahkan null check
                  if (page != null) {
                    value = (page - index).abs();
                    value = 1 - (value * 0.15);
                  }
                }
                return Transform.scale(
                  scale: value,
                  child: _bannerItem(
                    'assets/images/Banner${realIndex + 1}.png',
                    double.infinity,
                    double.infinity,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalBanners, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: (_currentBanner % _totalBanners == index) ? 18 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: (_currentBanner % _totalBanners == index)
                    ? Colors.black
                    : Colors.grey.shade500,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _bannerItem(String asset, double width, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCardOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // ini bakal jalankan navigasi
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(5, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Tombol "Lihat" di kanan atas
            Positioned(
              top: 12,
              right: 8,
              child: Container(
                width: 49,
                height: 19,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B929C),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Lihat",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0C3345), Color(0xFF155A7A)],
                      ),
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Color(0xFF0C3345),
                    ),
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
