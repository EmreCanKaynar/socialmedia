import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/Anasayfa.dart';
import 'package:social_media/servisler/FireStore.dart';
import 'package:social_media/servisler/Storage.dart';

class ProfilDuzenle extends StatefulWidget {
  const ProfilDuzenle({Key? key}) : super(key: key);

  @override
  State<ProfilDuzenle> createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  final Storage _storage = Storage();
  File? _secilmisFotograf;
  final FireStore _store = FireStore();
  String adiSoyadi = "hata";
  String hakkinda = "hata";
  String fotoUrl = " ";
  final TextEditingController _adiSoyadiController = TextEditingController();
  final TextEditingController _hakkindaController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        actions: [
          buildIconButtonBitti(),
        ],
        foregroundColor: Colors.white,
        backgroundColor: Colors.brown.shade300,
        centerTitle: true,
        title: const Text("Profili Düzenle"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _store.profilBilgileriniGetir(Kullanici.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Veri bulunamadı"),
            );
          } else {
            adiSoyadi = snapshot.data?["adiSoyadi"] ?? "null";
            hakkinda = snapshot.data?["hakkinda"] ?? "null";
            fotoUrl = snapshot.data?["fotoUrl"] ?? "null";
            return buildBody();
          }
        },
      ),
    );
  }

  _kaydet() async {
    String profilFotoUrl;
    if (_secilmisFotograf == null) {
      profilFotoUrl = fotoUrl;
    } else {
      profilFotoUrl = await _storage.resimYukle(_secilmisFotograf);
    }
    _store.kullaniciGuncelle(Kullanici.userId, _adiSoyadiController.text,
        profilFotoUrl, _hakkindaController.text);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Anasayfa()),
        (Route<dynamic> route) => false);
  }

  Center buildBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildColumnProfilFotografi(),
            Column(
              children: [
                buildRowAdiTextField(),
                buildRowHakkindaTextField(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row buildRowAdiTextField() {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Text(
            "Adı Soyadı",
            style: ProfilSabitleri.profilAdSoyad,
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  style: ProfilSabitleri.profilAdSoyad,
                  controller: _adiSoyadiController..text = adiSoyadi),
            )),
      ],
    );
  }

  Row buildRowHakkindaTextField() {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Text(
            "Hakkında",
            style: ProfilSabitleri.profilAdSoyad,
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: ProfilSabitleri.profilAdSoyad,
                controller: _hakkindaController..text = hakkinda,
              ),
            )),
      ],
    );
  }

  Widget buildColumnProfilFotografi() {
    return GestureDetector(
      onTap: () {
        galeridenSec();
      },
      child: Column(
        children: [
          buildProfilFotografi(),
          const SizedBox(
            height: 10,
          ),
          buildTextFotografDegistir(),
        ],
      ),
    );
  }

  Text buildTextFotografDegistir() => Text(
        "Profil Fotoğrafını Değiştir",
        style: ProfilSabitleri.profilFotografDegistir,
      );

  CircleAvatar buildProfilFotografi() {
    return CircleAvatar(
      radius: 70,
      backgroundImage: _secilmisFotograf == null
          ? NetworkImage(fotoUrl)
          : FileImage(_secilmisFotograf!) as ImageProvider,
    );
  }

  IconButton buildIconButtonBitti() {
    return IconButton(
        onPressed: () {
          _kaydet();
        },
        icon: const FaIcon(FontAwesomeIcons.check));
  }

  galeridenSec() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _secilmisFotograf = File(image.path);
    });
  }
}
