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

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Importante para detectar a Web

Future<void> onesignal(String? email, String? telefone, String? key,
    String? value, String? userId) async {
// 1. TRAVA PARA WEB: O pacote mobile não funciona corretamente na Web.
  if (kIsWeb) {
    print(
        "OneSignal: Rodando na Web. A inicialização deve ser feita via JavaScript.");
    return; // Sai da função imediatamente
  }
// 2. LÓGICA PARA APP (Android/iOS)
  OneSignal.initialize("7b01186f-cf76-4b5d-8354-87d83737d40c");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
// Pequeno delay para garantir inicialização
  await Future.delayed(const Duration(milliseconds: 500));
  try {
// Lógica de Login
    if (userId != null && userId.isNotEmpty && userId != "null") {
      print("OneSignal: Executando Login para ID: $userId");
      OneSignal.login(userId);
    } else {
      print("OneSignal: ID vazio. Pulando login.");
    }
// Adiciona Email
    if (email != null && email.isNotEmpty && email != "null") {
      print("OneSignal: Adicionando Email: $email");
      await OneSignal.User.addEmail(email);
    }
// Adiciona Telefone
    if (telefone != null && telefone.isNotEmpty && telefone != "null") {
      print("OneSignal: Adicionando SMS: $telefone");
      await OneSignal.User.addSms(telefone);
    }
// Adiciona Tags
    if (key != null && value != null && key.isNotEmpty && value.isNotEmpty) {
      OneSignal.User.addTagWithKey(key, value);
    }
// Solicita permissão
    await OneSignal.Notifications.requestPermission(true);
  } catch (e) {
    print("OneSignal Erro: $e");
  }
}
