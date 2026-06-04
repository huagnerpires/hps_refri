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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> deleteHistoryByEmail(String emailArgument) async {
  try {
    final collection = FirebaseFirestore.instance.collection('historico');

    // Buscar documentos onde o campo 'email' é igual ao emailArgument
    final querySnapshot =
        await collection.where('email', isEqualTo: emailArgument).get();

    // Apagar cada documento encontrado
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete(); // Remove o documento
    }

    return true; // Sucesso
  } catch (e) {
    print('Erro ao excluir documentos da coleção historico: $e');
    return false; // Falha
  }
}
