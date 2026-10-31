import 'package:flutter/material.dart';

class GiaiDieuApp extends StatelessWidget {
  const GiaiDieuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Giai Điệu',
      home: Scaffold(body: Center(child: Text('Giai Điệu'))),
    );
  }
}
