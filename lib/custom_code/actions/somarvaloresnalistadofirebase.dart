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

Future<double> somarvaloresnalistadofirebase(String setor) async {
  try {
    final firestore = FirebaseFirestore.instance;

    print('🔍 Buscando documentos na coleção CORRETIVAS...');
    print('🎯 Filtrando pelo SETOR: $setor');

    // Query com filtro pelo SETOR
    final querySnapshot = await firestore
        .collection('CORRETIVAS')
        .where('SETOR', isEqualTo: setor)
        .get();

    print('📊 Total de documentos encontrados: ${querySnapshot.docs.length}');

    double somaTotal = 0.0;
    int totalItens = 0;

    // Percorre todos os documentos da coleção
    for (var doc in querySnapshot.docs) {
      print('📄 Documento ID: ${doc.id}');
      print('  SETOR: ${doc.data()['SETOR']}');

      // Pega o campo VALOR de cada documento
      var valor = doc.data()['VALOR'];

      print('  Campo VALOR: $valor');

      // Verifica se o campo VALOR existe
      if (valor != null) {
        // Se for um Map (objeto com chaves 0, 1, 2, etc)
        if (valor is Map) {
          print('  ✅ É um Map com ${valor.length} itens');

          // Percorre cada valor do Map
          valor.forEach((key, item) {
            if (item is num) {
              somaTotal += item.toDouble();
              totalItens++;
              print(
                  '    ➕ Chave: $key | Valor: $item | Total parcial: $somaTotal');
            }
          });
        }
        // Se for uma lista
        else if (valor is List) {
          print('  ✅ É uma lista com ${valor.length} itens');

          for (var item in valor) {
            if (item is num) {
              somaTotal += item.toDouble();
              totalItens++;
              print('    ➕ Somando: $item | Total parcial: $somaTotal');
            }
          }
        }
      } else {
        print('  ❌ VALOR está vazio ou null');
      }
    }

    print(
        '✅ SOMA FINAL para o setor "$setor": $somaTotal (de $totalItens valores)');
    return somaTotal;
  } catch (e) {
    print('❌ ERRO ao somar valores: $e');
    print('Stack trace: ${StackTrace.current}');
    return 0.0;
  }
}
