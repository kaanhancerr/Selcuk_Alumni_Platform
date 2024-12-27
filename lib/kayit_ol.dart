import 'package:flutter/material.dart';
import 'package:su_mezuntakip/giris_yap.dart';

class KayitOl extends StatefulWidget {
  const KayitOl({super.key});

  @override
  State<KayitOl> createState() => _KayitOlState();
}

class _KayitOlState extends State<KayitOl> {
  var tfController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 230,
              height: 150,
              child: Image.asset("assets/images/selcuklogo.webp"),
            ),
            Icon(
              Icons.person_add,
              size: 35,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: tfController,
                    decoration: InputDecoration(
                        hintText: "Ad - Soyad",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                    keyboardType: TextInputType.number,
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: tfController,
                    decoration: InputDecoration(
                        hintText: "Telefon Numarası",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                    keyboardType: TextInputType.number,
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: tfController,
                    decoration: InputDecoration(
                        hintText: "E-posta",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: tfController,
                    decoration: InputDecoration(
                        hintText: "Şifre",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: tfController,
                    decoration: InputDecoration(
                      hintText: "Diploma PDF seklinde yukleyiniz...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Kayıt olmak istiyor musunuz?"),
                          action: SnackBarAction(
                              label: "Evet",
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Kayıt olundu"),
                                  ),
                                );
                              }),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400),
                    child: Text(
                      "Kayıt Ol",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GirisYap()));
                      },
                      child: const Text(
                        "Hesabınız var mı? Giriş yapın",
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
