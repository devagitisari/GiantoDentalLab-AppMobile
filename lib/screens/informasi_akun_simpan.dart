import 'package:flutter/material.dart';
import 'pengaturan-page.dart';

class InformasiAkunSimpan extends StatefulWidget {
  const InformasiAkunSimpan({super.key});

  @override
  State<InformasiAkunSimpan> createState() => _InformasiAkunSimpanState();
}

class _InformasiAkunSimpanState extends State<InformasiAkunSimpan> {
  final usernameController = TextEditingController(text: "Devagitisar1");
  final namaController = TextEditingController(text: "Deva Gitisarii");
  final noTelpController = TextEditingController(text: "0877889284");
  final emailController = TextEditingController(text: "devagitisar49@gmail.com");
  final alamatController = TextEditingController(
    text: "Jl. Haji Maksum (Sebelah TPA Al Kautsar)\nSAWANGAN, KOTA DEPOK, JAWA BARAT, ID 116511",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 15),

              // HEADER (Back + Title + Simpan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON
                  Opacity(
                    opacity: 0.65,
                    child: Container(
                      width: 33,
                      height: 33,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7E7E7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Image.asset('assets/icons/arrow-back.png'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // TITLE TENGAH
                  const Text(
                    "Informasi Akun",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // TOMBOL SIMPAN (Kanan)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => Pengaturan()),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 33,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // FORM
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  inputField("Nama Pengguna", usernameController),
                  const SizedBox(height: 20),
                  inputField("Nama", namaController),
                  const SizedBox(height: 20),
                  inputField("No Telepon", noTelpController),
                  const SizedBox(height: 20),
                  inputField("Email", emailController),
                  const SizedBox(height: 20),
                  inputField("Alamat", alamatController, maxLines: null),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // INPUT FIELD REUSABLE
  Widget inputField(String label, TextEditingController controller,
      {int? maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF43A047)),
            ),
          ),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
