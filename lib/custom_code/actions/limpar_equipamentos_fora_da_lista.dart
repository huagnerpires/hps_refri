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

Future<int> limparEquipamentosForaDaLista() async {
  try {
    final firestore = FirebaseFirestore.instance;

    print('📥 Preparando lista oficial de patrimônios...');

    /// LISTA OFICIAL (remove zeros à esquerda)
    final Set<String> listaPatrimonios = {
      '0070650',
      '0168726',
      '0119775',
      '0072740',
      '0168727',
      '0101212',
      '0168725',
      '0144968',
      '0086734',
      '0168729',
      '0168728',
      '0070847',
      '0070850',
      '0070848',
      '0093556',
      '0158443',
      '0119776',
      '0126658',
      '0161805',
      '0126976',
      '0122983',
      '0168724',
      '0147900',
      '0158445',
      '0089208',
      '0106998',
      '0140231',
      '0106999',
      '0162070',
      '0070849',
      '0117655',
      '0072742',
      '0158114',
      '0147368',
      '0161871',
      '0126624',
      '0126975',
      '0101364',
      '0158669',
      '0162068',
      '0158133',
      '0144827',
      '0144828',
      '0147873',
      '0140373',
      '0140372',
      '0140371',
      '0089205',
      '0140374',
      '0140382',
      '0147679',
      '0140375',
      '0094943',
      '0144850',
      '0162193',
      '0109295',
      '0140381',
      '0140380',
      '0147809',
      '0089215',
      '0089211',
      '0144849',
      '0101365',
      '0140104',
      '0093572',
      '0140105',
      '0168752',
      '0122981',
      '0122985',
      '0154301',
      '0122984',
      '0122982',
      '0147365',
      '0089209',
      '0135521',
      '0144970',
      '0147367',
      '0126977',
      '0162192',
      '0147366',
      '0168750',
      '0144971',
      '0115257',
      '0089212',
      '0089213',
      '0127000',
      '0070846',
      '0089207',
      '0092743',
      '0093573',
      '0086548',
      '0089210',
      '0168749',
      '0072741',
      '0158444',
      '0101449',
      '0140230',
      '0089947',
      '0162069',
      '0070938',
      '0086733',
      '0140376',
      '0168751',
      '0126488',
      '0093555',
      '0135410',
      '0140370'
    }.map((e) => e.replaceFirst(RegExp(r'^0+'), '')).toSet();

    print('✅ Total de patrimônios válidos: ${listaPatrimonios.length}');

    final snapshot = await firestore.collection('EQUIPAMENTOS_EMPRESA').get();

    int apagados = 0;

    print('🔍 Verificando ${snapshot.docs.length} documentos da coleção...');

    for (var doc in snapshot.docs) {
      final patrimonioRaw = doc.data()['PATRIMONIO'];

      if (patrimonioRaw == null) {
        print('⚠️ Documento ${doc.id} sem PATRIMONIO → apagando');
        await doc.reference.delete();
        apagados++;
        continue;
      }

      final patrimonioNormalizado =
          patrimonioRaw.toString().replaceFirst(RegExp(r'^0+'), '');

      if (!listaPatrimonios.contains(patrimonioNormalizado)) {
        print(
            '❌ PATRIMONIO $patrimonioRaw (normalizado: $patrimonioNormalizado) NÃO está na lista → APAGANDO');
        await doc.reference.delete();
        apagados++;
      } else {
        print(
            '✅ PATRIMONIO $patrimonioRaw (normalizado: $patrimonioNormalizado) OK');
      }
    }

    print('🗑️ TOTAL DE DOCUMENTOS APAGADOS: $apagados');
    return apagados;
  } catch (e) {
    print('❌ ERRO ao limpar equipamentos: $e');
    print(StackTrace.current);
    return 0;
  }
}
