import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selcuk_alumni_platform/pages/chat_sayfasi.dart';

class AgSayfasi extends StatefulWidget {
  const AgSayfasi({super.key});

  @override
  State<AgSayfasi> createState() => _AgSayfasiState();
}

class _AgSayfasiState extends State<AgSayfasi> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _secilenBolum;
  String? _secilenFirma;
  String? _secilenMezuniyetYili;

  List<String> _tumBolumler = [];
  List<String> _tumFirmalar = [];
  List<String> _tumMezuniyetYillari = [];

  @override
  void initState() {
    super.initState();
    _filtreSecenekleriniYukle();
  }

  Future<void> _filtreSecenekleriniYukle() async {
    final usersSnapshot = await _firestore.collection('users').get();

    Set<String> bolumler = {};
    Set<String> firmalar = {};
    Set<String> mezuniyetYillari = {};

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      if (data['bolum'] != null) bolumler.add(data['bolum']);
      if (data['firma'] != null) firmalar.add(data['firma']);
      if (data['mezuniyetYili'] != null)
        mezuniyetYillari.add(data['mezuniyetYili']);
    }

    setState(() {
      _tumBolumler = bolumler.toList()..sort();
      _tumFirmalar = firmalar.toList()..sort();
      _tumMezuniyetYillari = mezuniyetYillari.toList()..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('Hiç mezun bulunamadı'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (userData['adSoyad'] as String?)
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          '?',
                    ),
                  ),
                  title: Text(
                    userData['adSoyad'] ?? 'İsimsiz',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${userData['bolum'] ?? 'Bölüm belirtilmemiş'} (${userData['mezuniyetYili'] ?? '-'})'),
                      Text(
                          '${userData['firma'] ?? 'Firma belirtilmemiş'} - ${userData['pozisyon'] ?? 'Pozisyon belirtilmemiş'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatSayfasi(
                            aliciId: users[index].id,
                            aliciAdi:
                                userData['adSoyad'] ?? 'İsimsiz Kullanıcı',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtreleme'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _secilenBolum,
                  decoration: const InputDecoration(labelText: 'Bölüm'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tümü')),
                    ..._tumBolumler.map((bolum) => DropdownMenuItem(
                          value: bolum,
                          child: Text(bolum),
                        )),
                  ],
                  onChanged: (value) => setState(() => _secilenBolum = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _secilenFirma,
                  decoration: const InputDecoration(labelText: 'Firma'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tümü')),
                    ..._tumFirmalar.map((firma) => DropdownMenuItem(
                          value: firma,
                          child: Text(firma),
                        )),
                  ],
                  onChanged: (value) => setState(() => _secilenFirma = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _secilenMezuniyetYili,
                  decoration:
                      const InputDecoration(labelText: 'Mezuniyet Yılı'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tümü')),
                    ..._tumMezuniyetYillari.map((yil) => DropdownMenuItem(
                          value: yil,
                          child: Text(yil),
                        )),
                  ],
                  onChanged: (value) =>
                      setState(() => _secilenMezuniyetYili = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _secilenBolum = null;
                  _secilenFirma = null;
                  _secilenMezuniyetYili = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Filtreleri Temizle'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );
  }
}
