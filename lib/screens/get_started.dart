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

  void showAwesomePopup({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.info,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // ⬅ TARUH DI SINI
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Mengerti",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception("User null");

      final docRef = FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(user.uid);
      final docSnap = await docRef.get();

      // Buat data baru jika belum ada
      if (!docSnap.exists) {
        await docRef.set({
          'id_pelanggan': user.uid,
          'nama_pelanggan': user.displayName ?? '',
          'email': user.email,
          'password': '',
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
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      final data = (await docRef.get()).data()!;
      final alamat = (data['alamat'] ?? {}) as Map<String, dynamic>;

      setState(() => isLoading = false);

      if (alamat['nama_jalan'] == null || alamat['nama_jalan'] == "") {
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
      showAwesomePopup(
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
