import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_project/screens/form_alamat.dart';
import 'package:team_project/screens/home_page.dart';
import 'package:team_project/screens/login_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  Widget loadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0C3345),
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Konten scrollable di SafeArea
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(children: const [SizedBox(width: 48, height: 48)]),
                  const SizedBox(height: 26),
                  const Text(
                    'Sign Up',
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
                    'Daftar akun dan mulai perawatan gigi anda bersama Gianto Dental Lab',
                    style: TextStyle(
                      color: Color(0xFF0C3345),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  SignInForm(
                    onLoadingChanged: (loading) {
                      setState(() {
                        _isLoading = loading;
                      });
                    },
                  ),
                  const SizedBox(height: 160),
                  const PnyaAkunText(),
                ],
              ),
            ),
          ),

          // Fullscreen loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0C3345),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class PelangganService {
  final CollectionReference _pelangganCollection = FirebaseFirestore.instance
      .collection('pelanggan');

  Future<void> tambahPelanggan(Map<String, dynamic> data) async {
    await _pelangganCollection.add(data);
  }
}

class SignInForm extends StatefulWidget {
  final Function(bool)? onLoadingChanged;
  const SignInForm({super.key, this.onLoadingChanged});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noTelpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void showPasswordInfo() {
    showDialog(
      context: context,
      barrierDismissible: true, // bisa tap di luar untuk close
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Card utama
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
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
                      "Syarat Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0C3345),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• Minimal 8 karakter", style: TextStyle(fontFamily: 'Poppins')),
                          Text("• Ada huruf kecil (a-z)", style: TextStyle(fontFamily: 'Poppins')),
                          Text("• Ada huruf besar (A-Z)", style: TextStyle(fontFamily: 'Poppins')),
                          Text("• Ada angka (0-9)", style: TextStyle(fontFamily: 'Poppins')),
                          Text("• Ada simbol (!@#\$%^&*)", style: TextStyle(fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3345),
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

              // Icon di atas card
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.info_outline, color: Color(0xFF0C3345), size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String passwordStrength = ""; // weak, medium, strong
  Color strengthColor = Colors.red;
  double strengthValue = 0.0; // 0.33 / 0.66 / 1.0

  void showAwesomePopup({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.info,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glass card
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

              // Icon floating circle
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                    ), // kecil aja biar visual center
                    child: Icon(icon, color: color, size: 50),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkPasswordStrength(String password) {
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    // STRONG
    if (password.length >= 8 &&
        hasUpper &&
        hasLower &&
        hasNumber &&
        hasSpecial) {
      setState(() {
        passwordStrength = "Strong";
        strengthColor = Colors.green;
        strengthValue = 1.0; // full bar
      });
    }
    // MEDIUM
    else if (password.length >= 6 &&
        (hasUpper || hasLower) &&
        (hasNumber || hasSpecial)) {
      setState(() {
        passwordStrength = "Medium";
        strengthColor = Colors.orange;
        strengthValue = 0.66; // 2/3 bar
      });
    }
    // WEAK
    else {
      setState(() {
        passwordStrength = "Weak";
        strengthColor = Colors.red;
        strengthValue = 0.33; // 1/3 bar
      });
    }
  }

  Future<void> signUp() async {
    String nama = _namaController.text.trim();
    String email = _emailController.text.trim();
    String telp = _noTelpController.text.trim();
    String password = _passwordController.text.trim();

    // ❌ Validasi field kosong
    if (nama.isEmpty || email.isEmpty || telp.isEmpty || password.isEmpty) {
      showAwesomePopup(
        title: "Data Belum Lengkap",
        message: "Harap isi semua field sebelum melanjutkan.",
        color: Colors.red,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // Validasi email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showAwesomePopup(
        title: "Email Tidak Valid",
        message: "Masukkan format email yang benar.",
        color: Colors.red,
        icon: Icons.error,
      );
      return;
    }

    // ❌ Validasi nomor telepon
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(telp)) {
      showAwesomePopup(
        title: "Nomor Telepon Tidak Valid",
        message:
            "Nomor telepon harus diawali 08 dan terdiri dari 10-15 digit angka.",
        color: Colors.red,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // ❌ Validasi password
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    if (password.length < 8 ||
        !hasUpper ||
        !hasLower ||
        !hasNumber ||
        !hasSpecial) {
      showAwesomePopup(
        title: "Password Tidak Valid",
        message:
            "Password harus huruf kecil, huruf besar, angka dan simbol dengan minimal 8 karakter.",
        color: Colors.red,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    widget.onLoadingChanged?.call(true);
    try {
      final auth = FirebaseAuth.instance;

      // VALIDASI PASSWORD WAJIB
      String password = _passwordController.text.trim();

      bool hasUpper = password.contains(RegExp(r'[A-Z]'));
      bool hasLower = password.contains(RegExp(r'[a-z]'));
      bool hasNumber = password.contains(RegExp(r'[0-9]'));
      bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

      if (password.length < 8 ||
          !hasUpper ||
          !hasLower ||
          !hasNumber ||
          !hasSpecial) {
        setState(() => _isLoading = false);

        showAwesomePopup(
          title: "Password Tidak Valid",
          message:
              "Password harus huruf kecil, huruf besar, angka dan simbol dengan minimal 8 karakter.",
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        );
        return; // STOP SIGN UP
      }

      // buat akun
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = userCredential.user;

      // simpan data dasar pelanggan (belum ada alamat)
      await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(user!.uid)
          .set({
            'id_pelanggan': user.uid,
            'nama_pelanggan': _namaController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'alamat': {
              'detail_jalan': "",
              'gmaps': {'latitude': "", 'longitude': "", 'link': ""},
              'kecamatan': "",
              'kelurahan': "",
              'kota': "",
              'nama_jalan': "",
              'provinsi': "",
            },
            'no_telp': _noTelpController.text.trim(),
            'created_at': FieldValue.serverTimestamp(),
          });

      showAwesomePopup(
        title: "Akun Berhasil Dibuat!",
        message: "Silakan lengkapi alamat anda untuk melanjutkan.",
        color: Colors.green,
        icon: Icons.check_circle_rounded,
      );

      await Future.delayed(const Duration(seconds: 1));

      // lanjut ke isi alamat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IsiAlamatWithMap(uid: user.uid)),
      );
    } on FirebaseAuthException catch (e) {
      showAwesomePopup(
        title: "Terjadi Kesalahan",
        message: e.message ?? "Terjadi kesalahan.",
        color: Colors.red,
        icon: Icons.warning_amber_rounded,
      );
    } finally {
      widget.onLoadingChanged?.call(false);
    }
  }

  Future<void> _signInWithGoogle() async {
    widget.onLoadingChanged?.call(true); // mulai loading
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        widget.onLoadingChanged?.call(false);
        return; // user batal login
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // login atau register dengan credential Google
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception("Gagal login Google");

      final docRef = FirebaseFirestore.instance.collection('pelanggan').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // User belum ada → buat akun baru
        await docRef.set({
          'id_pelanggan': user.uid,
          'nama_pelanggan': user.displayName ?? '',
          'email': user.email ?? '',
          'password': '', // kosong karena login Google
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

        // langsung lanjut ke isi alamat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IsiAlamatWithMap(uid: user.uid)),
        );
        return;
      }

      // User sudah ada → ambil data alamat
      final data = docSnap.data() != null ? Map<String, dynamic>.from(docSnap.data()!) : {};
      final alamat = data['alamat'] as Map<String, dynamic>? ?? {};

      if ((alamat['nama_jalan'] ?? "").isEmpty) {
        // belum isi alamat → ke halaman isi alamat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IsiAlamatWithMap(uid: user.uid)),
        );
      } else {
        // sudah isi alamat → langsung HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(uid: user.uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      showAwesomePopup(
        title: "Gagal Membuat Akun",
        message: e.message ?? "Terjadi kesalahan saat login Google.",
        color: Colors.red,
        icon: Icons.warning_amber_rounded,
      );
    } finally {
      widget.onLoadingChanged?.call(false); // stop loading
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
                color: Color(0xFF999999),
              ),
              labelText: "Nama",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999)),
              ),
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
                color: Color(0xFF999999),
              ),
              labelText: "Email",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999)),
              ),
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
                color: Color(0xFF999999),
              ),
              labelText: "Nomor Telepon",
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF999999)),
              ),
            ),
          ),

          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onChanged: (value) {
              checkPasswordStrength(value);
            },
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Masukan Password anda",
              hintStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFF999999),
              ),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C3345),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder,

              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 👁️ Show/Hide Password
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF999999),
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),

                  // 🔵 Ikon Info Password
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                    onPressed: showPasswordInfo,
                  ),
                ],
              ),
            ),
          ),


          // 🔥 INDIKATOR PASSWORD STRENGTH
          if (passwordStrength.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: strengthValue,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(strengthColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    passwordStrength,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: (_isLoading) ? null : signUp,

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
        ],
      ),
    );
  }
}

class PnyaAkunText extends StatelessWidget {
  const PnyaAkunText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sudah memiliki akun? ",
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: const Text(
            "Log In",
            style: TextStyle(
              color: Color(0xFF0C3345),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
