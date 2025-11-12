import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:team_project/screens/intropage1.dart';
import 'package:team_project/screens/intropage2.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              IntroPage1(),
              IntroPage2(),
            ],
          ),

          // dot indicator
          Container(
            alignment: Alignment(0, 0.75),
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
          )
        ],
      ),
    );
  }
}