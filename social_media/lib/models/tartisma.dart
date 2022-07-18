import 'package:cloud_firestore/cloud_firestore.dart';

class Tartismalar {
  String id;
  String baslik;
  String yayinlayanId;
  int toplamYorumSayisi;
  Timestamp? olusturmaZamani;
  Tartismalar(
      {required this.id,
      required this.baslik,
      required this.yayinlayanId,
      this.toplamYorumSayisi = 0,
      this.olusturmaZamani});
  factory Tartismalar.olustur(DocumentSnapshot snapshot) {
    return Tartismalar(
      id: snapshot.documentID,
      baslik: snapshot.data["baslik"],
      yayinlayanId: snapshot.data["yayinlayanId"],
      olusturmaZamani: snapshot.data["olusturmaZamani"],
      toplamYorumSayisi: snapshot.data["toplamYorumSayisi"],
    );
  }
  factory Tartismalar.refolustur(
      DocumentReference ref, String tartismaBasligi, publisherId) {
    return Tartismalar(
        id: ref.documentID, baslik: tartismaBasligi, yayinlayanId: publisherId);
  }
}
