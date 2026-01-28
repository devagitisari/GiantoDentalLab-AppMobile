import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UbahKataSandi extends StatefulWidget {
  final String uid;
  const UbahKataSandi({super.key, required this.uid});

  @override
  State<UbahKataSandi> createState() => _UbahKataSandiState();
}

class _UbahKataSandiState extends State<UbahKataSandi> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool akunBelumPunyaPassword = false;

  @override
  void initState() {
    super.initState();
    _cekPassword();
  }

  Future<void> _cekPassword() async {
    final doc = await FirebaseFirestore.instance
        .collection("pelanggan")
        .doc(widget.uid)
        .get();

    final savedPassword = doc.data()?["password"];

    setState(() {
      akunBelumPunyaPassword =
          savedPassword == null || savedPassword.toString().isEmpty;
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (!akunBelumPunyaPassword && oldPass.isEmpty) {
      _showPopup("Harap isi password lama", success: false);
      return;
    }

    if (newPass != confirmPass) {
      _showPopup("Password baru dan konfirmasi tidak cocok", success: false);
      return;
    }

    // validasi kompleksitas password
    bool hasUpper = newPass.contains(RegExp(r'[A-Z]'));
    bool hasLower = newPass.contains(RegExp(r'[a-z]'));
    bool hasNumber = newPass.contains(RegExp(r'[0-9]'));
    bool hasSpecial = newPass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    if (newPass.length < 8 || !hasUpper || !hasLower || !hasNumber || !hasSpecial) {
      _showPopup(
        "Password harus terdiri dari huruf besar, kecil, angka, dan simbol",
        success: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!akunBelumPunyaPassword) {
        // user email/password -> re-authenticate dulu
        final cred = EmailAuthProvider.credential(email: user.email!, password: oldPass);
        await user.reauthenticateWithCredential(cred);
      }
      
      // update password
      await user.updatePassword(newPass);

      await FirebaseFirestore.instance
        .collection("pelanggan")
        .doc(widget.uid)
        .update({"password": newPass});

      _showPopup("Password berhasil diubah", success: true);

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      setState(() {
        akunBelumPunyaPassword = false; // akun sekarang punya password
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showPopup("Password lama salah", success: false);
      } else if (e.code == 'requires-recent-login') {
        _showPopup("Silakan login ulang untuk mengubah password", success: false);
      } else {
        _showPopup("Terjadi kesalahan: ${e.message}", success: false);
      }
    } catch (e) {
      _showPopup("Terjadi kesalahan saat mengubah password", success: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _showPopup(String message, {bool success = true}) {
    showDialog(
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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
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
                      success ? "Berhasil" : "Gagal",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: success ? Colors.green : Colors.red,
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
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0C3345)) : null,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 18,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Color(0xFF0C3345),
      ),
      hintStyle: const TextStyle(
        fontSize: 13,
        fontFamily: 'Poppins',
        color: Color(0xFF999999),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD0D0D0)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD0D0D0)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0C3345)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator, // <- tambahkan validator
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: _inputDecoration(label, icon: Icons.lock, hint: hint).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF0C3345),
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Ubah Kata Sandi",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C3345),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          width: 48,
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF0C3345),
                            size: 28
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Form( // <-- letakkan Form di sini
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (akunBelumPunyaPassword)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Akun Anda login menggunakan Google dan belum memiliki password. Silakan buat password baru.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (!akunBelumPunyaPassword)
                        _buildPasswordField(
                          controller: _oldPasswordController,
                          label: "Password Lama",
                          hint: "Masukkan password lama",
                          obscure: _obscureOld,
                          toggle: () => setState(() => _obscureOld = !_obscureOld),
                          validator: (value) {
                            if (!akunBelumPunyaPassword && (value == null || value.isEmpty)) {
                              return "Password lama harus diisi";
                            }
                            return null;
                          },
                        ),
                      if (!akunBelumPunyaPassword) const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: "Password Baru",
                        hint: "Masukkan password baru",
                        obscure: _obscureNew,
                        toggle: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Password baru harus diisi";
                          if (value.length < 8) return "Password minimal 8 karakter";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: "Konfirmasi Password",
                        hint: "Masukkan ulang password baru",
                        obscure: _obscureConfirm,
                        toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Konfirmasi password harus diisi";
                          if (value != _newPasswordController.text) return "Password tidak cocok";
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C3345),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Simpan",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
    );
  }
}
