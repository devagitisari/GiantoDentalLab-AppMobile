import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_project/screens/pengajuan_list.dart';

class FormPengajuanKunjungan extends StatefulWidget {
  final String? uid;
  final String? orderId; // tambahkan ini

  const FormPengajuanKunjungan({super.key, this.uid, this.orderId});

  @override
  State<FormPengajuanKunjungan> createState() => _FormPengajuanKunjunganState();
}

class _FormPengajuanKunjunganState extends State<FormPengajuanKunjungan> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  String? pernahJasa;
  File? pickedImage; // Foto dari device
  String? fotoUrl; // URL foto di Firebase Storage setelah submit
  bool isLoading = false;
  bool isPickingImage = false;

  @override
  void initState() {
    super.initState();
    fetchPelangganData();
    if (widget.orderId != null) {
      fetchOrderData(widget.orderId!);
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    keluhanController.dispose();
    super.dispose();
  }

  Future<void> fetchOrderData(String orderId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('order')
          .doc(orderId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          namaController.text = data['nama'] ?? '';
          teleponController.text = data['telepon'] ?? '';
          keluhanController.text = data['keluhan'] ?? '';
          pernahJasa = data['pemakaian_jasa'];
          fotoUrl = data['foto']; // foto lama
        });
      }
    } catch (e) {
      print("Error fetching order data: $e");
    }
  }

  Future<void> showAwesomePopupAutoClose({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.check_circle,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
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

  Future<String?> uploadToCloudinary(File imageFile) async {
    const cloudName = "YOUR_CLOUD_NAME";
    const uploadPreset = "YOUR_UPLOAD_PRESET";

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = "team_project"
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData =
          jsonDecode(await response.stream.bytesToString());
      return responseData['secure_url']; // URL HTTPS
    } else {
      print("Upload Cloudinary gagal: ${response.statusCode}");
      return null;
    }
  }


  // Ambil data pelanggan otomatis
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

  // Pick foto dari gallery
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

  // Preview & hapus foto sebelum submit
  Widget buildImagePreview() {
    if (pickedImage != null) {
      // Foto baru dipilih
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD0D0D0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(pickedImage!, fit: BoxFit.cover),
            ),
          ),
          // Tombol hapus foto
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() => pickedImage = null);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Hapus Foto",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    } else if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      // Foto lama (dari Firestore)
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD0D0D0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(fotoUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Future<void> submitForm() async {
    if (namaController.text.isEmpty ||
        teleponController.text.isEmpty ||
        keluhanController.text.isEmpty ||
        pernahJasa == null) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Harap isi semua field",
        color: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? uploadedFotoUrl;

      if (pickedImage != null) {
        uploadedFotoUrl = await uploadToCloudinary(pickedImage!);
      }

      final docRef = widget.orderId != null
          ? FirebaseFirestore.instance.collection('order').doc(widget.orderId)
          : FirebaseFirestore.instance.collection('order').doc();

      String status = "menunggu";
      if (widget.orderId != null) {
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          status = docSnapshot['status'] ?? "menunggu";
        }
      }

      // Simpan di collection order
      await docRef.set({
        'id_order': docRef.id,
        'id_pelanggan': widget.uid,
        'pemakaian_jasa': pernahJasa,
        'keluhan': keluhanController.text,
        'foto': uploadedFotoUrl ?? fotoUrl ?? "",
        'status': status,
        'created_at': widget.orderId != null
            ? FieldValue.serverTimestamp()
            : FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      showAwesomePopupAutoClose(
        title: "Sukses",
        message: widget.orderId != null
            ? "Detail berhasil diperbarui"
            : "Pengajuan berhasil dikirim",
        color: Colors.green,
        icon: Icons.check_circle,
      );

      Future.delayed(const Duration(milliseconds: 1200), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PengajuanKunjunganListPage(
              uid: FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
          ),
          (route) => false,
        );
      });
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PengajuanKunjunganListPage(
                            uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
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
                      child: const Icon(Icons.arrow_back, color: Color(0xFF0C3345), size: 28),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Form Pengajuan',
                    style: TextStyle(
                      color: Color(0xFF0C3345),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(flex: 2),
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
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Nama",
                  hintText: "Nama pelanggan",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C3345),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                    fontFamily: 'Poppins',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
                readOnly: true,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "No Telepon",
                  hintText: "Nomor pelanggan",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C3345),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                    fontFamily: 'Poppins',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  border: formOutlineInputBorder,
                  enabledBorder: formOutlineInputBorder,
                  focusedBorder: formOutlineInputBorder,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Upload Foto dengan style label sama seperti TextFormField
              GestureDetector(
                onTap: pickImage,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Foto",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    floatingLabelStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0C3345),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    border: formOutlineInputBorder,
                    enabledBorder: formOutlineInputBorder,
                    focusedBorder: formOutlineInputBorder,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  child: Row(
                    children: [
                      if (pickedImage != null)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                pickedImage!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => setState(() => pickedImage = null),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        const Icon(
                          Icons.upload_file,
                          size: 36,
                          color: Color(0xFFD0D0D0),
                        ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          pickedImage != null
                              ? "Foto siap diupload"
                              : "Upload Foto",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    fontSize: 18,
                    color: Color(0xFF0C3345),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
                    fontFamily: 'Poppins',
                  ),
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
                    fontSize: 18,
                    color: Color(0xFF0C3345),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                    fontFamily: 'Poppins',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
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
