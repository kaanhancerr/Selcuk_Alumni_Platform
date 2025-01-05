import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selcuk_alumni_platform/pages/kullanicilar_sayfasi.dart';
import 'package:selcuk_alumni_platform/pages/profil_sayfasi.dart';
import 'package:selcuk_alumni_platform/pages/ag_sayfasi.dart';
import 'package:selcuk_alumni_platform/pages/mesajlar_sayfasi.dart';
import 'package:selcuk_alumni_platform/pages/is_firsatlar_sayfasi.dart';

class EtkinliklerSayfasi extends StatefulWidget {
  const EtkinliklerSayfasi({super.key});

  @override
  State<EtkinliklerSayfasi> createState() => _EtkinliklerSayfasiState();
}

class _EtkinliklerSayfasiState extends State<EtkinliklerSayfasi> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdmin = false;
  int _selectedIndex = 0;

  final List<Widget> _sayfalar = [
    const EtkinliklerIcerik(),
    const AgSayfasi(),
    const MesajlarSayfasi(),
    const IsFirsatlarSayfasi(),
    const ProfilSayfasi(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isAdmin = user.email == "kaan@gmail.com";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String _getTitle() {
      switch (_selectedIndex) {
        case 0:
          return "Etkinlikler";
        case 1:
          return "Mezun Ağı";
        case 2:
          return "Mesajlar";
        case 3:
          return "İş & Fırsatlar";
        case 4:
          return "Profil";
        default:
          return "Etkinlikler";
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_getTitle()),
        leading: Container(),
        backgroundColor: Colors.transparent,
        actions: [
          if (_isAdmin && (_selectedIndex == 0 || _selectedIndex == 3))
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                if (_selectedIndex == 0)
                  const PopupMenuItem(
                    value: 'users',
                    child: Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text('Kullanıcılar'),
                      ],
                    ),
                  ),
                if (_selectedIndex == 0)
                  const PopupMenuItem(
                    value: 'suggestions',
                    child: Row(
                      children: [
                        Icon(Icons.pending_actions),
                        SizedBox(width: 8),
                        Text('Etkinlik Önerileri'),
                      ],
                    ),
                  ),
                if (_selectedIndex == 3)
                  const PopupMenuItem(
                    value: 'is_ilanlari',
                    child: Row(
                      children: [
                        Icon(Icons.work),
                        SizedBox(width: 8),
                        Text('İş İlanları'),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) {
                if (value == 'users') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KullanicilarSayfasi(),
                    ),
                  );
                } else if (value == 'suggestions') {
                  _showEtkinlikOnerileriDialog(context);
                } else if (value == 'is_ilanlari') {
                  _showIsIlanlariDialog(context);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/giris');
              }
            },
          ),
        ],
      ),
      body: _sayfalar[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow[700],
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Etkinlikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Ağ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'İş & Fırsatlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      // floatingActionButton: _isAdmin && _selectedIndex == 0
      //     ? FloatingActionButton(
      //         heroTag: 'adminButton',
      //         onPressed: () => _showYeniEtkinlikDialog(context),
      //         child: const Icon(Icons.add),
      //       )
      //     : null,
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEtkinlikDetay(BuildContext context, Map<String, dynamic> etkinlik) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(etkinlik['baslik']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklama: ${etkinlik['aciklama']}'),
              const SizedBox(height: 8),
              Text('Konum: ${etkinlik['konum']}'),
              const SizedBox(height: 8),
              Text('Tarih: ${_formatDate(etkinlik['tarih'] as Timestamp)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showYeniEtkinlikDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final baslikController = TextEditingController();
    final aciklamaController = TextEditingController();
    final konumController = TextEditingController();
    DateTime? secilenTarih;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Etkinlik Ekle'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  controller: konumController,
                  decoration: const InputDecoration(labelText: 'Konum'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Konum gerekli' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        secilenTarih = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  child: const Text('Tarih ve Saat Seç'),
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
                if (secilenTarih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen tarih seçiniz')),
                  );
                  return;
                }

                await _firestore.collection('etkinlikler').add({
                  'baslik': baslikController.text,
                  'aciklama': aciklamaController.text,
                  'konum': konumController.text,
                  'tarih': Timestamp.fromDate(secilenTarih!),
                  'olusturanId': _auth.currentUser?.uid,
                  'olusturmaTarihi': Timestamp.now(),
                });

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showEtkinlikOnerileriDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinlik Önerileri'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('etkinlik_onerileri')
                .orderBy('olusturmaTarihi', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Hata: ${snapshot.error}');
                return const Center(child: Text('Bir hata oluştu'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final oneriler = snapshot.data?.docs ?? [];

              if (oneriler.isEmpty) {
                return const Center(child: Text('Henüz öneri bulunmuyor'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: oneriler.length,
                itemBuilder: (context, index) {
                  final oneri = oneriler[index].data() as Map<String, dynamic>;

                  if (oneri['durum'] != 'beklemede') {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      title: Text(
                        oneri['baslik'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(oneri['aciklama'] ?? ''),
                          const SizedBox(height: 4),
                          Text('Konum: ${oneri['konum']}'),
                          Text(
                              'Tarih: ${_formatDate(oneri['tarih'] as Timestamp)}'),
                          Text('Öneren: ${oneri['olusturanEmail']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green,
                            onPressed: () async {
                              try {
                                await _firestore.collection('etkinlikler').add({
                                  'baslik': oneri['baslik'],
                                  'aciklama': oneri['aciklama'],
                                  'konum': oneri['konum'],
                                  'tarih': oneri['tarih'],
                                  'olusturanId': oneri['olusturanId'],
                                  'olusturmaTarihi': Timestamp.now(),
                                });

                                await _firestore
                                    .collection('etkinlik_onerileri')
                                    .doc(oneriler[index].id)
                                    .update({'durum': 'onaylandi'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Etkinlik önerisi onaylandı'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bir hata oluştu'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                            onPressed: () async {
                              try {
                                await _firestore
                                    .collection('etkinlik_onerileri')
                                    .doc(oneriler[index].id)
                                    .update({'durum': 'reddedildi'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Etkinlik önerisi reddedildi'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bir hata oluştu'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showIsIlanlariDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İş İlanları'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('is_ilanlari')
                .where('durum', isEqualTo: 'beklemede')
                .orderBy('olusturmaTarihi', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Hata: ${snapshot.error}');
                return const Center(child: Text('Bir hata oluştu'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final ilanlar = snapshot.data?.docs ?? [];

              if (ilanlar.isEmpty) {
                return const Center(child: Text('Bekleyen ilan yok'));
              }

              return ListView.builder(
                itemCount: ilanlar.length,
                itemBuilder: (context, index) {
                  final ilan = ilanlar[index].data() as Map<String, dynamic>;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      title: Text(
                        ilan['baslik'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ilan['aciklama'] ?? ''),
                          Text('Firma: ${ilan['firma']}'),
                          Text('Tip: ${ilan['tip']}'),
                          Text('Konum: ${ilan['konum']}'),
                          Text('İletişim: ${ilan['iletisim']}'),
                          Text('Öneren: ${ilan['olusturanEmail']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            color: Colors.green,
                            onPressed: () async {
                              try {
                                await _firestore
                                    .collection('is_ilanlari')
                                    .doc(ilanlar[index].id)
                                    .update({'durum': 'onaylandi'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('İlan onaylandı'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bir hata oluştu'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () async {
                              try {
                                await _firestore
                                    .collection('is_ilanlari')
                                    .doc(ilanlar[index].id)
                                    .update({'durum': 'reddedildi'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('İlan reddedildi'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bir hata oluştu'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

class EtkinliklerIcerik extends StatelessWidget {
  const EtkinliklerIcerik({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final bool isAdmin = auth.currentUser?.email == "kaan@gmail.com";

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/selcuk_banner.jpg.webp"),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selçuk Üniversitesi',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Etkinlikler',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('etkinlikler')
                      .orderBy('tarih', descending: true)
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
                        child: Text('Henüz etkinlik bulunmuyor'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final etkinlik = snapshot.data!.docs[index];
                        final etkinlikData =
                            etkinlik.data() as Map<String, dynamic>;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child:
                                  const Icon(Icons.event, color: Colors.white),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    etkinlikData['baslik'] ??
                                        'Başlıksız Etkinlik',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if (isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Etkinliği Sil'),
                                          content: const Text(
                                              'Bu etkinliği silmek istediğinizden emin misiniz?'),
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
                                                      .collection('etkinlikler')
                                                      .doc(etkinlik.id)
                                                      .delete();

                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Etkinlik silindi'),
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
                                                            'Etkinlik silinirken bir hata oluştu'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              child: const Text('Sil',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(etkinlikData['aciklama'] ?? ''),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(
                                          etkinlikData['tarih'] as Timestamp),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      etkinlikData['konum'] ??
                                          'Konum belirtilmedi',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              _showEtkinlikDetay(context, etkinlikData);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'oneriButton',
            onPressed: () => _showEtkinlikOneriDialog(context),
            label: const Text('Etkinlik Öner'),
            icon: const Icon(Icons.add_comment),
          ),
        ),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEtkinlikDetay(BuildContext context, Map<String, dynamic> etkinlik) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(etkinlik['baslik']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklama: ${etkinlik['aciklama']}'),
              const SizedBox(height: 8),
              Text('Konum: ${etkinlik['konum']}'),
              const SizedBox(height: 8),
              Text('Tarih: ${_formatDate(etkinlik['tarih'] as Timestamp)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showEtkinlikOneriDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final baslikController = TextEditingController();
    final aciklamaController = TextEditingController();
    final konumController = TextEditingController();
    DateTime? secilenTarih;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinlik Önerisi'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: baslikController,
                  decoration: const InputDecoration(labelText: 'Başlık'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Başlık gerekli' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: aciklamaController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Açıklama gerekli' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: konumController,
                  decoration: const InputDecoration(labelText: 'Konum'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Konum gerekli' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        secilenTarih = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  child: const Text('Tarih ve Saat Seç'),
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
                if (secilenTarih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen tarih seçiniz')),
                  );
                  return;
                }

                await firestore.collection('etkinlik_onerileri').add({
                  'baslik': baslikController.text,
                  'aciklama': aciklamaController.text,
                  'konum': konumController.text,
                  'tarih': Timestamp.fromDate(secilenTarih!),
                  'olusturanId': auth.currentUser?.uid,
                  'olusturanEmail': auth.currentUser?.email,
                  'olusturmaTarihi': Timestamp.now(),
                  'durum': 'beklemede',
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Etkinlik öneriniz başarıyla gönderildi'),
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
