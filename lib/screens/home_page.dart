import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/pengajuan_list.dart';
import 'package:team_project/screens/pengaturan_page.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Banner config
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
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _autoScrollBanner();
    _listenBannerPage();
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

  @override
  void dispose() {
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
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, ${isLoadingUser ? "..." : userName}! 👋",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Selamat datang kembali!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PengaturanPage(uid: widget.uid), // kirim uid
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.black87,
                        ),
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
                      "Jadwal Hari Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('jadwal')
                          .where('uid', isEqualTo: widget.uid)
                          .where('status', isEqualTo: 'kunjungan')
                          .orderBy('jdwl_order')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _emptyJadwalCard();
                        }

                        final now = DateTime.now();
                        final jadwalDocs = snapshot.data!.docs.where((doc) {
                          final jdwl = doc.data()['jdwl_order'] ?? "";
                          if (jdwl.isEmpty) return false;
                          try {
                            final dt = DateTime.parse(jdwl);
                            return dt.isAfter(now);
                          } catch (_) {
                            return false;
                          }
                        }).toList();

                        if (jadwalDocs.isEmpty) {
                          return _emptyJadwalCard();
                        }

                        final displayDocs = jadwalDocs.take(2).toList();

                        return Column(
                          children: displayDocs.map((doc) {
                            final data = doc.data();
                            final jdwl = data['jdwl_order'] ?? "";
                            String dateStr = "-", timeStr = "-";

                            try {
                              final dt = DateTime.parse(jdwl);
                              dateStr = DateFormat(
                                "dd MMM yyyy",
                                "id_ID",
                              ).format(dt);
                              timeStr = DateFormat("HH:mm").format(dt);
                            } catch (_) {}

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildJadwalCard(
                                title: data['aktivitas'] ?? "-",
                                description: data['keterangan'] ?? "-",
                                date: dateStr,
                                time: timeStr,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Layanan / Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
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
                    _buildCardOption(
                      Icons.schedule,
                      "Jadwal Kunjungan",
                      () {}, // nanti bisa ditambah navigasi lain
                    ),
                    _buildCardOption(Icons.shield, "Garansi & Keluhan", () {}),
                    _buildCardOption(Icons.history, "Riwayat Layanan", () {}),
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          "Belum ada jadwal yang akan datang.",
          style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
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
                  value = (_bannerController.page! - index).abs();
                  value = 1 - (value * 0.15);
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

  Widget _buildJadwalCard({
    required String title,
    required String description,
    required String date,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3345),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: -0.32,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 2.1,
              letterSpacing: -0.32,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF0C3345),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF0C3345),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 2.1,
                        letterSpacing: -0.32,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF0C3345),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF0C3345),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 2.1,
                        letterSpacing: -0.32,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
