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

import 'package:uuid/uuid.dart';

String generateUniqueIdempotencyKey() {
  var uuid = Uuid();

  // Gera um UUID
  String uniqueId = uuid.v4();

  // Obtém o timestamp atual em milissegundos
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  // Combina o UUID com o timestamp para garantir unicidade
  return '$timestamp-$uniqueId';
}

void main() {
  // Gera um identificador único
  String idempotencyKey = generateUniqueIdempotencyKey();

  // Exibe o identificador único
  print('X-Idempotency-Key: $idempotencyKey');
}
