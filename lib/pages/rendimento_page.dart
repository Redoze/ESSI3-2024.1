import 'package:flutter/material.dart';

class RendimentoPage extends StatefulWidget {
  @override
  _RendimentoPageState createState() => _RendimentoPageState();
}

class _RendimentoPageState extends State<RendimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _novaFonteController = TextEditingController();
  String? fonteSelecionada;
  Map<String, dynamic>? rendimentoEditando;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      rendimentoEditando = args;
      fonteSelecionada = args['fonte'];
      _novaFonteController.text = args['fonte'];
      _valorController.text = args['valor'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rendimentoEditando == null ? 'Cadastro de Rendimento' : 'Editar Rendimento'),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          String fonte = _novaFonteController.text;
                          double valor = double.parse(_valorController.text);

                          if (rendimentoEditando != null) {
                            // Editar rendimento existente
                            rendimentoEditando!['fonte'] = fonte;
                            rendimentoEditando!['valor'] = valor;
                          } else {
                            // Adicionar novo rendimento
                            rendimentoEditando = {'fonte': fonte, 'valor': valor};
                          }
                        });

                        _valorController.clear();
                        _novaFonteController.clear();
                        fonteSelecionada = null;

                        Navigator.pop(context, [rendimentoEditando]);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(rendimentoEditando == null ? 'Rendimento cadastrado!' : 'Rendimento atualizado!')),
                        );
                      }
                    },
                    child: Text(rendimentoEditando == null ? 'Salvar' : 'Atualizar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
