// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const double _pdfW = 555.28;

const List<String> _ptMonths = [
  '',
  'JANEIRO',
  'FEVEREIRO',
  'MARÇO',
  'ABRIL',
  'MAIO',
  'JUNHO',
  'JULHO',
  'AGOSTO',
  'SETEMBRO',
  'OUTUBRO',
  'NOVEMBRO',
  'DEZEMBRO',
];

Map<String, String> _webSafeHeaders() =>
    kIsWeb ? {} : {'User-Agent': 'Mozilla/5.0'};

Future<http.Response> _safeHttpGet(String? url,
    {Duration timeout = const Duration(seconds: 8)}) async {
  if (url == null || url.isEmpty || !url.startsWith('http')) {
    return http.Response('', 400);
  }
  try {
    return await http
        .get(Uri.parse(url), headers: _webSafeHeaders())
        .timeout(timeout);
  } catch (_) {
    return http.Response('', 400);
  }
}

String _normalizarTexto(String texto) {
  const comAcento = 'àáâãäåæçèéêëìíîïðñòóôõöùúûüýÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝ';
  const semAcento =
      'aaaaaaaceeeeiiiidnoooooouuuuyyAAAAAAACEEEEIIIIDNOOOOOUUUUY';
  var resultado = texto.toLowerCase().trim();
  for (int i = 0; i < comAcento.length; i++) {
    resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
  }
  return resultado.replaceAll(RegExp(r'\s+'), ' ');
}

bool _mesIgual(String docMes, String filtroMes) {
  return _normalizarTexto(docMes) == _normalizarTexto(filtroMes);
}

String _normPat(dynamic v) {
  return (v ?? '')
      .toString()
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

String _relFmtDate(dynamic ts) {
  if (ts == null) return '';
  if (ts is Timestamp) {
    final d = ts.toDate();
    return d.day.toString().padLeft(2, '0') +
        '/' +
        d.month.toString().padLeft(2, '0') +
        '/' +
        d.year.toString();
  }
  return '';
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Visualizar (StatefulWidget raiz)
/// ─────────────────────────────────────────────────────────────────────────────
class Visualizar extends StatefulWidget {
  const Visualizar({
    Key? key,
    this.width,
    this.height,
    required this.emailCliente,
    this.filtroAno,
    this.filtroMes,
    this.onClose,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String emailCliente;
  final String? filtroAno;
  final String? filtroMes;
  final Future<dynamic> Function()? onClose;

  @override
  _VisualizarState createState() => _VisualizarState();
}

class _VisualizarState extends State<Visualizar> {
  late Future<List<Map<String, dynamic>>> _listaPreventivasFuture;
  Map<String, dynamic>? _dadosCliente;
  bool _isDownloadingAll = false;
  int _downloadTotal = 0;
  int _downloadCurrent = 0;
  String _downloadLabel = '';
  int _totalEquip = 0;
  int _totalFeitos = 0;
  int _totalPendentes = 0;
  bool _loadingPendentes = true;

  static pw.ImageProvider? _cachedImgTopo;
  static pw.ImageProvider? _cachedLogoEmpresa;
  static Future<void>? _assetsFuture;
  List<Map<String, dynamic>> _listaPendentesDados = [];
  final TextEditingController _searchTopController = TextEditingController();
  String _searchTopTerm = '';

  // Escala responsiva para aumentar a fonte no modo Web / Desktop
  double get sc =>
      (kIsWeb && MediaQuery.of(context).size.width > 800) ? 1.35 : 1.0;

  @override
  void initState() {
    super.initState();
    _listaPreventivasFuture = _buscarTodasPreventivas();
    _calcularPendentes();
    _ensureAssetsLoaded();
  }

  @override
  void dispose() {
    _searchTopController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Visualizar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filtroAno != widget.filtroAno ||
        oldWidget.filtroMes != widget.filtroMes) {
      setState(() {
        _listaPreventivasFuture = _buscarTodasPreventivas();
        _searchTopController.clear();
        _searchTopTerm = '';
      });
      _calcularPendentes();
    }
  }

  static Future<void> _ensureAssetsLoaded() {
    _assetsFuture ??= _loadAssets();
    return _assetsFuture!;
  }

  static Future<void> _loadAssets() async {
    try {
      final r0 =
          await _safeHttpGet('https://i.ibb.co/v481FdX8/9491f9c633ca.png');
      if (r0.statusCode == 200 && r0.bodyBytes.isNotEmpty)
        _cachedImgTopo = pw.MemoryImage(r0.bodyBytes);
    } catch (_) {}
    try {
      final r1 = await _safeHttpGet('https://i.ibb.co/VpqNsxXt/Imagem1.jpg');
      if (r1.statusCode == 200 && r1.bodyBytes.isNotEmpty)
        _cachedLogoEmpresa = pw.MemoryImage(r1.bodyBytes);
    } catch (_) {}
  }

  Future<void> _calcularPendentes() async {
    setState(() => _loadingPendentes = true);
    try {
      final db = FirebaseFirestore.instance;
      Query<Map<String, dynamic>> equipQuery =
          db.collection('EQUIPAMENTOS_EMPRESA');
      equipQuery = equipQuery.where('CONTRATO', isEqualTo: true);
      if (widget.emailCliente.isNotEmpty)
        equipQuery = equipQuery.where('EMAIL', isEqualTo: widget.emailCliente);
      final equipDocs = (await equipQuery.get()).docs;
      final Map<String, Map<String, dynamic>> equipPorPat = {};
      for (final doc in equipDocs) {
        final d = doc.data();
        final pat = _normPat(d['PATRIMONIO']);
        if (pat.isNotEmpty) equipPorPat[pat] = d;
      }
      final int? anoFiltro = int.tryParse(widget.filtroAno ?? '');
      final String mesFiltroRaw = (widget.filtroMes ?? '').trim();
      Query<Map<String, dynamic>> prevQuery = db
          .collection('PREVENTIVAS')
          .where('EMAIL', isEqualTo: widget.emailCliente);
      if (anoFiltro != null)
        prevQuery = prevQuery.where('ANO', isEqualTo: anoFiltro);
      if (mesFiltroRaw.isNotEmpty)
        prevQuery = prevQuery.where('MES', isEqualTo: widget.filtroMes);
      final prevDocs = (await prevQuery.get()).docs;
      final Set<String> patsComPreventiva = {};
      for (final doc in prevDocs) {
        final pat = _normPat(doc.data()['PATRIMONIO']);
        if (pat.isNotEmpty && equipPorPat.containsKey(pat))
          patsComPreventiva.add(pat);
      }
      Query<Map<String, dynamic>> pendQuery = db
          .collection('PENDENCIAS')
          .where('emailPrincipal', isEqualTo: widget.emailCliente);
      final pendDocsAll = (await pendQuery.get()).docs;
      final Set<String> patsPendentesNoPeriodo = {};
      final List<Map<String, dynamic>> pendentesTemp = [];
      for (final doc in pendDocsAll) {
        final d = doc.data();
        if (anoFiltro != null && mesFiltroRaw.isNotEmpty) {
          bool dentroDoFiltro = false;
          final tsVisita = d['timestampVisita'];
          if (tsVisita != null && tsVisita is Timestamp) {
            final dt = tsVisita.toDate();
            final mesDoc = _ptMonths[dt.month];
            if (dt.year == anoFiltro && _mesIgual(mesDoc, mesFiltroRaw))
              dentroDoFiltro = true;
          }
          if (!dentroDoFiltro) {
            final tsCriado = d['criadoEm'];
            if (tsCriado != null && tsCriado is Timestamp) {
              final dt = tsCriado.toDate();
              final mesDoc = _ptMonths[dt.month];
              if (dt.year == anoFiltro && _mesIgual(mesDoc, mesFiltroRaw))
                dentroDoFiltro = true;
            }
          }
          if (!dentroDoFiltro) continue;
        }
        final patPend = _normPat(d['patrimonio']);
        if (patPend.isEmpty || !equipPorPat.containsKey(patPend)) continue;
        patsPendentesNoPeriodo.add(patPend);
        final equipData = equipPorPat[patPend]!;
        pendentesTemp.add({
          'EQUIPAMENTO': equipData['EQUIPAMENTO']?.toString() ??
              d['equipamento']?.toString() ??
              '',
          'MODELO':
              equipData['MODELO']?.toString() ?? d['modelo']?.toString() ?? '',
          'SALA': equipData['SALA']?.toString() ?? d['sala']?.toString() ?? '',
          'PATRIMONIO': equipData['PATRIMONIO']?.toString() ??
              d['patrimonio']?.toString() ??
              '',
          'SETOR':
              equipData['SETOR']?.toString() ?? d['setor']?.toString() ?? '',
          'MOTIVO': d['motivo']?.toString() ?? '',
          'STATUS': d['status']?.toString() ?? 'pendente',
          'TENTATIVAS': d['tentativas']?.toString() ?? '',
          'RESPONSAVEL': d['responsavel']?.toString() ?? '',
          'DATA_VISITA': d['dataVisitaFormatada']?.toString() ?? '',
          'HORARIO_VISITA': d['horarioVisitaFormatado']?.toString() ?? '',
          'REMETENTE_NOME': d['remetenteNome']?.toString() ?? '',
          '_docId': doc.id,
        });
      }
      int feitos = 0;
      for (final doc in equipDocs) {
        final pat = _normPat(doc.data()['PATRIMONIO']);
        if (pat.isNotEmpty && patsComPreventiva.contains(pat)) feitos++;
      }
      if (mounted) {
        setState(() {
          _totalEquip = equipDocs.length;
          _totalFeitos = feitos;
          _totalPendentes = pendentesTemp.length;
          _listaPendentesDados = pendentesTemp;
          _loadingPendentes = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingPendentes = false);
    }
  }

  void _mostrarDetalhesEquipamento(Map<String, dynamic> dados) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.devices_outlined,
              color: const Color(0xFF64B5F6), size: 20 * sc),
          SizedBox(width: 8 * sc),
          Expanded(
            child: Text(
              dados['EQUIPAMENTO']?.toString() ?? 'Detalhes do Equipamento',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * sc,
                  color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ]),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 500 * sc),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((dados['MOTIVO'] ?? '').isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.red.withAlpha(38) : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.red.withAlpha(102), width: 1),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MOTIVO DA PENDÊNCIA',
                              style: TextStyle(
                                  fontSize: 10 * sc,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700])),
                          SizedBox(height: 2 * sc),
                          Text(dados['MOTIVO'].toString(),
                              style: TextStyle(
                                  fontSize: 13 * sc,
                                  color:
                                      isDark ? Colors.white : Colors.black87)),
                        ]),
                  ),
                ...dados.entries
                    .where((e) =>
                        !e.key.startsWith('_') &&
                        e.key != 'MOTIVO' &&
                        e.key != 'STATUS' &&
                        e.key != 'REMETENTE_NOME')
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A3E)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white.withAlpha(31)
                                      : Colors.grey.shade200),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.key.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 10 * sc,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white.withAlpha(138)
                                              : Colors.grey[600])),
                                  SizedBox(height: 2 * sc),
                                  Text(e.value.toString(),
                                      style: TextStyle(
                                          fontSize: 14 * sc,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87)),
                                ]),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('FECHAR',
                style: TextStyle(
                    color: const Color(0xFF64B5F6), fontSize: 13 * sc)),
          ),
        ],
      ),
    );
  }

  Future<void> _gerarPdfPendentes(
    List<Map<String, dynamic>> lista,
    Function setStateDialog, {
    Future<void> Function(double, String)? onProgress,
  }) async {
    if (lista.isEmpty) return;
    try {
      await onProgress?.call(0.1, 'Carregando recursos...');
      await Future.microtask(() {});
      await _ensureAssetsLoaded();
      await onProgress?.call(0.5, 'Montando PDF...');

      final pdf = pw.Document();
      final mesLabel = widget.filtroMes ?? '';
      final anoLabel = widget.filtroAno ?? '';
      final nomeCliente =
          _dadosCliente?['display_name']?.toString().toUpperCase() ?? '';
      final localImgTopo = _cachedImgTopo;

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(14),
        header: (ctx) => pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          if (localImgTopo != null) ...[
            pw.Container(
                width: double.infinity,
                height: 220,
                child: pw.Image(localImgTopo, fit: pw.BoxFit.fill)),
            pw.SizedBox(height: 8),
          ],
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RELATÓRIO DE PENDÊNCIAS',
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700)),
                      if (nomeCliente.isNotEmpty)
                        pw.Text(nomeCliente,
                            style: pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700)),
                      if (mesLabel.isNotEmpty || anoLabel.isNotEmpty)
                        pw.Text('Período: $mesLabel / $anoLabel',
                            style: pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700)),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('${lista.length} equipamentos pendentes',
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700)),
                      pw.Text(
                          'Gerado em: ' +
                              DateTime.now().day.toString().padLeft(2, '0') +
                              '/' +
                              DateTime.now().month.toString().padLeft(2, '0') +
                              '/' +
                              DateTime.now().year.toString(),
                          style: pw.TextStyle(
                              fontSize: 8, color: PdfColors.grey600)),
                    ]),
              ]),
          pw.SizedBox(height: 4),
          pw.Divider(thickness: 1, color: PdfColors.red200),
          pw.SizedBox(height: 4),
          pw.Container(
            color: PdfColors.red700,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: pw.Row(children: [
              pw.Expanded(
                  flex: 1,
                  child: pw.Text('#',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 3,
                  child: pw.Text('EQUIPAMENTO',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('MODELO',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('LOCALIZAÇÃO',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('PATRIMÔNIO',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 3,
                  child: pw.Text('SETOR',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 3,
                  child: pw.Text('RESPONSÁVEL',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('MOTIVO',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('DATA/HORA',
                      style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white))),
            ]),
          ),
        ]),
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder(
              left: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
              right: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
              bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
              horizontalInside:
                  pw.BorderSide(width: 0.5, color: PdfColors.grey200),
              verticalInside:
                  pw.BorderSide(width: 0.5, color: PdfColors.grey200),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(2),
              5: pw.FlexColumnWidth(3),
              6: pw.FlexColumnWidth(3),
              7: pw.FlexColumnWidth(2),
              8: pw.FlexColumnWidth(2),
            },
            children: lista.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isEven = i % 2 == 0;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.grey50 : PdfColors.white),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text((i + 1).toString(),
                          style: pw.TextStyle(
                              fontSize: 7, color: PdfColors.grey600))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['EQUIPAMENTO']?.toString() ?? '-',
                          style: pw.TextStyle(
                              fontSize: 7, fontWeight: pw.FontWeight.bold))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['MODELO']?.toString() ?? '-',
                          style: const pw.TextStyle(fontSize: 7))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['SALA']?.toString() ?? '-',
                          style: const pw.TextStyle(fontSize: 7))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['PATRIMONIO']?.toString() ?? '-',
                          style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['SETOR']?.toString() ?? '-',
                          style: const pw.TextStyle(fontSize: 7))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['RESPONSAVEL']?.toString() ?? '-',
                          style: const pw.TextStyle(fontSize: 7))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item['MOTIVO']?.toString() ?? '-',
                          style: const pw.TextStyle(fontSize: 7))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          (item['DATA_VISITA'] ?? '').isNotEmpty
                              ? '${item['DATA_VISITA']}${(item['HORARIO_VISITA'] ?? '').isNotEmpty ? ' ${item['HORARIO_VISITA']}' : ''}'
                              : '-',
                          style: const pw.TextStyle(fontSize: 7))),
                ],
              );
            }).toList(),
          ),
        ],
      ));

      await onProgress?.call(0.85, 'Finalizando PDF...');
      final pdfBytes = await pdf.save();
      if (pdfBytes.isEmpty) throw Exception('PDF pendentes está vazio');
      await onProgress?.call(1.0, 'Pronto!');

      final dataAtual = DateTime.now();
      final nomeArquivo =
          'Pendentes_${mesLabel}_${anoLabel}_${dataAtual.millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: nomeArquivo);
      } else {
        await Printing.layoutPdf(
            onLayout: (_) async => pdfBytes, name: nomeArquivo);
      }
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(
            content: Text('PDF de pendentes gerado!'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  void _mostrarPendentesDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white.withAlpha(138) : Colors.black54;
    final textTertiary =
        isDark ? Colors.white.withAlpha(97) : Colors.grey[600]!;
    final searchFill = isDark ? const Color(0xFF2A2A3E) : Colors.grey[100]!;
    final searchBorder =
        isDark ? Colors.white.withAlpha(31) : Colors.grey.shade300;
    final dividerColor =
        isDark ? Colors.white.withAlpha(31) : Colors.grey.shade200;
    const primaryColor = Color(0xFF64B5F6);

    List<Map<String, dynamic>> listaFiltrada = List.from(_listaPendentesDados);
    TextEditingController searchController = TextEditingController();
    bool isGerandoPdf = false;
    double pdfProgress = 0.0;
    String pdfProgressLabel = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setStateDialog) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: BoxConstraints(maxHeight: 620 * sc),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 128 : 38),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A1A1A) : Colors.red[50],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                      bottom: BorderSide(
                          color: isDark
                              ? Colors.red.withAlpha(77)
                              : Colors.red.shade100,
                          width: 1)),
                ),
                child: Row(children: [
                  Container(
                    width: 36 * sc,
                    height: 36 * sc,
                    decoration: BoxDecoration(
                        color: Colors.red.withAlpha(38),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 20 * sc),
                  ),
                  SizedBox(width: 12 * sc),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Equipamentos Pendentes',
                              style: TextStyle(
                                  fontSize: 15 * sc,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary)),
                          Text(
                              '${listaFiltrada.length} sem preventiva no período',
                              style: TextStyle(
                                  fontSize: 12 * sc, color: Colors.red[400])),
                        ]),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: isGerandoPdf ? null : () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: 32 * sc,
                      height: 32 * sc,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(31)
                                : Colors.grey.shade300,
                            width: 1),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 16 * sc,
                          color: isGerandoPdf
                              ? Colors.grey
                              : (isDark
                                  ? Colors.white.withAlpha(153)
                                  : Colors.grey[700])),
                    ),
                  ),
                ]),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: textPrimary, fontSize: 13 * sc),
                  decoration: InputDecoration(
                    hintText: 'Buscar equipamento, sala, patrimônio...',
                    hintStyle:
                        TextStyle(color: textTertiary, fontSize: 12 * sc),
                    prefixIcon:
                        Icon(Icons.search, color: primaryColor, size: 18 * sc),
                    filled: true,
                    fillColor: searchFill,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: searchBorder, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: searchBorder, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: primaryColor, width: 1.5)),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 16 * sc, color: textTertiary),
                            onPressed: () => setStateDialog(() {
                                  searchController.clear();
                                  listaFiltrada =
                                      List.from(_listaPendentesDados);
                                }))
                        : null,
                  ),
                  onChanged: (value) => setStateDialog(() {
                    if (value.isEmpty) {
                      listaFiltrada = List.from(_listaPendentesDados);
                    } else {
                      final termo = value.toLowerCase();
                      listaFiltrada = _listaPendentesDados.where((item) {
                        final nome = (item['EQUIPAMENTO'] ?? '')
                            .toString()
                            .toLowerCase();
                        final sala =
                            (item['SALA'] ?? '').toString().toLowerCase();
                        final pat =
                            (item['PATRIMONIO'] ?? '').toString().toLowerCase();
                        final motivo =
                            (item['MOTIVO'] ?? '').toString().toLowerCase();
                        return nome.contains(termo) ||
                            sala.contains(termo) ||
                            pat.contains(termo) ||
                            motivo.contains(termo);
                      }).toList();
                    }
                  }),
                ),
              ),
              Divider(height: 1, color: dividerColor),
              Flexible(
                child: listaFiltrada.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 48 * sc,
                                  color: isDark
                                      ? Colors.white.withAlpha(61)
                                      : Colors.grey[300]),
                              SizedBox(height: 12 * sc),
                              Text(
                                  _listaPendentesDados.isEmpty
                                      ? 'Nenhum equipamento pendente!'
                                      : 'Nenhum item encontrado.',
                                  style: TextStyle(
                                      fontSize: 14 * sc, color: textSecondary)),
                            ]),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: listaFiltrada.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: dividerColor,
                            indent: 16,
                            endIndent: 16),
                        itemBuilder: (_, i) {
                          final item = listaFiltrada[i];
                          final nome =
                              item['EQUIPAMENTO']?.toString() ?? 'Equipamento';
                          final modelo = item['MODELO']?.toString() ?? '-';
                          final sala = item['SALA']?.toString() ?? 'Sem local';
                          final pat = item['PATRIMONIO']?.toString() ?? '-';
                          final setor = item['SETOR']?.toString() ?? '';
                          final motivo = item['MOTIVO']?.toString() ?? '';
                          return InkWell(
                            onTap: () => _mostrarDetalhesEquipamento(item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: Row(children: [
                                Container(
                                  width: 36 * sc,
                                  height: 36 * sc,
                                  decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(26),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.red, size: 18 * sc),
                                ),
                                SizedBox(width: 12 * sc),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(nome,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13 * sc,
                                                color: textPrimary)),
                                        SizedBox(height: 2 * sc),
                                        Text('$modelo  •  $sala',
                                            style: TextStyle(
                                                fontSize: 11 * sc,
                                                color: textSecondary)),
                                        SizedBox(height: 2 * sc),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.red.withAlpha(26),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text('PAT: $pat',
                                              style: TextStyle(
                                                  fontSize: 10 * sc,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red[700])),
                                        ),
                                        if (motivo.isNotEmpty) ...[
                                          SizedBox(height: 4 * sc),
                                          Text(motivo,
                                              style: TextStyle(
                                                  fontSize: 10 * sc,
                                                  color: Colors.orange[700],
                                                  fontStyle: FontStyle.italic),
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ]),
                                ),
                                Icon(Icons.chevron_right,
                                    color: textTertiary, size: 18 * sc),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
              Divider(height: 1, color: dividerColor),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181828) : Colors.grey[50],
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: listaFiltrada.isEmpty || isGerandoPdf
                            ? null
                            : () async {
                                setStateDialog(() {
                                  isGerandoPdf = true;
                                  pdfProgress = 0.0;
                                  pdfProgressLabel = 'Iniciando...';
                                });
                                await _gerarPdfPendentes(
                                    listaFiltrada, setStateDialog,
                                    onProgress: (v, label) async {
                                  setStateDialog(() {
                                    pdfProgress = v;
                                    pdfProgressLabel = label;
                                  });
                                });
                                setStateDialog(() {
                                  isGerandoPdf = false;
                                });
                              },
                        icon: Icon(Icons.picture_as_pdf_outlined,
                            color: listaFiltrada.isEmpty || isGerandoPdf
                                ? Colors.grey
                                : Colors.red,
                            size: 16 * sc),
                        label: Text('Baixar PDF',
                            style: TextStyle(
                                color: listaFiltrada.isEmpty || isGerandoPdf
                                    ? Colors.grey
                                    : Colors.red,
                                fontSize: 13 * sc)),
                      ),
                      TextButton(
                        onPressed:
                            isGerandoPdf ? null : () => Navigator.of(ctx).pop(),
                        child: Text('FECHAR',
                            style: TextStyle(
                                color:
                                    isGerandoPdf ? Colors.grey : primaryColor,
                                fontSize: 13 * sc)),
                      ),
                    ]),
              ),
            ]),
          ),
        );
      }),
    );
  }

  Future<List<Map<String, dynamic>>> _buscarTodasPreventivas() async {
    List<Map<String, dynamic>> listaFinal = [];
    try {
      if (widget.emailCliente.isNotEmpty) {
        final usuariosQuery = await FirebaseFirestore.instance
            .collection('USUARIOS')
            .where('email', isEqualTo: widget.emailCliente.trim())
            .limit(1)
            .get();
        if (usuariosQuery.docs.isNotEmpty)
          _dadosCliente = usuariosQuery.docs.first.data();
      }
      Query query = FirebaseFirestore.instance
          .collection('PREVENTIVAS')
          .where('EMAIL', isEqualTo: widget.emailCliente);
      if (widget.filtroAno != null && widget.filtroAno!.isNotEmpty) {
        int? anoNumber = int.tryParse(widget.filtroAno!);
        if (anoNumber != null) query = query.where('ANO', isEqualTo: anoNumber);
      }
      if (widget.filtroMes != null && widget.filtroMes!.isNotEmpty)
        query = query.where('MES', isEqualTo: widget.filtroMes);
      final querySnapshot = await query.get();
      final listaDocs = querySnapshot.docs.toList();
      listaDocs.sort((a, b) {
        DateTime? dataA, dataB;
        try {
          final d = a.data() as Map<String, dynamic>;
          dataA = (d['datacadastro'] ?? d['DATADAMANUTENCAO'])?.toDate();
        } catch (_) {}
        try {
          final d = b.data() as Map<String, dynamic>;
          dataB = (d['datacadastro'] ?? d['DATADAMANUTENCAO'])?.toDate();
        } catch (_) {}
        if (dataA == null) return 1;
        if (dataB == null) return -1;
        return dataB.compareTo(dataA);
      });
      for (var doc in listaDocs)
        listaFinal.add(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Erro ao buscar lista: $e');
    }
    return listaFinal;
  }

  Future<void> _baixarTodosPDFs(List<Map<String, dynamic>> lista) async {
    if (lista.isEmpty) return;
    setState(() {
      _isDownloadingAll = true;
      _downloadTotal = lista.length;
      _downloadCurrent = 0;
      _downloadLabel = 'Preparando...';
    });
    try {
      await _ensureAssetsLoaded();
      final pdf = pw.Document();
      pw.ImageProvider? imagemCliente;
      String nomeClienteRodape = '', cnpjClienteRodape = '';
      if (_dadosCliente != null) {
        final ud = _dadosCliente!;
        if (ud['display_name'] != null)
          nomeClienteRodape = ud['display_name'].toString().toUpperCase();
        if (ud['CNPJ'] != null)
          cnpjClienteRodape = ud['CNPJ'].toString();
        else if (ud['cnpj'] != null) cnpjClienteRodape = ud['cnpj'].toString();
        final photoUrl = ud['photo_url']?.toString().trim();
        final rCli =
            await _safeHttpGet(photoUrl, timeout: const Duration(seconds: 6));
        if (rCli.statusCode == 200)
          imagemCliente = pw.MemoryImage(rCli.bodyBytes);
      }
      final patrimonios =
          lista.map((d) => d['PATRIMONIO']?.toString() ?? '').toList();
      final imgQueries = await Future.wait(patrimonios.map((pat) async {
        if (pat.isEmpty) return null;
        try {
          return await FirebaseFirestore.instance
              .collection('IMAGENS')
              .where('PATRIMONIO', isEqualTo: pat)
              .limit(1)
              .get();
        } catch (_) {
          return null;
        }
      }));
      final List<String?> urlsEvap = [];
      final List<String?> urlsTermo = [];
      for (int i = 0; i < lista.length; i++) {
        String? evapUrl;
        final snap = imgQueries[i];
        if (snap != null && snap.docs.isNotEmpty) {
          evapUrl =
              (snap.docs.first.data() as Map)['IMAGEM']?.toString().trim();
          if (evapUrl != null && !evapUrl.startsWith('http')) evapUrl = null;
        }
        urlsEvap.add(evapUrl);
        String? termoUrl;
        final data = lista[i];
        for (String key in [
          'IMAGEM',
          'THAGEM',
          'TMAGEM',
          'FOTO',
          'foto',
          'imagem'
        ]) {
          if (data[key] != null && data[key].toString().trim().isNotEmpty) {
            termoUrl = data[key].toString().trim();
            break;
          }
        }
        if (termoUrl != null && !termoUrl.startsWith('http')) termoUrl = null;
        urlsTermo.add(termoUrl);
      }
      final allImgFutures = await Future.wait([
        ...urlsEvap
            .map((u) => _safeHttpGet(u, timeout: const Duration(seconds: 6))),
        ...urlsTermo
            .map((u) => _safeHttpGet(u, timeout: const Duration(seconds: 6))),
      ]);
      final resEvap = allImgFutures.sublist(0, lista.length);
      final resTermo = allImgFutures.sublist(lista.length);
      for (int i = 0; i < lista.length; i++) {
        final data = lista[i];
        final patrimonio = patrimonios[i];
        setState(() {
          _downloadCurrent = i + 1;
          _downloadLabel = 'Página ${i + 1}/${lista.length}';
        });
        pw.ImageProvider? imagemEvaporadora, imagemTermografia;
        if (resEvap[i].statusCode == 200)
          imagemEvaporadora = pw.MemoryImage(resEvap[i].bodyBytes);
        if (resTermo[i].statusCode == 200)
          imagemTermografia = pw.MemoryImage(resTermo[i].bodyBytes);
        String dataInicio = '';
        if ((data['datacadastro'] ?? data['DATADAMANUTENCAO']) != null) {
          final date =
              ((data['datacadastro'] ?? data['DATADAMANUTENCAO']) as Timestamp)
                  .toDate();
          dataInicio =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
        pdf.addPage(_buildPdfPage(
          data: data,
          patrimonio: patrimonio,
          dataInicio: dataInicio,
          textoObservacao: data['OBSERVACAO']?.toString().trim() ?? '',
          logoEmpresa: _cachedLogoEmpresa,
          imagemCliente: imagemCliente,
          imagemEvaporadora: imagemEvaporadora,
          imagemTermografia: imagemTermografia,
          nomeClienteRodape: nomeClienteRodape,
          cnpjClienteRodape: cnpjClienteRodape,
        ));
      }
      final pdfBytes = await pdf.save();
      if (pdfBytes.isEmpty) throw Exception('PDF geral está vazio');
      final dataAtual = DateTime.now();
      final nomeArquivo =
          'Relatorio_Geral_${widget.filtroMes ?? 'Geral'}_${dataAtual.millisecondsSinceEpoch}.pdf';
      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: nomeArquivo);
      } else {
        await Printing.layoutPdf(
            onLayout: (_) async => pdfBytes, name: nomeArquivo);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Relatório Geral baixado com sucesso!'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao gerar relatório geral.'),
          backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isDownloadingAll = false;
        _downloadCurrent = 0;
        _downloadTotal = 0;
        _downloadLabel = '';
      });
    }
  }

  Widget _badgeWidget(String text, Color bg, Color fg,
      {bool showIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: showIcon
            ? [
                const BoxShadow(
                    color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
              ]
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(text,
            style: TextStyle(
                fontSize: 11 * sc, fontWeight: FontWeight.bold, color: fg)),
        if (showIcon) ...[
          SizedBox(width: 4 * sc),
          Icon(Icons.visibility, size: 12 * sc, color: fg)
        ],
      ]),
    );
  }

  Widget _buildResumoPendentes(List<Map<String, dynamic>> listaCompleta,
      String searchTerm, int resultCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final cardBorder =
        isDark ? Colors.white.withAlpha(31) : Colors.grey.shade200;
    const primaryColor = Color(0xFF64B5F6);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary =
        isDark ? Colors.white.withAlpha(138) : Colors.grey[600]!;
    final searchFill = isDark ? const Color(0xFF2A2A3E) : Colors.grey[100]!;
    final searchBorder =
        isDark ? Colors.white.withAlpha(31) : Colors.grey.shade300;

    if (_loadingPendentes) {
      return Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cardBorder)),
        child: Row(children: [
          SizedBox(
              width: 12 * sc,
              height: 12 * sc,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: primaryColor)),
          SizedBox(width: 8 * sc),
          Text('Calculando...',
              style: TextStyle(fontSize: 12 * sc, color: textSecondary)),
        ]),
      );
    }

    final pct = _totalEquip > 0 ? _totalFeitos / _totalEquip : 0.0;

    Widget downloadBtn = _isDownloadingAll
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: 11 * sc,
                height: 11 * sc,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: primaryColor)),
            SizedBox(width: 5 * sc),
            Text('$_downloadCurrent/$_downloadTotal',
                style: TextStyle(
                    fontSize: 11 * sc,
                    color: primaryColor,
                    fontWeight: FontWeight.bold)),
          ])
        : GestureDetector(
            onTap: () => _baixarTodosPDFs(listaCompleta),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.download_rounded,
                    color: Colors.white, size: 14 * sc),
                SizedBox(width: 5 * sc),
                Text('PDF completo',
                    style: TextStyle(
                        fontSize: 11 * sc,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          );

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 12),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          child: Row(children: [
            if (_totalEquip > 0) ...[
              _badgeWidget('$_totalEquip total', primaryColor, Colors.white),
              const SizedBox(width: 5),
              _badgeWidget('$_totalFeitos feitos', Colors.green, Colors.white),
              const SizedBox(width: 5),
              InkWell(
                onTap: _totalPendentes > 0 ? _mostrarPendentesDialog : null,
                borderRadius: BorderRadius.circular(20),
                child: _badgeWidget(
                  '$_totalPendentes pend.',
                  _totalPendentes > 0 ? Colors.red : Colors.green,
                  Colors.white,
                  showIcon: _totalPendentes > 0,
                ),
              ),
            ],
            const Spacer(),
            downloadBtn,
          ]),
        ),
        if (_totalEquip > 0) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.toDouble(),
                minHeight: 4,
                backgroundColor: Colors.red.withAlpha(30),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
            child: Text('${(pct * 100).toStringAsFixed(0)}% concluído',
                style: TextStyle(fontSize: 10 * sc, color: textSecondary)),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchTopController,
                style: TextStyle(fontSize: 13 * sc, color: textPrimary),
                onChanged: (v) =>
                    setState(() => _searchTopTerm = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Buscar equipamento, patrimônio...',
                  hintStyle: TextStyle(fontSize: 12 * sc, color: textSecondary),
                  prefixIcon:
                      Icon(Icons.search, color: primaryColor, size: 18 * sc),
                  suffixIcon: _searchTopTerm.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              size: 15 * sc,
                              color: isDark ? Colors.white38 : Colors.grey),
                          onPressed: () => setState(() {
                                _searchTopController.clear();
                                _searchTopTerm = '';
                              }))
                      : null,
                  filled: true,
                  fillColor: searchFill,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: searchBorder, width: 1)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: searchBorder, width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 1.5)),
                ),
              ),
            ),
            if (searchTerm.isNotEmpty) ...[
              SizedBox(width: 8 * sc),
              Text('$resultCount',
                  style: TextStyle(fontSize: 11 * sc, color: textSecondary)),
            ],
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121218) : Colors.grey[100]!;
    const primaryColor = Color(0xFF64B5F6);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: scaffoldBg,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _listaPreventivasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: primaryColor));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Erro ao carregar dados: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64 * sc,
                          color: isDark
                              ? Colors.white.withAlpha(61)
                              : Colors.grey),
                      SizedBox(height: 16 * sc),
                      Text('Nenhuma preventiva encontrada.',
                          style: TextStyle(
                              fontSize: 16 * sc,
                              color: isDark
                                  ? Colors.white.withAlpha(138)
                                  : Colors.grey[700])),
                    ]),
              );
            }

            final listaCompleta = snapshot.data!;
            final lista = _searchTopTerm.isEmpty
                ? listaCompleta
                : listaCompleta.where((item) {
                    final equip =
                        (item['EQUIPAMENTO'] ?? '').toString().toLowerCase();
                    final pat =
                        (item['PATRIMONIO'] ?? '').toString().toLowerCase();
                    final setor =
                        (item['SETOR'] ?? '').toString().toLowerCase();
                    final sala = (item['SALA'] ?? '').toString().toLowerCase();
                    final modelo =
                        (item['MODELO'] ?? '').toString().toLowerCase();
                    return equip.contains(_searchTopTerm) ||
                        pat.contains(_searchTopTerm) ||
                        setor.contains(_searchTopTerm) ||
                        sala.contains(_searchTopTerm) ||
                        modelo.contains(_searchTopTerm);
                  }).toList();

            return Column(children: [
              _buildResumoPendentes(
                  listaCompleta, _searchTopTerm, lista.length),
              if (_isDownloadingAll)
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor, width: 1),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                SizedBox(
                                    width: 14 * sc,
                                    height: 14 * sc,
                                    child: const CircularProgressIndicator(
                                        color: primaryColor, strokeWidth: 2)),
                                SizedBox(width: 8 * sc),
                                Text('Gerando relatório completo',
                                    style: TextStyle(
                                        fontSize: 12 * sc,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor)),
                              ]),
                              Text('$_downloadCurrent / $_downloadTotal',
                                  style: TextStyle(
                                      fontSize: 12 * sc,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white.withAlpha(138)
                                          : Colors.black54)),
                            ]),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _downloadTotal > 0
                                ? _downloadCurrent / _downloadTotal
                                : 0,
                            minHeight: 5,
                            backgroundColor: isDark
                                ? Colors.white.withAlpha(31)
                                : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                primaryColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_downloadLabel,
                            style: TextStyle(
                                fontSize: 11 * sc,
                                color: isDark
                                    ? Colors.white.withAlpha(97)
                                    : Colors.grey[600]),
                            overflow: TextOverflow.ellipsis),
                      ]),
                ),
              if (_searchTopTerm.isNotEmpty && lista.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48 * sc,
                              color: isDark
                                  ? Colors.white.withAlpha(61)
                                  : Colors.grey[400]),
                          SizedBox(height: 12 * sc),
                          Text('Nenhum resultado para "$_searchTopTerm"',
                              style: TextStyle(
                                  fontSize: 14 * sc,
                                  color: isDark
                                      ? Colors.white.withAlpha(138)
                                      : Colors.grey[600])),
                        ]),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final pat = lista[index]['PATRIMONIO']?.toString() ??
                          index.toString();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ReportCard(
                          key: ValueKey(pat),
                          preventiva: lista[index],
                          cliente: _dadosCliente ?? {},
                          emailCliente: widget.emailCliente,
                          filtroAno: widget.filtroAno,
                          filtroMes: widget.filtroMes,
                        ),
                      );
                    },
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _ReportCard
// ─────────────────────────────────────────────────────────────────────────────
class _ReportCard extends StatefulWidget {
  final Map<String, dynamic> preventiva;
  final Map<String, dynamic> cliente;
  final String emailCliente;
  final String? filtroAno;
  final String? filtroMes;

  const _ReportCard(
      {Key? key,
      required this.preventiva,
      required this.cliente,
      required this.emailCliente,
      this.filtroAno,
      this.filtroMes})
      : super(key: key);

  @override
  __ReportCardState createState() => __ReportCardState();
}

class __ReportCardState extends State<_ReportCard> {
  String imgEvaporadora = '';
  String imgTermografia = '';
  bool loadingImages = true;
  bool isGeneratingPdf = false;
  double _pdfProgress = 0.0;
  String _pdfProgressLabel = '';

  // Escala responsiva para aumentar a fonte no modo Web / Desktop
  double get sc =>
      (kIsWeb && MediaQuery.of(context).size.width > 800) ? 1.35 : 1.0;

  @override
  void initState() {
    super.initState();
    _carregarImagens();
  }

  Future<void> _carregarImagens() async {
    final data = widget.preventiva;
    final patrimonio = data['PATRIMONIO']?.toString() ?? '';
    if (patrimonio.isNotEmpty) {
      try {
        final q = await FirebaseFirestore.instance
            .collection('IMAGENS')
            .where('PATRIMONIO', isEqualTo: patrimonio)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty)
          imgEvaporadora =
              q.docs.first.data()['IMAGEM']?.toString().trim() ?? '';
      } catch (_) {}
    }
    for (String key in [
      'IMAGEM',
      'THAGEM',
      'TMAGEM',
      'FOTO',
      'foto',
      'imagem'
    ]) {
      if (data.containsKey(key) &&
          data[key] != null &&
          data[key].toString().trim().isNotEmpty) {
        imgTermografia = data[key].toString().trim();
        break;
      }
    }
    if (mounted) setState(() => loadingImages = false);
  }

  String _fmtDate(dynamic ts) {
    if (ts == null) return '';
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return '';
  }

  String _ok(dynamic v) =>
      (v == true || v?.toString().toLowerCase() == 'true') ? 'OK' : '';

  String _okM(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v == true || v?.toString().toLowerCase() == 'true') return 'OK';
    }
    return '';
  }

  void _setProgress(double value, String label) {
    if (mounted)
      setState(() {
        _pdfProgress = value;
        _pdfProgressLabel = label;
      });
  }

  // ── SEÇÃO: helpers de UI ──────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, Color color,
      {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(35) : color.withAlpha(18),
        border:
            Border(bottom: BorderSide(color: color.withAlpha(60), width: 0.8)),
      ),
      child: Row(children: [
        Container(
          width: 18 * sc,
          height: 18 * sc,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: Colors.white, size: 10 * sc),
        ),
        SizedBox(width: 6 * sc),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 10 * sc,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.2)),
        ),
      ]),
    );
  }

  Widget _infoField(String label, String value,
      {Color? valueColor, bool isDark = false}) {
    final labelCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueCol = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8 * sc,
              fontWeight: FontWeight.w600,
              color: labelCol,
            ),
          ),
          SizedBox(width: 6 * sc),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 9 * sc,
                fontWeight: FontWeight.w700,
                color: valueColor ?? valueCol,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider({bool isDark = false}) => Divider(
      height: 1,
      thickness: 0.5,
      color: isDark ? const Color(0xFF252540) : const Color(0xFFF1F5F9),
      indent: 8,
      endIndent: 8);

  Widget _checkRow(String num, String label, String status,
      {bool isVal = false, bool isDark = false}) {
    const accent = Color(0xFF64B5F6);
    const okGreen = Color(0xFF059669);
    final isOk = status == 'OK';
    final hasVal = isVal && status.isNotEmpty;
    final divCol = isDark ? const Color(0xFF252540) : const Color(0xFFF1F5F9);
    final chipBg = isDark ? const Color(0xFF252540) : const Color(0xFFF8FAFC);
    final borderCol =
        isDark ? const Color(0xFF2D2D45) : const Color(0xFFE2E8F0);
    final okBg = isDark ? const Color(0xFF052E16) : const Color(0xFFD1FAE5);
    final valueCol = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final labelCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: divCol, width: 0.5))),
      child: Row(children: [
        Container(
          width: 16 * sc,
          height: 16 * sc,
          decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderCol, width: 0.5)),
          child: Center(
              child: Text(num,
                  style: TextStyle(
                      fontSize: 9 * sc,
                      fontWeight: FontWeight.w700,
                      color: labelCol))),
        ),
        SizedBox(width: 4 * sc),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 10.5 * sc, color: valueCol, height: 1.1))),
        SizedBox(width: 2 * sc),
        if (isOk)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
                color: okBg, borderRadius: BorderRadius.circular(20)),
            child: Text('OK',
                style: TextStyle(
                    fontSize: 6 * sc,
                    fontWeight: FontWeight.w800,
                    color: okGreen)),
          )
        else if (hasVal)
          Container(
            constraints: BoxConstraints(minWidth: 20 * sc),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
                color: isDark ? accent.withAlpha(40) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(status,
                    style: TextStyle(
                        fontSize: 7 * sc,
                        fontWeight: FontWeight.w800,
                        color: accent))),
          )
        else
          SizedBox(
              width: 16 * sc,
              child: Center(
                  child: Text('—',
                      style: TextStyle(fontSize: 9 * sc, color: borderCol)))),
      ]),
    );
  }

  Widget _card(
      {required Widget child, EdgeInsets? margin, bool isDark = false}) {
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderCol =
        isDark ? const Color(0xFF2D2D45) : const Color(0xFFE2E8F0);
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: child,
      ),
    );
  }

  void _openFullscreen(String url) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                      color: Colors.white54, size: 64)),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _imageBox(String url, {required double height, bool isDark = false}) {
    final borderCol =
        isDark ? const Color(0xFF2D2D45) : const Color(0xFFE2E8F0);
    final emptyCol = isDark ? Colors.white24 : const Color(0xFFCBD5E1);
    final bgCol = isDark ? const Color(0xFF13131F) : const Color(0xFFF8FAFC);

    return GestureDetector(
      onTap: () => _openFullscreen(url),
      child: Container(
        height: height * sc,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderCol, width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(children: [
            SizedBox.expand(
              child: loadingImages
                  ? Center(
                      child: SizedBox(
                          width: 20 * sc,
                          height: 20 * sc,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF64B5F6))))
                  : url.isNotEmpty
                      ? Image.network(url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.broken_image,
                                  size: 28 * sc, color: emptyCol)))
                      : Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Icon(Icons.image_not_supported_outlined,
                                  size: 28 * sc, color: emptyCol),
                              SizedBox(height: 6 * sc),
                              Text('SEM IMAGEM',
                                  style: TextStyle(
                                      fontSize: 10 * sc,
                                      fontWeight: FontWeight.w500,
                                      color: emptyCol)),
                            ])),
            ),
            if (!loadingImages && url.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.fullscreen,
                      color: Colors.white, size: 14 * sc),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prev = widget.preventiva;
    final cli = widget.cliente;

    const accent = Color(0xFF64B5F6);
    const amber = Color(0xFFD97706);
    const purple = Color(0xFF6D28D9);
    final pageBg = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF1F5F9);
    final borderCol =
        isDark ? const Color(0xFF2D2D45) : const Color(0xFFE2E8F0);
    final labelCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueCol = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final chipBg = isDark ? const Color(0xFF252540) : const Color(0xFFF8FAFC);

    final nomeCliente =
        cli['display_name']?.toString().toUpperCase() ?? 'CLIENTE';
    final cnpjCliente = (cli['CNPJ'] ?? cli['cnpj'] ?? '').toString();
    final observacao = prev['OBSERVACAO']?.toString().trim() ?? '';
    final tecnico = prev['TECNICORESPONSAVEL']?.toString() ?? '';
    final dataManutencao =
        _fmtDate(prev['datacadastro'] ?? prev['DATADAMANUTENCAO']);

    final pat = prev['PATRIMONIO']?.toString() ?? '';
    final equip =
        prev['EQUIPAMENTO']?.toString() ?? prev['MODELO']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D45) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── CABEÇALHO AZUL COM BOTÃO PDF ──────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF64B5F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (pat.isNotEmpty)
                      Text('PAT $pat',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10 * sc,
                              fontWeight: FontWeight.bold)),
                    if (equip.isNotEmpty)
                      Text('• $equip',
                          style: TextStyle(
                              color: Colors.white, fontSize: 10 * sc)),
                    if (dataManutencao.isNotEmpty)
                      Text('• $dataManutencao',
                          style:
                              TextStyle(color: Colors.white, fontSize: 9 * sc)),
                  ],
                ),
              ),
              InkWell(
                onTap: isGeneratingPdf
                    ? null
                    : () async {
                        setState(() {
                          isGeneratingPdf = true;
                          _pdfProgress = 0.0;
                          _pdfProgressLabel = 'Iniciando...';
                        });
                        try {
                          final patrimonio =
                              prev['PATRIMONIO']?.toString() ?? '';
                          await _gerarPDFViewer(patrimonio, widget.emailCliente,
                              filtroAno: widget.filtroAno,
                              filtroMes: widget.filtroMes,
                              onProgress: _setProgress);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('PDF baixado com sucesso!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2)));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Erro ao gerar PDF: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3)));
                          }
                        } finally {
                          if (mounted)
                            setState(() {
                              isGeneratingPdf = false;
                              _pdfProgress = 0.0;
                              _pdfProgressLabel = '';
                            });
                        }
                      },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    border: Border.all(
                        color: Colors.white.withAlpha(80), width: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isGeneratingPdf
                      ? SizedBox(
                          width: 12 * sc,
                          height: 12 * sc,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.picture_as_pdf_rounded,
                                color: Colors.white, size: 12 * sc),
                            SizedBox(width: 4 * sc),
                            Text('PDF',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10 * sc,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),

        // ── PROGRESS BAR DO PDF ────────────────────────────────────────────
        if (isGeneratingPdf)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: const Color(0xFF64B5F6).withAlpha(20),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _pdfProgress,
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                SizedBox(width: 8 * sc),
                Text('${(_pdfProgress * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 9 * sc,
                        color: accent,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

        // ── CORPO DO RELATÓRIO ─────────────────────────────────────────────
        Container(
          color: pageBg,
          padding: const EdgeInsets.all(6),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── 1. CABEÇALHO ───────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  SizedBox(
                    width: 70 * sc,
                    height: 36 * sc,
                    child: Image.network(
                      'https://i.ibb.co/VpqNsxXt/Imagem1.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text('HPS REFRIGERAÇÃO',
                          style: TextStyle(
                              fontSize: 9 * sc,
                              fontWeight: FontWeight.bold,
                              color: accent)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? accent.withAlpha(40)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accent.withAlpha(50)),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('DATA DA MANUTENÇÃO',
                                style: TextStyle(
                                    fontSize: 8 * sc,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(dataManutencao.isEmpty ? '—' : dataManutencao,
                                style: TextStyle(
                                    fontSize: 12 * sc,
                                    fontWeight: FontWeight.w800,
                                    color: accent)),
                            if ((prev['TIPOMANUTENCAO'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                    prev['TIPOMANUTENCAO']
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 8 * sc,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ],
                          ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      width: 40 * sc,
                      height: 40 * sc,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol, width: 0.8),
                        color: chipBg,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (cli['photo_url'] != null &&
                                cli['photo_url'].toString().startsWith('http'))
                            ? Image.network(cli['photo_url'].toString(),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Center(
                                    child: Icon(Icons.business,
                                        size: 20 * sc, color: labelCol)))
                            : Center(
                                child: Icon(Icons.business,
                                    size: 20 * sc, color: labelCol)),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),

            // ── 2. IDENTIFICAÇÃO ───────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader('IDENTIFICAÇÃO DO EQUIPAMENTO',
                        Icons.devices_rounded, accent,
                        isDark: isDark),
                    const SizedBox(height: 2),
                    Builder(builder: (ctx) {
                      final fields1 = [
                        _infoField(
                            'APARELHO', prev['EQUIPAMENTO']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField('MODELO', prev['MODELO']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField('TIPO', prev['TIPO']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField(
                            'FABRICANTE', prev['MARCA']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField(
                            'PATRIMÔNIO', prev['PATRIMONIO']?.toString() ?? '—',
                            valueColor: accent, isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField('TÉCNICO', tecnico, isDark: isDark),
                      ];
                      final fields2 = [
                        _infoField(
                            'VOLTAGEM', prev['TENSAO']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField('GÁS', prev['FLUIDO']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField('POTÊNCIA', prev['BTUS']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField('PRÉDIO', prev['SETOR']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField(
                            'LOCALIZAÇÃO', prev['SALA']?.toString() ?? '—',
                            isDark: isDark),
                        _divider(isDark: isDark),
                        _infoField(
                            'MANUTENÇÃO',
                            prev['TIPOMANUTENCAO']?.toString() ??
                                prev['DESCRICAODOSERVICO']?.toString() ??
                                '—',
                            isDark: isDark),
                      ];
                      return IntrinsicHeight(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Column(children: fields1)),
                              Container(
                                  width: 0.8,
                                  color: isDark
                                      ? const Color(0xFF252540)
                                      : const Color(0xFFF1F5F9)),
                              Expanded(child: Column(children: fields2)),
                            ]),
                      );
                    }),
                    const SizedBox(height: 4),
                  ]),
            ),

            // ── 3. IMAGENS ─────────────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: _card(
                  isDark: isDark,
                  margin: const EdgeInsets.only(bottom: 8, right: 4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionHeader(
                            'EVAPORADORA', Icons.camera_alt_rounded, accent,
                            isDark: isDark),
                        _imageBox(imgEvaporadora, height: 140, isDark: isDark),
                      ]),
                ),
              ),
              Expanded(
                child: _card(
                  isDark: isDark,
                  margin: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionHeader(
                            'TERMOGRAFIA', Icons.thermostat_rounded, amber,
                            isDark: isDark),
                        _imageBox(imgTermografia, height: 140, isDark: isDark),
                      ]),
                ),
              ),
            ]),

            // ── 4. VERIFICAÇÕES ────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                        'VERIFICAÇÕES', Icons.checklist_rounded, accent,
                        isDark: isDark),
                    Builder(builder: (ctx) {
                      final col1 = [
                        _checkRow('1', 'Limpeza evaporadora interna',
                            _ok(prev['LIMPEZAEVAPORADORAINTERNA']),
                            isDark: isDark),
                        _checkRow('2', 'Limpeza do filtro',
                            _ok(prev['LIMPEZAFILTRO']),
                            isDark: isDark),
                        _checkRow('3', 'Limpeza com bactericida',
                            _ok(prev['LIMPEZABACTERICIDA']),
                            isDark: isDark),
                        _checkRow(
                            '4',
                            'Controle e pilhas',
                            _okM(prev, [
                              'VERIFICAODOCONTROLPILHAS',
                              'VERIFICADOCONTROLPILHAS'
                            ]),
                            isDark: isDark),
                        _checkRow(
                            '5',
                            'Verificar ruídos',
                            _okM(prev,
                                ['VERIFICAODERUIDOS', 'VERIFICADODERUIDOS']),
                            isDark: isDark),
                        _checkRow(
                            '6',
                            'Verificar mal cheiro',
                            _okM(prev,
                                ['VERIFICAOMALCHEIRO', 'VERIFICACAOMALCHEIRO']),
                            isDark: isDark),
                        _checkRow('7', 'Corrente (A)',
                            prev['AMPERAGEM']?.toString() ?? '',
                            isVal: true, isDark: isDark),
                        _checkRow(
                            '8', 'Tensão (V)', prev['TENSAO']?.toString() ?? '',
                            isVal: true, isDark: isDark),
                        _checkRow('9', 'Verificar dreno',
                            _okM(prev, ['VERIFICAODODRENO', 'VERIFICADODRENO']),
                            isDark: isDark),
                        _checkRow(
                            '10',
                            'Verificar pressão (PSI)',
                            _okM(prev,
                                ['VERIFICAODAPRESSAO', 'VERIFICADAPRESSAO']),
                            isDark: isDark),
                        _checkRow('11', 'Polir condensadora',
                            _ok(prev['POLIRCONDENSADORA']),
                            isDark: isDark),
                      ];
                      final col2 = [
                        _checkRow(
                            '12',
                            'Parte elétrica',
                            _okM(prev, [
                              'VERIFICAODAPARTEELETRICA',
                              'VERIFICADAPARTEELETRICA'
                            ]),
                            isDark: isDark),
                        _checkRow(
                            '13',
                            'Isolamento térmico',
                            _okM(prev, [
                              'VERIFICAODOISOLAMENTOTRMICO',
                              'VERIFICADOISOLAMENTOTRMICO'
                            ]),
                            isDark: isDark),
                        _checkRow('14', 'Jateamento condensadora',
                            _ok(prev['JATEAMENTOCONDENSADORA']),
                            isDark: isDark),
                        _checkRow('15', 'Jateamento evaporadora',
                            _ok(prev['JATEAMENTOEVAPORADORA']),
                            isDark: isDark),
                        _checkRow(
                            '16', 'Lavagem do dreno', _ok(prev['LAVAGEMDRENO']),
                            isDark: isDark),
                        _checkRow('17', 'Carcaça evaporadora',
                            _ok(prev['LAVAGEMCARCACAEVAP']),
                            isDark: isDark),
                        _checkRow('18', 'Carcaça condensadora',
                            _ok(prev['LAVAGEMCARCACACOND']),
                            isDark: isDark),
                        _checkRow('19', 'Limpeza do compressor',
                            _ok(prev['LIMPEZACOMPRESSOR']),
                            isDark: isDark),
                        _checkRow('20', 'Turbina evaporadora',
                            _ok(prev['LAVAGEMTURBINAEVAP']),
                            isDark: isDark),
                        _checkRow(
                            '21',
                            'Pés de borracha',
                            _okM(prev, [
                              'VERIFICAODOSPEDEBORRACHA',
                              'VERIFICADOSPEDEBORRACHA'
                            ]),
                            isDark: isDark),
                      ];
                      return IntrinsicHeight(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Column(children: col1)),
                              Container(
                                  width: 0.8,
                                  color: isDark
                                      ? const Color(0xFF252540)
                                      : const Color(0xFFF1F5F9)),
                              Expanded(child: Column(children: col2)),
                            ]),
                      );
                    }),
                    const SizedBox(height: 4),
                  ]),
            ),

            // ── 5. SERVIÇOS REALIZADOS ─────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                        'SERVIÇOS REALIZADOS', Icons.build_rounded, purple,
                        isDark: isDark),
                    _checkRow('1', 'Higienização bactericida', 'OK',
                        isDark: isDark),
                    _checkRow('2', 'Lavar/secar filtros', 'OK', isDark: isDark),
                    _checkRow('3', 'Medir tensão elétrica', 'OK',
                        isDark: isDark),
                    _checkRow('4', 'Medir corrente elétrica', 'OK',
                        isDark: isDark),
                    _checkRow('5', 'Limpar carenagem da evap.', 'OK',
                        isDark: isDark),
                    _checkRow('6', 'Verificar ruídos/vazamentos', 'OK',
                        isDark: isDark),
                    const SizedBox(height: 4),
                  ]),
            ),

            // ── 6. OBSERVAÇÕES ─────────────────────────────────────────────
            if (observacao.isNotEmpty)
              _card(
                isDark: isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionHeader(
                          'INFORMAÇÕES ADICIONAIS', Icons.notes_rounded, purple,
                          isDark: isDark),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(observacao,
                            style: TextStyle(
                                fontSize: 11 * sc,
                                color: isDark
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFF0F172A),
                                height: 1.4)),
                      ),
                    ]),
              ),

            // ── 7. RODAPÉ ──────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol, width: 0.8),
              ),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('HPS REFRIGERAÇÃO',
                          style: TextStyle(
                              fontSize: 10 * sc,
                              fontWeight: FontWeight.w800,
                              color: valueCol)),
                      const SizedBox(height: 2),
                      Text('CNPJ: 28.340.152/0001-52',
                          style: TextStyle(fontSize: 9 * sc, color: labelCol)),
                      Text('(77) 98819-4630 / 98861-2447',
                          style: TextStyle(fontSize: 9 * sc, color: labelCol)),
                    ])),
                Container(
                  width: 0.8,
                  height: 50 * sc,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: borderCol,
                ),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        nomeCliente.length > 20
                            ? '${nomeCliente.substring(0, 20)}...'
                            : nomeCliente,
                        style: TextStyle(
                            fontSize: 11 * sc,
                            fontWeight: FontWeight.w700,
                            color: valueCol),
                      ),
                      if (cnpjCliente.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('CNPJ: $cnpjCliente',
                            style:
                                TextStyle(fontSize: 9 * sc, color: labelCol)),
                      ],
                    ])),
              ]),
            ),
          ]),
        ),

        // ── FOOTER AZUL ───────────────────────────────────────────────────
        Container(
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF64B5F6),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PDF helpers
// ─────────────────────────────────────────────────────────────────────────────
pw.Page _buildPdfPage({
  required Map<String, dynamic> data,
  required String patrimonio,
  required String dataInicio,
  required String textoObservacao,
  pw.ImageProvider? logoEmpresa,
  pw.ImageProvider? imagemCliente,
  pw.ImageProvider? imagemEvaporadora,
  pw.ImageProvider? imagemTermografia,
  required String nomeClienteRodape,
  required String cnpjClienteRodape,
}) {
  const cBlue = PdfColor.fromInt(0xFF64B5F6);
  const cBlueDk = PdfColor.fromInt(0xFF42A5F5);
  const cBlueSoft = PdfColor.fromInt(0xFFE3F2FD);
  const cGrey100 = PdfColor.fromInt(0xFFEEF2F7);
  const cGrey200 = PdfColor.fromInt(0xFFE2E8F0);
  const cGrey600 = PdfColor.fromInt(0xFF64748B);
  const cGrey800 = PdfColor.fromInt(0xFF1E293B);
  const cOk = PdfColor.fromInt(0xFF16A34A);
  const cOkBg = PdfColor.fromInt(0xFFDCFCE7);

  pw.TextStyle bold(double sz, {PdfColor? c}) => pw.TextStyle(
      fontSize: sz, fontWeight: pw.FontWeight.bold, color: c ?? cGrey800);
  pw.TextStyle norm(double sz, {PdfColor? c}) =>
      pw.TextStyle(fontSize: sz, color: c ?? cGrey800);

  pw.Widget secHdr(String t) => pw.Container(
        width: double.infinity,
        color: cBlue,
        padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.4)),
      );

  pw.TableRow identRow(String l1, dynamic v1, String l2, dynamic v2) =>
      pw.TableRow(children: [
        pw.Container(
            color: cGrey100,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(l1, style: bold(6.5, c: cGrey600))),
        pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(v1?.toString() ?? '-', style: norm(6.5))),
        pw.Container(
            color: cGrey100,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(l2, style: bold(6.5, c: cGrey600))),
        pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            child: pw.Text(v2?.toString() ?? '-', style: norm(6.5))),
      ]);

  pw.Widget chkItem(String n, String lbl, dynamic v, {bool isVal = false}) {
    final ok = v == true || v?.toString().toLowerCase() == 'true';
    final val = v?.toString() ?? '';
    final showOk = !isVal && ok;
    final showVal = isVal &&
        val.isNotEmpty &&
        val != 'null' &&
        val != 'true' &&
        val != 'false';
    return pw.Container(
      decoration: pw.BoxDecoration(
          border:
              pw.Border(bottom: pw.BorderSide(width: 0.3, color: cGrey200))),
      child: pw.Row(children: [
        pw.Container(
            width: 16,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
            child: pw.Text(n, style: norm(6, c: cGrey600))),
        pw.Container(width: 0.3, color: cGrey200),
        pw.Expanded(
            child: pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
                child: pw.Text(lbl, style: norm(6.5)))),
        pw.Container(width: 0.3, color: cGrey200),
        pw.Container(
          width: 28,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
          child: showOk
              ? pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: pw.BoxDecoration(
                      color: cOkBg, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Text('OK', style: bold(6, c: cOk)))
              : showVal
                  ? pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: pw.BoxDecoration(
                          color: cBlueSoft,
                          borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Text(val, style: bold(6, c: cBlueDk)))
                  : pw.Text('-', style: norm(6, c: cGrey600)),
        ),
      ]),
    );
  }

  pw.Widget imgBox(pw.ImageProvider? img) => img != null
      ? pw.Image(img, fit: pw.BoxFit.cover)
      : pw.Center(child: pw.Text('SEM IMAGEM', style: norm(7, c: cGrey600)));

  pw.Widget bordered(pw.Widget child) => pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.4, color: cGrey200)),
        child: child,
      );

  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(14),
    build: (pw.Context ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        bordered(pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: logoEmpresa != null
                    ? pw.Container(
                        width: 70,
                        height: 32,
                        child: pw.Image(logoEmpresa, fit: pw.BoxFit.contain))
                    : pw.Text('HPS REFRIGERAÇÃO', style: bold(9, c: cBlue))),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('DATA DA MANUTENÇÃO', style: bold(6, c: cBlue)),
                  pw.SizedBox(height: 2),
                  pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: pw.BoxDecoration(
                          color: cBlueSoft,
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(width: 0.5, color: cBlue)),
                      child: pw.Text(dataInicio.isEmpty ? '-' : dataInicio,
                          style: bold(10, c: cBlueDk))),
                ]),
            pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      imagemCliente != null
                          ? pw.Container(
                              width: 38,
                              height: 38,
                              child: pw.Image(imagemCliente,
                                  fit: pw.BoxFit.contain))
                          : pw.Container(
                              width: 38,
                              height: 38,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      width: 0.4, color: cGrey200)),
                              child: pw.Center(
                                  child:
                                      pw.Text('Sem Logo', style: norm(5.5)))),
                    ])),
          ],
        )),
        pw.SizedBox(height: 4),
        bordered(pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              secHdr('IDENTIFICAÇÃO'),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(width: 0.3, color: cGrey200),
                  verticalInside: pw.BorderSide(width: 0.3, color: cGrey200),
                ),
                columnWidths: const {
                  0: pw.FixedColumnWidth(70),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(70),
                  3: pw.FlexColumnWidth(),
                },
                children: [
                  identRow('APARELHO:', data['EQUIPAMENTO'] ?? '-', 'VOLTAGEM:',
                      data['TENSAO'] ?? '-'),
                  identRow('MODELO:', data['MODELO'] ?? '-', 'GÁS:',
                      data['FLUIDO'] ?? '-'),
                  identRow('TIPO:', data['TIPO'] ?? '-', 'POTÊNCIA:',
                      data['BTUS'] ?? '-'),
                  identRow('FABRICANTE:', data['MARCA'] ?? '-', 'PRÉDIO:',
                      data['SETOR']?.toString() ?? '-'),
                  identRow('PATRIMÔNIO:', patrimonio, 'LOCALIZAÇÃO:',
                      data['SALA'] ?? '-'),
                  identRow(
                      'TÉCNICO:',
                      data['TECNICORESPONSAVEL'] ?? '-',
                      'MANUTENÇÃO:',
                      data['TIPOMANUTENCAO'] ??
                          data['DESCRICAODOSERVICO']?.toString() ??
                          '-'),
                ],
              ),
            ])),
        pw.SizedBox(height: 4),
        pw.SizedBox(
            height: 190,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                    flex: 4,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('EVAPORADORA'),
                        pw.Expanded(child: imgBox(imagemEvaporadora)),
                      ],
                    ))),
                pw.SizedBox(width: 4),
                pw.Expanded(
                    flex: 6,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('CONDIÇÃO E VERIFICAÇÃO'),
                        chkItem('1', 'Limpeza evaporadora interna',
                            data['LIMPEZAEVAPORADORAINTERNA']),
                        chkItem(
                            '2', 'Limpeza do filtro', data['LIMPEZAFILTRO']),
                        chkItem('3', 'Limpeza com bactericida',
                            data['LIMPEZABACTERICIDA']),
                        chkItem(
                            '4',
                            'Controle e pilhas',
                            data['VERIFICAODOCONTROLPILHAS'] ??
                                data['VERIFICADOCONTROLPILHAS']),
                        chkItem(
                            '5',
                            'Verificar ruídos',
                            data['VERIFICAODERUIDOS'] ??
                                data['VERIFICADODERUIDOS']),
                        chkItem(
                            '6',
                            'Verificar mal cheiro',
                            data['VERIFICAOMALCHEIRO'] ??
                                data['VERIFICACAOMALCHEIRO']),
                        chkItem('7', 'Corrente elétrica (A)', data['AMPERAGEM'],
                            isVal: true),
                        chkItem('8', 'Tensão elétrica (V)', data['TENSAO'],
                            isVal: true),
                      ],
                    ))),
              ],
            )),
        pw.SizedBox(height: 4),
        pw.SizedBox(
            height: 215,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                    flex: 4,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('TERMOGRAFIA'),
                        pw.Expanded(child: imgBox(imagemTermografia)),
                      ],
                    ))),
                pw.SizedBox(width: 4),
                pw.Expanded(
                    flex: 6,
                    child: bordered(pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        secHdr('VERIFICAÇÕES'),
                        chkItem(
                            '1',
                            'Verificar dreno',
                            data['VERIFICAODODRENO'] ??
                                data['VERIFICADODRENO']),
                        chkItem(
                            '2',
                            'Verificar pressão (PSI)',
                            data['VERIFICAODAPRESSAO'] ??
                                data['VERIFICADAPRESSAO']),
                        chkItem('3', 'Polir condensadora',
                            data['POLIRCONDENSADORA']),
                        chkItem(
                            '4',
                            'Parte elétrica',
                            data['VERIFICAODAPARTEELETRICA'] ??
                                data['VERIFICADAPARTEELETRICA']),
                        chkItem(
                            '5',
                            'Isolamento térmico',
                            data['VERIFICAODOISOLAMENTOTRMICO'] ??
                                data['VERIFICADOISOLAMENTOTRMICO']),
                        chkItem('6', 'Jateamento condensadora',
                            data['JATEAMENTOCONDENSADORA']),
                        chkItem('7', 'Jateamento evaporadora',
                            data['JATEAMENTOEVAPORADORA']),
                        chkItem('8', 'Lavagem do dreno', data['LAVAGEMDRENO']),
                        chkItem('9', 'Carcaça evaporadora',
                            data['LAVAGEMCARCACAEVAP']),
                        chkItem('10', 'Carcaça condensadora',
                            data['LAVAGEMCARCACACOND']),
                        chkItem('11', 'Limpeza do compressor',
                            data['LIMPEZACOMPRESSOR']),
                        chkItem('12', 'Turbina evaporadora',
                            data['LAVAGEMTURBINAEVAP']),
                        chkItem(
                            '13',
                            'Pés de borracha',
                            data['VERIFICAODOSPEDEBORRACHA'] ??
                                data['VERIFICADOSPEDEBORRACHA']),
                      ],
                    ))),
              ],
            )),
        pw.SizedBox(height: 4),
        pw.Expanded(
            child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Expanded(
                flex: 6,
                child: bordered(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    secHdr('SERVIÇOS REALIZADOS'),
                    chkItem(
                        '1', 'Higienização com produtos bactericidas', true),
                    chkItem(
                        '2',
                        'Filtros: lavar com água corrente e sabão, secar',
                        true),
                    chkItem('3', 'Medir e informar tensão elétrica', true),
                    chkItem('4', 'Medir e informar corrente elétrica', true),
                    chkItem('5', 'Limpar carenagem da evaporadora', true),
                    chkItem(
                        '6', 'Verificar ruídos, vazamentos e mau cheiro', true),
                  ],
                ))),
            pw.SizedBox(width: 4),
            pw.Expanded(
                flex: 4,
                child: bordered(pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    secHdr('INFORMAÇÕES ADICIONAIS'),
                    pw.Expanded(
                        child: pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        textoObservacao.isNotEmpty
                            ? textoObservacao
                            : 'Sem observações.',
                        style: norm(7,
                            c: textoObservacao.isNotEmpty
                                ? cGrey800
                                : cGrey600),
                      ),
                    )),
                  ],
                ))),
          ],
        )),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
              color: cBlueDk, borderRadius: pw.BorderRadius.circular(3)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HPS REFRIGERAÇÃO',
                        style: bold(7.5, c: PdfColors.white)),
                    pw.Text('CNPJ: 28.340.152/0001-52',
                        style:
                            norm(6.5, c: const PdfColor.fromInt(0xB3FFFFFF))),
                    pw.Text('(77) 98819-4630 / 98861-2447',
                        style:
                            norm(6.5, c: const PdfColor.fromInt(0xB3FFFFFF))),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                        nomeClienteRodape.isNotEmpty
                            ? nomeClienteRodape
                            : 'CLIENTE',
                        style: bold(7.5, c: PdfColors.white)),
                    if (cnpjClienteRodape.isNotEmpty)
                      pw.Text('CNPJ: $cnpjClienteRodape',
                          style:
                              norm(6.5, c: const PdfColor.fromInt(0xB3FFFFFF))),
                  ]),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> _gerarPDFViewer(
  String patrimonio,
  String? emailCliente, {
  String? filtroAno,
  String? filtroMes,
  void Function(double, String)? onProgress,
}) async {
  try {
    onProgress?.call(0.1, 'Carregando recursos...');
    await Future.microtask(() {});
    await _VisualizarState._ensureAssetsLoaded();
    onProgress?.call(0.25, 'Buscando dados...');
    await Future.microtask(() {});

    String? urlTermo;
    String nomeClienteRodape = '', cnpjClienteRodape = '';
    pw.ImageProvider? imagemCliente, imagemEvaporadora, imagemTermografia;

    Query<Map<String, dynamic>> prevQuery = FirebaseFirestore.instance
        .collection('PREVENTIVAS')
        .where('PATRIMONIO', isEqualTo: patrimonio);
    if (filtroAno != null && filtroAno.isNotEmpty) {
      final anoNum = int.tryParse(filtroAno);
      if (anoNum != null) prevQuery = prevQuery.where('ANO', isEqualTo: anoNum);
    }
    final prevSnapshot = await prevQuery.get();
    final imgFirestoreSnap = await FirebaseFirestore.instance
        .collection('IMAGENS')
        .where('PATRIMONIO', isEqualTo: patrimonio)
        .limit(1)
        .get();
    QuerySnapshot<Map<String, dynamic>>? usuSnap;
    if (emailCliente != null && emailCliente.isNotEmpty) {
      usuSnap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: emailCliente.trim())
          .limit(1)
          .get();
    }
    final docsDoMes = prevSnapshot.docs.where((doc) {
      if (filtroMes == null || filtroMes.isEmpty) return true;
      final mesDoc = (doc.data()['MES'] ?? '').toString();
      return _mesIgual(mesDoc, filtroMes);
    }).toList();
    if (docsDoMes.isEmpty)
      throw Exception('Nenhuma preventiva encontrada para este período');
    docsDoMes.sort((a, b) {
      DateTime? dataA, dataB;
      try {
        dataA = (a.data()['datacadastro'] ?? a.data()['DATADAMANUTENCAO'])
            ?.toDate();
      } catch (_) {}
      try {
        dataB = (b.data()['datacadastro'] ?? b.data()['DATADAMANUTENCAO'])
            ?.toDate();
      } catch (_) {}
      if (dataA == null) return 1;
      if (dataB == null) return -1;
      return dataB.compareTo(dataA);
    });
    final data = docsDoMes.first.data();
    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    onProgress?.call(0.5, 'Carregando imagens...');
    await Future.microtask(() {});
    String? imgEvapUrl;
    if (imgFirestoreSnap.docs.isNotEmpty)
      imgEvapUrl =
          imgFirestoreSnap.docs.first.data()['IMAGEM']?.toString().trim();
    String? photoUrl;
    if (usuSnap != null && usuSnap.docs.isNotEmpty) {
      final ud = usuSnap.docs.first.data();
      if (ud['display_name'] != null)
        nomeClienteRodape = ud['display_name'].toString().toUpperCase();
      if (ud['CNPJ'] != null)
        cnpjClienteRodape = ud['CNPJ'].toString();
      else if (ud['cnpj'] != null) cnpjClienteRodape = ud['cnpj'].toString();
      photoUrl = ud['photo_url']?.toString().trim();
    }
    for (String key in [
      'IMAGEM',
      'THAGEM',
      'TMAGEM',
      'FOTO',
      'foto',
      'imagem'
    ]) {
      if (data.containsKey(key) &&
          data[key] != null &&
          data[key].toString().trim().isNotEmpty) {
        urlTermo = data[key].toString().trim();
        break;
      }
    }
    final imgResponses = await Future.wait([
      _safeHttpGet(imgEvapUrl, timeout: const Duration(seconds: 8)),
      _safeHttpGet(urlTermo, timeout: const Duration(seconds: 8)),
      _safeHttpGet(photoUrl, timeout: const Duration(seconds: 6)),
    ]);
    if (imgResponses[0].statusCode == 200)
      imagemEvaporadora = pw.MemoryImage(imgResponses[0].bodyBytes);
    if (imgResponses[1].statusCode == 200)
      imagemTermografia = pw.MemoryImage(imgResponses[1].bodyBytes);
    if (imgResponses[2].statusCode == 200)
      imagemCliente = pw.MemoryImage(imgResponses[2].bodyBytes);
    onProgress?.call(0.75, 'Montando páginas...');
    await Future.microtask(() {});
    String dataInicio = '';
    if ((data['datacadastro'] ?? data['DATADAMANUTENCAO']) != null)
      dataInicio = fmtDate(
          ((data['datacadastro'] ?? data['DATADAMANUTENCAO']) as Timestamp)
              .toDate());
    final pdf = pw.Document();
    pdf.addPage(_buildPdfPage(
      data: data,
      patrimonio: patrimonio,
      dataInicio: dataInicio,
      textoObservacao: data['OBSERVACAO']?.toString().trim() ?? '',
      logoEmpresa: _VisualizarState._cachedLogoEmpresa,
      imagemCliente: imagemCliente,
      imagemEvaporadora: imagemEvaporadora,
      imagemTermografia: imagemTermografia,
      nomeClienteRodape: nomeClienteRodape,
      cnpjClienteRodape: cnpjClienteRodape,
    ));
    onProgress?.call(0.9, 'Salvando PDF...');
    await Future.microtask(() {});
    final pdfBytes = await pdf.save();
    if (pdfBytes.isEmpty) throw Exception('PDF gerado está vazio');
    onProgress?.call(1.0, 'Concluído!');
    final dataAtual = DateTime.now();
    final nomeArquivo =
        'Preventiva_${patrimonio}_${dataAtual.day.toString().padLeft(2, '0')}${dataAtual.month.toString().padLeft(2, '0')}${dataAtual.year}_${dataAtual.hour.toString().padLeft(2, '0')}${dataAtual.minute.toString().padLeft(2, '0')}.pdf';
    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfBytes, filename: nomeArquivo);
    } else {
      await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes, name: nomeArquivo);
    }
  } catch (e, st) {
    print('ERRO _gerarPDFViewer: $e\n$st');
    rethrow;
  }
}
