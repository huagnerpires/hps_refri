import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GarantiaRecord extends FirestoreRecord {
  GarantiaRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "NOME_DO_EQUIPAMENTO" field.
  String? _nomeDoEquipamento;
  String get nomeDoEquipamento => _nomeDoEquipamento ?? '';
  bool hasNomeDoEquipamento() => _nomeDoEquipamento != null;

  // "NUMERO_DE_SERIE" field.
  int? _numeroDeSerie;
  int get numeroDeSerie => _numeroDeSerie ?? 0;
  bool hasNumeroDeSerie() => _numeroDeSerie != null;

  // "DATA_DO_SERVICO" field.
  DateTime? _dataDoServico;
  DateTime? get dataDoServico => _dataDoServico;
  bool hasDataDoServico() => _dataDoServico != null;

  // "MARCA" field.
  String? _marca;
  String get marca => _marca ?? '';
  bool hasMarca() => _marca != null;

  // "TEC_RESPONSAVEL" field.
  String? _tecResponsavel;
  String get tecResponsavel => _tecResponsavel ?? '';
  bool hasTecResponsavel() => _tecResponsavel != null;

  // "DESCRICAO" field.
  String? _descricao;
  String get descricao => _descricao ?? '';
  bool hasDescricao() => _descricao != null;

  // "VALOR" field.
  String? _valor;
  String get valor => _valor ?? '';
  bool hasValor() => _valor != null;

  // "EMAIL" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "PATRIMONIO" field.
  int? _patrimonio;
  int get patrimonio => _patrimonio ?? 0;
  bool hasPatrimonio() => _patrimonio != null;

  // "GARANTIA_ATE" field.
  DateTime? _garantiaAte;
  DateTime? get garantiaAte => _garantiaAte;
  bool hasGarantiaAte() => _garantiaAte != null;

  void _initializeFields() {
    _nomeDoEquipamento = snapshotData['NOME_DO_EQUIPAMENTO'] as String?;
    _numeroDeSerie = castToType<int>(snapshotData['NUMERO_DE_SERIE']);
    _dataDoServico = snapshotData['DATA_DO_SERVICO'] as DateTime?;
    _marca = snapshotData['MARCA'] as String?;
    _tecResponsavel = snapshotData['TEC_RESPONSAVEL'] as String?;
    _descricao = snapshotData['DESCRICAO'] as String?;
    _valor = snapshotData['VALOR'] as String?;
    _email = snapshotData['EMAIL'] as String?;
    _patrimonio = castToType<int>(snapshotData['PATRIMONIO']);
    _garantiaAte = snapshotData['GARANTIA_ATE'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('GARANTIA');

  static Stream<GarantiaRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GarantiaRecord.fromSnapshot(s));

  static Future<GarantiaRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GarantiaRecord.fromSnapshot(s));

  static GarantiaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      GarantiaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GarantiaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GarantiaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GarantiaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GarantiaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGarantiaRecordData({
  String? nomeDoEquipamento,
  int? numeroDeSerie,
  DateTime? dataDoServico,
  String? marca,
  String? tecResponsavel,
  String? descricao,
  String? valor,
  String? email,
  int? patrimonio,
  DateTime? garantiaAte,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'NOME_DO_EQUIPAMENTO': nomeDoEquipamento,
      'NUMERO_DE_SERIE': numeroDeSerie,
      'DATA_DO_SERVICO': dataDoServico,
      'MARCA': marca,
      'TEC_RESPONSAVEL': tecResponsavel,
      'DESCRICAO': descricao,
      'VALOR': valor,
      'EMAIL': email,
      'PATRIMONIO': patrimonio,
      'GARANTIA_ATE': garantiaAte,
    }.withoutNulls,
  );

  return firestoreData;
}

class GarantiaRecordDocumentEquality implements Equality<GarantiaRecord> {
  const GarantiaRecordDocumentEquality();

  @override
  bool equals(GarantiaRecord? e1, GarantiaRecord? e2) {
    return e1?.nomeDoEquipamento == e2?.nomeDoEquipamento &&
        e1?.numeroDeSerie == e2?.numeroDeSerie &&
        e1?.dataDoServico == e2?.dataDoServico &&
        e1?.marca == e2?.marca &&
        e1?.tecResponsavel == e2?.tecResponsavel &&
        e1?.descricao == e2?.descricao &&
        e1?.valor == e2?.valor &&
        e1?.email == e2?.email &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.garantiaAte == e2?.garantiaAte;
  }

  @override
  int hash(GarantiaRecord? e) => const ListEquality().hash([
        e?.nomeDoEquipamento,
        e?.numeroDeSerie,
        e?.dataDoServico,
        e?.marca,
        e?.tecResponsavel,
        e?.descricao,
        e?.valor,
        e?.email,
        e?.patrimonio,
        e?.garantiaAte
      ]);

  @override
  bool isValidKey(Object? o) => o is GarantiaRecord;
}
