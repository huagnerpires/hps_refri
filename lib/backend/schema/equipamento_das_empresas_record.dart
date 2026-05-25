import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EquipamentoDasEmpresasRecord extends FirestoreRecord {
  EquipamentoDasEmpresasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "EQUIPAMENTO" field.
  String? _equipamento;
  String get equipamento => _equipamento ?? '';
  bool hasEquipamento() => _equipamento != null;

  // "MARCA" field.
  String? _marca;
  String get marca => _marca ?? '';
  bool hasMarca() => _marca != null;

  // "MODELO" field.
  String? _modelo;
  String get modelo => _modelo ?? '';
  bool hasModelo() => _modelo != null;

  // "BTUS" field.
  String? _btus;
  String get btus => _btus ?? '';
  bool hasBtus() => _btus != null;

  // "SALA" field.
  String? _sala;
  String get sala => _sala ?? '';
  bool hasSala() => _sala != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "FLUIDO" field.
  String? _fluido;
  String get fluido => _fluido ?? '';
  bool hasFluido() => _fluido != null;

  // "NOME" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "TENSAO" field.
  String? _tensao;
  String get tensao => _tensao ?? '';
  bool hasTensao() => _tensao != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  void _initializeFields() {
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _tensao = snapshotData['TENSAO'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('equipamento_das_empresas');

  static Stream<EquipamentoDasEmpresasRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => EquipamentoDasEmpresasRecord.fromSnapshot(s));

  static Future<EquipamentoDasEmpresasRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => EquipamentoDasEmpresasRecord.fromSnapshot(s));

  static EquipamentoDasEmpresasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      EquipamentoDasEmpresasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EquipamentoDasEmpresasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EquipamentoDasEmpresasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EquipamentoDasEmpresasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EquipamentoDasEmpresasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEquipamentoDasEmpresasRecordData({
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  String? email,
  String? fluido,
  String? nome,
  String? tensao,
  String? tipo,
  String? patrimonio,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'EQUIPAMENTO': equipamento,
      'MARCA': marca,
      'MODELO': modelo,
      'BTUS': btus,
      'SALA': sala,
      'EMAIL': email,
      'FLUIDO': fluido,
      'NOME': nome,
      'TENSAO': tensao,
      'TIPO': tipo,
      'PATRIMONIO': patrimonio,
    }.withoutNulls,
  );

  return firestoreData;
}

class EquipamentoDasEmpresasRecordDocumentEquality
    implements Equality<EquipamentoDasEmpresasRecord> {
  const EquipamentoDasEmpresasRecordDocumentEquality();

  @override
  bool equals(
      EquipamentoDasEmpresasRecord? e1, EquipamentoDasEmpresasRecord? e2) {
    return e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.nome == e2?.nome &&
        e1?.tensao == e2?.tensao &&
        e1?.tipo == e2?.tipo &&
        e1?.patrimonio == e2?.patrimonio;
  }

  @override
  int hash(EquipamentoDasEmpresasRecord? e) => const ListEquality().hash([
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.email,
        e?.fluido,
        e?.nome,
        e?.tensao,
        e?.tipo,
        e?.patrimonio
      ]);

  @override
  bool isValidKey(Object? o) => o is EquipamentoDasEmpresasRecord;
}
