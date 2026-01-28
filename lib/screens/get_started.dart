import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_project/screens/form_alamat.dart';
import 'package:team_project/screens/home_page.dart';
import 'package:team_project/screens/login_page.dart';
import 'package:flutter/gestures.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  bool isLoading = false;

  Future<String> generateUniqueUsername(String nama) async {
    String base = nama.toLowerCase().replaceAll(" ", "");
    String username = "";
    bool exists = true;

    while (exists) {
      int randomNum = DateTime.now().millisecondsSinceEpoch % 10000;
      username = "$base$randomNum";

      final check = await FirebaseFirestore.instance
          .collection('pelanggan')
          .where('username', isEqualTo: username)
          .get();

      exists = check.docs.isNotEmpty;
    }

    return username;
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

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception("User null");

      final docRef =
          FirebaseFirestore.instance.collection('pelanggan').doc(user.uid);
      final docSnap = await docRef.get();

      // ==========================================================
      // 🔰 USER BARU → Buat username + foto profile default
      // ==========================================================
      if (!docSnap.exists) {
        String username =
            await generateUniqueUsername(user.displayName ?? "user");

        await docRef.set({
          'id_pelanggan': user.uid,
          'nama_pelanggan': user.displayName ?? '',
          'username': username,
          'email': user.email,
          'password': '', // google tidak punya password
          'foto_profile': 
              "https://i.ibb.co/7z7FQ5k/default-profile.png",
          'alamat': {
            'detail_jalan': "",
            'gmaps': {'latitude': "", 'longitude': "", 'link': ""},
            'kecamatan': "",
            'kelurahan': "",
            'kota': "",
            'nama_jalan': "",
            'provinsi': "",
          },
          'no_telp': '',
          'status_akun': 'aktif',
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // Ambil data terbaru
      final data = (await docRef.get()).data()!;

      // ==========================================================
      // 🔰 CEK STATUS AKUN
      // ==========================================================
      final status = data['status_akun'] ?? 'aktif';
      if (status == 'nonaktif') {
        setState(() => isLoading = false);
        showAwesomePopupAutoClose(
          title: "Akun Nonaktif",
          message: "Akun Anda saat ini nonaktif. Silakan hubungi admin.",
          color: Colors.red,
          icon: Icons.block,
        );
        return; // hentikan login
      }

      // ==========================================================
      // 🔰 USER SUDAH ADA → pastikan username & foto_profile ada
      // ==========================================================
      if (!data.containsKey('username') || data['username'] == "") {
        String username =
            await generateUniqueUsername(data['nama_pelanggan'] ?? "user");
        await docRef.update({'username': username});
      }

      if (!data.containsKey('foto_profile') || data['foto_profile'] == "") {
        await docRef.update({
          'foto_profile': 
              user.photoURL ?? "https://i.ibb.co/7z7FQ5k/default-profile.png"
        });
      }

      // ==========================================================
      // 🔰 CEK ALAMAT untuk routing
      // ==========================================================
      final alamat = (data['alamat'] ?? {}) as Map<String, dynamic>;

      setState(() => isLoading = false);

      if ((alamat['nama_jalan'] ?? "").isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IsiAlamatWithMap(uid: user.uid)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(uid: user.uid)),
        );
      }
    } catch (error) {
      setState(() => isLoading = false);
      showAwesomePopupAutoClose(
        title: "Gagal Login Google",
        message: "$error",
        color: Colors.red,
        icon: Icons.error_rounded,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/imgGetStarted.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // subtle gradient overlay
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.5),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 1.5],
                      ),
                    ),
                  ),
                ),

                // Text block
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 250),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            'Mulai Sekarang',
                            style: TextStyle(
                              color: Color(0xFF0C3345),
                              fontSize: 26,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              height: 0.95,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            'Daftar untuk melanjutkan konsultasi dan layanan pemasangan gigi tiruan anda',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color(0xFF0C3345),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Google button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logoGoogle.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Lanjutkan dengan Google',
                                  style: TextStyle(
                                    color: Color(0xFF0C3345),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Text(
                          'atau',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),

                        // Email button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C3345),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Lanjutkan dengan Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Login link
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Sudah memiliki akun? ',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: 'Log In',
                                style: const TextStyle(
                                  color: Color(0xFF0C3345),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // overlay loading (tambahkan state isLoading)
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
