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

Future<int> calcularDias(String dataAleatoria) async {
  // Data atual como data fixa
  final DateTime dataAtual = DateTime.now();

  // Converta a string dataAleatoria para DateTime
  final DateTime dataAleatoriaConvertida = DateTime.parse(dataAleatoria);

  // Calcule a diferença entre as datas
  final Duration diferenca = dataAtual.difference(dataAleatoriaConvertida);

  // Retorne o número de dias de diferença
  return diferenca.inDays;
}
