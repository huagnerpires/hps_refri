import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ManutencaoRecord extends FirestoreRecord {
  ManutencaoRecord._(
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

  // "ANO" field.
  int? _ano;
  int get ano => _ano ?? 0;
  bool hasAno() => _ano != null;

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

  // "MES" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "NOME" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "STATUS" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "TIPO" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  // "DATA_TERMINO" field.
  String? _dataTermino;
  String get dataTermino => _dataTermino ?? '';
  bool hasDataTermino() => _dataTermino != null;

  // "PREVISAODAPECA" field.
  String? _previsaodapeca;
  String get previsaodapeca => _previsaodapeca ?? '';
  bool hasPrevisaodapeca() => _previsaodapeca != null;

  // "Empresa" field.
  bool? _empresa;
  bool get empresa => _empresa ?? false;
  bool hasEmpresa() => _empresa != null;

  // "NUMERO_OS" field.
  String? _numeroOs;
  String get numeroOs => _numeroOs ?? '';
  bool hasNumeroOs() => _numeroOs != null;

  // "PATRIMONIO" field.
  String? _patrimonio;
  String get patrimonio => _patrimonio ?? '';
  bool hasPatrimonio() => _patrimonio != null;

  // "DEFEITO" field.
  String? _defeito;
  String get defeito => _defeito ?? '';
  bool hasDefeito() => _defeito != null;

  // "SETOR" field.
  String? _setor;
  String get setor => _setor ?? '';
  bool hasSetor() => _setor != null;

  // "PECAS" field.
  List<String>? _pecas;
  List<String> get pecas => _pecas ?? const [];
  bool hasPecas() => _pecas != null;

  // "VALOR" field.
  List<double>? _valor;
  List<double> get valor => _valor ?? const [];
  bool hasValor() => _valor != null;

  // "QUANTIDADE" field.
  double? _quantidade;
  double get quantidade => _quantidade ?? 0.0;
  bool hasQuantidade() => _quantidade != null;

  void _initializeFields() {
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _ano = castToType<int>(snapshotData['ANO']);
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _responsavel = snapshotData['RESPONSAVEL'] as String?;
    _tecnicoresponsavel = snapshotData['TECNICORESPONSAVEL'] as String?;
    _datadamanutencao = snapshotData['DATADAMANUTENCAO'] as DateTime?;
    _descricaodoservico = snapshotData['DESCRICAODOSERVICO'] as String?;
    _mes = snapshotData['MES'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _status = snapshotData['STATUS'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _dataTermino = snapshotData['DATA_TERMINO'] as String?;
    _previsaodapeca = snapshotData['PREVISAODAPECA'] as String?;
    _empresa = snapshotData['Empresa'] as bool?;
    _numeroOs = snapshotData['NUMERO_OS'] as String?;
    _patrimonio = snapshotData['PATRIMONIO'] as String?;
    _defeito = snapshotData['DEFEITO'] as String?;
    _setor = snapshotData['SETOR'] as String?;
    _pecas = getDataList(snapshotData['PECAS']);
    _valor = getDataList(snapshotData['VALOR']);
    _quantidade = castToType<double>(snapshotData['QUANTIDADE']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('MANUTENCAO');

  static Stream<ManutencaoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ManutencaoRecord.fromSnapshot(s));

  static Future<ManutencaoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ManutencaoRecord.fromSnapshot(s));

  static ManutencaoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ManutencaoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ManutencaoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ManutencaoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ManutencaoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ManutencaoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createManutencaoRecordData({
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  int? ano,
  String? email,
  String? fluido,
  String? responsavel,
  String? tecnicoresponsavel,
  DateTime? datadamanutencao,
  String? descricaodoservico,
  String? mes,
  String? nome,
  String? status,
  String? tipo,
  String? dataTermino,
  String? previsaodapeca,
  bool? empresa,
  String? numeroOs,
  String? patrimonio,
  String? defeito,
  String? setor,
  double? quantidade,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'EQUIPAMENTO': equipamento,
      'MARCA': marca,
      'MODELO': modelo,
      'BTUS': btus,
      'SALA': sala,
      'ANO': ano,
      'EMAIL': email,
      'FLUIDO': fluido,
      'RESPONSAVEL': responsavel,
      'TECNICORESPONSAVEL': tecnicoresponsavel,
      'DATADAMANUTENCAO': datadamanutencao,
      'DESCRICAODOSERVICO': descricaodoservico,
      'MES': mes,
      'NOME': nome,
      'STATUS': status,
      'TIPO': tipo,
      'DATA_TERMINO': dataTermino,
      'PREVISAODAPECA': previsaodapeca,
      'Empresa': empresa,
      'NUMERO_OS': numeroOs,
      'PATRIMONIO': patrimonio,
      'DEFEITO': defeito,
      'SETOR': setor,
      'QUANTIDADE': quantidade,
    }.withoutNulls,
  );

  return firestoreData;
}

class ManutencaoRecordDocumentEquality implements Equality<ManutencaoRecord> {
  const ManutencaoRecordDocumentEquality();

  @override
  bool equals(ManutencaoRecord? e1, ManutencaoRecord? e2) {
    const listEquality = ListEquality();
    return e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.ano == e2?.ano &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.responsavel == e2?.responsavel &&
        e1?.tecnicoresponsavel == e2?.tecnicoresponsavel &&
        e1?.datadamanutencao == e2?.datadamanutencao &&
        e1?.descricaodoservico == e2?.descricaodoservico &&
        e1?.mes == e2?.mes &&
        e1?.nome == e2?.nome &&
        e1?.status == e2?.status &&
        e1?.tipo == e2?.tipo &&
        e1?.dataTermino == e2?.dataTermino &&
        e1?.previsaodapeca == e2?.previsaodapeca &&
        e1?.empresa == e2?.empresa &&
        e1?.numeroOs == e2?.numeroOs &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.defeito == e2?.defeito &&
        e1?.setor == e2?.setor &&
        listEquality.equals(e1?.pecas, e2?.pecas) &&
        listEquality.equals(e1?.valor, e2?.valor) &&
        e1?.quantidade == e2?.quantidade;
  }

  @override
  int hash(ManutencaoRecord? e) => const ListEquality().hash([
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.ano,
        e?.email,
        e?.fluido,
        e?.responsavel,
        e?.tecnicoresponsavel,
        e?.datadamanutencao,
        e?.descricaodoservico,
        e?.mes,
        e?.nome,
        e?.status,
        e?.tipo,
        e?.dataTermino,
        e?.previsaodapeca,
        e?.empresa,
        e?.numeroOs,
        e?.patrimonio,
        e?.defeito,
        e?.setor,
        e?.pecas,
        e?.valor,
        e?.quantidade
      ]);

  @override
  bool isValidKey(Object? o) => o is ManutencaoRecord;
}
