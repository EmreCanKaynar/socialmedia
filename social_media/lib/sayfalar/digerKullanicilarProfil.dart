import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:social_media/models/digerKullanicilar.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/models/tartisma.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/Tartisma.dart';
import 'package:social_media/sayfalar/detayliMesajlar.dart';

import '../servisler/FireStore.dart';

class DigerKullanicilarProfil extends StatefulWidget {
  DigerKullanicilar kullanici;

  DigerKullanicilarProfil(this.kullanici, {Key? key}) : super(key: key);

  @override
  State<DigerKullanicilarProfil> createState() =>
      _DigerKullanicilarProfilState();
}

class _DigerKullanicilarProfilState extends State<DigerKullanicilarProfil> {
  String? mesajDocId;
  FireStore? _store;
  int takipci = 0;
  int takip = 0;
  int gonderiler = 0;
  String hakkinda = "deneme";
  bool? takipEdiliyorMu = false;
  List tartismaListesi = [];
  @override
  void initState() {
    _store = FireStore();
    mesajOlustur();
    olusturulanTartismaSayisiniGetir();
    kullaniciTakipEdiliyorMu();
    tartismalariGetir();
    kullaniciTakipEdiliyorMu();
    takipciGetir();
    takipEdilenleriGetir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown.shade300,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _store!.kullaniciVarMi(widget.kullanici.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          } else {
            widget.kullanici = DigerKullanicilar.olustur(snapshot.data);
            return buildListView();
          }
        },
      ),
    );
  }

  Future<void> tartismalariGetir() async {
    List list =
        await _store!.profilTartismaBasliklariniGetir(widget.kullanici.userId);
    setState(() {
      tartismaListesi = list;
    });
  }

  ListView buildListView() {
    return ListView(shrinkWrap: true, children: [
      buildKullaniciBilgileri(),
      buildAdSoyad(),
      buildHakkinda(),
      buildRowButonlar(),
      buildTextOlusturulanTartismalar(),
      const SizedBox(height: 10),
      FutureBuilder<List<DocumentSnapshot>>(
          future:
              _store!.profilTartismaBasliklariniGetir(widget.kullanici.userId),
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
                                      " yorum",
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

  Row buildRowButonlar() {
    return Row(
      children: [
        Expanded(child: buildButtonTakipEt()),
        Expanded(child: buildButtonMesajGonder()),
      ],
    );
  }

  Widget buildButtonMesajGonder() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.white)),
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetayliMesajlar(widget.kullanici, mesajDocId!),
              ),
            );
          },
          child: const Text(
            "Mesaj Gönder",
            style: ProfilSabitleri.profilOlusturulanTartismalar,
          ),
          style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              side: const BorderSide(width: 0.2, color: Colors.grey)),
        ),
      ),
    );
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

  Future<void> olusturulanTartismaSayisiniGetir() async {
    gonderiler = await _store!.tartismaSayisiniGetir(widget.kullanici.userId);
    setState(() {});
  }

  Future<void> takipciGetir() async {
    int takipciler =
        await _store!.takipciGetir(widget.kullanici.userId.toString());
    setState(() {
      takipci = takipciler;
    });
  }

  Future<void> takipEdilenleriGetir() async {
    int takipEdilenler =
        await _store!.takipEdilenleriGetir(widget.kullanici.userId.toString());
    setState(() {
      takip = takipEdilenler;
    });
  }

  Future<void> kullaniciTakipEdiliyorMu() async {
    takipEdiliyorMu = await _store!
        .kullaniciTakipEdiliyorMu(widget.kullanici.userId, Kullanici.userId);
    setState(() {});
  }

  Future<void> mesajOlustur() async {
    mesajDocId =
        await _store!.mesajOlustur(Kullanici.userId, widget.kullanici.userId);
  }

  Widget buildButtonTakipEt() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.white)),
        child: OutlinedButton(
          onPressed: () {
            if (takipEdiliyorMu!) {
              _store!.takiptenCik(widget.kullanici.userId, Kullanici.userId);
            } else {
              _store!.takipEt(widget.kullanici.userId, Kullanici.userId);
            }
            kullaniciTakipEdiliyorMu();
            takipciGetir();
          },
          child: Text(
            takipEdiliyorMu! ? "Takipten Çık" : "Takip Et",
            style: ProfilSabitleri.profilOlusturulanTartismalar,
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
        widget.kullanici.hakkinda!,
        style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat"),
      ),
    );
  }

  Padding buildAdSoyad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        widget.kullanici.adiSoyadi,
        style: ProfilSabitleri.profilAdSoyad,
      ),
    );
  }

  Row buildKullaniciBilgileri() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ProfilFotografi(photoUrl: widget.kullanici.photoUrl),
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
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(icerik, style: ProfilSabitleri.profilDurumSayaclari),
      ],
    );
  }
}

class ProfilFotografi extends StatelessWidget {
  String photoUrl;

  ProfilFotografi({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 55,
      backgroundImage: NetworkImage(photoUrl),
    );
  }
}
