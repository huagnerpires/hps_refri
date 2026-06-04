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

void main() {
  // Chama a função para calcular a nova data
  DateTime novaData = calcularNovaData(3);

  // Exibe o resultado formatado
  print('Nova data: $novaData');
}

// Função que calcula a nova data adicionando meses
DateTime calcularNovaData(int meses) {
  // Obtém a data atual
  DateTime now = DateTime.now();

  // Adiciona os meses e retorna a nova data como DateTime
  return DateTime(now.year, now.month + meses, now.day);
}
