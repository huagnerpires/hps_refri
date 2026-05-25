import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PatrimoniosRecord extends FirestoreRecord {
  PatrimoniosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "NDATERMOGRAFIA" field.
  String? _ndatermografia;
  String get ndatermografia => _ndatermografia ?? '';
  bool hasNdatermografia() => _ndatermografia != null;

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

  // "LIMPEZADAEVAPORADORA" field.
  bool? _limpezadaevaporadora;
  bool get limpezadaevaporadora => _limpezadaevaporadora ?? false;
  bool hasLimpezadaevaporadora() => _limpezadaevaporadora != null;

  // "LAVAGEMDOFILTRO" field.
  bool? _lavagemdofiltro;
  bool get lavagemdofiltro => _lavagemdofiltro ?? false;
  bool hasLavagemdofiltro() => _lavagemdofiltro != null;

  // "LIMPEZACOMBACTERICIDA" field.
  bool? _limpezacombactericida;
  bool get limpezacombactericida => _limpezacombactericida ?? false;
  bool hasLimpezacombactericida() => _limpezacombactericida != null;

  // "VERIFICAODODRENO" field.
  bool? _verificaododreno;
  bool get verificaododreno => _verificaododreno ?? false;
  bool hasVerificaododreno() => _verificaododreno != null;

  // "LAVAGEMDATURBINA" field.
  bool? _lavagemdaturbina;
  bool get lavagemdaturbina => _lavagemdaturbina ?? false;
  bool hasLavagemdaturbina() => _lavagemdaturbina != null;

  // "VERIFICAODERUIDOS" field.
  bool? _verificaoderuidos;
  bool get verificaoderuidos => _verificaoderuidos ?? false;
  bool hasVerificaoderuidos() => _verificaoderuidos != null;

  // "VERIFICAODOISOLAMENTOTRMICO" field.
  bool? _verificaodoisolamentotrmico;
  bool get verificaodoisolamentotrmico => _verificaodoisolamentotrmico ?? false;
  bool hasVerificaodoisolamentotrmico() => _verificaodoisolamentotrmico != null;

  // "LAVAGEMDACONDENSADORA" field.
  bool? _lavagemdacondensadora;
  bool get lavagemdacondensadora => _lavagemdacondensadora ?? false;
  bool hasLavagemdacondensadora() => _lavagemdacondensadora != null;

  // "TERMOGRAFIA" field.
  bool? _termografia;
  bool get termografia => _termografia ?? false;
  bool hasTermografia() => _termografia != null;

  // "VERIFICAODOSACABAMENTOS" field.
  bool? _verificaodosacabamentos;
  bool get verificaodosacabamentos => _verificaodosacabamentos ?? false;
  bool hasVerificaodosacabamentos() => _verificaodosacabamentos != null;

  // "ANO" field.
  int? _ano;
  int get ano => _ano ?? 0;
  bool hasAno() => _ano != null;

  // "PATRIMONIO" field.
  int? _patrimonio;
  int get patrimonio => _patrimonio ?? 0;
  bool hasPatrimonio() => _patrimonio != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "FLUIDO" field.
  String? _fluido;
  String get fluido => _fluido ?? '';
  bool hasFluido() => _fluido != null;

  // "RESPONSAVEL" field.
  String? _responsavel;
  String get responsavel => _responsavel ?? '';
  bool hasResponsavel() => _responsavel != null;

  // "TECNICORESPONSAVEL" field.
  String? _tecnicoresponsavel;
  String get tecnicoresponsavel => _tecnicoresponsavel ?? '';
  bool hasTecnicoresponsavel() => _tecnicoresponsavel != null;

  // "DATADAMANUTENCAO" field.
  DateTime? _datadamanutencao;
  DateTime? get datadamanutencao => _datadamanutencao;
  bool hasDatadamanutencao() => _datadamanutencao != null;

  // "DESCRICAODOSERVICO" field.
  String? _descricaodoservico;
  String get descricaodoservico => _descricaodoservico ?? '';
  bool hasDescricaodoservico() => _descricaodoservico != null;

  void _initializeFields() {
    _ndatermografia = snapshotData['NDATERMOGRAFIA'] as String?;
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _limpezadaevaporadora = snapshotData['LIMPEZADAEVAPORADORA'] as bool?;
    _lavagemdofiltro = snapshotData['LAVAGEMDOFILTRO'] as bool?;
    _limpezacombactericida = snapshotData['LIMPEZACOMBACTERICIDA'] as bool?;
    _verificaododreno = snapshotData['VERIFICAODODRENO'] as bool?;
    _lavagemdaturbina = snapshotData['LAVAGEMDATURBINA'] as bool?;
    _verificaoderuidos = snapshotData['VERIFICAODERUIDOS'] as bool?;
    _verificaodoisolamentotrmico =
        snapshotData['VERIFICAODOISOLAMENTOTRMICO'] as bool?;
    _lavagemdacondensadora = snapshotData['LAVAGEMDACONDENSADORA'] as bool?;
    _termografia = snapshotData['TERMOGRAFIA'] as bool?;
    _verificaodosacabamentos = snapshotData['VERIFICAODOSACABAMENTOS'] as bool?;
    _ano = castToType<int>(snapshotData['ANO']);
    _patrimonio = castToType<int>(snapshotData['PATRIMONIO']);
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _responsavel = snapshotData['RESPONSAVEL'] as String?;
    _tecnicoresponsavel = snapshotData['TECNICORESPONSAVEL'] as String?;
    _datadamanutencao = snapshotData['DATADAMANUTENCAO'] as DateTime?;
    _descricaodoservico = snapshotData['DESCRICAODOSERVICO'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('PATRIMONIOS');

  static Stream<PatrimoniosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PatrimoniosRecord.fromSnapshot(s));

  static Future<PatrimoniosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PatrimoniosRecord.fromSnapshot(s));

  static PatrimoniosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PatrimoniosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PatrimoniosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PatrimoniosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PatrimoniosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PatrimoniosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPatrimoniosRecordData({
  String? ndatermografia,
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  bool? limpezadaevaporadora,
  bool? lavagemdofiltro,
  bool? limpezacombactericida,
  bool? verificaododreno,
  bool? lavagemdaturbina,
  bool? verificaoderuidos,
  bool? verificaodoisolamentotrmico,
  bool? lavagemdacondensadora,
  bool? termografia,
  bool? verificaodosacabamentos,
  int? ano,
  int? patrimonio,
  String? email,
  String? fluido,
  String? responsavel,
  String? tecnicoresponsavel,
  DateTime? datadamanutencao,
  String? descricaodoservico,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'NDATERMOGRAFIA': ndatermografia,
      'EQUIPAMENTO': equipamento,
      'MARCA': marca,
      'MODELO': modelo,
      'BTUS': btus,
      'SALA': sala,
      'LIMPEZADAEVAPORADORA': limpezadaevaporadora,
      'LAVAGEMDOFILTRO': lavagemdofiltro,
      'LIMPEZACOMBACTERICIDA': limpezacombactericida,
      'VERIFICAODODRENO': verificaododreno,
      'LAVAGEMDATURBINA': lavagemdaturbina,
      'VERIFICAODERUIDOS': verificaoderuidos,
      'VERIFICAODOISOLAMENTOTRMICO': verificaodoisolamentotrmico,
      'LAVAGEMDACONDENSADORA': lavagemdacondensadora,
      'TERMOGRAFIA': termografia,
      'VERIFICAODOSACABAMENTOS': verificaodosacabamentos,
      'ANO': ano,
      'PATRIMONIO': patrimonio,
      'EMAIL': email,
      'FLUIDO': fluido,
      'RESPONSAVEL': responsavel,
      'TECNICORESPONSAVEL': tecnicoresponsavel,
      'DATADAMANUTENCAO': datadamanutencao,
      'DESCRICAODOSERVICO': descricaodoservico,
    }.withoutNulls,
  );

  return firestoreData;
}

class PatrimoniosRecordDocumentEquality implements Equality<PatrimoniosRecord> {
  const PatrimoniosRecordDocumentEquality();

  @override
  bool equals(PatrimoniosRecord? e1, PatrimoniosRecord? e2) {
    return e1?.ndatermografia == e2?.ndatermografia &&
        e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.limpezadaevaporadora == e2?.limpezadaevaporadora &&
        e1?.lavagemdofiltro == e2?.lavagemdofiltro &&
        e1?.limpezacombactericida == e2?.limpezacombactericida &&
        e1?.verificaododreno == e2?.verificaododreno &&
        e1?.lavagemdaturbina == e2?.lavagemdaturbina &&
        e1?.verificaoderuidos == e2?.verificaoderuidos &&
        e1?.verificaodoisolamentotrmico == e2?.verificaodoisolamentotrmico &&
        e1?.lavagemdacondensadora == e2?.lavagemdacondensadora &&
        e1?.termografia == e2?.termografia &&
        e1?.verificaodosacabamentos == e2?.verificaodosacabamentos &&
        e1?.ano == e2?.ano &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.responsavel == e2?.responsavel &&
        e1?.tecnicoresponsavel == e2?.tecnicoresponsavel &&
        e1?.datadamanutencao == e2?.datadamanutencao &&
        e1?.descricaodoservico == e2?.descricaodoservico;
  }

  @override
  int hash(PatrimoniosRecord? e) => const ListEquality().hash([
        e?.ndatermografia,
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.limpezadaevaporadora,
        e?.lavagemdofiltro,
        e?.limpezacombactericida,
        e?.verificaododreno,
        e?.lavagemdaturbina,
        e?.verificaoderuidos,
        e?.verificaodoisolamentotrmico,
        e?.lavagemdacondensadora,
        e?.termografia,
        e?.verificaodosacabamentos,
        e?.ano,
        e?.patrimonio,
        e?.email,
        e?.fluido,
        e?.responsavel,
        e?.tecnicoresponsavel,
        e?.datadamanutencao,
        e?.descricaodoservico
      ]);

  @override
  bool isValidKey(Object? o) => o is PatrimoniosRecord;
}
