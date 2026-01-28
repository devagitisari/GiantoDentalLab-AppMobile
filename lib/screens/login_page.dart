import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/home_page.dart';
import 'package:team_project/screens/form_alamat.dart';
import 'package:team_project/screens/sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
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

  Widget loadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Future<void> signIn() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 150));

    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = userCredential.user;

      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('pelanggan').doc(user.uid);
        final docSnap = await docRef.get();

        if (!docSnap.exists) {
          showAwesomePopupAutoClose(
            title: "Akun Tidak Terdaftar",
            message: "Email belum pernah digunakan. Silakan Sign Up dulu.",
            color: Colors.red,
            icon: Icons.warning_amber_rounded,
          );
        } else {
          final data = docSnap.data() as Map<String, dynamic>;

          // 🔥 Cek status akun
          final status = data['status'] ?? 'aktif';
          if (status == 'nonaktif') {
            showAwesomePopupAutoClose(
              title: "Akun Nonaktif",
              message: "Akun Anda saat ini nonaktif. Silakan hubungi admin.",
              color: Colors.red,
              icon: Icons.block,
            );
            return; // hentikan login
          }

          final alamat = data['alamat'] ?? {};
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
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAwesomePopupAutoClose(
          title: "Akun Tidak Terdaftar",
          message: "Email belum pernah digunakan. Silakan Sign Up dulu.",
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        );
      } else {
        showAwesomePopupAutoClose(
          title: "Login Gagal",
          message: e.message ?? "Terjadi kesalahan.",
          color: Colors.red,
          icon: Icons.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception("Gagal login Google");

      final docRef = FirebaseFirestore.instance.collection('pelanggan').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // Buat akun baru jika belum ada
        await docRef.set({
          'id_pelanggan': user.uid,
          'nama_pelanggan': user.displayName ?? '',
          'email': user.email ?? '',
          'password': '',
          'status': 'aktif', // 🔥 default akun baru aktif
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

      // 🔥 Ambil data terbaru dan cek status akun
      final finalSnap = await docRef.get();
      final data = finalSnap.data() != null 
          ? finalSnap.data() as Map<String, dynamic> 
          : <String, dynamic>{};

      final status = data['status'] ?? 'aktif';
      if (status == 'nonaktif') {
        showAwesomePopupAutoClose(
          title: "Akun Nonaktif",
          message: "Akun Anda saat ini nonaktif. Silakan hubungi admin.",
          color: Colors.red,
          icon: Icons.block,
        );
        return; // hentikan login
      }

      final alamat = data['alamat'] as Map<String, dynamic>? ?? {};
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
      showAwesomePopupAutoClose(
        title: "Gagal Login Google",
        message: "$error",
        color: Colors.red,
        icon: Icons.error_rounded,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // LOGO
                    Row(children: const [SizedBox(width: 48, height: 48)]),
                    const SizedBox(height: 26),

                    const Text(
                      'Log In',
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
                      'Masuk untuk melanjutkan perawatan gigi anda bersama Gianto Dental Lab',
                      style: TextStyle(
                        color: Color(0xFF0C3345),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "Masukkan email anda",
                        labelText: "Email",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF0C3345),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                          fontFamily: "Poppins",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        border: authOutlineInputBorder,
                        enabledBorder: authOutlineInputBorder,
                        focusedBorder: authOutlineInputBorder,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Masukkan kata sandi anda",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF0C3345),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                          fontFamily: "Poppins",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        border: authOutlineInputBorder,
                        enabledBorder: authOutlineInputBorder,
                        focusedBorder: authOutlineInputBorder,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF999999),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // CONTINUE
                    ElevatedButton(
                      onPressed: _isLoading ? null : signIn,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF0C3345),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // GOOGLE LOGIN
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

                    const SizedBox(height: 310),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Tidak memiliki akun? ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF0C3345),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔥 FULLSCREEN OVERLAY TANPA TERPOTONG
        if (_isLoading) Positioned.fill(child: loadingOverlay()),
      ],
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);