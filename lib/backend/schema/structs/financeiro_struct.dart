// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class FinanceiroStruct extends FFFirebaseStruct {
  FinanceiroStruct({
    int? ano,
    String? mes,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _ano = ano,
        _mes = mes,
        super(firestoreUtilData);

  // "ano" field.
  int? _ano;
  int get ano => _ano ?? 0;
  set ano(int? val) => _ano = val;

  void incrementAno(int amount) => ano = ano + amount;

  bool hasAno() => _ano != null;

  // "mes" field.
  String? _mes;
  String get mes => _mes ?? '';
  set mes(String? val) => _mes = val;

  bool hasMes() => _mes != null;

  static FinanceiroStruct fromMap(Map<String, dynamic> data) =>
      FinanceiroStruct(
        ano: castToType<int>(data['ano']),
        mes: data['mes'] as String?,
      );

  static FinanceiroStruct? maybeFromMap(dynamic data) => data is Map
      ? FinanceiroStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'ano': _ano,
        'mes': _mes,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'ano': serializeParam(
          _ano,
          ParamType.int,
        ),
        'mes': serializeParam(
          _mes,
          ParamType.String,
        ),
      }.withoutNulls;

  static FinanceiroStruct fromSerializableMap(Map<String, dynamic> data) =>
      FinanceiroStruct(
        ano: deserializeParam(
          data['ano'],
          ParamType.int,
          false,
        ),
        mes: deserializeParam(
          data['mes'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'FinanceiroStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FinanceiroStruct && ano == other.ano && mes == other.mes;
  }

  @override
  int get hashCode => const ListEquality().hash([ano, mes]);
}

FinanceiroStruct createFinanceiroStruct({
  int? ano,
  String? mes,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FinanceiroStruct(
      ano: ano,
      mes: mes,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FinanceiroStruct? updateFinanceiroStruct(
  FinanceiroStruct? financeiro, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    financeiro
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFinanceiroStructData(
  Map<String, dynamic> firestoreData,
  FinanceiroStruct? financeiro,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (financeiro == null) {
    return;
  }
  if (financeiro.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && financeiro.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final financeiroData = getFinanceiroFirestoreData(financeiro, forFieldValue);
  final nestedData = financeiroData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = financeiro.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFinanceiroFirestoreData(
  FinanceiroStruct? financeiro, [
  bool forFieldValue = false,
]) {
  if (financeiro == null) {
    return {};
  }
  final firestoreData = mapToFirestore(financeiro.toMap());

  // Add any Firestore field values
  mapToFirestore(financeiro.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFinanceiroListFirestoreData(
  List<FinanceiroStruct>? financeiros,
) =>
    financeiros?.map((e) => getFinanceiroFirestoreData(e, true)).toList() ?? [];
