import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/auth/firebase_auth/auth_util.dart';

double? somar(List<double>? valores) {
  // SOMAR VALORES VINDO DE UMA ARRAY DO FIREBASE E DAR O RESULTADO DOS VALORES
  if (valores == null || valores.isEmpty)
    return null; // Verifica se a lista é nula ou vazia
  return valores.reduce((a, b) => a + b); // Soma todos os valores da lista
}
