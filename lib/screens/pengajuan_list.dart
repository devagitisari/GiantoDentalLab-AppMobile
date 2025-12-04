import 'package:flutter/material.dart';
import 'package:team_project/screens/form_pengajuan_kunjungan.dart';
import 'package:team_project/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengajuanKunjunganListPage extends StatefulWidget {
  final String uid;
  const PengajuanKunjunganListPage({super.key, required this.uid});

  @override
  State<PengajuanKunjunganListPage> createState() =>
      _PengajuanKunjunganListPageState();
}

class _PengajuanKunjunganListPageState
    extends State<PengajuanKunjunganListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final String idPelanggan;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      idPelanggan = user.uid; // ambil UID user login
    } else {
      idPelanggan = '';
    }
  }

  Stream<QuerySnapshot> getPengajuanStream() {
    return _firestore
        .collection('pengajuan_kunjungan')
        .where('id_pelanggan', isEqualTo: idPelanggan)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // ==================== HEADER ====================
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: 100, // <<=== INI YANG BIKIN AREA JADI FULL
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// BACK BUTTON
                      Positioned(
                        left: 16,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(uid: idPelanggan),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE7E7E7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      /// TITLE
                      const Text(
                        'Pengajuan Kunjungan',
                        style: TextStyle(
                          color: Color(0xFF0C3345),
                          fontSize: 21,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================== LIST PENGAJUAN ====================
            Positioned.fill(
              top: 160,
              bottom: 100,
              child: StreamBuilder<QuerySnapshot>(
                stream: getPengajuanStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pengajuan kunjungan',
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
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 30,
                      right: 30,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        height: 101,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF0C3345), Color(0xFF1D7EAB)],
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 18,
                              top: 15,
                              child: Text(
                                data['judul'] ?? 'Pengajuan Baru',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              top: 60,
                              child: Text(
                                data['tanggal'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 18,
                              top: 60,
                              child: Container(
                                width: 85,
                                height: 17,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17.17),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    data['status'] ?? 'Menunggu',
                                    style: TextStyle(
                                      color: data['status'] == 'Disetujui'
                                          ? const Color(0xFF43A047)
                                          : (data['status'] == 'Tidak Disetujui'
                                                ? const Color(0xFFFF2626)
                                                : Colors.black),
                                      fontSize: 8.59,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ==================== TOMBOL TAMBAH ====================
            Positioned(
              right: 30,
              bottom: 50,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FormPengajuanKunjungan(uid: idPelanggan),
                    ),
                  );
                  // StreamBuilder otomatis update list
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C3345),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.add, color: Colors.white, size: 35),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
