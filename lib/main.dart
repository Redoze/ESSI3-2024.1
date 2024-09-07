import 'package:flutter/material.dart';

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
      home: CadastroRendimento(),
    );
  }
}

class CadastroRendimento extends StatefulWidget {
  @override
  _CadastroRendimentoState createState() => _CadastroRendimentoState();
}

class _CadastroRendimentoState extends State<CadastroRendimento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();

  // Lista para armazenar os rendimentos cadastrados
  List<Map<String, dynamic>> rendimentos = [];
  String? fonteSelecionada;
  String? fonteNova;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Rendimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  rendimentos.isEmpty
                      ? TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Fonte de Rendimento',
                          ),
                          onChanged: (value) {
                            fonteNova = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a fonte do rendimento';
                            }
                            return null;
                          },
                        )
                      : Column(
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Selecione ou insira a Fonte de Rendimento',
                              ),
                              value: fonteSelecionada,
                              items: rendimentos.map((rendimento) {
                                return DropdownMenuItem<String>(
                                  value: rendimento['fonte'],
                                  child: Text(rendimento['fonte']),
                                );
                              }).toList()
                                ..add(DropdownMenuItem<String>(
                                  value: 'novo',
                                  child: Text('Adicionar nova fonte'),
                                )),
                              onChanged: (value) {
                                setState(() {
                                  fonteSelecionada = value;
                                });
                              },
                            ),
                            if (fonteSelecionada == 'novo')
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Nova Fonte de Rendimento',
                                ),
                                onChanged: (value) {
                                  fonteNova = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira a nova fonte do rendimento';
                                  }
                                  return null;
                                },
                              ),
                          ],
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          // Se for uma nova fonte
                          if (fonteSelecionada == 'novo' || rendimentos.isEmpty) {
                            rendimentos.add({
                              'fonte': fonteNova!,
                              'valor': double.parse(_valorController.text),
                            });
                          } else {
                            // Verificar se a fonte selecionada já existe e somar o valor
                            for (var rendimento in rendimentos) {
                              if (rendimento['fonte'] == fonteSelecionada) {
                                rendimento['valor'] += double.parse(_valorController.text);
                              }
                            }
                          }
                        });

                        // Limpar os campos após o cadastro
                        _valorController.clear();
                        fonteSelecionada = null;
                        fonteNova = null;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Rendimento cadastrado!')),
                        );
                      }
                    },
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Listagem dos rendimentos cadastrados
            Expanded(
              child: ListView.builder(
                itemCount: rendimentos.length,
                itemBuilder: (context, index) {
                  final rendimento = rendimentos[index];
                  return ListTile(
                    title: Text(rendimento['fonte']),
                    subtitle: Text('Valor: R\$ ${rendimento['valor'].toStringAsFixed(2)}'),
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
