import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/sign-up.dart';

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

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // subtle gradient overlay from center to bottom
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
                    stops: [
                      0.0,
                      0.5,
                      1.5,
                    ]
                  ),
                ),
              ),
            ),

            // Text block placed a bit above the buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        'Mulai Sekarang',
                        style: const TextStyle(
                          color: Color(0xFF0C3345),
                          fontSize: 26,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          height: 0.95,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        'Daftar untuk melanjutkan konsultasi dan layanan pemasangan gigi tiruan anda',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
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
                    // Google button (white)
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
                    const SizedBox(height: 12),
                    const Text('atau', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),

                    // Email button (dark)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignInScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C3345),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    GestureDetector(
                      onTap: () {
                        // TODO: navigate to Log In
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Sudah memiliki akun? ',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(color: Color(0xFF0C3345), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}