import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificacaoRecord extends FirestoreRecord {
  NotificacaoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "titulo" field.
  String? _titulo;
  String get titulo => _titulo ?? '';
  bool hasTitulo() => _titulo != null;

  // "mensagem" field.
  String? _mensagem;
  String get mensagem => _mensagem ?? '';
  bool hasMensagem() => _mensagem != null;

  // "patrimonio" field.
  int? _patrimonio;
  int get patrimonio => _patrimonio ?? 0;
  bool hasPatrimonio() => _patrimonio != null;

  // "visto" field.
  bool? _visto;
  bool get visto => _visto ?? false;
  bool hasVisto() => _visto != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  // "mes" field.
  String? _mes;
  String get mes => _mes ?? '';
  bool hasMes() => _mes != null;

  // "ano" field.
  int? _ano;
  int get ano => _ano ?? 0;
  bool hasAno() => _ano != null;

  // "tipo" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  bool hasTipo() => _tipo != null;

  void _initializeFields() {
    _titulo = snapshotData['titulo'] as String?;
    _mensagem = snapshotData['mensagem'] as String?;
    _patrimonio = castToType<int>(snapshotData['patrimonio']);
    _visto = snapshotData['visto'] as bool?;
    _email = snapshotData['email'] as String?;
    _data = snapshotData['data'] as DateTime?;
    _mes = snapshotData['mes'] as String?;
    _ano = castToType<int>(snapshotData['ano']);
    _tipo = snapshotData['tipo'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('NOTIFICACAO');

  static Stream<NotificacaoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificacaoRecord.fromSnapshot(s));

  static Future<NotificacaoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificacaoRecord.fromSnapshot(s));

  static NotificacaoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificacaoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificacaoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificacaoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificacaoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificacaoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificacaoRecordData({
  String? titulo,
  String? mensagem,
  int? patrimonio,
  bool? visto,
  String? email,
  DateTime? data,
  String? mes,
  int? ano,
  String? tipo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'titulo': titulo,
      'mensagem': mensagem,
      'patrimonio': patrimonio,
      'visto': visto,
      'email': email,
      'data': data,
      'mes': mes,
      'ano': ano,
      'tipo': tipo,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificacaoRecordDocumentEquality implements Equality<NotificacaoRecord> {
  const NotificacaoRecordDocumentEquality();

  @override
  bool equals(NotificacaoRecord? e1, NotificacaoRecord? e2) {
    return e1?.titulo == e2?.titulo &&
        e1?.mensagem == e2?.mensagem &&
        e1?.patrimonio == e2?.patrimonio &&
        e1?.visto == e2?.visto &&
        e1?.email == e2?.email &&
        e1?.data == e2?.data &&
        e1?.mes == e2?.mes &&
        e1?.ano == e2?.ano &&
        e1?.tipo == e2?.tipo;
  }

  @override
  int hash(NotificacaoRecord? e) => const ListEquality().hash([
        e?.titulo,
        e?.mensagem,
        e?.patrimonio,
        e?.visto,
        e?.email,
        e?.data,
        e?.mes,
        e?.ano,
        e?.tipo
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificacaoRecord;
}
