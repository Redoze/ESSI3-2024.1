import 'package:flutter/material.dart';
import './rendimento_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> rendimentos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Rendimentos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/rendimento').then((value) {
                // Atualiza a lista de rendimentos quando retornar da página de rendimento
                if (value != null) {
                  setState(() {
                    rendimentos = List<Map<String, dynamic>>.from(value as List);
                  });
                }
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: rendimentos.isEmpty
            ? Center(child: Text('Nenhum rendimento cadastrado'))
            : ListView.builder(
                itemCount: rendimentos.length,
                itemBuilder: (context, index) {
                  final rendimento = rendimentos[index];
                  return ListTile(
                    title: Text(rendimento['fonte']),
                    subtitle: Text('Valor: R\$ ${rendimento['valor'].toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/rendimento',
                          arguments: rendimento,
                        ).then((value) {
                          // Atualiza a lista de rendimentos quando retornar da página de rendimento
                          if (value != null) {
                            setState(() {
                              rendimentos = List<Map<String, dynamic>>.from(value as List);
                            });
                          }
                        });
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
