import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_project/screens/form_alamat.dart';

class InformasiAkunEdit extends StatefulWidget {
  final String uid;
  const InformasiAkunEdit({super.key, required this.uid});

  @override
  State<InformasiAkunEdit> createState() => _InformasiAkunEditState();
}

class _InformasiAkunEditState extends State<InformasiAkunEdit> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = true;

  String docId = "";
  String namaPengguna = "";
  String nama = "";
  String noTelepon = "";
  String email = "";
  Map<String, dynamic> alamatMap = {};

  final TextEditingController namaController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

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
          alamatMap = data['alamat'] ?? {};

          setState(() {
            namaPengguna = data['username'] ?? "";
            nama = data['nama_pelanggan'] ?? "";
            noTelepon = data['no_telp'] ?? "";
            email = data['email'] ?? "";

            usernameController.text = namaPengguna;
            namaController.text = nama;
            noTelpController.text = noTelepon;

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

  Future<void> saveData() async {
    if (docId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(docId)
          .update({
            'username': usernameController.text,
            'nama_pelanggan': namaController.text,
            'no_telp': noTelpController.text,
            'alamat': alamatMap,
            'updated_at': FieldValue.serverTimestamp(),
          });

      showAwesomePopupAutoClose(
        title: "Berhasil",
        message: "Data berhasil diperbarui",
        color: Colors.green,
        icon: Icons.check_circle,
      );
    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Terjadi kesalahan: $e",
        color: Colors.red,
        icon: Icons.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF0C3345))
          : null,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 18,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Color(0xFF0C3345),
      ),
      hintStyle: const TextStyle(
        fontSize: 13,
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
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    String alamatRingkasan = alamatMap.isNotEmpty
        ? "${alamatMap['nama_jalan'] ?? ''}, ${alamatMap['kelurahan'] ?? ''}, ${alamatMap['kecamatan'] ?? ''}, ${alamatMap['kota'] ?? ''}, ${alamatMap['provinsi'] ?? ''}"
        : "Belum diisi";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Informasi Akun",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0C3345),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7E7E7),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF0C3345),
                                size: 28
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // FORM (dibuat scroll)
                  Expanded(
                    child: ListView(
                      children: [
                        TextField(
                          controller: usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            "Nama Pengguna",
                            icon: Icons.person,
                            hint: "Masukkan nama pengguna",
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: namaController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            "Nama",
                            icon: Icons.person_outline,
                            hint: "Masukkan nama lengkap",
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: noTelpController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            "No Telepon",
                            icon: Icons.phone,
                            hint: "Masukkan nomor telepon",
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: TextEditingController(text: email),
                          enabled: false,
                          decoration: _inputDecoration(
                            "Email",
                            icon: Icons.email,
                            hint: "Email akun",
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    IsiAlamatWithMap(uid: widget.uid),
                              ),
                            ).then((value) {
                              if (value != null &&
                                  value is Map<String, dynamic>) {
                                setState(() => alamatMap = value);
                              }
                            });
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              "Alamat",
                              icon: Icons.location_on,
                              hint: "Masukkan alamat lengkap",
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alamatRingkasan,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF0C3345),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BUTTON SIMPAN
                        ElevatedButton(
                          onPressed: isLoading ? null : saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C3345),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0C3345)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
