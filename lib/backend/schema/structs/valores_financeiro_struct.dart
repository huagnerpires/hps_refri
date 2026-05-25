// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class ValoresFinanceiroStruct extends FFFirebaseStruct {
  ValoresFinanceiroStruct({
    double? adm,
    double? pav15,
    double? central,
    double? manutencao,
    double? producao,
    double? refeitorio,
    double? pre,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _adm = adm,
        _pav15 = pav15,
        _central = central,
        _manutencao = manutencao,
        _producao = producao,
        _refeitorio = refeitorio,
        _pre = pre,
        super(firestoreUtilData);

  // "ADM" field.
  double? _adm;
  double get adm => _adm ?? 0.0;
  set adm(double? val) => _adm = val;

  void incrementAdm(double amount) => adm = adm + amount;

  bool hasAdm() => _adm != null;

  // "PAV15" field.
  double? _pav15;
  double get pav15 => _pav15 ?? 0.0;
  set pav15(double? val) => _pav15 = val;

  void incrementPav15(double amount) => pav15 = pav15 + amount;

  bool hasPav15() => _pav15 != null;

  // "CENTRAL" field.
  double? _central;
  double get central => _central ?? 0.0;
  set central(double? val) => _central = val;

  void incrementCentral(double amount) => central = central + amount;

  bool hasCentral() => _central != null;

  // "MANUTENCAO" field.
  double? _manutencao;
  double get manutencao => _manutencao ?? 0.0;
  set manutencao(double? val) => _manutencao = val;

  void incrementManutencao(double amount) => manutencao = manutencao + amount;

  bool hasManutencao() => _manutencao != null;

  // "PRODUCAO" field.
  double? _producao;
  double get producao => _producao ?? 0.0;
  set producao(double? val) => _producao = val;

  void incrementProducao(double amount) => producao = producao + amount;

  bool hasProducao() => _producao != null;

  // "REFEITORIO" field.
  double? _refeitorio;
  double get refeitorio => _refeitorio ?? 0.0;
  set refeitorio(double? val) => _refeitorio = val;

  void incrementRefeitorio(double amount) => refeitorio = refeitorio + amount;

  bool hasRefeitorio() => _refeitorio != null;

  // "PRE" field.
  double? _pre;
  double get pre => _pre ?? 0.0;
  set pre(double? val) => _pre = val;

  void incrementPre(double amount) => pre = pre + amount;

  bool hasPre() => _pre != null;

  static ValoresFinanceiroStruct fromMap(Map<String, dynamic> data) =>
      ValoresFinanceiroStruct(
        adm: castToType<double>(data['ADM']),
        pav15: castToType<double>(data['PAV15']),
        central: castToType<double>(data['CENTRAL']),
        manutencao: castToType<double>(data['MANUTENCAO']),
        producao: castToType<double>(data['PRODUCAO']),
        refeitorio: castToType<double>(data['REFEITORIO']),
        pre: castToType<double>(data['PRE']),
      );

  static ValoresFinanceiroStruct? maybeFromMap(dynamic data) => data is Map
      ? ValoresFinanceiroStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'ADM': _adm,
        'PAV15': _pav15,
        'CENTRAL': _central,
        'MANUTENCAO': _manutencao,
        'PRODUCAO': _producao,
        'REFEITORIO': _refeitorio,
        'PRE': _pre,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'ADM': serializeParam(
          _adm,
          ParamType.double,
        ),
        'PAV15': serializeParam(
          _pav15,
          ParamType.double,
        ),
        'CENTRAL': serializeParam(
          _central,
          ParamType.double,
        ),
        'MANUTENCAO': serializeParam(
          _manutencao,
          ParamType.double,
        ),
        'PRODUCAO': serializeParam(
          _producao,
          ParamType.double,
        ),
        'REFEITORIO': serializeParam(
          _refeitorio,
          ParamType.double,
        ),
        'PRE': serializeParam(
          _pre,
          ParamType.double,
        ),
      }.withoutNulls;

  static ValoresFinanceiroStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ValoresFinanceiroStruct(
        adm: deserializeParam(
          data['ADM'],
          ParamType.double,
          false,
        ),
        pav15: deserializeParam(
          data['PAV15'],
          ParamType.double,
          false,
        ),
        central: deserializeParam(
          data['CENTRAL'],
          ParamType.double,
          false,
        ),
        manutencao: deserializeParam(
          data['MANUTENCAO'],
          ParamType.double,
          false,
        ),
        producao: deserializeParam(
          data['PRODUCAO'],
          ParamType.double,
          false,
        ),
        refeitorio: deserializeParam(
          data['REFEITORIO'],
          ParamType.double,
          false,
        ),
        pre: deserializeParam(
          data['PRE'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'ValoresFinanceiroStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ValoresFinanceiroStruct &&
        adm == other.adm &&
        pav15 == other.pav15 &&
        central == other.central &&
        manutencao == other.manutencao &&
        producao == other.producao &&
        refeitorio == other.refeitorio &&
        pre == other.pre;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([adm, pav15, central, manutencao, producao, refeitorio, pre]);
}

ValoresFinanceiroStruct createValoresFinanceiroStruct({
  double? adm,
  double? pav15,
  double? central,
  double? manutencao,
  double? producao,
  double? refeitorio,
  double? pre,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ValoresFinanceiroStruct(
      adm: adm,
      pav15: pav15,
      central: central,
      manutencao: manutencao,
      producao: producao,
      refeitorio: refeitorio,
      pre: pre,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ValoresFinanceiroStruct? updateValoresFinanceiroStruct(
  ValoresFinanceiroStruct? valoresFinanceiro, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    valoresFinanceiro
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addValoresFinanceiroStructData(
  Map<String, dynamic> firestoreData,
  ValoresFinanceiroStruct? valoresFinanceiro,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (valoresFinanceiro == null) {
    return;
  }
  if (valoresFinanceiro.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && valoresFinanceiro.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final valoresFinanceiroData =
      getValoresFinanceiroFirestoreData(valoresFinanceiro, forFieldValue);
  final nestedData =
      valoresFinanceiroData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = valoresFinanceiro.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getValoresFinanceiroFirestoreData(
  ValoresFinanceiroStruct? valoresFinanceiro, [
  bool forFieldValue = false,
]) {
  if (valoresFinanceiro == null) {
    return {};
  }
  final firestoreData = mapToFirestore(valoresFinanceiro.toMap());

  // Add any Firestore field values
  mapToFirestore(valoresFinanceiro.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getValoresFinanceiroListFirestoreData(
  List<ValoresFinanceiroStruct>? valoresFinanceiros,
) =>
    valoresFinanceiros
        ?.map((e) => getValoresFinanceiroFirestoreData(e, true))
        .toList() ??
    [];
