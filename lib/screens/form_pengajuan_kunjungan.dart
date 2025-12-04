import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';

class FormPengajuanKunjungan extends StatefulWidget { 
  final String uid;
  const FormPengajuanKunjungan({super.key, required this.uid});

  @override
  State<FormPengajuanKunjungan> createState() => _FormPengajuanKunjunganState();
}

class _FormPengajuanKunjunganState extends State<FormPengajuanKunjungan> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  String? pernahJasa;
  File? pickedImage; // File gambar dari device
  String? fotoUrl;   // URL gambar di Firebase Storage
  bool isLoading = false;
  bool isPickingImage = false;

  @override
  void initState() {
    super.initState();
    fetchPelangganData(); // Ambil data otomatis saat form dibuka
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    keluhanController.dispose();
    super.dispose();
  }

  // Ambil data pelanggan dari Firestore
  Future<void> fetchPelangganData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(widget.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          namaController.text = data['nama_pelanggan'] ?? "";
          teleponController.text = data['no_telp'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching pelanggan data: $e");
    }
  }

  // Fungsi pick foto dari gallery
  Future<void> pickImage() async {
    if (isPickingImage) return;
    isPickingImage = true;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      print(e);
    } finally {
      isPickingImage = false;
    }
  }

  // Fungsi upload ke Firebase Storage
  Future<void> uploadImage() async {
    if (pickedImage == null) return;

    String fileName = "order_images/${DateTime.now().millisecondsSinceEpoch}.png";
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(pickedImage!);

    final snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      fotoUrl = downloadUrl;
    });
  }

  // Submit form ke Firestore
  Future<void> submitForm() async {
    if (namaController.text.isEmpty ||
        teleponController.text.isEmpty ||
        keluhanController.text.isEmpty ||
        pernahJasa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua field")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (pickedImage != null) {
        await uploadImage();
      }

      String orderId = FirebaseFirestore.instance.collection('order').doc().id;

      await FirebaseFirestore.instance.collection('order').doc(orderId).set({
        'id_order': orderId,
        'id_pelanggan': widget.uid,
        'id_layanan': "",
        'id_pelayanan': "",
        'pemakaian_jasa': pernahJasa,
        'nama': namaController.text,
        'telepon': teleponController.text,
        'keluhan': keluhanController.text,
        'foto': fotoUrl ?? "",
        'status': "pending",
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengajuan berhasil dikirim")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  // BACK BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
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
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),

                  // TITLE
                  const Text(
                    'Form Pengajuan',
                    style: TextStyle(
                      color: Color(0xFF0C3345),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                'Isi informasi di bawah untuk melakukan pengajuan konsultasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),



              // Nama
              TextFormField(
                controller: namaController,
                readOnly: true, // jadi user tidak bisa ubah
                decoration: InputDecoration(
                  labelText: "Nama",
                  hintText: "Nama pelanggan",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontFamily: 'Poppins'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: formOutlineInputBorder,
                  enabledBorder: formOutlineInputBorder,
                  focusedBorder: formOutlineInputBorder,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Telepon
              TextFormField(
                controller: teleponController,
                readOnly: true, // jadi user tidak bisa ubah
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "No Telepon",
                  hintText: "Nomor pelanggan",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontFamily: 'Poppins'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: formOutlineInputBorder,
                  enabledBorder: formOutlineInputBorder,
                  focusedBorder: formOutlineInputBorder,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Foto
              TextFormField(
                readOnly: true,
                onTap: () async {
                  if (isPickingImage) return; // mencegah dipanggil lagi
                  isPickingImage = true;

                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);

                    if (picked != null) {
                      setState(() {
                        pickedImage = File(picked.path);
                      });
                    }
                  } catch (e) {
                    print(e);
                  } finally {
                    isPickingImage = false;
                  }
                },
                decoration: InputDecoration(
                  labelText: "Foto",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: pickedImage != null ? "Foto siap diupload" : "Upload Foto",
                  labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                    fontFamily: 'Poppins',
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: formOutlineInputBorder,
                  enabledBorder: formOutlineInputBorder,
                  focusedBorder: formOutlineInputBorder,
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: const Icon(Icons.upload_file, color: Color(0xFFD0D0D0)),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown
              DropdownButtonFormField<String>(
                value: pernahJasa,
                decoration: InputDecoration(
                  labelText: "Pernah memakai jasa?",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: formOutlineInputBorder,
                  enabledBorder: formOutlineInputBorder,
                  focusedBorder: formOutlineInputBorder,
                  fillColor: Colors.white,
                  filled: true,
                ),
                hint: const Text(
                  "-- Pilih Jawaban --",
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontFamily: 'Poppins'),
                ),
                items: const [
                  DropdownMenuItem(value: 'Ya', child: Text('Ya')),
                  DropdownMenuItem(value: 'Tidak', child: Text('Tidak')),
                ],
                onChanged: (value) => setState(() => pernahJasa = value),
              ),
              const SizedBox(height: 16),

              // Keluhan
              TextFormField(
                controller: keluhanController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Catatan Keluhan",
                  hintText: "Masukkan Keluhan",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontFamily: 'Poppins'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: formOutlineInputBorder,
                  enabledBorder: formOutlineInputBorder,
                  focusedBorder: formOutlineInputBorder,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3345),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ajukan Kunjungan",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins'),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

const formOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);
