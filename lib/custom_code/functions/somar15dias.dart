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
