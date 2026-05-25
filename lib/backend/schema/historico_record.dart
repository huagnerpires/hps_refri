import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HistoricoRecord extends FirestoreRecord {
  HistoricoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "equipamento" field.
  String? _equipamento;
  String get equipamento => _equipamento ?? '';
  bool hasEquipamento() => _equipamento != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "descricao" field.
  String? _descricao;
  String get descricao => _descricao ?? '';
  bool hasDescricao() => _descricao != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "data_inicio" field.
  DateTime? _dataInicio;
  DateTime? get dataInicio => _dataInicio;
  bool hasDataInicio() => _dataInicio != null;

  // "data_termino" field.
  DateTime? _dataTermino;
  DateTime? get dataTermino => _dataTermino;
  bool hasDataTermino() => _dataTermino != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "INICIO" field.
  String? _inicio;
  String get inicio => _inicio ?? '';
  bool hasInicio() => _inicio != null;

  // "TERMINO" field.
  String? _termino;
  String get termino => _termino ?? '';
  bool hasTermino() => _termino != null;

  // "numero_os" field.
  String? _numeroOs;
  String get numeroOs => _numeroOs ?? '';
  bool hasNumeroOs() => _numeroOs != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  void _initializeFields() {
    _equipamento = snapshotData['equipamento'] as String?;
    _nome = snapshotData['nome'] as String?;
    _descricao = snapshotData['descricao'] as String?;
    _status = snapshotData['status'] as String?;
    _dataInicio = snapshotData['data_inicio'] as DateTime?;
    _dataTermino = snapshotData['data_termino'] as DateTime?;
    _email = snapshotData['email'] as String?;
    _inicio = snapshotData['INICIO'] as String?;
    _termino = snapshotData['TERMINO'] as String?;
    _numeroOs = snapshotData['numero_os'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('historico');

  static Stream<HistoricoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => HistoricoRecord.fromSnapshot(s));

  static Future<HistoricoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => HistoricoRecord.fromSnapshot(s));

  static HistoricoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      HistoricoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static HistoricoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      HistoricoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'HistoricoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is HistoricoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createHistoricoRecordData({
  String? equipamento,
  String? nome,
  String? descricao,
  String? status,
  DateTime? dataInicio,
  DateTime? dataTermino,
  String? email,
  String? inicio,
  String? termino,
  String? numeroOs,
  String? patrimonio,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'equipamento': equipamento,
      'nome': nome,
      'descricao': descricao,
      'status': status,
      'data_inicio': dataInicio,
      'data_termino': dataTermino,
      'email': email,
      'INICIO': inicio,
      'TERMINO': termino,
      'numero_os': numeroOs,
      'PATRIMONIO': patrimonio,
    }.withoutNulls,
  );

  return firestoreData;
}

class HistoricoRecordDocumentEquality implements Equality<HistoricoRecord> {
  const HistoricoRecordDocumentEquality();

  @override
  bool equals(HistoricoRecord? e1, HistoricoRecord? e2) {
    return e1?.equipamento == e2?.equipamento &&
        e1?.nome == e2?.nome &&
        e1?.descricao == e2?.descricao &&
        e1?.status == e2?.status &&
        e1?.dataInicio == e2?.dataInicio &&
        e1?.dataTermino == e2?.dataTermino &&
        e1?.email == e2?.email &&
        e1?.inicio == e2?.inicio &&
        e1?.termino == e2?.termino &&
        e1?.numeroOs == e2?.numeroOs &&
        e1?.patrimonio == e2?.patrimonio;
  }

  @override
  int hash(HistoricoRecord? e) => const ListEquality().hash([
        e?.equipamento,
        e?.nome,
        e?.descricao,
        e?.status,
        e?.dataInicio,
        e?.dataTermino,
        e?.email,
        e?.inicio,
        e?.termino,
        e?.numeroOs,
        e?.patrimonio
      ]);

  @override
  bool isValidKey(Object? o) => o is HistoricoRecord;
}
