import 'package:cloud_firestore/cloud_firestore.dart';

import 'schema/util/firestore_util.dart';

import 'schema/usuarios_record.dart';
import 'schema/patrimonios_record.dart';
import 'schema/corretivas_record.dart';
import 'schema/preventivas_record.dart';
import 'schema/imagens_record.dart';
import 'schema/dados_do_cliente_usuario_record.dart';
import 'schema/garantia_record.dart';
import 'schema/manutencao_record.dart';
import 'schema/nova_ordem_de_servico_record.dart';
import 'schema/atendimento_record.dart';
import 'schema/historico_record.dart';
import 'schema/equipamento_das_empresas_record.dart';
import 'schema/notificacao_record.dart';
import 'schema/equipamentos_usuario_record.dart';
import 'schema/equipamentos_empresa_record.dart';
import 'schema/chat_record.dart';
import 'schema/lista_chat_record.dart';
import 'schema/servicosrealizados_record.dart';
import 'schema/area_restrita_record.dart';
import 'schema/equipamentoscadastro_record.dart';

export 'dart:async' show StreamSubscription;
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:firebase_core/firebase_core.dart';
export 'schema/index.dart';
export 'schema/util/firestore_util.dart';
export 'schema/util/schema_util.dart';

export 'schema/usuarios_record.dart';
export 'schema/patrimonios_record.dart';
export 'schema/corretivas_record.dart';
export 'schema/preventivas_record.dart';
export 'schema/imagens_record.dart';
export 'schema/dados_do_cliente_usuario_record.dart';
export 'schema/garantia_record.dart';
export 'schema/manutencao_record.dart';
export 'schema/nova_ordem_de_servico_record.dart';
export 'schema/atendimento_record.dart';
export 'schema/historico_record.dart';
export 'schema/equipamento_das_empresas_record.dart';
export 'schema/notificacao_record.dart';
export 'schema/equipamentos_usuario_record.dart';
export 'schema/equipamentos_empresa_record.dart';
export 'schema/chat_record.dart';
export 'schema/lista_chat_record.dart';
export 'schema/servicosrealizados_record.dart';
export 'schema/area_restrita_record.dart';
export 'schema/equipamentoscadastro_record.dart';

/// Functions to query UsuariosRecords (as a Stream and as a Future).
Future<int> queryUsuariosRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      UsuariosRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<UsuariosRecord>> queryUsuariosRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      UsuariosRecord.collection,
      UsuariosRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<UsuariosRecord>> queryUsuariosRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      UsuariosRecord.collection,
      UsuariosRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query PatrimoniosRecords (as a Stream and as a Future).
Future<int> queryPatrimoniosRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      PatrimoniosRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<PatrimoniosRecord>> queryPatrimoniosRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PatrimoniosRecord.collection,
      PatrimoniosRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<PatrimoniosRecord>> queryPatrimoniosRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      PatrimoniosRecord.collection,
      PatrimoniosRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query CorretivasRecords (as a Stream and as a Future).
Future<int> queryCorretivasRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      CorretivasRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<CorretivasRecord>> queryCorretivasRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      CorretivasRecord.collection,
      CorretivasRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<CorretivasRecord>> queryCorretivasRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      CorretivasRecord.collection,
      CorretivasRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query PreventivasRecords (as a Stream and as a Future).
Future<int> queryPreventivasRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      PreventivasRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<PreventivasRecord>> queryPreventivasRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PreventivasRecord.collection,
      PreventivasRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<PreventivasRecord>> queryPreventivasRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      PreventivasRecord.collection,
      PreventivasRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ImagensRecords (as a Stream and as a Future).
Future<int> queryImagensRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ImagensRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ImagensRecord>> queryImagensRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ImagensRecord.collection,
      ImagensRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ImagensRecord>> queryImagensRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ImagensRecord.collection,
      ImagensRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query DadosDoClienteUsuarioRecords (as a Stream and as a Future).
Future<int> queryDadosDoClienteUsuarioRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      DadosDoClienteUsuarioRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<DadosDoClienteUsuarioRecord>> queryDadosDoClienteUsuarioRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      DadosDoClienteUsuarioRecord.collection,
      DadosDoClienteUsuarioRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<DadosDoClienteUsuarioRecord>> queryDadosDoClienteUsuarioRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      DadosDoClienteUsuarioRecord.collection,
      DadosDoClienteUsuarioRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query GarantiaRecords (as a Stream and as a Future).
Future<int> queryGarantiaRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      GarantiaRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<GarantiaRecord>> queryGarantiaRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      GarantiaRecord.collection,
      GarantiaRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<GarantiaRecord>> queryGarantiaRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      GarantiaRecord.collection,
      GarantiaRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ManutencaoRecords (as a Stream and as a Future).
Future<int> queryManutencaoRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ManutencaoRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ManutencaoRecord>> queryManutencaoRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ManutencaoRecord.collection,
      ManutencaoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ManutencaoRecord>> queryManutencaoRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ManutencaoRecord.collection,
      ManutencaoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query NovaOrdemDeServicoRecords (as a Stream and as a Future).
Future<int> queryNovaOrdemDeServicoRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      NovaOrdemDeServicoRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<NovaOrdemDeServicoRecord>> queryNovaOrdemDeServicoRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      NovaOrdemDeServicoRecord.collection,
      NovaOrdemDeServicoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<NovaOrdemDeServicoRecord>> queryNovaOrdemDeServicoRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      NovaOrdemDeServicoRecord.collection,
      NovaOrdemDeServicoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query AtendimentoRecords (as a Stream and as a Future).
Future<int> queryAtendimentoRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      AtendimentoRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<AtendimentoRecord>> queryAtendimentoRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      AtendimentoRecord.collection,
      AtendimentoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<AtendimentoRecord>> queryAtendimentoRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      AtendimentoRecord.collection,
      AtendimentoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query HistoricoRecords (as a Stream and as a Future).
Future<int> queryHistoricoRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      HistoricoRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<HistoricoRecord>> queryHistoricoRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      HistoricoRecord.collection,
      HistoricoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<HistoricoRecord>> queryHistoricoRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      HistoricoRecord.collection,
      HistoricoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query EquipamentoDasEmpresasRecords (as a Stream and as a Future).
Future<int> queryEquipamentoDasEmpresasRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      EquipamentoDasEmpresasRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<EquipamentoDasEmpresasRecord>> queryEquipamentoDasEmpresasRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      EquipamentoDasEmpresasRecord.collection,
      EquipamentoDasEmpresasRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<EquipamentoDasEmpresasRecord>>
    queryEquipamentoDasEmpresasRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
        queryCollectionOnce(
          EquipamentoDasEmpresasRecord.collection,
          EquipamentoDasEmpresasRecord.fromSnapshot,
          queryBuilder: queryBuilder,
          limit: limit,
          singleRecord: singleRecord,
        );

/// Functions to query NotificacaoRecords (as a Stream and as a Future).
Future<int> queryNotificacaoRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      NotificacaoRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<NotificacaoRecord>> queryNotificacaoRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      NotificacaoRecord.collection,
      NotificacaoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<NotificacaoRecord>> queryNotificacaoRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      NotificacaoRecord.collection,
      NotificacaoRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query EquipamentosUsuarioRecords (as a Stream and as a Future).
Future<int> queryEquipamentosUsuarioRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      EquipamentosUsuarioRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<EquipamentosUsuarioRecord>> queryEquipamentosUsuarioRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      EquipamentosUsuarioRecord.collection,
      EquipamentosUsuarioRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<EquipamentosUsuarioRecord>> queryEquipamentosUsuarioRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      EquipamentosUsuarioRecord.collection,
      EquipamentosUsuarioRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query EquipamentosEmpresaRecords (as a Stream and as a Future).
Future<int> queryEquipamentosEmpresaRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      EquipamentosEmpresaRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<EquipamentosEmpresaRecord>> queryEquipamentosEmpresaRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      EquipamentosEmpresaRecord.collection,
      EquipamentosEmpresaRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<EquipamentosEmpresaRecord>> queryEquipamentosEmpresaRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      EquipamentosEmpresaRecord.collection,
      EquipamentosEmpresaRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ChatRecords (as a Stream and as a Future).
Future<int> queryChatRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ChatRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ChatRecord>> queryChatRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ChatRecord.collection,
      ChatRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ChatRecord>> queryChatRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ChatRecord.collection,
      ChatRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ListaChatRecords (as a Stream and as a Future).
Future<int> queryListaChatRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ListaChatRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ListaChatRecord>> queryListaChatRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ListaChatRecord.collection,
      ListaChatRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ListaChatRecord>> queryListaChatRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ListaChatRecord.collection,
      ListaChatRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ServicosrealizadosRecords (as a Stream and as a Future).
Future<int> queryServicosrealizadosRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ServicosrealizadosRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ServicosrealizadosRecord>> queryServicosrealizadosRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ServicosrealizadosRecord.collection,
      ServicosrealizadosRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ServicosrealizadosRecord>> queryServicosrealizadosRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ServicosrealizadosRecord.collection,
      ServicosrealizadosRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query AreaRestritaRecords (as a Stream and as a Future).
Future<int> queryAreaRestritaRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      AreaRestritaRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<AreaRestritaRecord>> queryAreaRestritaRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      AreaRestritaRecord.collection,
      AreaRestritaRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<AreaRestritaRecord>> queryAreaRestritaRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      AreaRestritaRecord.collection,
      AreaRestritaRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query EquipamentoscadastroRecords (as a Stream and as a Future).
Future<int> queryEquipamentoscadastroRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      EquipamentoscadastroRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<EquipamentoscadastroRecord>> queryEquipamentoscadastroRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      EquipamentoscadastroRecord.collection,
      EquipamentoscadastroRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<EquipamentoscadastroRecord>> queryEquipamentoscadastroRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      EquipamentoscadastroRecord.collection,
      EquipamentoscadastroRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<int> queryCollectionCount(
  Query collection, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0) {
    query = query.limit(limit);
  }

  return query.count().get().catchError((err) {
    print('Error querying $collection: $err');
  }).then((value) => value.count!);
}

Stream<List<T>> queryCollection<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  return query.snapshots().handleError((err) {
    print('Error querying $collection: $err');
  }).map((s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList());
}

Future<List<T>> queryCollectionOnce<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  return query.get().then((s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList());
}

Filter filterIn(String field, List? list) => (list?.isEmpty ?? true)
    ? Filter(field, whereIn: null)
    : Filter(field, whereIn: list);

Filter filterArrayContainsAny(String field, List? list) =>
    (list?.isEmpty ?? true)
        ? Filter(field, arrayContainsAny: null)
        : Filter(field, arrayContainsAny: list);

extension QueryExtension on Query {
  Query whereIn(String field, List? list) => (list?.isEmpty ?? true)
      ? where(field, whereIn: null)
      : where(field, whereIn: list);

  Query whereNotIn(String field, List? list) => (list?.isEmpty ?? true)
      ? where(field, whereNotIn: null)
      : where(field, whereNotIn: list);

  Query whereArrayContainsAny(String field, List? list) =>
      (list?.isEmpty ?? true)
          ? where(field, arrayContainsAny: null)
          : where(field, arrayContainsAny: list);
}

class FFFirestorePage<T> {
  final List<T> data;
  final Stream<List<T>>? dataStream;
  final QueryDocumentSnapshot? nextPageMarker;

  FFFirestorePage(this.data, this.dataStream, this.nextPageMarker);
}

Future<FFFirestorePage<T>> queryCollectionPage<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  DocumentSnapshot? nextPageMarker,
  required int pageSize,
  required bool isStream,
}) async {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection).limit(pageSize);
  if (nextPageMarker != null) {
    query = query.startAfterDocument(nextPageMarker);
  }
  Stream<QuerySnapshot>? docSnapshotStream;
  QuerySnapshot docSnapshot;
  if (isStream) {
    docSnapshotStream = query.snapshots();
    docSnapshot = await docSnapshotStream.first;
  } else {
    docSnapshot = await query.get();
  }
  final getDocs = (QuerySnapshot s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList();
  final data = getDocs(docSnapshot);
  final dataStream = docSnapshotStream?.map(getDocs);
  final nextPageToken = docSnapshot.docs.isEmpty ? null : docSnapshot.docs.last;
  return FFFirestorePage(data, dataStream, nextPageToken);
}
