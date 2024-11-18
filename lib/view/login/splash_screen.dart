import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery/view/login/welcome_view.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:food_delivery/view/on_boarding/on_boarding_view.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Color hexToColor(String hexCode) {
    return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      // Exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Customize the status bar
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black),
      );

      // Navigate to home or login screen based on authentication
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainTabView()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnBoardingView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize media query
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: hexToColor('#ffe6cc'),
        child: Stack(
          children: [
            Positioned(
              top: mq.height * .2,
              width: mq.width * .95,
              right: mq.width * .006,
              child: Image.asset('assets/img/logoblack.png'),
            ),
            Positioned(
              bottom: mq.height * .08,
              left: mq.width * .32,
              width: mq.width * .99999,
              child: const Text(
                "𝑫𝒆𝒗𝑨𝒍𝒄𝒉𝒆𝒎𝒊𝒔𝒕𝒔",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Font1',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
