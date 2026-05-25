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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> updateOrDeleteChatCollection(String emailArgument) async {
  try {
    final collection = FirebaseFirestore.instance.collection('chat');

    // 1. Apagar documentos onde adm = false e email_cliente = emailArgument
    final deleteUpdateQuerySnapshot = await collection
        .where('adm', isEqualTo: false)
        .where('email_cliente', isEqualTo: emailArgument)
        .get();

    for (final doc in deleteUpdateQuerySnapshot.docs) {
      await doc.reference.delete(); // Remove o documento
    }

    // 2. Apagar documentos onde adm = true e email_cliente = emailArgument
    final deleteQuerySnapshot = await collection
        .where('adm', isEqualTo: true)
        .where('email_cliente', isEqualTo: emailArgument)
        .get();

    for (final doc in deleteQuerySnapshot.docs) {
      await doc.reference.delete(); // Remove o documento
    }

    return true; // Sucesso
  } catch (e) {
    print('Erro ao excluir documentos: $e');
    return false; // Falha
  }
}
