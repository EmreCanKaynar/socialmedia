import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/universite.dart';
import 'package:social_media/sabitler/appBarSabitleri.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sabitler/universiteSabitleri.dart';
import 'package:social_media/sayfalar/UniversiteDetay.dart';
import 'package:social_media/servisler/FireStore.dart';

class Universiteler extends StatefulWidget {
  const Universiteler({Key? key}) : super(key: key);

  @override
  State<Universiteler> createState() => _UniversitelerState();
}

class _UniversitelerState extends State<Universiteler> {
  final FireStore _store = FireStore();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: buildAppBar(),
      body: bodyListView(),
    );
  }

  ListView bodyListView() {
    return ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(
          height: 20,
        ),
        FutureBuilder<QuerySnapshot>(
          future: _store.universiteiBilgileriniGetir(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.documents.length,
                  itemBuilder: (context, index) {
                    Universite universite =
                        Universite.olustur(snapshot.data!.documents[index]);
                    return buildUniversiteKarti(context, universite);
                  });
            }
          },
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: ProfilSabitleri.profilAppBarBackGroundColor,
      elevation: 0,
      centerTitle: true,
      title: const Text("Üniversiteler", style: AppBarSabitleri.titleTextStyle),
    );
  }

  Widget buildUniversiteKarti(BuildContext context, Universite universite) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UniversiteDetay(universite),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.brown.shade200),
          height: MediaQuery.of(context).size.height * 0.20,
          child: Row(
            children: [
              universiteFotografi(universite.fotoUrl),
              const SizedBox(
                width: 10,
              ),
              universiteAdiVeSehriText(
                  universite.universiteAdi, universite.sehir),
            ],
          ),
        ),
      ),
    );
  }

  Container universiteFotografi(String fotoUrl) {
    return Container(
      height: 120,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white60,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(fotoUrl),
        ),
      ),
    );
  }

  Expanded universiteAdiVeSehriText(String universiteAdi, String sehir) {
    return Expanded(
      child: SizedBox(
        height: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              universiteAdi,
              style: UniversiteSabitleri.universiteAdiTextStyle,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              sehir,
              style: UniversiteSabitleri.universiteSehirAdi,
            )
          ],
        ),
      ),
    );
  }
}
