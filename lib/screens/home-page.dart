<<<<<<< HEAD

=======
>>>>>>> 7c1527d38777c2febcd63f85b35f9ba095843dd2
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFF7F7F7)),
          child: Stack(
            children: [
              Positioned(
                left: 338,
                top: 71,
                child: Container(
                  width: 34,
                  height: 34,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Stack(),
                ),
              ),
              Positioned(
                left: 26,
                top: 77,
                child: Text(
                  'Halo,.....',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 121,
                child: Container(
                  width: 353,
                  height: 201,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/353x201"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 505,
                child: Container(
                  width: 169,
                  height: 123,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 202,
                top: 505,
                child: Container(
                  width: 171,
                  height: 123,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 223,
                top: 513,
                child: Container(
                  width: 38,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.50, -0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [const Color(0xFF0C3345), const Color(0xFF155A7A)],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        top: -2,
                        child: Container(
                          width: 31,
                          height: 38,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/31x38"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 647,
                child: Container(
                  width: 169,
                  height: 123,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 204,
                top: 647,
                child: Container(
                  width: 169,
                  height: 123,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 367,
                child: Container(
                  width: 353,
                  height: 98,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, 0.50),
                      end: Alignment(1.00, 0.50),
                      colors: [const Color(0xFF0C3345), const Color(0xFF1D7EAB)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 36,
                top: 428,
                child: Container(
                  width: 318,
                  height: 22,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: 591,
                child: Text(
                  'Pengajuan Kunjungan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.75,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 21,
                top: 342,
                child: Text(
                  'Jadwal Kunjungan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.75,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 210,
                top: 592,
                child: Text(
                  'Jadwal Kunjungan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.75,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 211,
                top: 738,
                child: Text(
                  'Riwayat Layanan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.75,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 738,
                child: SizedBox(
                  width: 117,
                  height: 16,
                  child: Text(
                    'Garansi dan Keluhan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.75,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 513,
                child: Container(
                  width: 38,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.50, -0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [const Color(0xFF0C3345), const Color(0xFF155A7A)],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 7,
                        top: 7,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: -66,
                                top: 24,
                                child: Container(
                                  width: 36,
                                  height: 35,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: OvalBorder(),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1,
                        top: 1,
                        child: Container(
                          width: 35,
                          height: 39,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/35x39"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 430,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, -0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [const Color(0xFF0C3345), const Color(0xFF155A7A)],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 660,
                child: Container(
                  width: 38,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.50, -0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [const Color(0xFF0C3345), const Color(0xFF155A7A)],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 7,
                        top: 7,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: -66,
                                top: 24,
                                child: Container(
                                  width: 36,
                                  height: 35,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: OvalBorder(),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        top: 0,
                        child: Container(
                          width: 30,
                          height: 38,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/30x38"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 223,
                top: 660,
                child: Container(
                  width: 38,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.50, -0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [const Color(0xFF0C3345), const Color(0xFF155A7A)],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 7,
                        top: 7,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: -3,
                                top: -5,
                                child: Container(
                                  width: 27,
                                  height: 33,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage("https://placehold.co/27x33"),
                                      fit: BoxFit.cover,
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
              Positioned(
                left: 120,
                top: 518,
                child: Container(
                  width: 49,
                  height: 19,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF7B929C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 518,
                child: Container(
                  width: 49,
                  height: 19,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF7B929C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 661,
                child: Container(
                  width: 49,
                  height: 19,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF7B929C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 661,
                child: Container(
                  width: 49,
                  height: 19,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF7B929C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 518,
                child: SizedBox(
                  width: 49,
                  height: 19,
                  child: Text(
                    'Lihat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 2.10,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 379,
                child: Text(
                  'Kunjungan Pertama',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 399,
                child: Text(
                  'Pembuatan gigi palsu  |  Kunjungan rumah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 2.10,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Positioned(
                left: 67,
                top: 428,
                child: SizedBox(
                  width: 107,
                  height: 22,
                  child: Text(
                    '20 September 2025',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0C3345),
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 2.10,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 518,
                child: SizedBox(
                  width: 49,
                  height: 19,
                  child: Text(
                    'Lihat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 2.10,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 661,
                child: SizedBox(
                  width: 49,
                  height: 19,
                  child: Text(
                    'Lihat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 2.10,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 660,
                child: SizedBox(
                  width: 49,
                  height: 19,
                  child: Text(
                    'Lihat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 2.10,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 428,
                child: Container(
                  width: 85,
                  height: 22,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 17,
                        top: 0,
                        child: SizedBox(
                          width: 94,
                          height: 22,
                          child: Text(
                            '11:00 - 12:30 WIB',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF0C3345),
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 2.10,
                              letterSpacing: -0.32,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 2,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.50, -0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [const Color(0xFF0C3345), const Color(0xFF155A7A)],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1,
                        top: 3,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/15x15"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 53,
                top: 129,
                child: SizedBox(
                  width: 284,
                  height: 40,
                  child: Text(
                    'GIANTO DENTAL LAB KINI HADIR DENGAN 2 PELAYANAN! \n\n\n\n\n\n\n\n\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF234555),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Rethink Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.20,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 52,
                top: 430,
                child: Container(
                  width: 11,
                  height: 14,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/11x14"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 53,
                top: 419,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
                  width: 15,
                  height: 19,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/15x19"),
                      fit: BoxFit.cover,
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 7c1527d38777c2febcd63f85b35f9ba095843dd2
