import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider.dart';
import 'SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Make sure to await the initialization
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Mart',
      theme: Provider.of<ThemeProvider>(context).currentTheme, // Use the theme from the provider
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
