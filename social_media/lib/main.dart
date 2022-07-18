import 'package:flutter/material.dart';
import 'package:social_media/sabitler/appBarSabitleri.dart';
import 'package:social_media/sayfalar/Yonlendirme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: AppBarSabitleri.titleTextStyle,
          foregroundColor: Colors.black,
        ),
      ),
      home: const Yonlendirme(),
    );
  }
}
