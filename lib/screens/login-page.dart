import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/home-page.dart';
import 'package:team_project/screens/form-alamat.dart';
import 'package:team_project/screens/sign-up.dart';

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
                  child: Icon(icon, color: Colors.red, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> signIn() async {
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = userCredential.user;

      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('pelanggan')
            .doc(user.uid);
        final docSnap = await docRef.get();
        final data = docSnap.data() as Map<String, dynamic>;
        final alamat = data['alamat'] ?? {};

        if (alamat is Map &&
            (alamat['nama_jalan'] == null || alamat['nama_jalan'] == "")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => IsiAlamat(uid: user.uid)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(uid: user.uid)),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      showAwesomePopup(
        title: "Login Gagal",
        message: e.message ?? "Terjadi kesalahan.",
        color: Colors.red,
        icon: Icons.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception("Gagal login Google");

      final docRef = FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(user.uid);
      final docSnap = await docRef.get();

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
            'kode_pos': "",
            'kota': "",
            'nama_jalan': "",
            'provinsi': "",
          },
          'no_telp': '',
          'created_at': FieldValue.serverTimestamp(),
        });

        // ambil ulang data setelah set
        final newSnap = await docRef.get();
        final data = newSnap.data() as Map<String, dynamic>;
        final alamat = data['alamat'] ?? {};

        if (alamat['nama_jalan'] == null || alamat['nama_jalan'] == "") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => IsiAlamat(uid: user.uid)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(uid: user.uid)),
          );
        }
      } else {
        final data = docSnap.data() as Map<String, dynamic>;
        final alamat = data['alamat'] ?? {};

        if (alamat['nama_jalan'] == null || alamat['nama_jalan'] == "") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => IsiAlamat(uid: user.uid)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(uid: user.uid)),
          );
        }
      }
    } catch (error) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
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
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF0C3345),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                // === EMAIL FIELD ===
                TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Masukkan email anda",
                    labelText: "Email",
                    floatingLabelBehavior: FloatingLabelBehavior.always,

                    // SAMAKAN DENGAN SIGN UP
                    labelStyle: const TextStyle(
                      fontSize: 14,
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

                // === PASSWORD FIELD ===
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Masukkan kata sandi anda",
                    floatingLabelBehavior: FloatingLabelBehavior.always,

                    // SAMAKAN DENGAN SIGN UP
                    labelStyle: const TextStyle(
                      fontSize: 14,
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
                ElevatedButton(
                  onPressed: _isLoading ? null : signIn,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0C3345),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
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
                        Image.asset('assets/images/logoGoogle.png', height: 24),
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

                const SizedBox(height: 320),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Tidak memiliki akun? ",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF444444),
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
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF0C3345),
                          fontWeight: FontWeight.w600,
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
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);
