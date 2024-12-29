import 'package:flutter/material.dart';
import 'package:selcuk_alumni_platform/components/my_button.dart';
import 'package:selcuk_alumni_platform/components/my_textfield.dart';
import 'package:selcuk_alumni_platform/kayit_ol.dart';

class GirisYap extends StatefulWidget {
  const GirisYap({super.key});

  @override
  State<GirisYap> createState() => _GirisYapState();
}

class _GirisYapState extends State<GirisYap> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  void login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hoşgeldiniz",
          style: TextStyle(),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
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
                    MyTextField(
                      hintText: "E-posta",
                      obscureText: false,
                      controller: _emailController,
                    ),
                    MyTextField(
                      hintText: "Şifre",
                      obscureText: true,
                      controller: _pwController,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 190, top: 0),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Şifremi Unuttum",
                          style: TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ),
                    ),
                    MyButton(
                      text: "Giriş Yap",
                      onTap: login,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Hesabınız yok mu?",
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const KayitOl()));
                          },
                          child: Text(
                            "Hemen kayıt ol",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
