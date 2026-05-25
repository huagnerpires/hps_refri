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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> removerPatrimoniosDuplicados() async {
  try {
    final firestore = FirebaseFirestore.instance;

    print('🔍 Buscando documentos na coleção EQUIPAMENTOS_EMPRESA...');

    final querySnapshot =
        await firestore.collection('EQUIPAMENTOS_EMPRESA').get();

    print('📊 Total de documentos encontrados: ${querySnapshot.docs.length}');

    // Mapa para controlar patrimônios já encontrados
    final Map<String, String> patrimonioPrimeiroDoc = {};
    int totalApagados = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final patrimonio = data['PATRIMONIO'];

      print('📄 Documento ID: ${doc.id}');
      print('  PATRIMONIO: $patrimonio');

      if (patrimonio == null || patrimonio.toString().trim().isEmpty) {
        print('  ⚠️ Patrimônio vazio ou null, ignorando...');
        continue;
      }

      final patrimonioKey = patrimonio.toString().trim();

      // Se já existe, apaga
      if (patrimonioPrimeiroDoc.containsKey(patrimonioKey)) {
        print(
            '  ❌ PATRIMONIO DUPLICADO encontrado! Apagando documento ${doc.id}');
        await firestore.collection('EQUIPAMENTOS_EMPRESA').doc(doc.id).delete();
        totalApagados++;
      } else {
        // Primeiro registro desse patrimônio
        patrimonioPrimeiroDoc[patrimonioKey] = doc.id;
        print('  ✅ Primeiro registro desse patrimônio, mantendo.');
      }
    }

    print('🗑️ TOTAL DE DOCUMENTOS APAGADOS: $totalApagados');
    return totalApagados;
  } catch (e) {
    print('❌ ERRO ao remover patrimônios duplicados: $e');
    print('Stack trace: ${StackTrace.current}');
    return 0;
  }
}
