import 'package:cloud_firestore/cloud_firestore.dart';

class Universite {
  String id;
  String universiteAdi;
  String sehir;
  String fotoUrl;
  // universiteDetaylari
  String hakkinda = "hata";
  List tumOzellikler = ["hata", "hata", "hata", "hata", "hata"];
  List fotografGalerisi = ["hata", "hata", "hata", "hata"];

  Universite(
      {required this.id,
      required this.universiteAdi,
      required this.sehir,
      required this.fotoUrl});
  factory Universite.olustur(DocumentSnapshot? snapshot) {
    return Universite(
        id: snapshot!.documentID,
        universiteAdi: snapshot.data["universiteAdi"],
        sehir: snapshot.data["sehir"],
        fotoUrl: snapshot.data["fotoUrl"]);
  }
  void setUniversiteDetaylari(DocumentSnapshot snapshot) {
    tumOzellikler.clear();
    fotografGalerisi.clear();
    hakkinda = snapshot.data["hakkinda"];
    tumOzellikler = snapshot.data["universiteKaynaklari"] as List;
    fotografGalerisi = snapshot.data["fotografGalerisi"] as List;
  }
}
