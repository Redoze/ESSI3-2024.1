import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gastos_service.dart';

class ListaDeGastosPage extends StatefulWidget {
  @override
  _ListaDeGastosPageState createState() => _ListaDeGastosPageState();
}

class _ListaDeGastosPageState extends State<ListaDeGastosPage> {
  List<Map<String, dynamic>> _gastos = [];
  List<Map<String, dynamic>> _filteredGastos = [];
  String _searchQuery = '';
  String _sortColumn = 'date'; // Padrão de ordenação por data
  bool _isAscending = false;
  String _filterPeriod = 'all'; // Filtros: 'all', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _loadGastos();
  }

  // Carregar gastos do serviço
  void _loadGastos() async {
    final gastos = await GastosService.carregarGastos();
    setState(() {
      _gastos = gastos;
      _filteredGastos = gastos;
    });
  }

  // Ordenar os gastos
  void _sortGastos(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }

      _filteredGastos.sort((a, b) {
        if (_sortColumn == 'value') {
          return _isAscending
              ? a['value'].compareTo(b['value'])
              : b['value'].compareTo(a['value']);
        } else if (_sortColumn == 'category') {
          return _isAscending
              ? a['category'].compareTo(b['category'])
              : b['category'].compareTo(a['category']);
        } else {
          // Ordenação por data (padrão)
          return _isAscending
              ? a['date'].compareTo(b['date'])
              : b['date'].compareTo(a['date']);
        }
      });
    });
  }

  // Filtros por período (mês, ano)
  void _filterByPeriod(String? period) {
    setState(() {
      _filterPeriod = period ?? 'all';

      if (_filterPeriod == 'month') {
        final currentMonth = DateTime.now().month;
        _filteredGastos = _gastos
            .where((gasto) => DateTime.parse(gasto['date']).month == currentMonth)
            .toList();
      } else if (_filterPeriod == 'year') {
        final currentYear = DateTime.now().year;
        _filteredGastos = _gastos
            .where((gasto) => DateTime.parse(gasto['date']).year == currentYear)
            .toList();
      } else {
        _filteredGastos = _gastos;
      }
    });
  }

  // Busca por palavra-chave
  void _searchGastos(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredGastos = _gastos
          .where((gasto) =>
              gasto['description'].toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  // Excluir gasto
  void _deleteGasto(int index) async {
    await GastosService.removerGasto(index);
    _loadGastos();
  }

  // Exibir modal com detalhes do gasto
  void _viewGastoDetails(Map<String, dynamic> gasto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Gasto'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valor: R\$ ${gasto['value']}'),
              Text('Categoria: ${gasto['category']}'),
              Text('Data: ${gasto['date']}'),
              if (gasto['description'] != null && gasto['description'] != '')
                Text('Descrição: ${gasto['description']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Editar gasto
  void _editGasto(int index, Map<String, dynamic> gasto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _valueController = TextEditingController(text: gasto['value'].toString());
        final _categoryController = TextEditingController(text: gasto['category']);
        final _dateController = TextEditingController(text: gasto['date']);
        final _descriptionController = TextEditingController(text: gasto['description'] ?? '');

        return AlertDialog(
          title: Text('Editar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Valor'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Categoria'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Data'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Salvar'),
              onPressed: () async {
                final updatedGasto = {
                  'value': double.tryParse(_valueController.text) ?? 0.0, // Garantindo que seja 0.0
                  'category': _categoryController.text,
                  'date': _dateController.text,
                  'description': _descriptionController.text,
                };

                await GastosService.atualizarGasto(index, updatedGasto);
                Navigator.of(context).pop();
                _loadGastos();
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Exibir resumo de gastos
  double _calculateTotalGastos() {
    return _filteredGastos.fold(0.0, (total, gasto) {
      return total + (gasto['value'] ?? 0.0); // Tratando valor nulo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Gastos'),
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar gastos',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchGastos,
            ),
          ),
          
          // Filtros de período
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _filterPeriod,
              items: [
                DropdownMenuItem(value: 'all', child: Text('Todos os períodos')),
                DropdownMenuItem(value: 'month', child: Text('Este mês')),
                DropdownMenuItem(value: 'year', child: Text('Este ano')),
              ],
              onChanged: _filterByPeriod,
            ),
          ),

          // Cabeçalho da lista
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _sortGastos('category'),
                  child: Text('Categoria'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _sortGastos('value'),
                  child: Text('Valor'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _sortGastos('date'),
                  child: Text('Data'),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text('Ações'),
                ),
              ),
            ],
          ),

          // Lista de gastos
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGastos.length,
              itemBuilder: (context, index) {
                final gasto = _filteredGastos[index];
                return ListTile(
                  title: Text(gasto['category']),
                  subtitle: Text(
                      'R\$ ${gasto['value'].toStringAsFixed(2)} - ${DateFormat.yMd().format(DateTime.parse(gasto['date']))}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editGasto(index, gasto);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteGasto(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _viewGastoDetails(gasto);
                  },
                );
              },
            ),
          ),

          // Exibir resumo de total de gastos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total de gastos: R\$ ${_calculateTotalGastos().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
