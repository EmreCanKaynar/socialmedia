import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/models/interfaceOfKullanici.dart';

class Kullanici extends ButunKullanicilar {
  static String userId = "";
  static String adiSoyadi = "nullW";
  static String email = "nullW";
  static String? photoUrl =
      "https://blacksaildivision.com/wp-content/uploads/2015/03/centos-users-and-groups-624x390.jpg";
  static String? hakkinda = "Açıklama";

  Kullanici.olustur(DocumentSnapshot? snapshot) {
    userId = snapshot!.documentID.trim();
    adiSoyadi = snapshot.data["adiSoyadi"];
    email = snapshot.data["email"];
    photoUrl = snapshot.data["fotoUrl"];
    hakkinda = snapshot.data["hakkinda"];
  }

  @override
  String kullaniciId() {
    return userId;
  }
}
