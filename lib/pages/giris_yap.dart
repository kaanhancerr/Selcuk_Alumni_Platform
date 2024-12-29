import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selcuk_alumni_platform/components/my_button.dart';
import 'package:selcuk_alumni_platform/components/my_textfield.dart';
import 'package:selcuk_alumni_platform/pages/kayit_ol.dart';
import 'package:selcuk_alumni_platform/pages/etkinlikler_sayfasi.dart';

class GirisYap extends StatefulWidget {
  const GirisYap({super.key});

  @override
  State<GirisYap> createState() => _GirisYapState();
}

class _GirisYapState extends State<GirisYap> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;
  bool _isLoading = false;
  bool _isAdmin = false; // Admin girişi için toggle
  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_emailController.text.isEmpty || _pwController.text.isEmpty) {
        throw 'Lütfen tüm alanları doldurunuz';
      }

      // Firebase ile giriş
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _pwController.text.trim(),
      );

      if (_isAdmin) {
        // Admin girişi için kontrol
        if (_emailController.text.trim() != "kaan@gmail.com") {
          throw 'Bu hesap admin yetkisine sahip değil';
        }

        final adminDoc = await _firestore
            .collection('admins')
            .doc(userCredential.user!.uid)
            .get();

        if (!adminDoc.exists) {
          throw 'Bu hesap admin yetkisine sahip değil';
        }
      } else {
        // Normal kullanıcı girişi için kontrol
        if (_emailController.text.trim() == "kaan@gmail.com") {
          throw 'Lütfen admin girişini kullanın';
        }

        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw 'Kullanıcı bilgileri bulunamadı';
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EtkinliklerSayfasi()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getMessageFromErrorCode(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Firebase hata kodlarını Türkçe mesajlara çevirme
  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "invalid-email":
        return "Geçersiz e-posta adresi";
      case "wrong-password":
        return "Hatalı şifre";
      case "user-not-found":
        return "Bu e-posta ile kayıtlı kullanıcı bulunamadı";
      case "user-disabled":
        return "Bu kullanıcı hesabı devre dışı bırakılmış";
      case "too-many-requests":
        return "Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin";
      default:
        return "Bir hata oluştu. Lütfen tekrar deneyin";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAdmin ? "Admin Girişi" : "Üye Girişi"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/selcuklogo.webp",
                  height: 150,
                  width: 500,
                ),
                const SizedBox(height: 20),
                Icon(
                  _isAdmin ? Icons.admin_panel_settings : Icons.school,
                  size: 70,
                  color: _isAdmin ? Colors.red : null,
                ),
                const SizedBox(height: 20),
                // Kullanıcı tipi seçimi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Admin Girişi"),
                    Switch(
                      value: _isAdmin,
                      onChanged: (value) {
                        setState(() {
                          _isAdmin = value;
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      MyTextField(
                        hintText: "E-posta",
                        obscureText: false,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'E-posta alanı boş bırakılamaz';
                          }
                          if (!value.contains('@')) {
                            return 'Geçerli bir e-posta adresi giriniz';
                          }
                          return null;
                        },
                      ),
                      MyTextField(
                        hintText: "Şifre",
                        obscureText: true,
                        controller: _pwController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre alanı boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      if (!_isAdmin) // Sadece normal kullanıcılar için şifremi unuttum
                        Padding(
                          padding: const EdgeInsets.only(right: 190, top: 0),
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Şifremi Unuttum",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13),
                            ),
                          ),
                        ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      MyButton(
                        text: _isLoading
                            ? "Giriş Yapılıyor..."
                            : _isAdmin
                                ? "Admin Girişi Yap"
                                : "Giriş Yap",
                        onTap: _isLoading ? null : login,
                      ),
                      if (!_isAdmin) // Sadece normal kullanıcılar için kayıt ol
                        const SizedBox(height: 30),
                      if (!_isAdmin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Hesabınız yok mu?",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const KayitOl(),
                                  ),
                                );
                              },
                              child: Text(
                                "Hemen kayıt ol",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
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
      ),
    );
  }
}
