import 'package:flutter/material.dart';
import 'package:su_mezuntakip/components/my_textfield.dart';
import 'package:su_mezuntakip/giris_yap.dart';
import 'package:su_mezuntakip/kayit_ol.dart';

class TanitimSayfa extends StatefulWidget {
  const TanitimSayfa({super.key});

  @override
  State<TanitimSayfa> createState() => _TanitimSayfaState();
}

class _TanitimSayfaState extends State<TanitimSayfa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mezun Takip Sistemi",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.grey.shade400,
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              ("assets/images/selcuklogo.webp"),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Text(
                "Hoş Geldiniz!\n\nBu uygulama, Teknoloji Fakültesi mezunlarının kariyer gelişimlerini desteklemek ve iletişim ağlarını güçlendirmek amacıyla oluşturulmuştur. Burada mezunların deneyimlerini paylaşabilir, iş ve staj fırsatlarına ulaşabilir ve etkinliklerden haberdar olabilirsiniz. Hedefimiz, güçlü bir mezun topluluğu oluşturmaktır.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GirisYap()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400),
                  child: const Text(
                    "Giriş Yap",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KayitOl(),
                  ),
                );
              },
              child: const Text("Hesabınız yok mu? Hemen Kayıt ol"),
            ),
            MyTextField()
          ],
        ),
      ),
    );
  }
}
