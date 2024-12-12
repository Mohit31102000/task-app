import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/screens/home_screen.dart';
import 'package:task_app/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // Timer(
    //   const Duration(seconds: 3),
    //   () => Navigator.pushNamed(context, '/loginScreen'),
    // );

    Timer(
      const Duration(seconds: 3),
      () => checkAccess(),
    );
    super.initState();
  }

  Future<void> checkAccess() async {
    SharedPreferences? pref = await SharedPreferences.getInstance();
    var userId = pref.getString('userId');
    debugPrint('User id : $userId');

    if (userId == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 200,
                width: 200,
                child: Image.asset('assets/images/app_logo.png')),
            const SizedBox(height: 30),
            const Text(
              "TASK APP",
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
