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

Future<int> paranumero(String? patrimonio) async {
  if (patrimonio == null || patrimonio.isEmpty) {
    return 0;
  }

  // Extract numeric characters from the patrimonio string
  String numericString = patrimonio.replaceAll(RegExp(r'[^0-9]'), '');

  if (numericString.isEmpty) {
    return 0;
  }

  try {
    return int.parse(numericString);
  } catch (e) {
    return 0;
  }
}
