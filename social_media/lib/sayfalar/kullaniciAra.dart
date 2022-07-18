import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/digerKullanicilar.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/digerKullanicilarProfil.dart';
import 'package:social_media/sayfalar/profil.dart';
import 'package:social_media/servisler/FireStore.dart';

class KullaniciAra extends StatefulWidget {
  const KullaniciAra({Key? key}) : super(key: key);

  @override
  State<KullaniciAra> createState() => _KullaniciAraState();
}

class _KullaniciAraState extends State<KullaniciAra> {
  String kelime = " ";
  final FireStore _store = FireStore();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      body: SafeArea(
        child: Column(
          children: [
            buildSearchBox(),
            Expanded(
              child: kelime == " "
                  ? buildTextKullaniciArayin()
                  : buildFutureBuilderKullaniciKartlari(),
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder<QuerySnapshot> buildFutureBuilderKullaniciKartlari() {
    return FutureBuilder<QuerySnapshot>(
        future: _store.kullanicileriFiltrele(kelime),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: Text(
              "Kullanıcı Bulunamadı",
              style: ProfilSabitleri.profilOlusturulanTartismalar,
            ));
          } else {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.documents.length,
                itemBuilder: (context, index) {
                  if (snapshot.data!.documents.isEmpty) {
                    return const Center(
                        child: Text("Arama sonucunu bulamadık."));
                  } else {
                    DigerKullanicilar kullanici = DigerKullanicilar.olustur(
                        snapshot.data!.documents[index]);
                    return kullaniciKartlari(kullanici);
                  }
                });
          }
        });
  }

  Center buildTextKullaniciArayin() {
    return const Center(
        child: Text(
      "Kullanıcı Arayın",
      style: ProfilSabitleri.profilOlusturulanTartismalar,
    ));
  }

  Widget kullaniciKartlari(DigerKullanicilar kullanici) {
    return GestureDetector(
      onTap: () {
        if (kullanici.userId == Kullanici.userId) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Profil(),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DigerKullanicilarProfil(kullanici),
              ));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.brown.shade200,
          child: ListTile(
            title: Text(
              kullanici.adiSoyadi,
              style: ProfilSabitleri.profilAdSoyad,
            ),
            leading: CircleAvatar(
                radius: 22, backgroundImage: NetworkImage(kullanici.photoUrl)),
          ),
        ),
      ),
    );
  }

  Padding buildSearchBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(),
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              kelime = value;
            });
          },
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.go,
          maxLength: 20,
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            counter: Offstage(),
            border: InputBorder.none,
            label: Text(
              "Kullanıcı Ara",
              style: ProfilSabitleri.profilAdSoyad,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
