import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/servisler/Authentication.dart';
import 'package:social_media/servisler/FireStore.dart';

class HesapOlustur extends StatefulWidget {
  const HesapOlustur({Key? key}) : super(key: key);

  @override
  State<HesapOlustur> createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  Authentication _auth = Authentication();
  final FireStore _store = FireStore();
  // Automatic warning mode
  AutovalidateMode _mode = AutovalidateMode.disabled;
  //
  bool singUpConditions = false;
  //
  final GlobalKey<FormState> _formKey = GlobalKey();
  //
  String? mail, sifre, kullaniciAdi;
  /////
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: buildIconButtonGoBACK(context),
        title: appBarTextTitle(),
      ),
      body: buildListView(),
    );
  }

  Form buildListView() {
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            children: [
              buildTextFormKullaniciAdi(),
              buildTextFormEposta(),
              buildTextFormPassword(),
              const SizedBox(
                height: 25,
              ),
              buildButtonHesapOlustur(),
            ],
          ),
          buildSignUpIndicator(),
        ],
      ),
    );
  }

  Widget buildSignUpIndicator() {
    return singUpConditions
        ? const Center(child: CircularProgressIndicator())
        : const SizedBox();
  }

  ElevatedButton buildButtonHesapOlustur() {
    return ElevatedButton(
      onPressed: () async {
        // that code close all active keyboards
        FocusManager.instance.primaryFocus?.unfocus();
        var formProcess = _formKey.currentState;
        if (formProcess!.validate()) {
          formProcess.save();
          setState(() {
            singUpConditions = true;
          });
          try {
            FirebaseUser user = await _auth.signUpWithEmailAndPassword(
                mail.toString(), sifre.toString());
            Kullanici.userId = user.uid;
            _store.kullaniciOlustur(
              user.uid,
              user.email,
              kullaniciAdi.toString(),
              "https://blacksaildivision.com/wp-content/uploads/2015/03/centos-users-and-groups-624x390.jpg",
            );
            try {
              DocumentSnapshot snapshot = await _store.kullaniciVarMi(user.uid);
              Kullanici.olustur(snapshot);
            } catch (_) {
              print("Hesap Olustur Hata");
            }

            Navigator.pop(context);
          } on PlatformException catch (err) {
            setState(() {
              singUpConditions = false;
            });

            errorMessangerSnackBar(err);
          }
        } else {
          setState(() {
            _mode = AutovalidateMode.always;
          });
        }
      },
      child: const Text(
        "Hesap Oluştur",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  void errorMessangerSnackBar(PlatformException err) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: "Tamam",
          onPressed: () {},
        ),
        content: Text(
          errorMessages(err),
        ),
      ),
    );
  }

  String errorMessages(error) {
    String hata = "hata";
    switch (error.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
        hata = "E mail adresi zaten kayıltı";
        break;
      case "ERROR_INVALID_EMAIL":
        hata = "Mail formatında bir değer giriniz";
        break;
      case "ERROR_WEAK_PASSWORD":
        hata = "Daha güçlü bir şifre tercih edin";
        break;
      case "ERROR_WRONG_PASSWORD":
        hata = "Şifre hatalı , kontrol edip tekrar deneyiniz";
        break;
      case "ERROR_USER_DISABLED":
        hata = "Hesabınız belirli nedenlerden dolayı kullanıma kapatılmıştır";
        break;
      case "ERROR_USER_NOT_FOUND":
        hata = "Mail adresi bulunamadı ,silinmiş olabilir";
        break;
    }
    return hata;
  }

  TextFormField buildTextFormPassword() {
    return TextFormField(
      obscureText: true,
      autovalidateMode: _mode,
      onSaved: (deger) {
        sifre = deger;
      },
      validator: (value) {
        if (value!.length < 7) {
          return "Güvenliğiniz için en az 7 karakter giriniz";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        labelText: "Şifre",
        icon: Icon(Icons.lock),
      ),
    );
  }

  TextFormField buildTextFormEposta() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: _mode,
      onSaved: (girilenDeger) {
        mail = girilenDeger;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Bu alan doldurulması zorunludur";
        } else if (!value.contains("@")) {
          return "E-posta uzantısı giriniz";
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        labelText: "E-Posta",
        icon: Icon(
          Icons.mail,
        ),
      ),
    );
  }

  TextFormField buildTextFormKullaniciAdi() {
    return TextFormField(
      autovalidateMode: _mode,
      onSaved: (girilenDeger) {
        kullaniciAdi = girilenDeger;
      },
      validator: (value) {
        if (value!.length < 5) {
          return "Ad soyad kısmı en az 5 karakter olmalıdır";
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        labelText: "Adınız Soyadınız",
        border: UnderlineInputBorder(),
        icon: Icon(
          Icons.person,
        ),
      ),
    );
  }

  Text appBarTextTitle() {
    return const Text(
      "Hesap Oluştur",
      style: TextStyle(fontWeight: FontWeight.w400),
    );
  }

  IconButton buildIconButtonGoBACK(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back));
  }
}
