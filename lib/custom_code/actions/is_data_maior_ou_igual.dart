// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<bool> isDataMaiorOuIgual(String data) async {
  // Captura apenas ano, mês e dia da data atual
  DateTime dataAtual = DateTime.now();
  DateTime dataAtualFormatada =
      DateTime(dataAtual.year, dataAtual.month, dataAtual.day);

  // Converte a string recebida para um objeto DateTime
  DateTime dataParametro = DateTime.parse(data);

  // Verifica se a data atual é maior ou igual à data passada
  if (dataAtualFormatada.isAfter(dataParametro) ||
      dataAtualFormatada.isAtSameMomentAs(dataParametro)) {
    return true;
  } else {
    return false;
  }
}
