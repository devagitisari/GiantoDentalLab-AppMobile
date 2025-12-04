import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InformasiAkunEdit extends StatefulWidget {
  final String uid; // uid dari Firebase Auth
  const InformasiAkunEdit({super.key, required this.uid});

  @override
  State<InformasiAkunEdit> createState() => _InformasiAkunEditState();
}

class _InformasiAkunEditState extends State<InformasiAkunEdit> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = true;

  String docId = ""; // untuk simpan doc id Firestore

  String namaPengguna = "";
  String nama = "";
  String noTelepon = "";
  String email = "";

  final TextEditingController namaController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();
  final TextEditingController namaJalanController = TextEditingController();
  final TextEditingController kelurahanController = TextEditingController();
  final TextEditingController kecamatanController = TextEditingController();
  final TextEditingController kotaController = TextEditingController();
  final TextEditingController provinsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('pelanggan')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var data = snapshot.docs.first.data() as Map<String, dynamic>;
          docId = snapshot.docs.first.id;
          Map<String, dynamic> alamatMap = data['alamat'] ?? {};

          setState(() {
            namaPengguna = data['nama_pengguna'] ?? "";
            nama = data['nama_pelanggan'] ?? "";
            noTelepon = data['no_telp'] ?? "";
            email = data['email'] ?? "";

            namaController.text = nama;
            noTelpController.text = noTelepon;
            namaJalanController.text = alamatMap['nama_jalan'] ?? '';
            kelurahanController.text = alamatMap['kelurahan'] ?? '';
            kecamatanController.text = alamatMap['kecamatan'] ?? '';
            kotaController.text = alamatMap['kota'] ?? '';
            provinsiController.text = alamatMap['provinsi'] ?? '';

            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> saveData() async {
    if (docId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('pelanggan').doc(docId).update({
        'nama_pelanggan': namaController.text,
        'no_telp': noTelpController.text,
        'alamat': {
          'nama_jalan': namaJalanController.text,
          'kelurahan': kelurahanController.text,
          'kecamatan': kecamatanController.text,
          'kota': kotaController.text,
          'provinsi': provinsiController.text,
        },
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil diperbarui")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Informasi Akun")),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: TextEditingController(text: namaPengguna),
                enabled: false,
                decoration: _inputDecoration("Nama Pengguna", Icons.person),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaController,
                decoration: _inputDecoration("Nama", Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noTelpController,
                decoration: _inputDecoration("No Telepon", Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: email),
                enabled: false,
                decoration: _inputDecoration("Email", Icons.email),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaJalanController,
                decoration: _inputDecoration("Nama Jalan", Icons.map),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kelurahanController,
                decoration: _inputDecoration("Kelurahan", Icons.location_city),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kecamatanController,
                decoration: _inputDecoration("Kecamatan", Icons.place),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kotaController,
                decoration: _inputDecoration("Kota", Icons.location_city),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: provinsiController,
                decoration: _inputDecoration("Provinsi", Icons.map_outlined),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
