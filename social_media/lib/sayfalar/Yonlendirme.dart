import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/sayfalar/Anasayfa.dart';
import 'package:social_media/sayfalar/girisSayfasi.dart';
import 'package:social_media/servisler/Authentication.dart';
import 'package:social_media/servisler/FireStore.dart';

class Yonlendirme extends StatefulWidget {
  const Yonlendirme({Key? key}) : super(key: key);

  @override
  State<Yonlendirme> createState() => _YonlendirmeState();
}

class _YonlendirmeState extends State<Yonlendirme> {
  Authentication _auth = Authentication();
  FireStore _store = FireStore();
  bool girisYapildiMi = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: _auth.onStateChanged(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData) {
            Kullanici.userId = snapshot.data!.uid;
            return const Anasayfa();
          } else {
            return const GirisSayfasi();
          }
        }
      },
    );
  }

  kullaniciOlustur() async {
    DocumentSnapshot snapshot = await _store.kullaniciVarMi(Kullanici.userId);
  }
}
