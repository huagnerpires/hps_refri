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

Future<String> pontucaoprotugues(String? twxtr) async {
  if (twxtr == null || twxtr.isEmpty) {
    return '';
  }

  String texto = twxtr.trim();

  // Remove espaços extras
  texto = texto.replaceAll(RegExp(r'\s+'), ' ');

  // Capitalizar primeira letra
  if (texto.isNotEmpty) {
    texto = texto[0].toUpperCase() + texto.substring(1);
  }

  // Corrigir espaços antes de pontuação
  texto = texto.replaceAll(RegExp(r'\s+([,.!?;:])'), r'$1');

  // Adicionar espaço após pontuação (exceto no final)
  texto = texto.replaceAll(RegExp(r'([,.!?;:])(?=[^\s])'), r'$1 ');

  // Corrigir múltiplas pontuações
  texto = texto.replaceAll(RegExp(r'\.{2,}'), '...');
  texto = texto.replaceAll(RegExp(r'!{2,}'), '!');
  texto = texto.replaceAll(RegExp(r'\?{2,}'), '?');

  // Capitalizar após ponto final, exclamação e interrogação
  texto = texto.replaceAllMapped(RegExp(r'([.!?])\s+([a-zà-ÿ])'), (match) {
    return '${match.group(1)} ${match.group(2)!.toUpperCase()}';
  });

  // Remover espaços antes do final da string
  texto = texto.trimRight();

  // Garantir que termine com pontuação apropriada
  if (texto.isNotEmpty && !RegExp(r'[.!?]$').hasMatch(texto)) {
    texto += '.';
  }

  return texto;
}
