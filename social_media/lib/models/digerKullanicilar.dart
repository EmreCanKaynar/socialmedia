import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/models/interfaceOfKullanici.dart';

class DigerKullanicilar extends ButunKullanicilar {
  String userId = "";
  String adiSoyadi = "nullW";
  String email = "nullW";
  String photoUrl =
      "https://blacksaildivision.com/wp-content/uploads/2015/03/centos-users-and-groups-624x390.jpg";
  String? hakkinda = " ";
  DigerKullanicilar(
      {required this.userId,
      required this.adiSoyadi,
      required this.email,
      this.hakkinda = "none",
      this.photoUrl =
          "https://blacksaildivision.com/wp-content/uploads/2015/03/centos-users-and-groups-624x390.jpg"});
  factory DigerKullanicilar.olustur(DocumentSnapshot? snapshot) {
    return DigerKullanicilar(
      userId: snapshot!.documentID,
      adiSoyadi: snapshot.data["adiSoyadi"],
      email: snapshot.data["email"],
      hakkinda: snapshot.data["hakkinda"],
      photoUrl: snapshot.data["fotoUrl"],
    );
  }

  @override
  String kullaniciId() {
    return userId;
  }
}
