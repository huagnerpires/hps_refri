import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DadosDoClienteUsuarioRecord extends FirestoreRecord {
  DadosDoClienteUsuarioRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "NOME_DA_EMPRESA" field.
  String? _nomeDaEmpresa;
  String get nomeDaEmpresa => _nomeDaEmpresa ?? '';
  bool hasNomeDaEmpresa() => _nomeDaEmpresa != null;

  // "TIPO_DO_CONTRATO" field.
  String? _tipoDoContrato;
  String get tipoDoContrato => _tipoDoContrato ?? '';
  bool hasTipoDoContrato() => _tipoDoContrato != null;

  // "CARGO" field.
  String? _cargo;
  String get cargo => _cargo ?? '';
  bool hasCargo() => _cargo != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  void _initializeFields() {
    _nomeDaEmpresa = snapshotData['NOME_DA_EMPRESA'] as String?;
    _tipoDoContrato = snapshotData['TIPO_DO_CONTRATO'] as String?;
    _cargo = snapshotData['CARGO'] as String?;
    _email = snapshotData['EMAIL'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Dados_do_cliente_usuario');

  static Stream<DadosDoClienteUsuarioRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => DadosDoClienteUsuarioRecord.fromSnapshot(s));

  static Future<DadosDoClienteUsuarioRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => DadosDoClienteUsuarioRecord.fromSnapshot(s));

  static DadosDoClienteUsuarioRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DadosDoClienteUsuarioRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DadosDoClienteUsuarioRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DadosDoClienteUsuarioRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DadosDoClienteUsuarioRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DadosDoClienteUsuarioRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDadosDoClienteUsuarioRecordData({
  String? nomeDaEmpresa,
  String? tipoDoContrato,
  String? cargo,
  String? email,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'NOME_DA_EMPRESA': nomeDaEmpresa,
      'TIPO_DO_CONTRATO': tipoDoContrato,
      'CARGO': cargo,
      'EMAIL': email,
    }.withoutNulls,
  );

  return firestoreData;
}

class DadosDoClienteUsuarioRecordDocumentEquality
    implements Equality<DadosDoClienteUsuarioRecord> {
  const DadosDoClienteUsuarioRecordDocumentEquality();

  @override
  bool equals(
      DadosDoClienteUsuarioRecord? e1, DadosDoClienteUsuarioRecord? e2) {
    return e1?.nomeDaEmpresa == e2?.nomeDaEmpresa &&
        e1?.tipoDoContrato == e2?.tipoDoContrato &&
        e1?.cargo == e2?.cargo &&
        e1?.email == e2?.email;
  }

  @override
  int hash(DadosDoClienteUsuarioRecord? e) => const ListEquality()
      .hash([e?.nomeDaEmpresa, e?.tipoDoContrato, e?.cargo, e?.email]);

  @override
  bool isValidKey(Object? o) => o is DadosDoClienteUsuarioRecord;
}
