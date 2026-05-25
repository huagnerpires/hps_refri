import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NovaOrdemDeServicoRecord extends FirestoreRecord {
  NovaOrdemDeServicoRecord._(
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

  // "VALOR_DO_SERVICO" field.
  String? _valorDoServico;
  String get valorDoServico => _valorDoServico ?? '';
  bool hasValorDoServico() => _valorDoServico != null;

  // "TENSAO" field.
  String? _tensao;
  String get tensao => _tensao ?? '';
  bool hasTensao() => _tensao != null;

  // "GARANTIA" field.
  String? _garantia;
  String get garantia => _garantia ?? '';
  bool hasGarantia() => _garantia != null;

  // "NUMERO_SERIE" field.
  String? _numeroSerie;
  String get numeroSerie => _numeroSerie ?? '';
  bool hasNumeroSerie() => _numeroSerie != null;

  // "PATRIMONIO" field.
  int? _patrimonio;
  int get patrimonio => _patrimonio ?? 0;
  bool hasPatrimonio() => _patrimonio != null;

  // "NUMERO_PESQUISA" field.
  String? _numeroPesquisa;
  String get numeroPesquisa => _numeroPesquisa ?? '';
  bool hasNumeroPesquisa() => _numeroPesquisa != null;

  void _initializeFields() {
    _equipamento = snapshotData['EQUIPAMENTO'] as String?;
    _marca = snapshotData['MARCA'] as String?;
    _modelo = snapshotData['MODELO'] as String?;
    _btus = snapshotData['BTUS'] as String?;
    _sala = snapshotData['SALA'] as String?;
    _ano = castToType<int>(snapshotData['ANO']);
    _email = snapshotData['EMAIL'] as String?;
    _fluido = snapshotData['FLUIDO'] as String?;
    _tecnicoresponsavel = snapshotData['TECNICORESPONSAVEL'] as String?;
    _datadamanutencao = snapshotData['DATADAMANUTENCAO'] as DateTime?;
    _descricaodoservico = snapshotData['DESCRICAODOSERVICO'] as String?;
    _mes = snapshotData['MES'] as String?;
    _nome = snapshotData['NOME'] as String?;
    _status = snapshotData['STATUS'] as String?;
    _tipo = snapshotData['TIPO'] as String?;
    _dataTermino = snapshotData['DATA_TERMINO'] as String?;
    _valorDoServico = snapshotData['VALOR_DO_SERVICO'] as String?;
    _tensao = snapshotData['TENSAO'] as String?;
    _garantia = snapshotData['GARANTIA'] as String?;
    _numeroSerie = snapshotData['NUMERO_SERIE'] as String?;
    _patrimonio = castToType<int>(snapshotData['PATRIMONIO']);
    _numeroPesquisa = snapshotData['NUMERO_PESQUISA'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('nova_ordem_de_servico');

  static Stream<NovaOrdemDeServicoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NovaOrdemDeServicoRecord.fromSnapshot(s));

  static Future<NovaOrdemDeServicoRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => NovaOrdemDeServicoRecord.fromSnapshot(s));

  static NovaOrdemDeServicoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NovaOrdemDeServicoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NovaOrdemDeServicoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NovaOrdemDeServicoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NovaOrdemDeServicoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NovaOrdemDeServicoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNovaOrdemDeServicoRecordData({
  String? equipamento,
  String? marca,
  String? modelo,
  String? btus,
  String? sala,
  int? ano,
  String? email,
  String? fluido,
  String? tecnicoresponsavel,
  DateTime? datadamanutencao,
  String? descricaodoservico,
  String? mes,
  String? nome,
  String? status,
  String? tipo,
  String? dataTermino,
  String? valorDoServico,
  String? tensao,
  String? garantia,
  String? numeroSerie,
  int? patrimonio,
  String? numeroPesquisa,
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
      'TECNICORESPONSAVEL': tecnicoresponsavel,
      'DATADAMANUTENCAO': datadamanutencao,
      'DESCRICAODOSERVICO': descricaodoservico,
      'MES': mes,
      'NOME': nome,
      'STATUS': status,
      'TIPO': tipo,
      'DATA_TERMINO': dataTermino,
      'VALOR_DO_SERVICO': valorDoServico,
      'TENSAO': tensao,
      'GARANTIA': garantia,
      'NUMERO_SERIE': numeroSerie,
      'PATRIMONIO': patrimonio,
      'NUMERO_PESQUISA': numeroPesquisa,
    }.withoutNulls,
  );

  return firestoreData;
}

class NovaOrdemDeServicoRecordDocumentEquality
    implements Equality<NovaOrdemDeServicoRecord> {
  const NovaOrdemDeServicoRecordDocumentEquality();

  @override
  bool equals(NovaOrdemDeServicoRecord? e1, NovaOrdemDeServicoRecord? e2) {
    return e1?.equipamento == e2?.equipamento &&
        e1?.marca == e2?.marca &&
        e1?.modelo == e2?.modelo &&
        e1?.btus == e2?.btus &&
        e1?.sala == e2?.sala &&
        e1?.ano == e2?.ano &&
        e1?.email == e2?.email &&
        e1?.fluido == e2?.fluido &&
        e1?.tecnicoresponsavel == e2?.tecnicoresponsavel &&
        e1?.datadamanutencao == e2?.datadamanutencao &&
        e1?.descricaodoservico == e2?.descricaodoservico &&
        e1?.mes == e2?.mes &&
        e1?.nome == e2?.nome &&
        e1?.status == e2?.status &&
        e1?.tipo == e2?.tipo &&
        e1?.dataTermino == e2?.dataTermino &&
        e1?.valorDoServico == e2?.valorDoServico &&
        e1?.tensao == e2?.tensao &&
        e1?.garantia == e2?.garantia &&
        e1?.numeroSerie == e2?.numeroSerie &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.numeroPesquisa == e2?.numeroPesquisa;
  }

  @override
  int hash(NovaOrdemDeServicoRecord? e) => const ListEquality().hash([
        e?.equipamento,
        e?.marca,
        e?.modelo,
        e?.btus,
        e?.sala,
        e?.ano,
        e?.email,
        e?.fluido,
        e?.tecnicoresponsavel,
        e?.datadamanutencao,
        e?.descricaodoservico,
        e?.mes,
        e?.nome,
        e?.status,
        e?.tipo,
        e?.dataTermino,
        e?.valorDoServico,
        e?.tensao,
        e?.garantia,
        e?.numeroSerie,
        e?.patrimonio,
        e?.numeroPesquisa
      ]);

  @override
  bool isValidKey(Object? o) => o is NovaOrdemDeServicoRecord;
}
