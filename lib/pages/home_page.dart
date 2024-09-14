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
        title: Text('Aplicativo de Finanças'),
      ),
      drawer: Drawer( // Adicionando o Drawer para navegação
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu de Navegação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Adicionar Gastos'),
              onTap: () {
                Navigator.pushNamed(context, '/gastos');
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Lista de Gastos'),
              onTap: () {
                Navigator.pushNamed(context, '/listagastos');
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Adicionar Rendimentos'),
              onTap: () {
                Navigator.pushNamed(context, '/rendimento');
              },
            ),
          ],
        ),
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
