import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/models/tartisma.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/Tartisma.dart';
import 'package:social_media/servisler/FireStore.dart';

class TartismaOlustur extends StatefulWidget {
  const TartismaOlustur({Key? key}) : super(key: key);

  @override
  State<TartismaOlustur> createState() => _TartismaOlusturState();
}

class _TartismaOlusturState extends State<TartismaOlustur> {
  final _controller = TextEditingController();
  final FireStore _store = FireStore();
  GlobalKey<FormState> _formState = GlobalKey();
  String paylasilacakTartisma = "error";
  String ilkYorum = "error";
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade300,
        elevation: 0,
        centerTitle: true,
        title: buildTextAppBarTitle(),
      ),
      body: buildTartismaOlustur(),
    );
  }

  Form buildTartismaOlustur() {
    return Form(
      key: _formState,
      child: ListView(
        children: [
          buildTextFieldTartismaBasligi(),
          buildTextFieldIlkYorum(),
          buildShareButton(),
        ],
      ),
    );
  }

  Padding buildShareButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.brown.shade200),
        onPressed: () async {
          if (_formState.currentState!.validate()) {
            _formState.currentState!.save();
            try {
              DocumentReference ref = await _store.tartismaPaylas(
                  Kullanici.userId.trim(), paylasilacakTartisma);
              klavyeyiKapat();
              _controller.clear();
              Tartismalar tartisma = Tartismalar.refolustur(
                  ref, paylasilacakTartisma, Kullanici.userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Tartışma başarıyla oluşturuldu!",
                  ),
                ),
              );
              try {
                _store.yorumYap(tartisma.id, Kullanici.userId, ilkYorum);
              } catch (_) {
                print("yorum yaparken bir hata oluştu");
              }
              ;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Tartisma(tartisma: tartisma),
                  ));
            } catch (_) {
              print("hata");
            }
          }
        },
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }

  void klavyeyiKapat() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Padding buildTextFieldTartismaBasligi() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(width: 1, color: Colors.brown.shade200)),
        child: TextFormField(
          enableSuggestions: false,
          autocorrect: false,
          controller: _controller,
          validator: (value) {
            if (value!.isEmpty) {
              return "Bu alan doldurması zorunludur";
            } else {
              return null;
            }
          },
          onSaved: (input) {
            paylasilacakTartisma = input!;
          },
          style: const TextStyle(color: Colors.white),
          minLines: 1,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.go,
          maxLength: 40,
          decoration: const InputDecoration(
            enabledBorder: null,
            border: InputBorder.none,
            label: Text(
              "Tartışma başlığı",
              style: ProfilSabitleri.profilOlusturulanTartismaYorumSayisi,
            ),
          ),
        ),
      ),
    );
  }

  Padding buildTextFieldIlkYorum() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(width: 1, color: Colors.brown.shade200)),
        child: TextFormField(
          enableSuggestions: false,
          autocorrect: false,
          validator: (value) {
            if (value!.isEmpty) {
              return "Bu alan doldurması zorunludur";
            } else {
              return null;
            }
          },
          onSaved: (input) {
            ilkYorum = input!;
          },
          style: const TextStyle(color: Colors.black),
          minLines: 1,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.go,
          maxLength: 140,
          decoration: const InputDecoration(
            fillColor: Colors.red,
            enabledBorder: null,
            border: InputBorder.none,
            label: Text(
              "İlk yorumunuzu yazın",
              style: ProfilSabitleri.profilOlusturulanTartismaYorumSayisi,
            ),
          ),
        ),
      ),
    );
  }

  Text buildTextAppBarTitle() => Text("Tartışma Oluştur");
}
