import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_media/models/digerKullanicilar.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/models/tartisma.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/digerKullanicilarProfil.dart';
import 'package:social_media/sayfalar/profil.dart';
import 'package:text_scroll/text_scroll.dart';

import '../models/yorum.dart';
import '../servisler/FireStore.dart';

class Tartisma extends StatefulWidget {
  FireStore _store = FireStore();
  Tartismalar tartisma;
  bool yorumBegenildi = false;
  Tartisma({Key? key, required this.tartisma}) : super(key: key);
  @override
  State<Tartisma> createState() => _TartismaState();
}

class _TartismaState extends State<Tartisma> {
  String yapilacakYorum = "error";
  GlobalKey<FormState> _formState = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: ProfilSabitleri.profilAppBarBackGroundColor,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                bottomSheet();
              },
              icon: const FaIcon(FontAwesomeIcons.comment))
        ],
        title: TextScroll(
          widget.tartisma.baslik,
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
          delayBefore: const Duration(milliseconds: 500),
          numberOfReps: 5,
          pauseBetween: const Duration(milliseconds: 10),
          style: const TextStyle(color: Colors.white, fontSize: 17),
          textAlign: TextAlign.right,
          selectable: true,
        ),
      ),
      body: ListView(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: widget._store.yorumlariGetir(widget.tartisma.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.documents.length,
                  itemBuilder: (context, index) {
                    Yorum yorum = Yorum.name(snapshot.data!.documents[index]);
                    return Card(
                      color: Colors.brown.shade200,
                      child: ListTile(
                        title: buildFutureBuilderKullaniciAdSoyad(yorum),
                        subtitle: buildStreamBuilderYorumBegeniSayisi(yorum),
                        trailing: IconButton(
                          icon: buildFutureBuilderIconRengi(yorum),
                          onPressed: () async {
                            bool yorumBegendiMi = false;
                            if (await yorumBegenildiMi(widget.tartisma.id,
                                yorum.id, Kullanici.userId)) {
                              yorumBegendiMi = true;
                              setState(() {
                                widget.yorumBegenildi = yorumBegendiMi;
                              });
                              yorumDislike(widget.tartisma.id, yorum.id,
                                  Kullanici.userId);
                            } else {
                              yorumBegendiMi = false;
                              setState(() {
                                widget.yorumBegenildi = yorumBegendiMi;
                              });
                              yorumLike(widget.tartisma.id, yorum.id,
                                  Kullanici.userId);
                            }
                          },
                        ),
                        leading: FutureBuilder<DocumentSnapshot>(
                            future: widget._store
                                .kullaniciVarMi(yorum.yorumYapanId),
                            builder: (context, kullaniciSnapshot) {
                              if (!kullaniciSnapshot.hasData) {
                                return const Text("Error Kullanici Adi");
                              } else {
                                DigerKullanicilar kullanici =
                                    DigerKullanicilar.olustur(
                                        kullaniciSnapshot.data);
                                return buildGestureDecetorProfilYonlendirme(
                                    kullanici, context);
                              }
                            }),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  GestureDetector buildGestureDecetorProfilYonlendirme(
      DigerKullanicilar kullanici, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Kullanici.userId == kullanici.userId) {
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
            ),
          );
        }
      },
      child: CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(kullanici.photoUrl),
      ),
    );
  }

  FutureBuilder<DocumentSnapshot> buildFutureBuilderKullaniciAdSoyad(
      Yorum yorum) {
    return FutureBuilder<DocumentSnapshot>(
        future: widget._store.kullaniciVarMi(yorum.yorumYapanId),
        builder: (context, kullaniciSnapshot) {
          if (!kullaniciSnapshot.hasData) {
            return const Text("Error Kullanici Adi");
          } else {
            DigerKullanicilar kullanici =
                DigerKullanicilar.olustur(kullaniciSnapshot.data);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kullanici.adiSoyadi,
                  style: ProfilSabitleri.profilAdSoyad,
                ),
                AutoSizeText(yorum.yorum,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.brown.shade800)),
              ],
            );
          }
        });
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilderYorumBegeniSayisi(
      Yorum yorum) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget._store.yorumunBegeniSayisi(widget.tartisma.id, yorum.id),
        builder: (context, snap) {
          yorum.yorumBegeniSayisi =
              snap.data?.documents.length.toString() ?? "0";
          if (!snap.hasData) {
            return Text("HasData Error");
          } else {
            return Text(
              yorum.yorumBegeniSayisi + " kişi bu yorumu beğendi",
              style: ProfilSabitleri.profilOlusturulanTartismaYorumSayisi,
            );
          }
        });
  }

  FutureBuilder<bool> buildFutureBuilderIconRengi(Yorum yorum) {
    return FutureBuilder<bool>(
      future: widget._store
          .yorumBegenildiMi(widget.tartisma.id, yorum.id, Kullanici.userId),
      builder: (context, yorumsnap) {
        if (yorumsnap.data == true) {
          widget.yorumBegenildi = true;
          return Icon(Icons.favorite,
              color: widget.yorumBegenildi ? Colors.red : Colors.white);
        } else {
          widget.yorumBegenildi = false;
          return Icon(Icons.favorite,
              color: widget.yorumBegenildi ? Colors.red : Colors.white);
        }
      },
    );
  }

  Future<bool> yorumBegenildiMi(
      String gonderiId, String yorumId, String userId) async {
    bool begenildimi =
        await widget._store.yorumBegenildiMi(gonderiId, yorumId, userId);
    return begenildimi;
  }

  yorumDislike(String gonderiId, String yorumId, String userId) {
    widget._store.yorumDislike(gonderiId, yorumId, userId);
  }

  yorumLike(String gonderiId, String yorumId, String userId) {
    widget._store.yorumuBegen(gonderiId, yorumId, userId);
  }

  void bottomSheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: context,
      builder: (context) {
        return Form(
          key: _formState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: textFormFieldYorumYap(),
              ),
            ],
          ),
        );
      },
    );
  }

  TextFormField textFormFieldYorumYap() => TextFormField(
        enableSuggestions: false,
        minLines: 1,
        maxLines: 4,
        maxLength: 200,
        autocorrect: false,
        validator: (value) {
          if (value!.isEmpty) {
            return "Bu alan doldurması zorunludur";
          } else {
            return null;
          }
        },
        onSaved: (input) {
          yapilacakYorum = input!;
        },
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Yorum yazın",
          suffixIcon: yorumYapButonu(),
        ),
      );
  IconButton yorumYapButonu() {
    return IconButton(
        onPressed: () {
          if (_formState.currentState!.validate()) {
            _formState.currentState!.save();
            try {
              widget._store.yorumYap(
                  widget.tartisma.id, Kullanici.userId, yapilacakYorum);
              widget._store.tartismaninToplamYorumSaysiniArtir(
                  widget.tartisma.yayinlayanId, widget.tartisma.id);
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarShowMessage(),
              );
              Navigator.pop(context);
            } catch (_) {
              print("yorum yaparken bir hata oluştu! --> try catch(Tartisma)");
            }
          }
        },
        icon: Icon(Icons.done));
  }

  SnackBar snackBarShowMessage() {
    return const SnackBar(
      content: Text(
        "Yorum başarıyla yapıldı",
      ),
    );
  }
}
