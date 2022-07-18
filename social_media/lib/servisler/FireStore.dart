import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/models/tartisma.dart';

class FireStore {
  final Firestore _auth = Firestore.instance;

  void kullaniciOlustur(
      String id, String email, String adiSoyadi, String photoUrl) async {
    DateTime time = DateTime.now();
    await _auth.collection("kullanicilar").document(id).setData({
      "adiSoyadi": adiSoyadi,
      "email": email,
      "olusturmaZamani": time,
      "fotoUrl": photoUrl,
      "hakkinda": ""
    });
  }

  Future<DocumentSnapshot> kullaniciVarMi(String id) async {
    bool kullaniciVarMi = false;
    DocumentSnapshot snapshot =
        await _auth.collection("kullanicilar").document(id).get();
    return snapshot;
  }

  void kullaniciGuncelle(
      String id, String adiSoyadi, String photoUrl, String hakkinda) {
    _auth.collection("kullanicilar").document(id).updateData(
        {"adiSoyadi": adiSoyadi, "fotoUrl": photoUrl, "hakkinda": hakkinda});
  }

  Future<int> takipciGetir(String id) async {
    QuerySnapshot snapshot = await _auth
        .collection("profil")
        .document(id)
        .collection("takipciler")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<int> takipEdilenleriGetir(String id) async {
    QuerySnapshot snapshot = await _auth
        .collection("profil")
        .document(id)
        .collection("takipEdilenler")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<List<DocumentSnapshot>> profilTartismaBasliklariniGetir(
      String id) async {
    QuerySnapshot snapshot = await _auth
        .collection("tartisma")
        .document(id)
        .collection("tartismalarim")
        .getDocuments();
    return snapshot.documents;
  }

  Future<List<Tartismalar>>
      butunEnFazlaYorumAlmisTartismaBasliklariniGetir() async {
    List<Tartismalar> tartismalar = [];
    List<String> kullaniciId = [];
    QuerySnapshot snap = await _auth.collection("tartisma").getDocuments();
    for (DocumentSnapshot i in snap.documents) {
      kullaniciId.add(i.documentID.toString());
      QuerySnapshot snap2 = await _auth
          .collection("tartisma")
          .document(i.documentID.toString())
          .collection("tartismalarim")
          .getDocuments();
      for (int i = 0; i < snap2.documents.length; i++) {
        tartismalar.add(Tartismalar.olustur(snap2.documents[i]));
      }
    }
    // tartışmanın yüklenme tarihine liste yeninden sıralanıyor.
    tartismalar
        .sort((a, b) => a.toplamYorumSayisi.compareTo(b.toplamYorumSayisi));
    // listeyi ters çeviriyor
    tartismalar = tartismalar.reversed.toList();

    return tartismalar;
  }

  Future<List<Tartismalar>> butunEnYeniTartismaBasliklariniGetir() async {
    List<Tartismalar> tartismalar = [];
    List<String> kullaniciId = [];
    QuerySnapshot snap = await _auth.collection("tartisma").getDocuments();
    for (DocumentSnapshot i in snap.documents) {
      kullaniciId.add(i.documentID.toString());
      QuerySnapshot snap2 = await _auth
          .collection("tartisma")
          .document(i.documentID.toString())
          .collection("tartismalarim")
          .getDocuments();
      for (int i = 0; i < snap2.documents.length; i++) {
        tartismalar.add(Tartismalar.olustur(snap2.documents[i]));
      }
    }
    // tartışmanın yüklenme tarihine liste yeninden sıralanıyor.
    tartismalar.sort((a, b) => a.olusturmaZamani!.compareTo(b.olusturmaZamani));
    // listeyi ters çeviriyor
    tartismalar = tartismalar.reversed.toList();

    return tartismalar;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _auth
        .collection("yorum")
        .document(gonderiId)
        .collection("yorumlar")
        .orderBy("olusturmaZamani", descending: false)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> toplamYorumSayisi(String gonderiId) async {
    QuerySnapshot snapshot = await _auth
        .collection("yorum")
        .document(gonderiId)
        .collection("yorumlar")
        .getDocuments();
    return snapshot.documents;
  }

  Stream<QuerySnapshot> yorumunBegeniSayisi(String gonderiId, String yorumId) {
    return _auth
        .collection("yorum")
        .document(gonderiId)
        .collection("yorumlar")
        .document(yorumId)
        .collection("yorumuBegenenler")
        .snapshots();
  }

  yorumuBegen(String gonderiId, String yorumId, String kullaniciId) {
    return _auth
        .collection("yorum")
        .document(gonderiId)
        .collection("yorumlar")
        .document(yorumId)
        .collection("yorumuBegenenler")
        .document(kullaniciId)
        .setData({});
  }

  Future<bool> yorumBegenildiMi(
      String gonderiId, String yorumId, String userId) async {
    bool begenildiMi = false;
    DocumentSnapshot snapshot = await _auth
        .collection("yorum")
        .document(gonderiId)
        .collection("yorumlar")
        .document(yorumId)
        .collection("yorumuBegenenler")
        .document(userId)
        .get();
    if (snapshot.exists) {
      begenildiMi = true;
    } else {
      begenildiMi = false;
    }
    return begenildiMi;
  }

  yorumDislike(String gonderiId, String yorumId, String userId) {
    _auth
        .collection("yorum")
        .document(gonderiId)
        .collection("yorumlar")
        .document(yorumId)
        .collection("yorumuBegenenler")
        .document(userId)
        .delete();
  }

  Future<DocumentReference> tartismaPaylas(
      String userId, String tartismaBasligi) async {
    var ref = await _auth
        .collection("tartisma")
        .document(userId)
        .collection("tartismalarim")
        .add({
      "baslik": tartismaBasligi,
      "yayinlayanId": userId,
      "olusturmaZamani": Timestamp.now(),
      "toplamYorumSayisi": 1,
    });
    var snap = await _auth
        .collection("tartisma")
        .document(userId)
        .setData({"field": "value"});
    return ref;
  }

  yorumYap(String gonderiId, String yorumYapanId, String yorum) {
    _auth.collection("yorum").document(gonderiId).collection("yorumlar").add({
      "yorum": yorum,
      "olusturmaZamani": Timestamp.now(),
      "yorumYapanId": yorumYapanId,
    });
  }

  tartismaninToplamYorumSaysiniArtir(
      String tartismaSahibiId, String tartismaId) {
    _auth
        .collection("tartisma")
        .document(tartismaSahibiId)
        .collection("tartismalarim")
        .document(tartismaId)
        .updateData(
      {
        "toplamYorumSayisi": FieldValue.increment(1),
      },
    );
  }

  takipEt(String takipEdilenId, String takipEdenId) {
    _auth
        .collection("profil")
        .document(takipEdilenId)
        .collection("takipciler")
        .document(takipEdenId)
        .setData({"takipEtmeZamani": Timestamp.now()});

    _auth
        .collection("profil")
        .document(takipEdenId)
        .collection("takipEdilenler")
        .document(takipEdilenId)
        .setData({"filed": "value"});
  }

  takiptenCik(String takipEdilenId, String takipEdenId) {
    _auth
        .collection("profil")
        .document(takipEdilenId)
        .collection("takipciler")
        .document(takipEdenId)
        .delete();

    _auth
        .collection("profil")
        .document(takipEdenId)
        .collection("takipEdilenler")
        .document(takipEdilenId)
        .delete();
  }

  Future<bool> kullaniciTakipEdiliyorMu(
      String takipEdilenId, String takipEdenId) async {
    bool kullaniciTakipEdiliyorMu = false;
    var snapshot = await _auth
        .collection("profil")
        .document(takipEdilenId)
        .collection("takipciler")
        .document(takipEdenId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> bildirimlerTakipEdenleriiGetir(String kullaniciId) {
    Stream<QuerySnapshot> snapshot = _auth
        .collection("profil")
        .document(kullaniciId)
        .collection("takipciler")
        .orderBy("takipEtmeZamani", descending: true)
        .limit(10)
        .snapshots();
    return snapshot;
  }

  Future<QuerySnapshot> bildirimlerTartismalariGetir(String kullaniciId) async {
    QuerySnapshot snapshot = await _auth
        .collection("tartisma")
        .document(kullaniciId)
        .collection("tartismalarim")
        .getDocuments();
    return snapshot;
  }

  Stream<QuerySnapshot> bildirimlerTartismayaYapilanYorumlariGetir(
      String tartismaId) {
    Stream<QuerySnapshot> snapshot = _auth
        .collection("yorum")
        .document(tartismaId)
        .collection("yorumlar")
        .orderBy("olusturmaZamani", descending: true)
        .limit(10)
        .snapshots();
    return snapshot;
  }

  Future<int> tartismaSayisiniGetir(String kullaniciId) async {
    QuerySnapshot snapshot = await _auth
        .collection("tartisma")
        .document(kullaniciId)
        .collection("tartismalarim")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<QuerySnapshot> universiteiBilgileriniGetir() async {
    return await _auth.collection("universiteler").getDocuments();
  }

  Future<DocumentSnapshot> universiteDetayliBilgileriniGetir(
      String uniId) async {
    return await _auth.collection("universiteDetay").document(uniId).get();
  }

  Stream<QuerySnapshot> gecmisMesajlarinKullanicilariniGetir(
      String kullaniciId) {
    Stream<QuerySnapshot> snapshot = _auth
        .collection("mesajlar")
        .where("uyeler", arrayContains: kullaniciId)
        .snapshots();
    return snapshot;
  }

  Stream<QuerySnapshot> anlikMesajlariGetir(String docId) {
    Stream<QuerySnapshot> snapshot = _auth
        .collection("mesajlar")
        .document(docId)
        .collection("sohbetIcerik")
        .orderBy("gonderimZamani", descending: false)
        .snapshots();
    return snapshot;
  }

  anlikMesajGonder(String docId, String gonderenId, String mesaj) {
    _auth
        .collection("mesajlar")
        .document(docId)
        .collection("sohbetIcerik")
        .add({
      "gonderenId": gonderenId,
      "gonderimZamani": Timestamp.now(),
      "mesaj": mesaj
    });
  }

  Future<String> mesajOlustur(
      String mesajGonderecekUyeninId, String mesajGonderilecekUyeninId) async {
    DocumentReference? docsnap;
    QuerySnapshot snapshot = await _auth
        .collection("mesajlar")
        .where("uyeler", arrayContains: mesajGonderecekUyeninId)
        .getDocuments();
    bool varMi = false;
    // eger QuerySnapshot boş işe --> yani veri yok ise yeni bir mesaj oluşturuluyor
    if (snapshot.documents.isEmpty) {
      docsnap = await _auth.collection("mesajlar").add(
        {
          "displayMessage": "uygulamadan olusturuldu",
          "uyeler": [mesajGonderecekUyeninId, mesajGonderilecekUyeninId]
        },
      );
    } else {
      /* eger veri var ise 2.sorgu burada başlıyor , [ 2 id 1 array de var mı sorgusu] */
      for (int i = 0; i < snapshot.documents.length; i++) {
        List list = snapshot.documents[i].data["uyeler"] as List;
        /*  eğer iki veri de 1 arrayde var mı kontrolu yapılıyor var ise dokuman referansi gonderiliyor */
        if (list.contains(mesajGonderilecekUyeninId)) {
          varMi = true;
          docsnap = snapshot.documents[i].reference;
          break;
        }
      }
      if (varMi == false) {
        docsnap = await _auth.collection("mesajlar").add(
          {
            "displayMessage": "uygulamadan olusturuldu",
            "uyeler": [mesajGonderecekUyeninId, mesajGonderilecekUyeninId]
          },
        );
      }
    }
    return docsnap!.documentID;
  }

  Future<QuerySnapshot> kullanicileriFiltrele(String kelime) async {
    QuerySnapshot snapshot = await _auth
        .collection('kullanicilar')
        .orderBy('adiSoyadi')
        .startAt([kelime]).endAt([kelime + '\uf8ff']).getDocuments();

    return snapshot;
  }

  Stream<DocumentSnapshot> profilBilgileriniGetir(String userId) {
    Stream<DocumentSnapshot> snapshot =
        _auth.collection("kullanicilar").document(userId).snapshots();
    return snapshot;
  }
}
