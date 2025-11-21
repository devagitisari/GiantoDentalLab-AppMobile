import 'package:flutter/material.dart';

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          FormGaransiPembuatanBaru(),
        ]),
      ),
    );
  }
}

class FormGaransiPembuatanBaru extends StatelessWidget {
  const FormGaransiPembuatanBaru({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 30,
                top: 83,
                child: Opacity(
                  opacity: 0.65,
                  child: Container(
                    width: 33,
                    height: 33,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE7E7E7),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 36.60,
                top: 89.60,
                child: Container(
                  width: 19.80,
                  height: 19.80,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Stack(),
                ),
              ),
              Positioned(
                left: 30,
                top: 140,
                child: Text(
                  'Form  Pengajuan Garansi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.05,
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 173,
                child: SizedBox(
                  width: 343,
                  child: Text(
                    'Isi informasi dibawah untuk melakukan pengajuan penjadwalan  kunjungan khusus garansi',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 232,
                child: Container(
                  width: 353,
                  height: 463,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF0F0F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 15,
                        top: 282,
                        child: Container(
                          width: 328,
                          height: 38,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFD9D9D9),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 260,
                        child: Text(
                          'Tanggal  dan Waktu',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 36,
                        top: 290,
                        child: Text(
                          '-- Pilih tanggal  dan Waktu --',
                          style: TextStyle(
                            color: const Color(0xFFCFCFCF),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 44,
                        child: Container(
                          width: 328,
                          height: 38,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFD9D9D9),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 23,
                        child: Text(
                          'Layanan',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 90,
                        child: Text(
                          'Keluhan ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 31,
                        top: 52,
                        child: Text(
                          'Garansi Pembuatan Gigi Tiruan Baru',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.80),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 115,
                        child: SizedBox(
                          width: 310,
                          child: Text(
                            'Masukan Keluhan',
                            style: TextStyle(
                              color: const Color(0xFFD9D9D9),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.75,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 352,
                        child: Container(
                          width: 324,
                          height: 38,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFD9D9D9),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 21,
                        top: 329,
                        child: Text(
                          'Jenis Pelayanan',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 35,
                        top: 360,
                        child: Text(
                          '-- Pilih Jenis Pelayanan--',
                          style: TextStyle(
                            color: const Color(0xFFD0D0D0),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 305,
                        top: 289,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                      Positioned(
                        left: 305,
                        top: 357,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20, // tambahkan biar responsif
                bottom: 40, // pakai bottom biar konsisten daripada top
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3345),
                      padding: const EdgeInsets.symmetric(vertical: 20), // cukup tinggi aja
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Aksi pengajuan
                    },
                    child: const Text(
                      'Pengajuan Kunjungan Garansi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.31,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}