import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KullanicilarSayfasi extends StatelessWidget {
  const KullanicilarSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlı Kullanıcılar'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Bir hata oluştu'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz kayıtlı kullanıcı bulunmuyor'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final user = snapshot.data!.docs[index];
              final userData = user.data() as Map<String, dynamic>;
              final createdAt = (userData['createdAt'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(userData['adSoyad'] ?? 'İsimsiz Kullanıcı'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['email'] ?? ''),
                      Text(
                        'Kayıt Tarihi: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
