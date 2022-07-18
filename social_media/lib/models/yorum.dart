import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  String id;
  String yorum;
  String yorumYapanId;
  Timestamp olusturmaZamani;
  bool yorumBegenildi = false;
  String yorumBegeniSayisi = "error";
  Yorum(
      {required this.id,
      required this.yorum,
      required this.yorumYapanId,
      required this.olusturmaZamani});
  factory Yorum.name(DocumentSnapshot snapshot) {
    return Yorum(
        id: snapshot.documentID,
        yorum: snapshot.data["yorum"],
        yorumYapanId: snapshot.data["yorumYapanId"],
        olusturmaZamani: snapshot.data["olusturmaZamani"]);
  }
  factory Yorum.olustur(
      String id, String yorum, String yorumYapanId, Timestamp olusturmaZamani) {
    return Yorum(
        id: id,
        yorum: yorum,
        yorumYapanId: yorumYapanId,
        olusturmaZamani: olusturmaZamani);
  }
}
