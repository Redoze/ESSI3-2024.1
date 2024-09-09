import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/rendimento_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Rendimento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Página inicial
      routes: {
        '/rendimento': (context) => RendimentoPage(), // Rota para a página de rendimento
      },
    );
  }
}
