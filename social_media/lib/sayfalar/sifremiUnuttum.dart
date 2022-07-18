import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media/servisler/Authentication.dart';

class SifremiUnuttum extends StatefulWidget {
  const SifremiUnuttum({Key? key}) : super(key: key);

  @override
  State<SifremiUnuttum> createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  final emailConttoler = TextEditingController();
  final Authentication _auth = Authentication();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Şifremi Unuttum"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        buildTextWarningMessage("Şifrenizi sıfırlamak için"),
        buildTextWarningMessage("E mail adresinizi giriniz."),
        const SizedBox(
          height: 25,
        ),
        buildTextFormEposta(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildElevatedButtonResetPasswod(),
          ],
        ),
      ]),
    );
  }

  Widget buildElevatedButtonResetPasswod() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.mail),
        label: Text("Şifremi Sıfırla"),
        onPressed: () {
          resetPassword(emailConttoler.text);
        },
      ),
    );
  }

  Center buildTextWarningMessage(String text) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget buildTextFormEposta() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: emailConttoler,
        keyboardType: TextInputType.emailAddress,
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
      ),
    );
  }

  void resetPassword(String email) async {
    try {
      await _auth.resetPassword(email);
      FocusManager.instance.primaryFocus?.unfocus();
      showMessage("Şifre sıfırlama linki gönderildi");
    } on PlatformException catch (error) {
      FocusManager.instance.primaryFocus?.unfocus();
      showMessage(errorMessages(error));
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          text,
        ),
      ),
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
      default:
        hata = "Bilinmeyen bir hata oluştu";
    }
    return hata;
  }
}
