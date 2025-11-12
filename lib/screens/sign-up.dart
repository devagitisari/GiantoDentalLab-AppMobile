import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/login-page.dart';

// Fungsi untuk login dengan Google
  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        print('Login berhasil dengan akun: ${account.email}');
      }
    } catch (error) {
      print('Gagal login: $error');
    }
  }

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

class SignInForm extends StatelessWidget {
  const SignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          //form nama
          TextFormField(
            onSaved: (nama) {},
            onChanged: (nama) {},
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
            onSaved: (email) {},
            onChanged: (email) {},
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

          //form pw
          TextFormField(
            onSaved: (password) {},
            onChanged: (password) {},
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
            onPressed: () {},
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
              "Daftar Akun",
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