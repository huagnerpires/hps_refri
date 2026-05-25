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

Future<void> tudomaiusculoexcetoemail() async {
  try {
    final firestore = FirebaseFirestore.instance;

    print('🔄 Iniciando atualização em massa...');
    print('📁 Coleção: EQUIPAMENTOS_EMPRESA');

    final querySnapshot =
        await firestore.collection('EQUIPAMENTOS_EMPRESA').get();

    print('📊 Total de documentos encontrados: ${querySnapshot.docs.length}');

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final Map<String, dynamic> dadosAtualizados = {};

      data.forEach((key, value) {
        // NÃO altera EMAIL
        if (key.toUpperCase() == 'EMAIL') {
          dadosAtualizados[key] = value;
        }
        // STRING → MAIÚSCULO
        else if (value is String) {
          dadosAtualizados[key] = value.toUpperCase();
        }
        // LISTA
        else if (value is List) {
          dadosAtualizados[key] = value.map((item) {
            if (item is String) {
              return item.toUpperCase();
            }
            return item;
          }).toList();
        }
        // MAP
        else if (value is Map) {
          final Map<String, dynamic> mapInterno = {};
          value.forEach((k, v) {
            if (v is String) {
              mapInterno[k] = v.toUpperCase();
            } else {
              mapInterno[k] = v;
            }
          });
          dadosAtualizados[key] = mapInterno;
        }
        // OUTROS TIPOS
        else {
          dadosAtualizados[key] = value;
        }
      });

      await doc.reference.update(dadosAtualizados);

      print('✅ Documento atualizado: ${doc.id}');
    }

    print('🎉 ATUALIZAÇÃO EM MASSA FINALIZADA COM SUCESSO');
  } catch (e) {
    print('❌ ERRO NA ATUALIZAÇÃO EM MASSA: $e');
    print('STACK TRACE: ${StackTrace.current}');
  }
}
