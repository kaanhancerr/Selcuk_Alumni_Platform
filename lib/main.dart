import 'package:flutter/material.dart';
import 'package:selcuk_alumni_platform/themes/colors_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:selcuk_alumni_platform/pages/giris_yap.dart';
import 'package:selcuk_alumni_platform/pages/etkinlikler_sayfasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const EtkinliklerSayfasi(),
      theme: colorsMode,
      routes: {
        '/giris': (context) => const GirisYap(),
        '/etkinlikler': (context) => const EtkinliklerSayfasi(),
      },
    );
  }
}
