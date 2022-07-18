import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:social_media/models/universite.dart';
import 'package:social_media/sabitler/universiteSabitleri.dart';
import 'package:social_media/servisler/FireStore.dart';

class UniversiteDetay extends StatefulWidget {
  Universite universite;

  UniversiteDetay(this.universite, {Key? key}) : super(key: key);

  @override
  State<UniversiteDetay> createState() => _UniversiteDetayState();
}

class _UniversiteDetayState extends State<UniversiteDetay> {
  final _store = FireStore();
  @override
  void initState() {
    universiteDetaylariniGetir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      body: SafeArea(
        child: ListView(
          children: [
            universiteFotografVeText(context, widget.universite.universiteAdi,
                widget.universite.fotoUrl),
            buildBasliklarText("Hakkında"),
            buildHakkindaIcerikText(widget.universite.hakkinda),
            buildBasliklarText("Galeri"),
            galeriIcerik(widget.universite.fotografGalerisi),
            buildBasliklarText("Özellikler"),
            buildOzelliklerIcerik(context, widget.universite.tumOzellikler),
          ],
        ),
      ),
    );
  }

  Future bottomSheettumOzellikler(List tumOzellikler) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        builder: (BuildContext context, ScrollController scrollController) {
          return ListView.builder(
            controller: scrollController,
            itemCount: tumOzellikler.length,
            itemBuilder: (context, index) {
              return buildOzellikKarti(index, tumOzellikler);
            },
          );
        },
      ),
    );
  }

  Future<void> universiteDetaylariniGetir() async {
    DocumentSnapshot snapshot =
        await _store.universiteDetayliBilgileriniGetir(widget.universite.id);
    widget.universite.setUniversiteDetaylari(snapshot);
    setState(() {});
  }

  Column buildOzelliklerIcerik(BuildContext context, List tumOzellikler) {
    return Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: (tumOzellikler.length + 4) - tumOzellikler.length,
          itemBuilder: (context, index) {
            return buildOzellikKarti(index, tumOzellikler);
          },
        ),
        buttonTumOzellikler(context),
      ],
    );
  }

  Padding buildOzellikKarti(int index, List ozellikListesi) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        color: Colors.brown.shade200,
        child: ListTile(
          title: Text(
            ozellikListesi[index].toString(),
            style: UniversiteSabitleri.universiteSehirAdi,
          ),
          trailing: ozelligeGoreIconDondur(ozellikListesi[index].toString()),
        ),
      ),
    );
  }

  Container galeriIcerik(List galeriListesi) {
    return Container(
      height: 175,
      child: CarouselSlider.builder(
        itemCount: galeriListesi.length,
        itemBuilder: (context, index, realindex) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    galeriListesi[index],
                  ),
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 400,
          autoPlay: true,
        ),
      ),
    );
  }

  Padding buildHakkindaIcerikText(String hakkinda) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ReadMoreText(
        hakkinda,
        trimLines: 3,
        colorClickableText: Colors.pink,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'daha fazla',
        trimExpandedText: 'daha az',
        moreStyle: const TextStyle(
          color: Colors.brown,
          fontSize: 13,
        ),
        lessStyle: const TextStyle(color: Colors.brown, fontSize: 13),
      ),
    );
  }

  Padding buildBasliklarText(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: UniversiteSabitleri.universiteAdiTextStyle,
      ),
    );
  }

  Stack universiteFotografVeText(
      BuildContext context, String universiteAdi, String fotoUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        universiteFotografi(fotoUrl),
        universiteAdiText(universiteAdi),
        geriDonButonu(context),
      ],
    );
  }

  Positioned universiteAdiText(String universiteAdi) {
    return Positioned(
      child: Center(
        child: Text(
          universiteAdi,
          style: UniversiteSabitleri.universiteAdiTextStyle,
        ),
      ),
    );
  }

  Container universiteFotografi(String fotograf) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.45), BlendMode.darken),
          fit: BoxFit.cover,
          image: NetworkImage(fotograf),
        ),
      ),
      height: 200,
    );
  }

  Positioned geriDonButonu(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
    );
  }

  SizedBox buttonTumOzellikler(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(
              width: 2, color: Colors.white, style: BorderStyle.solid),
          primary: Colors.grey,
        ),
        onPressed: () {
          bottomSheettumOzellikler(widget.universite.tumOzellikler);
        },
        child: const Text(
          "Tüm Özellikler",
        ),
      ),
    );
  }

  FaIcon ozelligeGoreIconDondur(String ozellik) {
    FaIcon icon = const FaIcon(FontAwesomeIcons.faceFrown);
    switch (ozellik) {
      case "Banka":
        icon = const FaIcon(
          FontAwesomeIcons.buildingColumns,
          color: Colors.white,
        );
        break;
      case "Havuz":
        icon =
            const FaIcon(FontAwesomeIcons.personSwimming, color: Colors.white);
        break;
      case "Amfi Tiyatro":
        icon = const FaIcon(FontAwesomeIcons.masksTheater, color: Colors.white);
        break;
      case "Yürüyüş Parkı":
        icon =
            const FaIcon(FontAwesomeIcons.personWalking, color: Colors.white);
        break;
      case "Kargo":
        icon = const FaIcon(FontAwesomeIcons.truck, color: Colors.white);
        break;
      case "Otopark":
        icon =
            const FaIcon(FontAwesomeIcons.squareParking, color: Colors.white);
        break;
      case "Ulaşım":
        icon = const FaIcon(FontAwesomeIcons.bus, color: Colors.white);
        break;
      case "Sinema Salonu":
        icon = const FaIcon(FontAwesomeIcons.film, color: Colors.white);
        break;
      case "Starbucks":
        icon = const FaIcon(FontAwesomeIcons.mugSaucer, color: Colors.white);
        break;
      case "Kulüp ve Topluluklar":
        icon = const FaIcon(FontAwesomeIcons.ccDinersClub, color: Colors.white);
        break;
      case "Güvenlik":
        icon = const FaIcon(FontAwesomeIcons.shield, color: Colors.white);
        break;
      case "Engelsiz Kampüs":
        icon = const FaIcon(FontAwesomeIcons.userCheck, color: Colors.white);
        break;
      case "Sağlık Merkezi":
        icon = const FaIcon(FontAwesomeIcons.hospital, color: Colors.white);
        break;
      case "Yemekhane":
        icon = const FaIcon(FontAwesomeIcons.bowlFood, color: Colors.white);
        break;
      case "Öğrenci Yurdu":
        icon = const FaIcon(FontAwesomeIcons.house, color: Colors.white);
        break;
      case "Spor Salonu":
        icon = const FaIcon(FontAwesomeIcons.dumbbell, color: Colors.white);
        break;
      case "Tenis Kortu":
        icon = const FaIcon(FontAwesomeIcons.tableTennisPaddleBall,
            color: Colors.white);
        break;
      case "Müze":
        icon =
            const FaIcon(FontAwesomeIcons.buildingColumns, color: Colors.white);
        break;
      case "Dans Salonu":
        icon =
            const FaIcon(FontAwesomeIcons.peoplePulling, color: Colors.white);
        break;
      case "Kafeterya":
        icon = const FaIcon(FontAwesomeIcons.store, color: Colors.white);
        break;
      case "Konuk Evi":
        icon =
            const FaIcon(FontAwesomeIcons.buildingColumns, color: Colors.white);
        break;
      case "Stadyum":
        icon = const FaIcon(FontAwesomeIcons.futbol, color: Colors.white);
        break;
      case "Kütüphane":
        icon =
            const FaIcon(FontAwesomeIcons.buildingColumns, color: Colors.white);
        break;
      case "Radyo Stüdyosu":
        icon = const FaIcon(FontAwesomeIcons.radio, color: Colors.white);
        break;
      case "Buz Pisti":
        icon =
            const FaIcon(FontAwesomeIcons.personSkating, color: Colors.white);
        break;
      case "Konferans Salonu":
        icon = const FaIcon(FontAwesomeIcons.peopleRoof, color: Colors.white);
        break;

      default:
        const FaIcon(FontAwesomeIcons.faceFrown);
        break;
    }
    return icon;
  }
}
