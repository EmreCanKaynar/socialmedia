import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Storage {
  final StorageReference _storage = FirebaseStorage.instance.ref();
  String? resimId;

  Future<String> resimYukle(File? resimDosyasi) async {
    resimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage
        .child("resimler/profil/profil_$resimId.jpg")
        .putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResim = await snapshot.ref.getDownloadURL();
    return yuklenenResim;
  }
}
