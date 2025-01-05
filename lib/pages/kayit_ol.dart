import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selcuk_alumni_platform/components/my_button.dart';
import 'package:selcuk_alumni_platform/components/my_textfield.dart';
import 'package:selcuk_alumni_platform/pages/giris_yap.dart';

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

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Hata mesajı için
  String? _errorMessage;

  // Loading durumu için
  bool _isLoading = false;

  // Kayıt fonksiyonu
  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Şifre kontrolü
    if (_sifreController.text != _sifreonayController.text) {
      setState(() {
        _errorMessage = "Şifreler eşleşmiyor";
      });
      return;
    }

    if (_emailController.text.trim() == "kaan@gmail.com") {
      setState(() {
        _errorMessage = "Bu e-posta adresi kullanılamaz";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Firebase Authentication ile kullanıcı oluşturma
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
      );

      // Firestore'a kullanıcı bilgilerini kaydetme
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'adSoyad': _adsoyadController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        // Başarılı kayıt sonrası giriş sayfasına yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GirisYap()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getMessageFromErrorCode(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Bir hata oluştu. Lütfen tekrar deneyin.";
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
      case "email-already-in-use":
        return "Bu e-posta adresi zaten kullanımda";
      case "invalid-email":
        return "Geçersiz e-posta adresi";
      case "operation-not-allowed":
        return "E-posta/şifre girişi etkin değil";
      case "weak-password":
        return "Şifre çok zayıf";
      default:
        return "Bir hata oluştu. Lütfen tekrar deneyin";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
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
                SizedBox(
                  width: 230,
                  height: 150,
                  child: Image.asset("assets/images/selcuklogo.webp"),
                ),
                const Icon(
                  Icons.person_add,
                  size: 35,
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      MyTextField(
                        hintText: "Ad - Soyad",
                        obscureText: false,
                        controller: _adsoyadController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ad Soyad alanı boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
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
                        controller: _sifreController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre alanı boş bırakılamaz';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalıdır';
                          }
                          return null;
                        },
                      ),
                      MyTextField(
                        hintText: "Şifre onay",
                        obscureText: true,
                        controller: _sifreonayController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre onay alanı boş bırakılamaz';
                          }
                          if (value != _sifreController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 15),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: MyButton(
                          text: _isLoading ? "Kayıt Yapılıyor..." : "Kayıt Ol",
                          onTap: _isLoading ? null : signUp,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hesabınız var mı?",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GirisYap(),
                                ),
                              );
                            },
                            child: Text(
                              "Giriş yapın",
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
