import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Главное")),
      body: Center(child: Text("Здесь будут новости или избранные каналы")),
    );
  }
}