import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_media/sayfalar/Bildirimler.dart';
import 'package:social_media/sayfalar/Universiteler.dart';
import 'package:social_media/sayfalar/akis.dart';
import 'package:social_media/sayfalar/kullaniciAra.dart';
import 'package:social_media/sayfalar/tartismaOlustur.dart';
import 'package:social_media/servisler/Authentication.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({Key? key}) : super(key: key);

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  PageController? _pageController;
  int _currentIndex = 0;
  Authentication _auth = Authentication();
  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            Akis(),
            Universiteler(),
            KullaniciAra(),
            TartismaOlustur(),
            Bildirimler()
          ]),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
        backgroundColor: Colors.brown.shade200,
        onTap: (index) {
          _pageController!.jumpToPage(index);
          _currentIndex = index;
          setState(() {});
        },
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house), label: "Akış"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.buildingColumns),
              label: "Üniversiteler"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: "Ara"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.message), label: "Tartşıma"),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.wandMagicSparkles),
              label: "Tercih Sihirbazı"),
        ]);
  }
}
