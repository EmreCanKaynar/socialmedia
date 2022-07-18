import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_media/models/kullanici.dart';
import 'package:social_media/models/tartisma.dart';
import 'package:social_media/sabitler/appBarSabitleri.dart';
import 'package:social_media/sabitler/profilSabitleri.dart';
import 'package:social_media/sayfalar/Bildirimler.dart';
import 'package:social_media/sayfalar/Mesajlar.dart';
import 'package:social_media/sayfalar/Tartisma.dart';
import 'package:social_media/sayfalar/profil.dart';
import 'package:social_media/servisler/FireStore.dart';

import '../models/kullanici.dart';

class Akis extends StatefulWidget {
  const Akis({Key? key}) : super(key: key);

  @override
  State<Akis> createState() => _AkisState();
}

class _AkisState extends State<Akis> with TickerProviderStateMixin {
  final FireStore _store = FireStore();
  String? adiSoyadi;
  String? mailAdresi;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TabController? _controller;
  @override
  void initState() {
    kullaniciBilgileriniGetir();
    print(Kullanici.userId);
    buildUserAccountsDrawerHeader();
    _controller = TabController(length: 2, vsync: this);
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      key: scaffoldKey,
      drawer: buildDrawer(),
      appBar: AppBar(
        bottom: buildTabBar(),
        elevation: 0,
        leading: buildIconProfile(scaffoldKey),
        actions: [
          buildIconButtonRefreshPage(),
          buildIconDirectMessage(),
        ],
        centerTitle: true,
        backgroundColor: ProfilSabitleri.profilAppBarBackGroundColor,
        title: const Text("Akış", style: AppBarSabitleri.titleTextStyle),
      ),
      body: Column(children: [
        buildTabBarView(),
      ]),
    );
  }

  IconButton buildIconButtonRefreshPage() {
    return IconButton(
        onPressed: () {
          setState(() {});
        },
        icon: const Icon(
          Icons.refresh,
          color: Colors.white,
        ));
  }

  Drawer buildDrawer() {
    return Drawer(
      backgroundColor: Colors.brown.shade200,
      child: ListView(children: [
        buildUserAccountsDrawerHeader(),
        buildGestureDetectorProfil(),
        buildGestureDetectorBildirimler(),
        buildDrawerListTile(Icons.account_circle, "Tartışmalarım"),
        buildDrawerListTile(Icons.account_circle, "Ayarlar"),
        buildDrawerListTile(Icons.account_circle, "Yardım"),
        buildGestureDetectorCikisYap(),
      ]),
    );
  }

  FutureBuilder<DocumentSnapshot> buildUserAccountsDrawerHeader() {
    return FutureBuilder(
        future: _store.kullaniciVarMi(Kullanici.userId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            Kullanici.olustur(snap.data);
            return UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.brown.shade300),
              accountName: Text(Kullanici.adiSoyadi,
                  style: ProfilSabitleri.profilAdSoyad),
              accountEmail: Text(
                Kullanici.email,
                style: ProfilSabitleri.profilOlusturulanTartismaYorumSayisi,
              ),
              currentAccountPicture: CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(Kullanici.photoUrl.toString()),
              ),
            );
          }
        });
  }

  GestureDetector buildGestureDetectorProfil() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profil(),
              ));
        },
        child: buildDrawerListTile(Icons.account_circle, "Profil"));
  }

  GestureDetector buildGestureDetectorBildirimler() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Bildirimler(),
              ));
        },
        child: buildDrawerListTile(Icons.account_circle, "Bildirimler"));
  }

  GestureDetector buildGestureDetectorCikisYap() {
    return GestureDetector(
        onTap: () {
          _auth.signOut();
        },
        child: buildDrawerListTile(Icons.account_circle, "Çıkış Yap"));
  }

  // Drawer içindeki sayfa yönlendirmelerini yapan butonlar
  ListTile buildDrawerListTile(IconData iconData, String baslik) {
    return ListTile(
      leading: Icon(iconData, color: Colors.black),
      title: Text(
        baslik,
        style: ProfilSabitleri.profilAdSoyad,
      ),
    );
  }

  Expanded buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _controller,
        children: [
          enYeniTartismalarSayfasi(),
          enCokYorumAlmisTartismalarSayfasi()
        ],
      ),
    );
  }

  Widget enCokYorumAlmisTartismalarSayfasi() {
    return ListView(
      children: [
        buildSearchBox(),
        buildDivider(context),
        futureBuilderEnFazlaYorumluTartismalar(),
      ],
    );
  }

  Widget enYeniTartismalarSayfasi() {
    return ListView(
      children: [
        buildSearchBox(),
        buildDivider(context),
        futureBuilderButunTartismalar(),
      ],
    );
  }

  FutureBuilder<List<Tartismalar>> futureBuilderEnFazlaYorumluTartismalar() {
    return FutureBuilder<List<Tartismalar>>(
      future: _store.butunEnFazlaYorumAlmisTartismaBasliklariniGetir(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return listViewTartismaGonderileri(snapshot);
        }
      },
    );
  }

  FutureBuilder<List<Tartismalar>> futureBuilderButunTartismalar() {
    return FutureBuilder<List<Tartismalar>>(
      future: _store.butunEnYeniTartismaBasliklariniGetir(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return listViewTartismaGonderileri(snapshot);
        }
      },
    );
  }

  ListView listViewTartismaGonderileri(
      AsyncSnapshot<List<Tartismalar>> snapshot) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Tartisma(tartisma: snapshot.data![index]),
                  ));
            },
            child: Card(
              color: Colors.brown.shade200,
              child: ListTile(
                title: Text(snapshot.data![index].baslik,
                    style: ProfilSabitleri.profilAdSoyad),
                trailing: const Icon(Icons.arrow_forward_ios),
                subtitle: futureBuilderToplamYorumSayisi(snapshot, index),
              ),
            ),
          );
        });
  }

  FutureBuilder<List<DocumentSnapshot>> futureBuilderToplamYorumSayisi(
      AsyncSnapshot<List<Tartismalar>> snapshot, int index) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _store.toplamYorumSayisi(snapshot.data![index].id),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Text("yorum yapılmamış.");
        } else {
          snapshot.data![index].toplamYorumSayisi = snap.data!.length;

          return Text(
            snapshot.data![index].toplamYorumSayisi.toString() + " yorum",
            style: ProfilSabitleri.profilOlusturulanTartismaYorumSayisi,
          );
        }
      },
    );
  }

  Future<void> kullaniciBilgileriniGetir() async {
    DocumentSnapshot snapshot = await _store.kullaniciVarMi(Kullanici.userId);
    Kullanici.olustur(snapshot);
  }

  TabBar buildTabBar() {
    return TabBar(
      indicatorColor: Colors.black,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.black,
      controller: _controller,
      tabs: const [
        Tab(
          icon: Icon(
            Icons.ac_unit,
            color: Colors.blue,
          ),
        ),
        Tab(
            icon: Icon(
          Icons.whatshot,
          color: Colors.red,
        )),
      ],
    );
  }

  Container buildDivider(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.20),
      child: const Divider(
        color: Colors.black,
      ),
    );
  }

  Padding buildSearchBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.go,
        maxLength: 20,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          counter: Offstage(),
          border: InputBorder.none,
          label: Text("Anahtar kelime ile arama yap"),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  IconButton buildIconDirectMessage() {
    return IconButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Mesajlar()));
      },
      icon: const FaIcon(
        FontAwesomeIcons.envelopeOpenText,
        color: Colors.white,
      ),
    );
  }

  IconButton buildIconProfile(GlobalKey<ScaffoldState> key) {
    return IconButton(
      onPressed: () async {
        key.currentState?.openDrawer();
      },
      icon: const FaIcon(
        FontAwesomeIcons.bars,
        size: 25,
        color: Colors.white,
      ),
    );
  }
}
