// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class DadosUsuarioStruct extends FFFirebaseStruct {
  DadosUsuarioStruct({
    String? nome,
    String? senha,
    String? email,
    DocumentReference? referencia,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _nome = nome,
        _senha = senha,
        _email = email,
        _referencia = referencia,
        super(firestoreUtilData);

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "senha" field.
  String? _senha;
  String get senha => _senha ?? '';
  set senha(String? val) => _senha = val;

  bool hasSenha() => _senha != null;

  // "email" field.
  String? _email;
  String get email => _email ?? 'hpsrefri@gmail.com';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "referencia" field.
  DocumentReference? _referencia;
  DocumentReference? get referencia => _referencia;
  set referencia(DocumentReference? val) => _referencia = val;

  bool hasReferencia() => _referencia != null;

  static DadosUsuarioStruct fromMap(Map<String, dynamic> data) =>
      DadosUsuarioStruct(
        nome: data['nome'] as String?,
        senha: data['senha'] as String?,
        email: data['email'] as String?,
        referencia: data['referencia'] as DocumentReference?,
      );

  static DadosUsuarioStruct? maybeFromMap(dynamic data) => data is Map
      ? DadosUsuarioStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'nome': _nome,
        'senha': _senha,
        'email': _email,
        'referencia': _referencia,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
        'senha': serializeParam(
          _senha,
          ParamType.String,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'referencia': serializeParam(
          _referencia,
          ParamType.DocumentReference,
        ),
      }.withoutNulls;

  static DadosUsuarioStruct fromSerializableMap(Map<String, dynamic> data) =>
      DadosUsuarioStruct(
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
        senha: deserializeParam(
          data['senha'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        referencia: deserializeParam(
          data['referencia'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['USUARIOS'],
        ),
      );

  @override
  String toString() => 'DadosUsuarioStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DadosUsuarioStruct &&
        nome == other.nome &&
        senha == other.senha &&
        email == other.email &&
        referencia == other.referencia;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([nome, senha, email, referencia]);
}

DadosUsuarioStruct createDadosUsuarioStruct({
  String? nome,
  String? senha,
  String? email,
  DocumentReference? referencia,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    DadosUsuarioStruct(
      nome: nome,
      senha: senha,
      email: email,
      referencia: referencia,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

DadosUsuarioStruct? updateDadosUsuarioStruct(
  DadosUsuarioStruct? dadosUsuario, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    dadosUsuario
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDadosUsuarioStructData(
  Map<String, dynamic> firestoreData,
  DadosUsuarioStruct? dadosUsuario,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (dadosUsuario == null) {
    return;
  }
  if (dadosUsuario.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && dadosUsuario.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final dadosUsuarioData =
      getDadosUsuarioFirestoreData(dadosUsuario, forFieldValue);
  final nestedData =
      dadosUsuarioData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = dadosUsuario.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDadosUsuarioFirestoreData(
  DadosUsuarioStruct? dadosUsuario, [
  bool forFieldValue = false,
]) {
  if (dadosUsuario == null) {
    return {};
  }
  final firestoreData = mapToFirestore(dadosUsuario.toMap());

  // Add any Firestore field values
  mapToFirestore(dadosUsuario.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDadosUsuarioListFirestoreData(
  List<DadosUsuarioStruct>? dadosUsuarios,
) =>
    dadosUsuarios?.map((e) => getDadosUsuarioFirestoreData(e, true)).toList() ??
    [];
