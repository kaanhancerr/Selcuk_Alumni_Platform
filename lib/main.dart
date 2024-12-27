import 'package:flutter/material.dart';
import 'package:su_mezuntakip/tanitim_sayfa.dart';
import 'package:su_mezuntakip/themes/colors_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TanitimSayfa(),
      theme: colorsMode,
    );
  }
}
