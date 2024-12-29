import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selcuk_alumni_platform/pages/chat_sayfasi.dart';

class YeniMesajSayfasi extends StatelessWidget {
  const YeniMesajSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Mesaj'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            return const Center(child: Text('Hiç kullanıcı bulunamadı'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (userData['adSoyad'] as String?)
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        '?',
                  ),
                ),
                title: Text(userData['adSoyad'] ?? 'İsimsiz Kullanıcı'),
                subtitle: Text(userData['bolum'] ?? 'Bölüm belirtilmemiş'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatSayfasi(
                        aliciId: users[index].id,
                        aliciAdi: userData['adSoyad'] ?? 'İsimsiz Kullanıcı',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
