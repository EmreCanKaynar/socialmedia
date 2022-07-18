import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/digerKullanicilar.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/models/tartisma.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/Tartisma.dart';
import 'package:social_media/sayfalar/digerKullanicilarProfil.dart';
import 'package:social_media/servisler/FireStore.dart';

class Bildirimler extends StatefulWidget {
  const Bildirimler({Key? key}) : super(key: key);

  @override
  State<Bildirimler> createState() => _BildirimlerState();
}

class _BildirimlerState extends State<Bildirimler> {
  final FireStore _store = FireStore();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.brown.shade300,
        centerTitle: true,
        title: Text("Bildirimler"),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          buildBaslikText("Takip Edenler"),
          buildStreamBuilderTakipEdenleriGetir(),
          buildBaslikText("Tartismalar"),
          buildFutureBuilderTartismalarBildirimleri(),
        ],
      ),
    );
  }

  Padding buildBaslikText(String baslik) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        baslik,
        style: ProfilSabitleri.profilOlusturulanTartismalar,
      ),
    );
  }

  FutureBuilder<QuerySnapshot> buildFutureBuilderTartismalarBildirimleri() {
    return FutureBuilder<QuerySnapshot>(
      future: _store.bildirimlerTartismalariGetir(Kullanici.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text("Veri yok");
        } else {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.documents.length,
            itemBuilder: (context, index) {
              return StreamBuilder<QuerySnapshot>(
                stream: _store.bildirimlerTartismayaYapilanYorumlariGetir(
                    snapshot.data!.documents[index].documentID),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Text("Veri yok...");
                  } else {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snap.data!.documents.length,
                      itemBuilder: (context, ind) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: _store.kullaniciVarMi(
                              snap.data!.documents[ind].data["yorumYapanId"]),
                          builder: (context, lastSnap) {
                            if (!lastSnap.hasData) {
                              return Text("Burada veri yok");
                            } else {
                              DigerKullanicilar kullanici =
                                  DigerKullanicilar.olustur(lastSnap.data);
                              Tartismalar tartisma = Tartismalar.olustur(
                                  snapshot.data!.documents[index]);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Tartisma(tartisma: tartisma),
                                    ),
                                  );
                                },
                                child: lastSnap.data!.documentID ==
                                        Kullanici.userId
                                    ? const SizedBox()
                                    : ListTile(
                                        leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                kullanici.photoUrl)),
                                        title: Text(
                                            snapshot.data!.documents[index]
                                                    .data["baslik"] +
                                                " adlı tartışmana " +
                                                kullanici.adiSoyadi +
                                                " yorum yaptı.",
                                            style:
                                                ProfilSabitleri.profilAdSoyad),
                                      ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilderTakipEdenleriGetir() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.bildirimlerTakipEdenleriiGetir(Kullanici.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Hiç bildirim yok");
        } else {
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.documents.length,
              itemBuilder: (context, index) {
                return Center(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: _store.kullaniciVarMi(
                        snapshot.data!.documents[index].documentID),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return Text("Future verisi yok");
                      } else {
                        DigerKullanicilar kullanici =
                            DigerKullanicilar.olustur(snap.data);
                        return buildTakipEdenlerListTile(kullanici);
                      }
                    },
                  ),
                );
              });
        }
      },
    );
  }

  Widget buildTakipEdenlerListTile(DigerKullanicilar kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DigerKullanicilarProfil(kullanici),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.photoUrl),
        ),
        title: Text(
          kullanici.adiSoyadi + " seni takip etmeye başladı.",
          style: ProfilSabitleri.profilAdSoyad,
        ),
      ),
    );
  }
}
