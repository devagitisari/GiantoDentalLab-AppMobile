import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home-page.dart';

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class PelangganService {
  final CollectionReference _pelangganCollection = FirebaseFirestore.instance
      .collection('pelanggan');

  Future<void> tambahPelanggan(Map<String, dynamic> data) async {
    await _pelangganCollection.add(data);
  }
}

class IsiAlamat extends StatefulWidget {
  final String uid;
  const IsiAlamat({super.key, required this.uid});

  @override
  State<IsiAlamat> createState() => _IsiAlamatState();
}

class _IsiAlamatState extends State<IsiAlamat> {
  final _alamatController = TextEditingController();
  bool _isLoading = false;

  Future<void> _simpanData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login");

      await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(user.uid)
          .update({
        'alamat': {
          'nama_jalan': _alamatController.text.trim(),
          'detail_jalan': "",
          'gmaps': {'latitude': "", 'longitude': "", 'link': ""},
          'kecamatan': "",
          'kelurahan': "",
          'kode_pos': "",
          'kota': "",
          'provinsi': "",
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Data berhasil disimpan")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(uid: user.uid)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7E7E7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Image.asset(
                      'assets/icons/arrow-back.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),
            const Text(
              'Sign Up',
              style: TextStyle(
                color: Color(0xFF0C3345),
                fontSize: 26,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Daftar akun dan mulai perawatan gigi anda bersama Gianto Dental Lab',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xFF0C3345),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),

            TextFormField(
              controller: _alamatController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Masukkan alamat anda",
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Color(0xFF999999),
                ),
                labelText: "Alamat",
                labelStyle: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0C3345),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFF999999)),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: _isLoading ? null : _simpanData,

              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0C3345),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              child: Text(
                _isLoading ? "Menyimpan..." : "Continue",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
