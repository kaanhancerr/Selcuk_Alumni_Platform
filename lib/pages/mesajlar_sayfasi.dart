import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selcuk_alumni_platform/pages/chat_sayfasi.dart';

class MesajlarSayfasi extends StatelessWidget {
  const MesajlarSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Kullanıcı kontrolü
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Lütfen giriş yapın'));
    }

    final String currentUserId = currentUser.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('users', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data?.docs ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Text('Henüz bir sohbet bulunmuyor'),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final otherUserId = (chatData['users'] as List)
                  .firstWhere((id) => id != currentUserId);

              return Column(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        _firestore.collection('users').doc(otherUserId).get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Yükleniyor...'),
                        );
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      final userName =
                          userData['adSoyad'] ?? 'İsimsiz Kullanıcı';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(userName[0].toUpperCase()),
                        ),
                        title: Text(userName),
                        subtitle: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chats')
                              .doc(chats[index].id)
                              .collection('messages')
                              .orderBy('tarih', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, messageSnapshot) {
                            if (!messageSnapshot.hasData ||
                                messageSnapshot.data!.docs.isEmpty) {
                              return const Text('Henüz mesaj yok');
                            }

                            final lastMessage = messageSnapshot.data!.docs.first
                                .data() as Map<String, dynamic>;
                            final isOwnMessage =
                                lastMessage['gonderenId'] == currentUserId;

                            return Text(
                              '${isOwnMessage ? "Siz: " : ""}${lastMessage['mesaj']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatSayfasi(
                                aliciId: otherUserId,
                                aliciAdi: userName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (index != chats.length - 1)
                    const Divider(
                      color: Colors.black54,
                      thickness: 0.5,
                      height: 0,
                      indent: 0,
                      endIndent: 0,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
