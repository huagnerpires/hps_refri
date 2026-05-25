import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start WhatsAppAPI Group Code

class WhatsAppAPIGroup {
  static String getBaseUrl() => 'https://graph.facebook.com/v18.0';
  static Map<String, String> headers = {
    'Key': 'Authorization',
    'Value':
        'Bearer EAAXZAeECUjQMBQINZC9sdZBWfVlpEDtjgtLU8PtebDgOPYvA7qVhOZCHvdLMh6WSmhzw1VtwQEkFsAyMILcjv5CKXVVaE4amOwHgqSYBZBGTHAZA6PBbxmlsQ3FnOZCnJ5VQD0P20EZAWtu0BXpsOP8Jw9X1EwpXlRdGyZBl697Kh0E3rkZCt2yzhXuCXHv1Myv62fB3LlUTaazj06rcZA21rSbzskVvpQVIHfhdZCB0AzU94BrVoQZBoXMdZBbsfZBNZAYy6r8ryzl3TQhdZCiFZAiXrCAnGZA',
    'Key': 'Content-Type',
    'Value': 'application/json',
  };
  static EnviarMensagemCall enviarMensagemCall = EnviarMensagemCall();
}

class EnviarMensagemCall {
  Future<ApiCallResponse> call({
    String? phoneNumberId = '77988194630',
  }) async {
    final baseUrl = WhatsAppAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "messaging_product": "whatsapp",
  "to": "{${escapeStringForJson(phoneNumberId)}}",
  "type": "text",
  "text": {
    "body": "{mensagem}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'EnviarMensagem',
      apiUrl: '${baseUrl}/{phoneNumberId}/messages',
      callType: ApiCallType.POST,
      headers: {
        'Key': 'Authorization',
        'Value':
            'Bearer EAAXZAeECUjQMBQINZC9sdZBWfVlpEDtjgtLU8PtebDgOPYvA7qVhOZCHvdLMh6WSmhzw1VtwQEkFsAyMILcjv5CKXVVaE4amOwHgqSYBZBGTHAZA6PBbxmlsQ3FnOZCnJ5VQD0P20EZAWtu0BXpsOP8Jw9X1EwpXlRdGyZBl697Kh0E3rkZCt2yzhXuCXHv1Myv62fB3LlUTaazj06rcZA21rSbzskVvpQVIHfhdZCB0AzU94BrVoQZBoXMdZBbsfZBNZAYy6r8ryzl3TQhdZCiFZAiXrCAnGZA',
        'Key': 'Content-Type',
        'Value': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End WhatsAppAPI Group Code

class GetProdutosCall {
  static Future<ApiCallResponse> call({
    String? patrimonio = '',
    String? tipo = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getProdutos',
      apiUrl:
          'https://xpyqkzupzjsbuqimeodu.supabase.co/rest/v1/produtos?PATRIMONIO=eq.${patrimonio}&tipo=eq.${tipo}&select=*',
      callType: ApiCallType.GET,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhweXFrenVwempzYnVxaW1lb2R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2MDE1MDYsImV4cCI6MjA0MjE3NzUwNn0.OQRZA7B-bDh2QCqC0f1K92yPM9uC7vKqO4KLkjBBGjQ',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? id(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].id''',
      ));
  static String? createdat(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].created_at''',
      ));
  static int? patrimonio(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].PATRIMONIO''',
      ));
  static String? mes(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].MÊS''',
      ));
  static int? ano(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].ANO''',
      ));
  static String? equipamento(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].EQUIPAMENTO''',
      ));
  static String? marca(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].MARCA''',
      ));
  static String? modelo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].MODELO''',
      ));
  static String? btus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].BTUS''',
      ));
  static String? fludo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].FLUÍDO''',
      ));
  static String? sala(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].SALA''',
      ));
  static String? responsvel(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].RESPONSÁVEL''',
      ));
  static bool? termografia(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$[:].TERMOGRAFIA''',
      ));
  static String? tipo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].tipo''',
      ));
}

class MesEmManutencaoCall {
  static Future<ApiCallResponse> call({
    String? patrimonio = '',
    String? tipo = '',
    String? mes = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'MesEmManutencao',
      apiUrl:
          'https://xpyqkzupzjsbuqimeodu.supabase.co/rest/v1/manutencao?PATRIMONIO=eq.${patrimonio}&tipo=eq.${tipo}&MÊS=eq.${mes}&select=*',
      callType: ApiCallType.GET,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhweXFrenVwempzYnVxaW1lb2R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2MDE1MDYsImV4cCI6MjA0MjE3NzUwNn0.OQRZA7B-bDh2QCqC0f1K92yPM9uC7vKqO4KLkjBBGjQ',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? id(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].id''',
      ));
  static String? createdat(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].created_at''',
      ));
  static int? patrimonio(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].PATRIMONIO''',
      ));
  static String? mes(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].MÊS''',
      ));
  static int? ano(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].ANO''',
      ));
  static String? equipamento(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].EQUIPAMENTO''',
      ));
  static String? marca(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].MARCA''',
      ));
  static String? modelo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].MODELO''',
      ));
  static String? btus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].BTUS''',
      ));
  static String? fludo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].FLUÍDO''',
      ));
  static String? sala(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].SALA''',
      ));
  static String? responsvel(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].RESPONSÁVEL''',
      ));
  static bool? termografia(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$[:].TERMOGRAFIA''',
      ));
  static String? tipo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].tipo''',
      ));
  static String? email(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].email''',
      ));
}

class DeletaNotificacaoCall {
  static Future<ApiCallResponse> call({
    String? email = '',
  }) async {
    final ffApiRequestBody = '''
{
  "target_email": "${email}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'deletaNotificacao',
      apiUrl:
          'https://iiuvovcxialwnvgnfdvh.supabase.co/rest/v1/rpc/delete_rows_by_email',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlpdXZvdmN4aWFsd252Z25mZHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0OTQ5MDIsImV4cCI6MjA3OTA3MDkwMn0.KsIMsaxbp6bJIEo6KxOCRQitncf27FWkJF9Uv_UlDro',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlpdXZvdmN4aWFsd252Z25mZHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0OTQ5MDIsImV4cCI6MjA3OTA3MDkwMn0.KsIMsaxbp6bJIEo6KxOCRQitncf27FWkJF9Uv_UlDro',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeletarGarantiaCall {
  static Future<ApiCallResponse> call({
    String? documentoid = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'deletarGarantia',
      apiUrl:
          'https://firestore.googleapis.com/v1/projects/h-p-s-modificado-emdcp0/databases/(default)/documents/GARANTIA/${documentoid}',
      callType: ApiCallType.DELETE,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class PagamentoViaPixCall {
  static Future<ApiCallResponse> call({
    double? quanto,
    String? email = '',
    String? nome = '',
    String? idIndentificacao = '',
  }) async {
    final ffApiRequestBody = '''
{
  "transaction_amount": ${quanto},
  "payment_method_id": "pix",
  "payer": {
    "email": "${email}",
    "first_name": "${nome}"
  }
}


''';
    return ApiManager.instance.makeApiCall(
      callName: 'PagamentoViaPix',
      apiUrl: 'https://api.mercadopago.com/v1/payments',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer APP_USR-2844929455593841-102322-ac853bd2b94718448d6c40e7c2d0ee3f-652633782',
        'X-Idempotency-Key': '${idIndentificacao}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? id(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.id''',
      ));
  static String? chavePix(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.point_of_interaction.transaction_data.qr_code''',
      ));
  static String? qRcode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.point_of_interaction.transaction_data.qr_code_base64''',
      ));
  static String? site(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.point_of_interaction.transaction_data.ticket_url''',
      ));
}

class StatusPagamentoCall {
  static Future<ApiCallResponse> call({
    int? idPagamento,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'StatusPagamento',
      apiUrl: 'https://api.mercadopago.com/v1/payments/${idPagamento}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer APP_USR-2844929455593841-102322-ac853bd2b94718448d6c40e7c2d0ee3f-652633782',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.status''',
      ));
}

class EnviarCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? titulo = '',
    String? mensagem = '',
  }) async {
    final ffApiRequestBody = '''
{
  "app_id": "7b01186f-cf76-4b5d-8354-87d83737d40c",
  "filters": [
    {
      "field": "tag",
      "key": "Email",
      "relation": "=",
      "value": "${email}"
    }
  ],
  "headings": {
    "en": "${titulo}"
  },
  "contents": {
    "en": "${mensagem}"},
"android_channel_id": "577bba44-d1bf-4ac9-9d11-20d89e09a61a",
  "priority": 10
}
''';
    return ApiManager.instance.makeApiCall(
      callName: 'enviar',
      apiUrl: 'https://onesignal.com/api/v1/notifications',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ExternalidCall {
  static Future<ApiCallResponse> call({
    String? externalid = '',
  }) async {
    final ffApiRequestBody = '''
{
  "identity": {
    "external_id": "${escapeStringForJson(externalid)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'externalid',
      apiUrl:
          'https://api.onesignal.com/apps/7b01186f-cf76-4b5d-8354-87d83737d40c/users',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ZapCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{ 
  "messaging_product": "whatsapp",
  "to": "5577988194630",
  "type": "template",
  "template": { 
    "name": "hps_deslocamento",
    "language": { "code": "pt_BR" },
    "components": [
      {
        "type": "body",
        "parameters": [
          {
            "type": "text",
            "text": "joao paulo"
          },
          {
            "type": "text",
            "text": "15/12/2025"
          }
        ]
      }
    ]
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'zap',
      apiUrl: 'https://graph.facebook.com/v22.0/902190519646048/messages',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer EAAUcNns4h2sBQPxE5OVzEtKK4GuHUPShEWOaetgFqDi63MPpX5peGmA0XEbzXgRZBe3xFN3vV3oNxyZCT90iHVDjGNssVnR8ibYPdbwIcuYkl04EzxTZAZArQR7HTI21H2B68lYHU9gUnfWxcN5wj6QngRDtH4YaXZAhS3Psk9ei7hTi0OcMqOUhzORWhxGQ1AsXZAwRde11r0zYBbtTWZAle31QhOnNY8ZCEVAn45DLpqJwKKCn5XW9XqCf4MW6Edjja0lLH8XpTfSeEjm4OMdlwZCiHkvsIZBTDEKQZDZD',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
