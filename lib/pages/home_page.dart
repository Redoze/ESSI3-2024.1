import 'package:flutter/material.dart';

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
        title: Text(
          'Finanças',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true, // Centraliza o título na AppBar
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bem-vindo, Usuário!',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
            ? Center(
                child: Text(
                  'Seja bem-vindo ao aplicativo de Finanças!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: rendimentos.length,
                itemBuilder: (context, index) {
                  final rendimento = rendimentos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        rendimento['fonte'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Valor: R\$ ${rendimento['valor'].toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
