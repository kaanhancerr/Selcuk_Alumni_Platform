import 'package:flutter/material.dart';

class GirisYap extends StatefulWidget {
  const GirisYap({super.key});

  @override
  State<GirisYap> createState() => _GirisYapState();
}

class _GirisYapState extends State<GirisYap> {
  var kullaniciAdi = TextEditingController();
  var sifre = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Yap"),
        backgroundColor: Colors.grey.shade400,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Image.asset(
              "assets/images/selcuklogo.webp",
              height: 150,
              width: 500,
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.school,
              size: 70,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: kullaniciAdi,
                    decoration: InputDecoration(
                        hintText: "E-posta",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: sifre,
                    decoration: InputDecoration(
                      hintText: "Şifre",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    obscureText: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 210),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Şifremi Unuttum",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Hesabınız yok mu? Kayıt ol",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
