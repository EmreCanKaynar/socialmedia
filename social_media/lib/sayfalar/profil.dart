import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/models/tartisma.dart';
import 'package:social_media/sabitler/appBarSabitleri.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/Tartisma.dart';
import 'package:social_media/sayfalar/profilDuzenle.dart';
import 'package:social_media/sayfalar/tartismaOlustur.dart';

import '../servisler/FireStore.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  FireStore? _store;
  int takipci = 0;
  int takip = 0;
  int gonderiler = 0;
  String hakkinda = "deneme";
  List tartismaListesi = [];
  @override
  void initState() {
    _store = FireStore();
    olusturulanTartismaSayisiniGetir();
    tartismalariGetir();
    takipciGetir();
    takipEdilenleriGetir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        actions: [buildIconButtonProfiliDuzenle(context)],
        backgroundColor: ProfilSabitleri.profilAppBarBackGroundColor,
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profil",
          style: AppBarSabitleri.titleTextStyle,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _store!.kullaniciVarMi(Kullanici.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          } else {
            Kullanici.olustur(snapshot.data);
            return buildListView();
          }
        },
      ),
    );
  }

  IconButton buildIconButtonProfiliDuzenle(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilDuzenle(),
          ),
        );
      },
      icon: const FaIcon(FontAwesomeIcons.idCard),
    );
  }

  Future<void> tartismalariGetir() async {
    List list = await _store!.profilTartismaBasliklariniGetir(Kullanici.userId);
    print(list.length);
    print(tartismaListesi.length);
    setState(() {
      tartismaListesi = list;
    });
  }

  Future<void> olusturulanTartismaSayisiniGetir() async {
    gonderiler = await _store!.tartismaSayisiniGetir(Kullanici.userId);
    setState(() {});
  }

  ListView buildListView() {
    return ListView(shrinkWrap: true, children: [
      buildKullaniciBilgileri(),
      buildAdSoyad(),
      buildHakkinda(),
      buildButtonTartismaOlustur(),
      buildTextOlusturulanTartismalar(),
      const SizedBox(height: 10),
      FutureBuilder<List<DocumentSnapshot>>(
          future: _store!.profilTartismaBasliklariniGetir(Kullanici.userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 0,
                width: 0,
              );
            } else {
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Tartismalar tartisma =
                        Tartismalar.olustur(snapshot.data![index]);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Tartisma(tartisma: tartisma),
                            ));
                      },
                      child: Card(
                        color: Colors.brown.shade200,
                        child: ListTile(
                          title: Text(
                            tartisma.baslik,
                            style: ProfilSabitleri.profilAdSoyad,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          subtitle: FutureBuilder<List<DocumentSnapshot>>(
                            future: _store?.toplamYorumSayisi(tartisma.id),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return Text("yorum yapılmamış.");
                              } else {
                                tartisma.toplamYorumSayisi = snap.data!.length;

                                return Text(
                                  tartisma.toplamYorumSayisi.toString() +
                                      "  yorum",
                                  style: ProfilSabitleri
                                      .profilOlusturulanTartismaYorumSayisi,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  });
            }
          }),
    ]);
  }

  ListView buildListViewOlusturulanTartismalar() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: tartismaListesi.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              child: ListTile(
                title: Text(tartismaListesi[index]["baslik"]),
              ),
            ),
          );
        });
  }

  Center buildTextOlusturulanTartismalar() {
    return const Center(
      child: Text(
        "Oluşturulan Tartışmalar",
        style: ProfilSabitleri.profilOlusturulanTartismalar,
      ),
    );
  }

  Future<void> takipciGetir() async {
    int takipciler = await _store!.takipciGetir(Kullanici.userId.toString());
    setState(() {
      takipci = takipciler;
    });
  }

  Future<void> takipEdilenleriGetir() async {
    int takipEdilenler =
        await _store!.takipEdilenleriGetir(Kullanici.userId.toString());
    setState(() {
      takip = takipEdilenler;
    });
  }

  Widget buildButtonTartismaOlustur() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.white)),
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TartismaOlustur(),
                ));
          },
          child: const Text(
            "Tartışma Oluştur",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: "Montserrat"),
          ),
          style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              side: const BorderSide(width: 0.2, color: Colors.grey)),
        ),
      ),
    );
  }

  Padding buildHakkinda() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        Kullanici.hakkinda!,
        style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat"),
      ),
    );
  }

  Padding buildAdSoyad() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        Kullanici.adiSoyadi,
        style: ProfilSabitleri.profilAdSoyad,
      ),
    );
  }

  Row buildKullaniciBilgileri() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: ProfilFotografi(),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: buildColumn("$gonderiler", "Tartışmalar")),
              Expanded(child: buildColumn(takipci.toString(), "Takipçi")),
              Expanded(child: buildColumn("$takip", "Takip")),
            ],
          ),
        )
      ],
    );
  }

  Column buildColumn(String sayi, String icerik) {
    return Column(
      children: [
        Text(
          sayi,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          icerik,
          style: ProfilSabitleri.profilDurumSayaclari,
        ),
      ],
    );
  }
}

class ProfilFotografi extends StatelessWidget {
  const ProfilFotografi({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 55,
      backgroundImage: NetworkImage(Kullanici.photoUrl!),
    );
  }
}
