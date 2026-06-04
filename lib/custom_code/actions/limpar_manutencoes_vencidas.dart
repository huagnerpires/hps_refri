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
import 'package:intl/intl.dart';

Future<int> limparManutencoesVencidas() async {
  try {
    print('=== INÍCIO DA LIMPEZA DE MANUTENÇÕES ===');

    // Referência para a coleção 'MANUTENCAO'
    final CollectionReference manutencaoRef =
        FirebaseFirestore.instance.collection('MANUTENCAO');

    // Data atual
    final DateTime dataAtual = DateTime.now();
    print('Data atual: ${DateFormat('dd/MM/yyyy').format(dataAtual)}');

    // Calcula a data de 15 dias atrás
    final DateTime dataLimite = dataAtual.subtract(Duration(days: 15));
    print(
        'Data limite (15 dias atrás): ${DateFormat('dd/MM/yyyy').format(dataLimite)}');

    // Busca todos os documentos da coleção
    final QuerySnapshot snapshot = await manutencaoRef.get();
    print('Total de documentos encontrados: ${snapshot.docs.length}');

    // Formato brasileiro de data
    final DateFormat formatoBrasileiro = DateFormat('dd/MM/yyyy');

    // Contador de itens excluídos
    int itensExcluidos = 0;

    // Itera sobre cada documento
    for (DocumentSnapshot doc in snapshot.docs) {
      try {
        print('\n--- Processando documento: ${doc.id} ---');

        // Obtém os dados do documento
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          print('Documento vazio');
          continue;
        }

        if (!data.containsKey('DATA_TERMINO')) {
          print('Campo DATA_TERMINO não encontrado');
          continue;
        }

        // Obtém o campo DATA_TERMINO como String
        final String? dataTerminoString =
            data['DATA_TERMINO']?.toString().trim();

        if (dataTerminoString == null || dataTerminoString.isEmpty) {
          print('DATA_TERMINO está vazio');
          continue;
        }

        print('DATA_TERMINO: $dataTerminoString');

        // Converte a String no formato dd/MM/yyyy para DateTime
        DateTime? dataTermino;
        try {
          dataTermino = formatoBrasileiro.parse(dataTerminoString);
          print('Data convertida: ${formatoBrasileiro.format(dataTermino)}');
        } catch (e) {
          print('Erro ao converter data: $e');
          continue;
        }

        // Calcula a diferença de dias entre data atual e data de término
        final int diferencaDias = dataAtual.difference(dataTermino).inDays;
        print('Diferença de dias: $diferencaDias');

        // Verifica se já passaram MAIS DE 15 dias desde a DATA_TERMINO
        if (diferencaDias > 15) {
          print('✅ Item vencido há $diferencaDias dias! Excluindo...');

          // Exclui o documento
          await doc.reference.delete();
          itensExcluidos++;

          print('✅ Item excluído com sucesso!');
        } else if (diferencaDias >= 0) {
          print(
              '❌ Item ainda válido (passaram apenas $diferencaDias dias, faltam ${15 - diferencaDias} dias)');
        } else {
          print(
              '⚠️ Data de término é futura (daqui a ${diferencaDias.abs()} dias)');
        }
      } catch (e) {
        print('❌ Erro ao processar documento ${doc.id}: $e');
        continue;
      }
    }

    print('\n=== FIM DA LIMPEZA ===');
    print('✅ Total de itens excluídos: $itensExcluidos');
    return itensExcluidos;
  } catch (e) {
    print('❌ ERRO GERAL: $e');
    return -1;
  }
}
