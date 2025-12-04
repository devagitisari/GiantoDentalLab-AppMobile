import 'package:flutter/material.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  bool statusPengajuan = true;
  bool pengingatKunjungan = true;
  bool penawaranKhusus = true;
  bool updateFitur = true;
  bool syaratKetentuan = true;
  bool perubahanAkun = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),

            // ============================
            //        HEADER TENGAH
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Notifikasi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 229, 229, 229),
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================
            //        LIST NOTIFIKASI
            // ============================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  const Text(
                    "Notifikasi Layanan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildSwitchTile(
                    "Status Pengajuan",
                    statusPengajuan,
                    (v) => setState(() => statusPengajuan = v),
                  ),
                  buildSwitchTile(
                    "Pengingat Kunjungan",
                    pengingatKunjungan,
                    (v) => setState(() => pengingatKunjungan = v),
                  ),
                  buildSwitchTile(
                    "Penawaran Khusus",
                    penawaranKhusus,
                    (v) => setState(() => penawaranKhusus = v),
                  ),
                  buildSwitchTile(
                    "Update Fitur",
                    updateFitur,
                    (v) => setState(() => updateFitur = v),
                  ),
                  buildSwitchTile(
                    "Syarat & Ketentuan",
                    syaratKetentuan,
                    (v) => setState(() => syaratKetentuan = v),
                  ),
                  buildSwitchTile(
                    "Perubahan Data Akun",
                    perubahanAkun,
                    (v) => setState(() => perubahanAkun = v),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  //              WIDGET SWITCH LIST TILE
  // ==================================================
  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF0B3D4D),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
