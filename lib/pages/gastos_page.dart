import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gastos_service.dart'; // Importa o serviço de gastos

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

  // Função para carregar os gastos usando o GastosService
  void _carregarGastos() async {
    List<Map<String, dynamic>> dados = await GastosService.carregarGastos();
    setState(() {
      gastos = dados;
    });
  }

  // Função para adicionar um gasto
  void _adicionarGasto() async {
    if (_formKey.currentState!.validate()) {
      final novoGasto = {
        'value': double.parse(_valorController.text),  // Padronizado como 'value'
        'description': _descricaoController.text,
        'category': _categoriaSelecionada ?? 'Outros',
        'date': _dataSelecionada.toIso8601String(),
      };

      await GastosService.adicionarGasto(novoGasto);

      _carregarGastos(); // Recarrega a lista de gastos
      _limparCampos(); // Limpa os campos após adicionar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gasto adicionado com sucesso!')),
      );
    }
  }

  // Função para limpar os campos após adicionar
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

  // Formulário de adicionar gastos
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _adicionarGasto,
            child: Text('Adicionar Gasto'),
          ),
        ],
      ),
    );
  }

  // Lista de gastos
  Widget _buildListaGastos() {
    if (gastos.isEmpty) {
      return Center(
        child: Text('Nenhum gasto cadastrado.'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: gastos.length,
        itemBuilder: (context, index) {
          final gasto = gastos[index];
          return ListTile(
            title: Text(gasto['category']),
            subtitle: Text(
                'Valor: R\$ ${gasto['value'].toStringAsFixed(2)} - Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(gasto['date']))}'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildForm(),
              SizedBox(height: 16),
              Divider(),
              Text('Lista de Gastos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildListaGastos(),
            ],
          ),
        ),
      ),
    );
  }
}