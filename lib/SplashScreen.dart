import 'dart:async';
import 'package:e_mart_user/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Auth/LoginScreen.dart';
import 'BottomNavigation/BottomNavigation.dart';


User? user = FirebaseAuth.instance.currentUser;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), checkingTheSavedData
    );
  }

  void checkingTheSavedData() async {

    // print("user.....${user}");
    if (user == null) {
      // print("object........$user");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      print("user found");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNavigationHome()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/emart.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to E-Mart',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Shopping Made Easy',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              // Add a loading indicator
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
