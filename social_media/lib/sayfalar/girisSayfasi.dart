import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/sayfalar/hesapOlustur.dart';
import 'package:social_media/sayfalar/sifremiUnuttum.dart';
import 'package:social_media/servisler/Authentication.dart';
import 'package:social_media/servisler/FireStore.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key? key}) : super(key: key);

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  //
  String? mail, password;
  //Authantication Serverces
  final Authentication _auth = Authentication();
  final FireStore _store = FireStore();
  // contidions
  bool obsecure = true;
  bool _allConditions = false;
  AutovalidateMode _validateMode = AutovalidateMode.disabled;
  // global key about form.
  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            buildListView(),
            signInDownloading(),
          ],
        ),
      ),
    );
  }

  Widget signInDownloading() {
    return _allConditions
        ? Center(child: CircularProgressIndicator())
        : SizedBox();
  }

  Form buildListView() {
    return Form(
      key: _formState,
      child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          children: [
            const SizedBox(
              height: 30,
            ),
            buildCircleLogo(),
            const SizedBox(
              height: 30,
            ),
            buildTextFormMail(),
            const SizedBox(
              height: 30,
            ),
            buildTextFormPassword(),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(child: buildButtonHesapOlustur()),
                const SizedBox(
                  width: 5,
                ),
                Expanded(child: buildButtonGirisYap()),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "veya",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            buildTextGoogleSignIn(),
            const SizedBox(
              height: 15,
            ),
            buildTextForgotMyPassword(),
          ]),
    );
  }

  Widget buildTextForgotMyPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SifremiUnuttum(),
            ));
      },
      child: Text(
        "Şifremi Unuttum",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildTextGoogleSignIn() {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _allConditions = true;
        });
        try {
          FirebaseUser user = await _auth.SignInWithGoogle();
          DocumentSnapshot snapshot = await _store.kullaniciVarMi(user.uid);
          if (snapshot.exists) {
            print("kullanıcı mevcut");
          } else {
            print("kullanıcı sıfırdan oluşturuldu");
            _store.kullaniciOlustur(
                user.uid, user.email, user.displayName, user.photoUrl);
          }
        } on PlatformException catch (error) {
          setState(() {
            _allConditions = false;
          });
          errorMessangerSnackBar(error);
        }
      },
      child: const Text(
        "Google ile Giriş Yap",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
    );
  }

  ElevatedButton buildButtonGirisYap() {
    return ElevatedButton(
      onPressed: () async {
        if (_formState.currentState!.validate()) {
          _formState.currentState!.save();
          setState(() {
            _allConditions = true;
          });
          try {
            var user = await _auth.signInEmailAndPassword(
                mail.toString(), password.toString());
            Kullanici.olustur(await kullaniciBilgileriniGetir(user.uid));
            Kullanici.userId = user.uid;
            print("giris Sayfasi : " + Kullanici.userId);
            FocusManager.instance.primaryFocus?.unfocus();
          } on PlatformException catch (err) {
            errorMessangerSnackBar(err);
            setState(() {
              _allConditions = false;
            });
          }
        } else {
          setState(() {
            _validateMode = AutovalidateMode.onUserInteraction;
          });
        }
      },
      child: const Text("Giriş Yap"),
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

  ElevatedButton buildButtonHesapOlustur() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HesapOlustur(),
            ));
      },
      child: Text("Hesap Oluştur"),
    );
  }

  TextFormField buildTextFormPassword() {
    return TextFormField(
      onSaved: (_password) {
        password = _password;
      },
      autovalidateMode: _validateMode,
      validator: (value) {
        if (value!.isEmpty) {
          return "Bu alan doldurması zorunludur";
        } else {
          return null;
        }
      },
      obscureText: obsecure,
      decoration: InputDecoration(
        labelText: "Şifrenizi giriniz",
        suffixIcon: IconButton(
          onPressed: () {
            if (obsecure) {
              obsecure = false;
            } else {
              obsecure = true;
            }
            setState(() {
              obsecure;
            });
          },
          icon: Icon(obsecure ? Icons.visibility_off : Icons.visibility),
        ),
        icon: Icon(
          Icons.lock,
          color: Colors.blue,
        ),
      ),
    );
  }

  TextFormField buildTextFormMail() {
    return TextFormField(
      onSaved: (_mail) {
        mail = _mail;
      },
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return "Bu alan doldurulması zorunludur";
        } else if (!value.contains("@")) {
          return "Mail uzantısı girilmelidir";
        } else {
          return null;
        }
      },
      autovalidateMode: _validateMode,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelStyle: TextStyle(color: Colors.grey),
        labelText: "E mail adresinizi giriniz",
        iconColor: Colors.blue,
        icon: Icon(
          Icons.mail,
          color: Colors.blue.shade400,
        ),
      ),
    );
  }

  CircleAvatar buildCircleLogo() {
    return const CircleAvatar(
      radius: 70,
      backgroundImage: NetworkImage(
          "https://www.donanimhaber.com/images/images/haber/123019/600x338google-fotograflar-yeniden-tasarlandi-yeni-logo-haritalar-gorunumu-daha-basit-kullanici-arayuzu-ve-daha-fazlasi.jpg"),
    );
  }

  String errorMessages(error) {
    String hata = "hata";
    switch (error.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
        hata = "E mail adresi zaten kayıltı.";
        break;
      case "ERROR_INVALID_EMAIL":
        hata = "Mail formatında bir değer giriniz.";
        break;
      case "ERROR_WEAK_PASSWORD":
        hata = "Daha güçlü bir şifre tercih edin.";
        break;
      case "ERROR_WRONG_PASSWORD":
        hata = "Şifre hatalı! Kontrol edip tekrar deneyiniz.";
        break;
      case "ERROR_USER_DISABLED":
        hata = "Hesabınız belirli nedenlerden dolayı kullanıma kapatılmıştır.";
        break;
      case "ERROR_USER_NOT_FOUND":
        hata = "Kullanıcı bulunamadı! Bilgilerinizi kontrol ediniz.";
        break;
    }
    return hata;
  }

  Future<DocumentSnapshot> kullaniciBilgileriniGetir(String id) async {
    DocumentSnapshot doc = await _store.kullaniciVarMi(id);
    return doc;
  }
}
