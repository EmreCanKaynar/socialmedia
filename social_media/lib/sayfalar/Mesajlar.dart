import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/digerKullanicilar.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/detayliMesajlar.dart';
import 'package:social_media/servisler/FireStore.dart';

class Mesajlar extends StatefulWidget {
  const Mesajlar({Key? key}) : super(key: key);

  @override
  State<Mesajlar> createState() => _MesajlarState();
}

class _MesajlarState extends State<Mesajlar> {
  final FireStore _store = FireStore();
  final String sonEtksilesim = "5 dakika önce";
  DigerKullanicilar? digerKullanici;
  String? digerKullaniciId;
  List usersId = [];

  @override
  void initState() {
    mesajlasilmisKullanicilariGetir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: ProfilSabitleri.profilAppBarBackGroundColor,
        foregroundColor: Colors.white,
        title: Text(
          Kullanici.adiSoyadi,
        ),
      ),
      body: ListView(
        children: [textBaslikSohbetler(), buildStreamBuilder()],
      ),
    );
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.gecmisMesajlarinKullanicilariniGetir(Kullanici.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return textSohbetYokMesaji();
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.documents.length,
            itemBuilder: (context, index) {
              usersId.clear();
              usersId = snapshot.data!.documents[index].data["uyeler"];
              for (int i = 0; i < usersId.length; i++) {
                if (usersId[i] != Kullanici.userId) {
                  digerKullaniciId = usersId[i];
                }
              }
              return FutureBuilder<DocumentSnapshot>(
                  future: _store.kullaniciVarMi(digerKullaniciId.toString()),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return SizedBox();
                    } else {
                      DigerKullanicilar navigatoraGidecekKullanici =
                          DigerKullanicilar.olustur(snap.data);
                      digerKullanici = DigerKullanicilar.olustur(snap.data);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetayliMesajlar(
                                  navigatoraGidecekKullanici,
                                  snapshot.data!.documents[index].documentID),
                            ),
                          );
                        },
                        child: cardVarOlanMesajlar(digerKullanici!.photoUrl,
                            digerKullanici!.adiSoyadi),
                      );
                    }
                  });
            },
          );
        }
      },
    );
  }

  Center textSohbetYokMesaji() {
    return const Center(
        child: Text(
      "Hiçbir sohbetini görüntüleyemiyoruz",
      style: ProfilSabitleri.profilOlusturulanTartismalar,
    ));
  }

  Card cardVarOlanMesajlar(String imageUrl, String adSoyad) {
    return Card(
      color: Colors.brown.shade200,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          adSoyad,
          style: ProfilSabitleri.profilAdSoyad,
        ),
        subtitle: Text(
          sonEtksilesim,
        ),
      ),
    );
  }

  Padding textBaslikSohbetler() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "Sohbetler",
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat",
            fontSize: 30),
      ),
    );
  }

  Stream<QuerySnapshot> mesajlasilmisKullanicilariGetir() {
    return _store.gecmisMesajlarinKullanicilariniGetir(Kullanici.userId);
  }
}
