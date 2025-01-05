import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IsFirsatlarSayfasi extends StatelessWidget {
  const IsFirsatlarSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Kullanıcı kontrolü
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Lütfen giriş yapın')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('is_ilanlari')
            .orderBy('olusturmaTarihi', descending: true)
            .where('durum', isEqualTo: 'onaylandi')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Hata: ${snapshot.error}'); // Hatayı konsola yazdır
            return const Center(
              child: Text('Veriler yüklenirken bir sorun oluştu'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ilanlar = snapshot.data?.docs ?? [];

          return Stack(
            children: [
              if (ilanlar.isEmpty)
                const Center(child: Text('Henüz ilan bulunmuyor'))
              else
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ilanlar.length,
                  itemBuilder: (context, index) {
                    final ilan = ilanlar[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ilan['baslik'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Admin için silme butonu
                                if (auth.currentUser?.email == "kaan@gmail.com")
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      // Silme onayı için dialog göster
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('İlanı Sil'),
                                          content: const Text(
                                              'Bu ilanı silmek istediğinizden emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  await firestore
                                                      .collection('is_ilanlari')
                                                      .doc(ilanlar[index].id)
                                                      .delete();

                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'İlan silindi'), // ilan silme fonks. firestoredan da silinir.
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'İlan silinirken bir hata oluştu'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              child: const Text(
                                                'Sil',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ilan['tip'] == 'Staj'
                                        ? Colors.blue[100]
                                        : Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ilan['tip'] ?? 'İş İlanı',
                                    style: TextStyle(
                                      color: ilan['tip'] == 'Staj'
                                          ? Colors.blue[900]
                                          : Colors.green[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(ilan['aciklama'] ?? ''),
                            const SizedBox(height: 8),
                            Text('Firma: ${ilan['firma'] ?? ''}'),
                            Text('Konum: ${ilan['konum'] ?? ''}'),
                            Text('İletişim: ${ilan['iletisim'] ?? ''}'),
                            Text(
                                'İlan Tarihi: ${_formatDate(ilan['olusturmaTarihi'] as Timestamp)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'ilanButton',
                  onPressed: () => _showIlanEkleDialog(context),
                  label: const Text('İlan Ver'),
                  icon: const Icon(Icons.add_business),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showIlanEkleDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final baslikController = TextEditingController();
    final aciklamaController = TextEditingController();
    final firmaController = TextEditingController();
    final konumController = TextEditingController();
    final iletisimController = TextEditingController();
    String secilenTip = 'İş İlanı';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni İlan'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: secilenTip,
                  decoration: const InputDecoration(labelText: 'İlan Tipi'),
                  items: ['İş İlanı', 'Staj']
                      .map((tip) => DropdownMenuItem(
                            value: tip,
                            child: Text(tip),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) secilenTip = value;
                  },
                ),
                TextFormField(
                  controller: baslikController,
                  decoration: const InputDecoration(labelText: 'Başlık'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Başlık gerekli' : null,
                ),
                TextFormField(
                  controller: aciklamaController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Açıklama gerekli' : null,
                ),
                TextFormField(
                  controller: firmaController,
                  decoration: const InputDecoration(labelText: 'Firma'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Firma gerekli' : null,
                ),
                TextFormField(
                  controller: konumController,
                  decoration: const InputDecoration(labelText: 'Konum'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Konum gerekli' : null,
                ),
                TextFormField(
                  controller: iletisimController,
                  decoration:
                      const InputDecoration(labelText: 'İletişim Bilgileri'),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'İletişim bilgileri gerekli'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final FirebaseFirestore firestore = FirebaseFirestore.instance;
                final FirebaseAuth auth = FirebaseAuth.instance;

                await firestore.collection('is_ilanlari').add({
                  'baslik': baslikController.text,
                  'aciklama': aciklamaController.text,
                  'firma': firmaController.text,
                  'konum': konumController.text,
                  'iletisim': iletisimController.text,
                  'tip': secilenTip,
                  'durum': 'beklemede',
                  'olusturanId': auth.currentUser?.uid,
                  'olusturanEmail': auth.currentUser?.email,
                  'olusturmaTarihi': Timestamp.now(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('İlanınız onay için gönderildi'),
                    ),
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
