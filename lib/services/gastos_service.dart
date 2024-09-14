import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GastosService {
  static const String _gastosKey = 'gastos';

  // Carregar todos os gastos
  static Future<List<Map<String, dynamic>>> carregarGastos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gastosString = prefs.getString(_gastosKey);
    if (gastosString != null) {
      return List<Map<String, dynamic>>.from(json.decode(gastosString));
    }
    return [];
  }

  // Salvar lista de gastos
  static Future<void> salvarGastos(List<Map<String, dynamic>> gastos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_gastosKey, json.encode(gastos));
  }

  // Adicionar novo gasto
  static Future<void> adicionarGasto(Map<String, dynamic> novoGasto) async {
    List<Map<String, dynamic>> gastos = await carregarGastos();
    gastos.add(novoGasto);
    await salvarGastos(gastos);
  }

  // Atualizar gasto
  static Future<void> atualizarGasto(int index, Map<String, dynamic> gastoEditado) async {
    List<Map<String, dynamic>> gastos = await carregarGastos();
    gastos[index] = gastoEditado;
    await salvarGastos(gastos);
  }

  // Excluir gasto
  static Future<void> removerGasto(int index) async {
    List<Map<String, dynamic>> gastos = await carregarGastos();
    gastos.removeAt(index);
    await salvarGastos(gastos);
  }
}
