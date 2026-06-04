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

// GERAR UMA ACTION PARA MANDAR MENSAGEM NO WATSAPP ONDE VOU MANDAR NO CAMPO MENSAGEM IRA MANDAR MENSAGEM E TELEFONE SERA O NUMERO DIGITADO
import 'package:url_launcher/url_launcher.dart';

Future watsapp(
  String? mensagem,
  int? telefone,
) async {
  if (telefone == null || mensagem == null || mensagem.isEmpty) {
    return;
  }

  // Formatar o número de telefone removendo caracteres especiais
  String numeroFormatado = telefone.toString().replaceAll(RegExp(r'[^\d]'), '');

  // Adicionar código do país se não estiver presente (assumindo Brasil +55)
  if (!numeroFormatado.startsWith('55') && numeroFormatado.length <= 11) {
    numeroFormatado = '55$numeroFormatado';
  }

  // Codificar a mensagem para URL
  String mensagemCodificada = Uri.encodeComponent(mensagem);

  // Criar URL do WhatsApp
  String whatsappUrl =
      'https://wa.me/$numeroFormatado?text=$mensagemCodificada';

  try {
    // Verificar se pode abrir a URL
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Fallback para URL scheme do WhatsApp
      String fallbackUrl =
          'whatsapp://send?phone=$numeroFormatado&text=$mensagemCodificada';
      if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(Uri.parse(fallbackUrl));
      }
    }
  } catch (e) {
    // Em caso de erro, não fazer nada ou log do erro
    print('Erro ao abrir WhatsApp: $e');
  }
}
