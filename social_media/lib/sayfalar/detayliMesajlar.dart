import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_media/models/digerKullanicilar.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/digerKullanicilarProfil.dart';
import 'package:social_media/servisler/FireStore.dart';

class DetayliMesajlar extends StatefulWidget {
  DigerKullanicilar kullanici;
  String docId;

  DetayliMesajlar(this.kullanici, this.docId, {Key? key}) : super(key: key);

  @override
  State<DetayliMesajlar> createState() => _DetayliMesajlarState();
}

class _DetayliMesajlarState extends State<DetayliMesajlar> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController textContoller = TextEditingController();
  final FireStore _store = FireStore();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: Colors.brown.shade300,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DigerKullanicilarProfil(widget.kullanici),
                ));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.kullanici.photoUrl),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(widget.kullanici.adiSoyadi)
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                scrollDown();
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: _store.anlikMesajlariGetir(widget.docId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  } else {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.documents.length,
                      itemBuilder: (conetext, index) {
                        return mesaj(
                            snapshot.data!.documents[index].data["mesaj"],
                            snapshot.data!.documents[index].data["gonderenId"]);
                      },
                    );
                  }
                },
              ),
            ),
          ),
          mesajGonderTextFormField()
        ],
      ),
    );
  }

  Padding mesajGonderTextFormField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: textContoller,
        keyboardType: TextInputType.text,
        autocorrect: false,
        enableSuggestions: false,
        style: ProfilSabitleri.profilAdSoyad,
        decoration: InputDecoration(
          hintText: "Mesaj yazın",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffixIcon: iconButtonMesajGonder(),
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.brown, width: 1.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  IconButton iconButtonMesajGonder() {
    return IconButton(
      icon:
          const FaIcon(FontAwesomeIcons.arrowRight, color: Colors.yellowAccent),
      onPressed: () {
        anlikMesajGonder(textContoller.text);
        textContoller.clear();
        scrollDown();
      },
    );
  }

  Align mesaj(String message, String mesajSahibiId) {
    return Align(
      alignment: mesajSahibiId == Kullanici.userId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.brown.shade400,
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            message,
            style: ProfilSabitleri.profilOlusturulanTartismaYorumSayisi,
          ),
        ),
      ),
    );
  }

  void anlikMesajGonder(String mesaj) {
    try {
      _store.anlikMesajGonder(widget.docId, Kullanici.userId, mesaj);
    } catch (_) {
      print(
          "Mesaj bilinmeyen bir nedenden dolayı gönderilemedi. Error --> anlikMesajGonder");
    }
  }

  void scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 45);
  }
}
