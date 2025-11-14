import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/form-alamat.dart';
import 'package:team_project/screens/home-page.dart';
import 'package:team_project/screens/login-page.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                const SizedBox(height: 80),
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7E7E7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Image.asset(
                          'assets/icons/arrow-back.png',
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),
                const Text(
                  'Sign Up',
                  style: const TextStyle(
                    color: Color(0xFF0C3345),
                    fontSize: 26,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  'Daftar akun dan mulai perawatan gigi anda bersama Gianto Dental Lab',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF0C3345),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                SignInForm(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const SizedBox(height: 16),
                const PnyaAkunText(),
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

class PelangganService {
  final CollectionReference _pelangganCollection =
      FirebaseFirestore.instance.collection('pelanggan');

  Future<void> tambahPelanggan(Map<String, dynamic> data) async {
    await _pelangganCollection.add(data);
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noTelpController = TextEditingController();

  bool _isLoading = false;

  Future<void> signUp() async {
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;

      // buat akun
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = userCredential.user;

      // simpan data dasar pelanggan (belum ada alamat)
      await FirebaseFirestore.instance.collection('pelanggan').doc(user!.uid).set({
        'id_pelanggan': user.uid,
        'nama_pelanggan': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'no_telp': _noTelpController.text.trim(),
        'alamat': '',
        'password': _passwordController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // lanjut ke isi alamat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IsiAlamat(uid: user.uid)),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ ${e.message}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception("Gagal login Google");

      final docRef = FirebaseFirestore.instance.collection('pelanggan').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        await docRef.set({
          'id_pelanggan': user.uid,
          'nama_pelanggan': user.displayName ?? '',
          'email': user.email,
          'password': '',
          'alamat': '',
          'no_telp': '',
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      final userData = await docRef.get();
      final alamat = userData['alamat'] ?? '';

      if (alamat.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IsiAlamat(uid: user.uid)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Gagal login Google: $error")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _namaController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Masukkan nama",
              hintStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFF999999)
              ),
              labelText: "Nama",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345)
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999))
              )
            ),
          ),
          const SizedBox(height: 24),
          //form email
          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Masukkan email anda",
              hintStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFF999999)
              ),
              labelText: "Email",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345)
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999))
              )
            ),
          ),

          const SizedBox(height: 24),
          
          TextFormField(
            controller: _noTelpController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Masukkan nomor telepon anda",
              hintStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFF999999)
              ),
              labelText: "Nomor Telepon",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345)
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999))
              )
            ),
          ),

          const SizedBox(height: 24),
          //form pw
          TextFormField(
            controller: _passwordController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Masukkan kata sandi anda",
              hintStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFF999999)
              ),
              labelText: "Kata Sandi",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345)
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999))
              )
            ),
          ),
          
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _isLoading ? null : signUp,
            
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
                  // simple placeholder for Google logo
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
        ],
      ),
    );
  }
}

class PnyaAkunText extends StatelessWidget {
  const PnyaAkunText({ Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Belum memiliki akun?",
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => LoginInScreen()),
            );
          },
          child: const Text(
            "Log In",
            style: TextStyle(
              color: Color(0xFF0C3345),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      ],
    );
  }
}