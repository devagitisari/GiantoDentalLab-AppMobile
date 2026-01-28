import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_project/screens/home_page.dart';
import 'package:team_project/screens/get_started.dart';
import 'package:team_project/screens/pengaturan_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilPengguna extends StatefulWidget {
  final String uid;
  const ProfilPengguna({super.key, required this.uid});

  @override
  State<ProfilPengguna> createState() => _ProfilPenggunaState();
}

class _ProfilPenggunaState extends State<ProfilPengguna> {
  String namaPengguna = "";
  String username = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void launchWhatsApp() async {
    final number = "628561098914"; // nomor WA tanpa +
    final message = Uri.encodeComponent(
      "Halo, saya ingin bertanya tentang aplikasi Gianto Dental Lab. Apakah Anda bisa membantu saya?",
    );
    final url = "https://wa.me/$number?text=$message";

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Tidak dapat membuka WhatsApp.",
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(widget.uid)
          .get();

      if (doc.exists) {
        setState(() {
          namaPengguna = doc['nama_pelanggan'] ?? "";
          username = doc['username'] ?? "";
          fotoProfile = doc['foto_profile'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildButton(
    String text,
    Color backgroundColor,
    VoidCallback onTap, {
    Widget? leadingIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 51,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: leadingIcon != null
            ? Row(
                children: [
                  leadingIcon,
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void showLogoutPopup(BuildContext context) {
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
                    const Text(
                      "Keluar Akun",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFFFF0101),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Apakah kamu yakin ingin keluar akun?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GetStarted(),
                                ),
                                (route) => false,
                              );
                            } catch (e) {
                              showAwesomePopupAutoClose(
                                title: "Gagal Logout",
                                message: "Terjadi kesalahan saat logout.\n$e",
                                color: Colors.red,
                                icon: Icons.error,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0101),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Iya, Keluar",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFFF0101),
                  radius: 40,
                  child: const Icon(
                    Icons.logout,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showWhatsAppPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
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
                    const Text(
                      "Hubungi Kami",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF25D366), // Hijau WA
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Apakah kamu ingin menghubungi kami melalui WhatsApp?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // tutup popup
                            launchWhatsApp(); // buka WA
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(140, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Ya, Hubungi",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF25D366), // Hijau WA
                child: Icon(
                  FontAwesomeIcons.whatsapp,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
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

  String? fotoProfile;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadToCloudinary(File imageFile) async {
  const cloudName = "YOUR_CLOUD_NAME";
  const uploadPreset = "YOUR_UPLOAD_PRESET";

  final uri = Uri.parse(
    "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
  );

  final request = http.MultipartRequest("POST", uri)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

  final response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final data = json.decode(resStr);
    return data['secure_url']; // ✅ URL HTTPS
  } else {
    return null;
  }
}


  Future<void> pickAndUploadPhoto() async {
  try {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final File imageFile = File(image.path);

    // Upload ke Cloudinary
    final imageUrl = await uploadToCloudinary(imageFile);

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception("Upload ke Cloudinary gagal");
    }

    // Simpan URL ke Firestore
    await FirebaseFirestore.instance
        .collection('pelanggan')
        .doc(widget.uid)
        .update({'foto_profile': imageUrl});

    setState(() {
      fotoProfile = imageUrl;
    });

    print("URL Cloudinary: $imageUrl");

    showAwesomePopupAutoClose(
      title: "Berhasil!",
      message: "Foto profil berhasil diperbarui.",
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
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C3345)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER BACK DAN JUDUL
                    // HEADER
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomePage(uid: widget.uid),
                            ),
                          ),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7E7E7),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Profil Pengguna",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0C3345),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 64,
                        ), // placeholder supaya teks tetap center
                      ],
                    ),

                    const SizedBox(height: 30),

                    // KARTU PROFIL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    (fotoProfile != null &&
                                        fotoProfile!.isNotEmpty)
                                    ? NetworkImage(fotoProfile!)
                                    : null,
                                child:
                                    (fotoProfile == null ||
                                        fotoProfile!.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF0C3345),
                                      )
                                    : null,
                              ),
                              GestureDetector(
                                onTap: pickAndUploadPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white70,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Color(0xFF0C3345),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            namaPengguna,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "@$username",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL MENU
                    Column(
                      children: [
                        buildButton(
                          "PENGATURAN",
                          const Color(0xFF0C3345),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PengaturanPage(uid: widget.uid),
                              ),
                            );
                          },
                          leadingIcon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),

                        buildButton(
                          "NOTIFIKASI",
                          const Color(0xFF0C3345),
                          () {
                            showAwesomePopupAutoClose(
                              title: "Notifikasi",
                              message: "Fitur notifikasi belum tersedia.",
                              color: Colors.orange,
                              icon: Icons.notifications,
                            );
                          },
                          leadingIcon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),


                        buildButton(
                          "HUBUNGI KAMI",
                          const Color(0xFF0C3345),
                          showWhatsAppPopup,
                          leadingIcon: const Icon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                        ),

                        buildButton(
                          "KELUAR AKUN",
                          const Color(0xFFFF0101),
                          () => showLogoutPopup(context),
                          leadingIcon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
