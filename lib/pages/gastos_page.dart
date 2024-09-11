import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para persistência local (opcional)
import 'dart:convert'; // Para converter a lista em JSON

class GastosPage extends StatefulWidget {
  @override
  _GastosPageState createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String? _categoriaSelecionada;
  DateTime _dataSelecionada = DateTime.now();

  List<Map<String, dynamic>> gastos = [];

  List<String> categorias = ['Alimentação', 'Transporte', 'Lazer', 'Outros'];

  @override
  void initState() {
    super.initState();
    _carregarGastos(); // Carrega os gastos ao iniciar a página
  }

  // Função para carregar os gastos do SharedPreferences
  void _carregarGastos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gastosString = prefs.getString('gastos');
    if (gastosString != null) {
      setState(() {
        gastos = List<Map<String, dynamic>>.from(json.decode(gastosString));
      });
    }
  }

  // Função para salvar os gastos no SharedPreferences
  void _salvarGastos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('gastos', json.encode(gastos));
  }

  // Função para adicionar um gasto
  void _adicionarGasto() {
    if (_formKey.currentState!.validate()) {
      final novoGasto = {
        'valor': double.parse(_valorController.text),
        'descricao': _descricaoController.text,
        'categoria': _categoriaSelecionada ?? 'Outros',
        'data': _dataSelecionada,
      };

      setState(() {
        gastos.add(novoGasto);
        _salvarGastos(); // Salva a lista atualizada
      });

      _limparCampos(); // Limpa o formulário após adicionar o gasto
    }
  }

  // Função para editar um gasto
  void _editarGasto(int index) {
    final gasto = gastos[index];
    _valorController.text = gasto['valor'].toString();
    _descricaoController.text = gasto['descricao'];
    _categoriaSelecionada = gasto['categoria'];
    _dataSelecionada = gasto['data'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Gasto'),
          content: _buildForm(),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    gastos[index] = {
                      'valor': double.parse(_valorController.text),
                      'descricao': _descricaoController.text,
                      'categoria': _categoriaSelecionada ?? 'Outros',
                      'data': _dataSelecionada,
                    };
                    _salvarGastos(); // Salva a lista atualizada
                  });
                  Navigator.pop(context);
                  _limparCampos();
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Função para excluir um gasto
  void _excluirGasto(int index) {
    setState(() {
      gastos.removeAt(index);
      _salvarGastos(); // Salva a lista atualizada
    });
  }

  // Função para limpar os campos após adicionar/editar
  void _limparCampos() {
    _valorController.clear();
    _descricaoController.clear();
    _categoriaSelecionada = null;
    _dataSelecionada = DateTime.now();
  }

  // Função para selecionar uma data
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  // Formulário para adicionar ou editar gastos
  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextFormField(
          controller: _valorController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Valor do Gasto'),
          validator: (value) {
            if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
              return 'Insira um valor válido';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _descricaoController,
          decoration: InputDecoration(labelText: 'Descrição (opcional)'),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Categoria'),
          value: _categoriaSelecionada,
          items: categorias.map((String categoria) {
            return DropdownMenuItem<String>(
              value: categoria,
              child: Text(categoria),
            );
          }).toList(),
          onChanged: (String? novaCategoria) {
            setState(() {
              _categoriaSelecionada = novaCategoria;
            });
          },
        ),
        SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}'),
            ),
            TextButton(
              onPressed: () => _selecionarData(context),
              child: Text('Selecionar Data'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Gastos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: _buildForm(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _adicionarGasto,
              child: Text('Adicionar Gasto'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: gastos.isEmpty
                  ? Center(child: Text('Nenhum gasto cadastrado'))
                  : ListView.builder(
                      itemCount: gastos.length,
                      itemBuilder: (context, index) {
                        final gasto = gastos[index];
                        return ListTile(
                          title: Text(gasto['categoria']),
                          subtitle: Text(
                              'Valor: R\$ ${gasto['valor'].toStringAsFixed(2)} - Data: ${DateFormat('dd/MM/yyyy').format(gasto['data'])}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editarGasto(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _excluirGasto(index),
                              ),
                            ],
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
