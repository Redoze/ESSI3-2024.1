import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para converter os dados para JSON

class RendimentoPage extends StatefulWidget {
  @override
  _RendimentoPageState createState() => _RendimentoPageState();
}

class _RendimentoPageState extends State<RendimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _novaFonteController = TextEditingController();

  List<Map<String, dynamic>> rendimentos = [];

  @override
  void initState() {
    super.initState();
    _carregarRendimentos(); // Carregar os rendimentos quando a tela for aberta
  }

  // Método para carregar rendimentos salvos
  Future<void> _carregarRendimentos() async {
    final prefs = await SharedPreferences.getInstance();
    String? rendimentosString = prefs.getString('rendimentos');

    if (rendimentosString != null) {
      setState(() {
        rendimentos = List<Map<String, dynamic>>.from(json.decode(rendimentosString));
      });
    }
  }

  // Método para salvar rendimentos
  Future<void> _salvarRendimentos() async {
    final prefs = await SharedPreferences.getInstance();
    String rendimentosString = json.encode(rendimentos);
    await prefs.setString('rendimentos', rendimentosString);
  }

  // Método para adicionar ou editar um rendimento
  void _adicionarOuEditarRendimento() {
    if (_formKey.currentState!.validate()) {
      String fonte = _novaFonteController.text;
      double valor = double.parse(_valorController.text);

      setState(() {
        // Adicionar o rendimento à lista
        rendimentos.add({'fonte': fonte, 'valor': valor});
      });

      _salvarRendimentos(); // Salvar rendimentos sempre que houver alteração

      _valorController.clear();
      _novaFonteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rendimento adicionado!')),
      );
    }
  }

  // Método para remover um rendimento
  void _removerRendimento(int index) {
    setState(() {
      rendimentos.removeAt(index);
    });
    _salvarRendimentos(); // Salvar os rendimentos atualizados
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rendimento removido!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Rendimentos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            // fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true, // Centraliza o título na AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _novaFonteController,
                    decoration: InputDecoration(
                      labelText: 'Fonte de Rendimento',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a fonte do rendimento';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o valor do rendimento';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Insira um valor válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _adicionarOuEditarRendimento,
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Lista de rendimentos
            Expanded(
              child: rendimentos.isEmpty
                  ? Center(
                      child: Text('Nenhum rendimento adicionado.'),
                    )
                  : ListView.builder(
                      itemCount: rendimentos.length,
                      itemBuilder: (context, index) {
                        final rendimento = rendimentos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(rendimento['fonte']),
                            subtitle: Text('Valor: R\$ ${rendimento['valor'].toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removerRendimento(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
