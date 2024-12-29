import 'package:flutter/material.dart';
import 'package:selcuk_alumni_platform/components/my_button.dart';
import 'package:selcuk_alumni_platform/components/my_textfield.dart';
import 'package:selcuk_alumni_platform/giris_yap.dart';

class KayitOl extends StatefulWidget {
  const KayitOl({super.key});

  @override
  State<KayitOl> createState() => _KayitOlState();
}

class _KayitOlState extends State<KayitOl> {
  final TextEditingController _adsoyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _sifreonayController = TextEditingController();

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
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
                    MyTextField(
                        hintText: "Ad - Soyad",
                        obscureText: true,
                        controller: _adsoyadController),
                    const SizedBox(height: 1),
                    MyTextField(
                        hintText: "E-posta",
                        obscureText: true,
                        controller: _emailController),
                    const SizedBox(height: 1),
                    MyTextField(
                        hintText: "Şifre",
                        obscureText: false,
                        controller: _sifreController),
                    const SizedBox(height: 1),
                    MyTextField(
                        hintText: "Şifre onay",
                        obscureText: false,
                        controller: _sifreonayController),
                    const SizedBox(height: 25),
                    MyButton(text: "Kayıt ol", onTap: () {}),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hesabınız var mı?",
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GirisYap()));
                          },
                          child: Text(
                            "Giriş yapın",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                fontWeight: FontWeight.bold),
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
