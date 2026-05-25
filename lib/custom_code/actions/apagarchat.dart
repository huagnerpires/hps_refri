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

Future apagarchat() async {
  // Future apagarchat() async {  // crie um codigo para apagar uma coleção completa no firebase  try {    await FirebaseFirestore.instance.collection('chat').get().then((snapshot) {      for (DocumentSnapshot doc in snapshot.docs) {        doc.reference.delete();      }    });    print('Coleção apagada com sucesso');  } catch (e) {    print('Erro ao apagar coleção: $e');  }} APAGAR DUAS COLEÇOES
  try {
    await FirebaseFirestore.instance.collection('chat').get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    print('Coleção "chat" apagada com sucesso');
  } catch (e) {
    print('Erro ao apagar coleção "chat": $e');
  }
}
