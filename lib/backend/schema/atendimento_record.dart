import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AtendimentoRecord extends FirestoreRecord {
  AtendimentoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "patrimonio" field.
  int? _patrimonio;
  int get patrimonio => _patrimonio ?? 0;
  bool hasPatrimonio() => _patrimonio != null;

  // "descricao" field.
  String? _descricao;
  String get descricao => _descricao ?? '';
  bool hasDescricao() => _descricao != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "os" field.
  String? _os;
  String get os => _os ?? '';
  bool hasOs() => _os != null;

  // "cliente" field.
  String? _cliente;
  String get cliente => _cliente ?? '';
  bool hasCliente() => _cliente != null;

  // "DATA" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "sala" field.
  String? _sala;
  String get sala => _sala ?? '';
  bool hasSala() => _sala != null;

  // "solicitante" field.
  String? _solicitante;
  String get solicitante => _solicitante ?? '';
  bool hasSolicitante() => _solicitante != null;

  // "NOVO" field.
  bool? _novo;
  bool get novo => _novo ?? false;
  bool hasNovo() => _novo != null;

  void _initializeFields() {
    _nome = snapshotData['nome'] as String?;
    _patrimonio = castToType<int>(snapshotData['patrimonio']);
    _descricao = snapshotData['descricao'] as String?;
    _status = snapshotData['status'] as String?;
    _email = snapshotData['email'] as String?;
    _os = snapshotData['os'] as String?;
    _cliente = snapshotData['cliente'] as String?;
    _data = snapshotData['DATA'] as DateTime?;
    _sala = snapshotData['sala'] as String?;
    _solicitante = snapshotData['solicitante'] as String?;
    _novo = snapshotData['NOVO'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('atendimento');

  static Stream<AtendimentoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AtendimentoRecord.fromSnapshot(s));

  static Future<AtendimentoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AtendimentoRecord.fromSnapshot(s));

  static AtendimentoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AtendimentoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AtendimentoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AtendimentoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AtendimentoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AtendimentoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAtendimentoRecordData({
  String? nome,
  int? patrimonio,
  String? descricao,
  String? status,
  String? email,
  String? os,
  String? cliente,
  DateTime? data,
  String? sala,
  String? solicitante,
  bool? novo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nome': nome,
      'patrimonio': patrimonio,
      'descricao': descricao,
      'status': status,
      'email': email,
      'os': os,
      'cliente': cliente,
      'DATA': data,
      'sala': sala,
      'solicitante': solicitante,
      'NOVO': novo,
    }.withoutNulls,
  );

  return firestoreData;
}

class AtendimentoRecordDocumentEquality implements Equality<AtendimentoRecord> {
  const AtendimentoRecordDocumentEquality();

  @override
  bool equals(AtendimentoRecord? e1, AtendimentoRecord? e2) {
    return e1?.nome == e2?.nome &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.descricao == e2?.descricao &&
        e1?.status == e2?.status &&
        e1?.email == e2?.email &&
        e1?.os == e2?.os &&
        e1?.cliente == e2?.cliente &&
        e1?.data == e2?.data &&
        e1?.sala == e2?.sala &&
        e1?.solicitante == e2?.solicitante &&
        e1?.novo == e2?.novo;
  }

  @override
  int hash(AtendimentoRecord? e) => const ListEquality().hash([
        e?.nome,
        e?.patrimonio,
        e?.descricao,
        e?.status,
        e?.email,
        e?.os,
        e?.cliente,
        e?.data,
        e?.sala,
        e?.solicitante,
        e?.novo
      ]);

  @override
  bool isValidKey(Object? o) => o is AtendimentoRecord;
}
