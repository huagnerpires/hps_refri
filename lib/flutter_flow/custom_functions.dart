import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/auth/firebase_auth/auth_util.dart';

int? anoatual() {
// PRECISO DE UMA FUNÇÃO DO ANO ATUAL FORMATADO DE ACORDO O ANO ATUAL
  return DateTime.now().year; // Retorna o ano atual
}

String? somar15dias(
  String? datatermino,
  String? dias,
) {
  // preciso que pegue os dois primeiros numeros da datatermino e some mais 15 dias ex 09/11/2025 somando 15 dias o resultado sera 24/11/2025
  if (datatermino == null || dias == null) return null;

  // Parse the input date
  DateTime date = DateFormat('dd/MM/yyyy').parse(datatermino);

  // Add 15 days to the date
  DateTime newDate = date.add(Duration(days: int.parse(dias)));

  // Format the new date back to the desired string format
  return DateFormat('dd/MM/yyyy').format(newDate);
}

String? getMesMaiuscula(String? maiusculo) {
  // CONVERTER TEXTO MINUSCULO PARA MAIUSCULO
  if (maiusculo == null) return null;
  return maiusculo.toUpperCase();
}

int? doubleinteger(double? quantidadedeos) {
  // fazer double formatar para integer
  if (quantidadedeos == null) return null;
  return quantidadedeos.toInt(); // Converte double para int
}

String? getMesMaiusculaA(String? maiusculo) {
  // CONVERTER TEXTO MINUSCULO PARA MAIUSCULO
  if (maiusculo == null) return null;
  return maiusculo.toUpperCase();
}

double? somar(List<double>? valores) {
  // SOMAR VALORES VINDO DE UMA ARRAY DO FIREBASE E DAR O RESULTADO DOS VALORES
  if (valores == null || valores.isEmpty)
    return null; // Verifica se a lista é nula ou vazia
  return valores.reduce((a, b) => a + b); // Soma todos os valores da lista
}

int? geraros() {
  //  gerar numero aleatorio de o.s sempre com 6 digitos
  return 100000 +
      math.Random().nextInt(900000); // Gera um número aleatório de 6 dígitos
}
