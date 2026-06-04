// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

double calcularPorcentagem(String valorString) {
  // Converte a string em double
  double valor = double.tryParse(valorString) ??
      0.0; // Converte ou usa 0.0 se a conversão falhar

  // Calcula 30% do valor
  double percentual = 0.30; // 30%
  return valor * percentual;
}

void main() {
  // Exemplo de uso
  String valorReais = "100.0"; // Altere este valor conforme necessário
  double resultado = calcularPorcentagem(valorReais);

  print('30% de R\$ $valorReais é R\$ $resultado');
}
