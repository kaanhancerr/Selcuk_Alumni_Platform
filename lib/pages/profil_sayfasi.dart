import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selcuk_alumni_platform/components/my_textfield.dart';

class ProfilSayfasi extends StatefulWidget {
  const ProfilSayfasi({super.key});

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _mezuniyetYiliController =
      TextEditingController();
  final TextEditingController _bolumController = TextEditingController();
  final TextEditingController _firmaController = TextEditingController();
  final TextEditingController _pozisyonController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _mezuniyetYiliController.text = _userData?['mezuniyetYili'] ?? '';
            _bolumController.text = _userData?['bolum'] ?? '';
            _firmaController.text = _userData?['firma'] ?? '';
            _pozisyonController.text = _userData?['pozisyon'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler yüklenirken bir hata oluştu')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'mezuniyetYili': _mezuniyetYiliController.text.trim(),
          'bolum': _bolumController.text.trim(),
          'firma': _firmaController.text.trim(),
          'pozisyon': _pozisyonController.text.trim(),
          'updatedAt': Timestamp.now(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil başarıyla güncellendi')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellenirken bir hata oluştu')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hoşgeldiniz, ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userData?['adSoyad'] ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Mezuniyet Bilgileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: 'Mezuniyet Yılı',
                obscureText: false,
                controller: _mezuniyetYiliController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mezuniyet yılı gerekli';
                  }
                  return null;
                },
              ),
              MyTextField(
                hintText: 'Bölüm',
                obscureText: false,
                controller: _bolumController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bölüm bilgisi gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'İş Bilgileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: 'Çalıştığı Firma',
                obscureText: false,
                controller: _firmaController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Firma bilgisi gerekli';
                  }
                  return null;
                },
              ),
              MyTextField(
                hintText: 'Pozisyon',
                obscureText: false,
                controller: _pozisyonController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pozisyon bilgisi gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(_isLoading ? 'Kaydediliyor...' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
