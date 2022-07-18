import 'package:flutter/material.dart';

class Sihirbaz extends StatefulWidget {
  const Sihirbaz({Key? key}) : super(key: key);

  @override
  State<Sihirbaz> createState() => _SihirbazState();
}

class _SihirbazState extends State<Sihirbaz> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Tercih Sihirbazı"),
      ),
    );
  }
}
