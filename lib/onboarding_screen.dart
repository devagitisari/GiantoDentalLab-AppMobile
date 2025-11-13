import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:team_project/screens/intropage1.dart';
import 'package:team_project/screens/intropage2.dart';
import 'package:team_project/screens/get_started.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false; // buat tahu posisi halaman aktif

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Halaman yang bisa digeser manual
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 1); // halaman ke-2 berarti index 1
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
            ],
          ),

          // Dot indicator di tengah bawah
          Align(
            alignment: const Alignment(0, 0.75),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 2,
              effect: const ExpandingDotsEffect(
                activeDotColor: Color(0xFF0C3345),
                dotColor: Colors.black12,
                dotHeight: 10,
                dotWidth: 10,
                spacing: 8,
              ),
            ),
          ),

          // Tombol di bawah (tetap, tapi berubah sesuai halaman)
          Align(
            alignment: const Alignment(0, 0.9),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (onLastPage) {
                      // kalau di halaman terakhir → ke GetStarted
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const GetStarted()),
                      );
                    } else {
                      // kalau di halaman pertama → geser ke halaman berikutnya
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3345),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    onLastPage ? 'Mulai Sekarang' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
