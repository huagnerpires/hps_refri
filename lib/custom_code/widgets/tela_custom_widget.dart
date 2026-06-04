// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:math';

// ─── DeviceId persistido ─────────────────────────────────────────────────────
Future<String> _tcGetDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  const chave = 'hps_device_unique_id';
  String? id = prefs.getString(chave);
  if (id == null || id.isEmpty) {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    id = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await prefs.setString(chave, id);
  }
  return id;
}

/// ═════════════════════════════════════════════════════════════════════════════
/// WIDGET PRINCIPAL — verificação de permissão
/// ═════════════════════════════════════════════════════════════════════════════
class TelaCustomWidget extends StatefulWidget {
  const TelaCustomWidget({
    Key? key,
    this.width,
    this.height,
    this.nomeUsuario,
    this.emailUsuario,
    this.nomeEmpresa,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? nomeUsuario;
  final String? emailUsuario;
  final String? nomeEmpresa;

  @override
  State<TelaCustomWidget> createState() => _TelaCustomWidgetState();
}

class _TelaCustomWidgetState extends State<TelaCustomWidget> {
  bool _carregando = true;
  bool _temPermissao = false;
  bool _enviando = false;
  bool _enviado = false;

  @override
  void initState() {
    super.initState();
    _verificarPermissao();
  }

  Future<void> _verificarPermissao() async {
    try {
      final email = currentUserEmail.trim();

      // Nome vem do AppState; se vazio, busca no Firestore como fallback
      String nome = FFAppState().variavelUSUARIO.nome.trim();
      if (nome.isEmpty) {
        try {
          final snapU = await FirebaseFirestore.instance
              .collection('USUARIOS')
              .where('email', isEqualTo: email.toLowerCase())
              .limit(1)
              .get();
          if (snapU.docs.isNotEmpty) {
            nome = (snapU.docs.first.data()['display_name'] ??
                    snapU.docs.first.data()['NOMEDOUSUARIO'] ??
                    '')
                .toString()
                .trim();
          }
        } catch (_) {}
      }

      bool permissao = false;

      String norm(String s) => s
          .toLowerCase()
          .trim()
          .replaceAll('ç', 'c')
          .replaceAll('ã', 'a')
          .replaceAll('á', 'a')
          .replaceAll('â', 'a')
          .replaceAll('à', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('î', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u');

      final emailNorm = norm(email);
      final nomeNorm = norm(nome);

      final todos =
          await FirebaseFirestore.instance.collection('AREA_RESTRITA').get();

      for (final doc in todos.docs) {
        final d = doc.data();

        // 1. Permissão (qualquer campo)
        final temPerm = d['permissao_financeiro'] == true ||
            d['permissao'] == true ||
            d['PERMISSAO'] == true;
        if (!temPerm) continue;

        // 2. Email deve bater
        final docEmail1 = norm((d['email'] ?? '').toString());
        final docEmail2 = norm((d['ID_DO_CELULAR'] ?? '').toString());
        final bateEmail = emailNorm.isNotEmpty &&
            (docEmail1 == emailNorm || docEmail2 == emailNorm);
        if (!bateEmail) continue;

        // 3. Nome deve bater (campo novo ou antigo)
        // Se nome estiver vazio no AppState E no Firestore, libera só por email+permissão
        final docNome1 = norm((d['nome'] ?? '').toString());
        final docNome2 = norm((d['NOMEDOUSUARIO'] ?? '').toString());
        if (nomeNorm.isNotEmpty && docNome1.isNotEmpty) {
          final bateNome = docNome1 == nomeNorm || docNome2 == nomeNorm;
          if (!bateNome) continue;
        }

        permissao = true;
        break;
      }

      if (mounted)
        setState(() {
          _temPermissao = permissao;
          _carregando = false;
        });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _solicitarAcesso() async {
    setState(() => _enviando = true);
    try {
      final nome =
          (widget.nomeUsuario != null && widget.nomeUsuario!.isNotEmpty)
              ? widget.nomeUsuario!
              : FFAppState().variavelUSUARIO.nome;
      final empresa =
          (widget.nomeEmpresa != null && widget.nomeEmpresa!.isNotEmpty)
              ? widget.nomeEmpresa!
              : '';
      final mensagem = empresa.isNotEmpty
          ? 'O usuário $nome da empresa $empresa solicitou acesso ao financeiro do app.'
          : 'O usuário $nome solicitou acesso ao financeiro do app.';

      try {
        await http.post(
          Uri.parse('https://onesignal.com/api/v1/notifications'),
          headers: {
            'Authorization':
                'Basic ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'app_id': '7b01186f-cf76-4b5d-8354-87d83737d40c',
            'filters': [
              {
                'field': 'tag',
                'key': 'Email',
                'relation': '=',
                'value': 'hpsrefri@gmail.com'
              }
            ],
            'headings': {'en': 'Solicitação do financeiro'},
            'contents': {'en': mensagem},
            'android_channel_id': '577bba44-d1bf-4ac9-9d11-20d89e09a61a',
            'priority': 10,
          }),
        );
      } catch (_) {}

      try {
        await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
          'email': 'hpsrefri@gmail.com',
          'titulo': 'Solicitação do financeiro',
          'mensagem': mensagem,
          'tipo': 'sistema',
          'visto': false,
          'data': Timestamp.now(),
          'status': 'pendente',
          'os': '',
        });
      } catch (_) {}

      if (mounted) {
        setState(() {
          _enviando = false;
          _enviado = true;
        });
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Atenção!'),
            content: const Text(
                'Solicitação de acesso ao financeiro recebida. Nossa equipe estará avaliando e liberando acesso.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text('Ok'))
            ],
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? double.infinity;

    if (_carregando) {
      return SizedBox(
          width: w,
          height: h,
          child:
              Center(child: CircularProgressIndicator(color: theme.primary)));
    }

    if (!_temPermissao) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500.0),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: theme.error, width: 2.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: theme.accent4,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Icon(Icons.lock_rounded,
                          color: theme.error, size: 40.0),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Área Restrita',
                      textAlign: TextAlign.center,
                      style: theme.headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: theme.headlineMedium.fontWeight,
                          fontStyle: theme.headlineMedium.fontStyle,
                        ),
                        color: theme.error,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você não tem autorização para ver estes valores',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: theme.bodyMedium.fontWeight,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48.0,
                      child: _enviando
                          ? Container(
                              decoration: BoxDecoration(
                                color: theme.error,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Center(
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5)),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _enviado ? null : _solicitarAcesso,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _enviado
                                    ? theme.secondaryText
                                    : theme.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _enviado
                                    ? 'Solicitação Enviada'
                                    : 'Solicitar Acesso',
                                style: theme.titleSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: theme.titleSmall.fontWeight,
                                    fontStyle: theme.titleSmall.fontStyle,
                                  ),
                                  color: theme.info,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_temPermissao) {
      final email =
          (widget.emailUsuario != null && widget.emailUsuario!.isNotEmpty)
              ? widget.emailUsuario!
              : currentUserEmail;
      return SizedBox(
          width: w,
          height: h,
          child: RelatorioCard(width: w, height: h, email: email));
    }

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: theme.error, width: 2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                          color: theme.accent4,
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Icon(Icons.lock_rounded,
                          color: theme.error, size: 40.0)),
                  const SizedBox(height: 16),
                  Text('Área Restrita',
                      textAlign: TextAlign.center,
                      style: theme.headlineMedium.override(
                          font: GoogleFonts.interTight(
                              fontWeight: theme.headlineMedium.fontWeight,
                              fontStyle: theme.headlineMedium.fontStyle),
                          color: theme.error,
                          letterSpacing: 0.0)),
                  const SizedBox(height: 8),
                  Text('Você não tem autorização para ver estes valores',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight: theme.bodyMedium.fontWeight,
                              fontStyle: theme.bodyMedium.fontStyle),
                          color: theme.secondaryText,
                          letterSpacing: 0.0)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: _enviando
                        ? Container(
                            decoration: BoxDecoration(
                                color: theme.error,
                                borderRadius: BorderRadius.circular(12.0)),
                            child: const Center(
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5))))
                        : ElevatedButton(
                            onPressed: _enviado ? null : _solicitarAcesso,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _enviado
                                    ? theme.secondaryText
                                    : theme.error,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                elevation: 0),
                            child: Text(
                                _enviado
                                    ? 'Solicitação Enviada'
                                    : 'Solicitar Acesso',
                                style: theme.titleSmall.override(
                                    font: GoogleFonts.interTight(
                                        fontWeight: theme.titleSmall.fontWeight,
                                        fontStyle: theme.titleSmall.fontStyle),
                                    color: theme.info,
                                    letterSpacing: 0.0))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RELATÓRIO CARD — original do projeto
// ═══════════════════════════════════════════════════════════════════════════

class RelatorioCard extends StatefulWidget {
  const RelatorioCard({
    Key? key,
    this.width,
    this.height,
    required this.email,
    this.mes,
    this.ano,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String email;
  final String? mes;
  final String? ano;

  @override
  _RelatorioCardState createState() => _RelatorioCardState();
}

class _RelatorioCardState extends State<RelatorioCard> {
  String? _filtroMes;
  String? _filtroAno;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final PdfColor _baseColor = PdfColor.fromInt(0xFF39D2C0);
  final PdfColor _textColor = PdfColors.blueGrey900;

  pw.Font? _fontRegular;
  pw.Font? _fontBold;
  pw.Font? _fontItalic;

  final List<String> _listaMeses = [
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
    'DEZEMBRO'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.mes != null && widget.mes!.isNotEmpty) {
      _filtroMes = widget.mes;
    } else {
      _filtroMes = _listaMeses[DateTime.now().month - 1];
    }
    if (widget.ano != null && widget.ano!.isNotEmpty) {
      _filtroAno = widget.ano;
    } else {
      _filtroAno = DateTime.now().year.toString();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BoxShadow> getElevationShadow(bool isDark) => [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        )
      ];

  double _calcularValorItem(dynamic rawVal) {
    double valor = 0.0;
    if (rawVal is List) {
      for (var item in rawVal) {
        if (item is num)
          valor += item.toDouble();
        else if (item is String) valor += double.tryParse(item) ?? 0.0;
      }
    } else if (rawVal is num) {
      valor = rawVal.toDouble();
    } else if (rawVal is String) {
      valor = double.tryParse(rawVal) ?? 0.0;
    }
    return valor;
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return 'N/A';
    if (raw is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(raw.toDate());
    }
    if (raw is String) {
      final t = raw.trim();
      if (t.isEmpty) return 'N/A';
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(t)) return t;
      try {
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(t));
      } catch (_) {
        return t.split(' ').first;
      }
    }
    return raw.toString();
  }

  Future<void> _generatePdf(List<QueryDocumentSnapshot> docs) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando PDF, aguarde um instante... ⚡'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF39D2C0),
      ),
    );

    final pdf = pw.Document();

    if (_fontRegular == null || _fontBold == null || _fontItalic == null) {
      final fonts = await Future.wait([
        PdfGoogleFonts.openSansRegular(),
        PdfGoogleFonts.openSansBold(),
        PdfGoogleFonts.openSansItalic(),
      ]);
      _fontRegular = fonts[0];
      _fontBold = fonts[1];
      _fontItalic = fonts[2];
    }

    Map<String, List<Map<String, dynamic>>> itensPorSetor = {};
    Map<String, double> totaisPorSetor = {};
    double totalGeral = 0.0;

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      String setor = data['SETOR']?.toString().toUpperCase() ?? 'GERAL';
      double valorDoc = _calcularValorItem(data['VALOR']);
      data['_VALOR_CALCULADO'] = valorDoc;
      if (!itensPorSetor.containsKey(setor)) {
        itensPorSetor[setor] = [];
        totaisPorSetor[setor] = 0.0;
      }
      itensPorSetor[setor]!.add(data);
      totaisPorSetor[setor] = totaisPorSetor[setor]! + valorDoc;
      totalGeral += valorDoc;
    }

    var setoresOrdenados = itensPorSetor.keys.toList()..sort();
    final String dataImpressao =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        theme: pw.ThemeData.withFont(
          base: _fontRegular,
          bold: _fontBold,
          italic: _fontItalic,
        ),
        header: (context) => _buildPdfHeader(dataImpressao),
        footer: (context) => _buildPdfFooter(context, totalGeral),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                pw.Text("Filtros Aplicados: ",
                    style: pw.TextStyle(
                        color: _textColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
                pw.Text(
                    "Ano: ${_filtroAno ?? 'Todos'}  •  Mês: ${_filtroMes ?? 'Todos'}",
                    style: pw.TextStyle(color: _textColor, fontSize: 10)),
              ]),
            ),
            pw.SizedBox(height: 20),
            ...setoresOrdenados.map((setor) {
              List<Map<String, dynamic>> lista = itensPorSetor[setor]!;
              double totalSetor = totaisPorSetor[setor]!;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    decoration: pw.BoxDecoration(
                      color: _baseColor,
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(4),
                        topRight: pw.Radius.circular(4),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("SETOR: $setor",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12)),
                        pw.Text(
                            "Subtotal: R\$ ${totalSetor.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder(
                      verticalInside: pw.BorderSide.none,
                      horizontalInside:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      bottom:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      left: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      right:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    ),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(85),
                      1: const pw.FixedColumnWidth(110),
                      2: const pw.FlexColumnWidth(),
                      3: const pw.FixedColumnWidth(80),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey50),
                        children: [
                          _buildTh("OS / DATA"),
                          _buildTh("LOCAL / EQUIP."),
                          _buildTh("DETALHAMENTO (PEÇAS E SERVIÇOS)"),
                          _buildTh("VALOR", align: pw.TextAlign.right),
                        ],
                      ),
                      ...lista.map((data) => _buildTableRow(data)).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Relatorio_Financeiro_Manutencao.pdf',
    );
  }

  pw.Widget _buildPdfHeader(String dataImpressao) {
    return pw.Column(children: [
      pw.Center(
        child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
          pw.Text("HPS REFRIGERAÇÃO",
              style: pw.TextStyle(
                  color: PdfColors.blue800,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text("AV. Pará 486 - Ibirapuera, Vitória da Conquista - BA",
              style: pw.TextStyle(color: PdfColors.black, fontSize: 11)),
          pw.Text("Tel: 77 98819-4630 ou 98861-2447",
              style: pw.TextStyle(color: PdfColors.black, fontSize: 11)),
        ]),
      ),
      pw.SizedBox(height: 20),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("RELATÓRIO FINANCEIRO",
                style: pw.TextStyle(
                    color: _baseColor,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text("Detalhamento de Manutenção Corretiva",
                style: pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text("Data de Emissão",
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
            pw.Text(dataImpressao,
                style: pw.TextStyle(
                    color: _textColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10)),
          ]),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Divider(color: _baseColor, thickness: 2),
      pw.SizedBox(height: 10),
    ]);
  }

  pw.Widget _buildPdfFooter(pw.Context context, double totalGeral) {
    return pw.Column(children: [
      pw.Divider(color: PdfColors.grey400),
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Página ${context.pageNumber} de ${context.pagesCount}",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text("TOTAL GERAL: ",
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _textColor)),
              pw.Text(
                  "R\$ ${totalGeral.toStringAsFixed(2).replaceAll('.', ',')}",
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _baseColor)),
            ]),
          ],
        ),
      ),
    ]);
  }

  pw.Widget _buildTh(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(text,
          textAlign: align,
          style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.TableRow _buildTableRow(Map<String, dynamic> data) {
    double valTotalItem =
        data['_VALOR_CALCULADO'] ?? _calcularValorItem(data['VALOR']);
    String sala = data['SALA']?.toString() ?? '-';
    String equip = data['EQUIPAMENTO']?.toString() ?? '-';
    String os = data['NUMERO_OS']?.toString() ?? data['OS']?.toString() ?? '-';
    String dataTermino = data['DATA_TERMINO']?.toString() ?? '-';
    String defeito = data['DEFEITO']?.toString() ?? '';
    String servicoRealizado = data['SERVICOREALIZADO']?.toString() ??
        data['DESCRICAODOSERVICO']?.toString() ??
        '';

    var rawPecas = data['PECAS'] ?? data['pecas'];
    List<String> listaPecas = [];
    if (rawPecas is List)
      listaPecas = List.from(rawPecas).map((e) => e.toString()).toList();
    else if (rawPecas != null) listaPecas.add(rawPecas.toString());

    List<double> listaValoresInd = [];
    if (data['VALOR'] is List) {
      for (var item in data['VALOR']) {
        if (item is num)
          listaValoresInd.add(item.toDouble());
        else if (item is String)
          listaValoresInd.add(double.tryParse(item) ?? 0.0);
      }
    } else {
      listaValoresInd.add(valTotalItem);
    }

    final detalhamentoWidget = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (defeito.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text("Defeito: $defeito",
                style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.red800,
                    fontWeight: pw.FontWeight.bold)),
          ),
        ...List.generate(listaPecas.length, (index) {
          double valPeca =
              (index < listaValoresInd.length) ? listaValoresInd[index] : 0.0;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                    child: pw.Text("• ${listaPecas[index]}",
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey800))),
                pw.SizedBox(width: 8),
                pw.Text(
                    "R\$ ${valPeca.toStringAsFixed(2).replaceAll('.', ',')}",
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.black)),
              ],
            ),
          );
        }),
        if (listaPecas.isEmpty)
          if (servicoRealizado.isNotEmpty)
            pw.Text("• $servicoRealizado",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))
          else
            pw.Text("Serviço Geral",
                style:
                    const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
      ],
    );

    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("OS: $os",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(dataTermino,
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey700)),
              ]),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(sala,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text(equip,
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey600)),
              ]),
        ),
        pw.Padding(
            padding: const pw.EdgeInsets.all(6), child: detalhamentoWidget),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
              "R\$ ${valTotalItem.toStringAsFixed(2).replaceAll('.', ',')}",
              textAlign: pw.TextAlign.right,
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  // ── POPUP DE DETALHES com SafeArea ──────────────────────────────────────
  void _showDetalhesPopup(BuildContext context, Map<String, dynamic> data) {
    final theme = FlutterFlowTheme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;
    double popupWidth = isWeb ? 520 : double.maxFinite;

    final String status = data['STATUS']?.toString() ?? '-';
    final bool isConcluida = status.toLowerCase().contains('conclu');
    final String patrimonio = data['PATRIMONIO']?.toString() ?? '';

    double valorNumericoTotal = _calcularValorItem(data['VALOR']);
    String valorTotalFmt =
        "R\$ ${valorNumericoTotal.toStringAsFixed(2).replaceAll('.', ',')}";

    var rawPecas = data['PECAS'] ?? data['pecas'];
    List<String> listaPecas = [];
    if (rawPecas is List) {
      listaPecas = List.from(rawPecas).map((e) => e.toString()).toList();
    } else if (rawPecas != null) {
      listaPecas.add(rawPecas.toString());
    }

    List<double> listaValoresIndividuais = [];
    if (data['VALOR'] is List) {
      for (var item in data['VALOR']) {
        if (item is num)
          listaValoresIndividuais.add(item.toDouble());
        else if (item is String)
          listaValoresIndividuais.add(double.tryParse(item) ?? 0.0);
      }
    } else {
      listaValoresIndividuais.add(valorNumericoTotal);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          backgroundColor: Colors.transparent,
          child: SafeArea(
            child: Container(
              width: popupWidth,
              constraints: BoxConstraints(
                  maxWidth: popupWidth is double ? popupWidth : 520,
                  maxHeight: MediaQuery.of(context).size.height * 0.92),
              decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Cabeçalho
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF39D2C0), Color(0xFF00897B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text("Detalhes da Manutenção",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ]),
                ),
                // Conteúdo scrollável
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (patrimonio.isNotEmpty)
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('IMAGENS')
                                .where('PATRIMONIO', isEqualTo: patrimonio)
                                .limit(1)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  height: 200,
                                  color: theme.primaryBackground,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xFF39D2C0))),
                                );
                              }
                              String? urlImagem;
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                final docImg = snapshot.data!.docs.first.data()
                                    as Map<String, dynamic>;
                                urlImagem = docImg['IMAGEM']?.toString();
                              }
                              if (urlImagem != null && urlImagem.isNotEmpty) {
                                return Stack(children: [
                                  Image.network(
                                    urlImagem,
                                    height: 210,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _photoPlaceholder(theme),
                                    loadingBuilder: (_, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 210,
                                        color: theme.primaryBackground,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                                color: const Color(0xFF39D2C0),
                                                value: progress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? progress
                                                            .cumulativeBytesLoaded /
                                                        progress
                                                            .expectedTotalBytes!
                                                    : null)),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.65)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "OS: ${data['NUMERO_OS'] ?? data['OS'] ?? '-'}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          _statusBadge(status, isConcluida),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]);
                              }
                              return _photoPlaceholder(theme);
                            },
                          )
                        else
                          _photoPlaceholder(theme),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (patrimonio.isEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.primaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.alternate),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "OS: ${data['NUMERO_OS'] ?? data['OS'] ?? '-'}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: theme.primaryText),
                                      ),
                                      _statusBadge(status, isConcluida),
                                    ],
                                  ),
                                ),
                              if (valorNumericoTotal == 0)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2F1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF39D2C0),
                                        width: 1),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.check_circle,
                                        color: Color(0xFF00695C), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                          "SERVIÇO COBERTO PELO CONTRATO",
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF00695C),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11)),
                                    ),
                                  ]),
                                ),
                              _sectionHeader("Localização",
                                  Icons.location_on_outlined, theme),
                              _modernRow("Setor",
                                  data['SETOR']?.toString() ?? '-', theme),
                              _modernRow("Sala / Local",
                                  data['SALA']?.toString() ?? '-', theme),
                              _sectionHeader(
                                  "Equipamento", Icons.ac_unit_outlined, theme),
                              _modernRow(
                                  "Equipamento",
                                  data['EQUIPAMENTO']?.toString() ?? '-',
                                  theme),
                              _modernRow("Marca",
                                  data['MARCA']?.toString() ?? '-', theme),
                              _modernRow("Modelo",
                                  data['MODELO']?.toString() ?? '-', theme),
                              _modernRow("Patrimônio",
                                  patrimonio.isEmpty ? '-' : patrimonio, theme),
                              if ((data['BTUS']?.toString() ?? '').isNotEmpty)
                                _modernRow("BTUs/Potência",
                                    data['BTUS'].toString(), theme),
                              if ((data['FLUIDO']?.toString() ?? '').isNotEmpty)
                                _modernRow(
                                    "Fluido", data['FLUIDO'].toString(), theme),
                              _sectionHeader("Datas & Técnico",
                                  Icons.calendar_today_outlined, theme),
                              _modernRow("Data Manutenção",
                                  _formatDate(data['DATADAMANUTENCAO']), theme),
                              _modernRow("Data Término",
                                  _formatDate(data['DATA_TERMINO']), theme),
                              _modernRow(
                                  "Mês/Ano",
                                  "${data['MES'] ?? '-'} / ${data['ANO'] ?? '-'}",
                                  theme),
                              _modernRow(
                                  "Técnico",
                                  data['TECNICORESPONSAVEL']?.toString() ?? '-',
                                  theme),
                              _sectionHeader(
                                  "Serviço", Icons.build_outlined, theme),
                              _modernRow("Defeito Relatado",
                                  data['DEFEITO']?.toString() ?? '-', theme),
                              _modernRow(
                                  "Serviço Realizado",
                                  data['SERVICOREALIZADO']?.toString() ?? '-',
                                  theme),
                              _modernRow(
                                  "Descrição Detalhada",
                                  data['DESCRICAODOSERVICO']?.toString() ?? '-',
                                  theme),
                              _sectionHeader("Peças e Custos",
                                  Icons.handyman_outlined, theme),
                              if (listaPecas.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text("Nenhuma peça/serviço listado.",
                                      style: TextStyle(
                                          color: theme.secondaryText,
                                          fontSize: 13)),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.primaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.alternate),
                                  ),
                                  child: Column(
                                    children:
                                        listaPecas.asMap().entries.map((e) {
                                      final idx = e.key;
                                      final peca = e.value;
                                      final isLast =
                                          idx == listaPecas.length - 1;
                                      final valPeca =
                                          idx < listaValoresIndividuais.length
                                              ? listaValoresIndividuais[idx]
                                              : 0.0;
                                      final valFmt =
                                          "R\$ ${valPeca.toStringAsFixed(2).replaceAll('.', ',')}";
                                      return Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          child: Row(children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                  color: Color(0xFF39D2C0),
                                                  shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child: Text(peca,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: theme
                                                            .primaryText))),
                                            const SizedBox(width: 8),
                                            Text(valFmt,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.primaryText)),
                                          ]),
                                        ),
                                        if (!isLast)
                                          Divider(
                                              height: 1,
                                              color: theme.alternate),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF39D2C0).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFF39D2C0)
                                          .withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Custo Total:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: theme.primaryText)),
                                    Text(valorTotalFmt,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF39D2C0),
                                            fontSize: 18)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _photoPlaceholder(FlutterFlowTheme theme) => Container(
        height: 160,
        color: theme.primaryBackground,
        child: Center(
          child: Icon(Icons.ac_unit,
              color: const Color(0xFF39D2C0).withOpacity(0.25), size: 60),
        ),
      );

  Widget _statusBadge(String status, bool isConcluida) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:
              isConcluida ? const Color(0xFF26A69A) : const Color(0xFFFF8F00),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(status.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      );

  Widget _sectionHeader(String title, IconData icon, FlutterFlowTheme theme) =>
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(children: [
          Icon(icon, color: const Color(0xFF39D2C0), size: 15),
          const SizedBox(width: 6),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF39D2C0),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
          const SizedBox(width: 8),
          Expanded(
              child: Divider(
                  height: 1, color: const Color(0xFF39D2C0).withOpacity(0.3))),
        ]),
      );

  Widget _modernRow(String label, String value, FlutterFlowTheme theme) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryText)),
            ),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryText)),
            ),
          ],
        ),
      );

  // ── Popup de setor completo com SafeArea ──────────────────────────────────
  void _showSetorCompletoPopup(BuildContext context, String nomeSetor,
      List<QueryDocumentSnapshot> listaCompleta) {
    final theme = FlutterFlowTheme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;
    double popupWidth = isWeb ? 600 : double.maxFinite;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String localSearch = "";
        return StatefulBuilder(builder: (context, setStatePopup) {
          var listaFiltrada = listaCompleta.where((doc) {
            if (localSearch.isEmpty) return true;
            var data = doc.data() as Map<String, dynamic>;
            String search = localSearch.toLowerCase();
            String os =
                (data['NUMERO_OS']?.toString() ?? data['OS']?.toString() ?? "")
                    .toLowerCase();
            String patrimonio =
                (data['PATRIMONIO']?.toString() ?? "").toLowerCase();
            String sala = (data['SALA']?.toString() ?? "").toLowerCase();
            return os.contains(search) ||
                patrimonio.contains(search) ||
                sala.contains(search);
          }).toList();

          return SafeArea(
            child: AlertDialog(
              backgroundColor: theme.secondaryBackground,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              title: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF39D2C0), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text("Setor: $nomeSetor",
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))),
                    InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, color: Colors.white))
                  ],
                ),
              ),
              content: Container(
                width: popupWidth,
                constraints: const BoxConstraints(maxHeight: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              setStatePopup(() => localSearch = val),
                          style: GoogleFonts.inter(
                              fontSize: 13, color: theme.primaryText),
                          decoration: InputDecoration(
                            hintText: "Filtrar neste setor...",
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13, color: theme.secondaryText),
                            prefixIcon: Icon(Icons.search,
                                size: 20, color: theme.secondaryText),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          "Exibindo ${listaFiltrada.length} de ${listaCompleta.length} registros.",
                          style: GoogleFonts.inter(
                              color: theme.secondaryText,
                              fontSize: 12,
                              fontStyle: FontStyle.italic)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (listaFiltrada.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text("Nenhum item encontrado.",
                                    style: GoogleFonts.inter(
                                        color: theme.secondaryText)),
                              ),
                            ...listaFiltrada.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return _buildServiceCard(context, data);
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Fechar",
                        style: GoogleFonts.inter(
                            color: const Color(0xFF39D2C0),
                            fontWeight: FontWeight.bold)))
              ],
            ),
          );
        });
      },
    );
  }

  // ── Popup Notas Fiscais com SafeArea ─────────────────────────────────────
  void _showNotasFiscaisPopup(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    String anoRef = _filtroAno ?? DateTime.now().year.toString();
    String mesRaw = _filtroMes ?? _listaMeses[DateTime.now().month - 1];
    String mesRef = mesRaw.substring(0, 1).toUpperCase() +
        mesRaw.substring(1).toLowerCase();
    String storagePath = '${widget.email}/$anoRef/$mesRef/NOTAS FISCAIS';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: AlertDialog(
            backgroundColor: theme.secondaryBackground,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: EdgeInsets.zero,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            title: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF39D2C0), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text("Notas Fiscais - $mesRef/$anoRef",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))),
                  InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white))
                ],
              ),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 500),
              child: FutureBuilder<ListResult>(
                future:
                    FirebaseStorage.instance.ref().child(storagePath).listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF39D2C0)));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erro ao carregar arquivos.",
                            style: GoogleFonts.inter(color: theme.error)));
                  }
                  if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_off,
                                size: 40, color: theme.secondaryText),
                            const SizedBox(height: 10),
                            Text("Nenhuma nota encontrada nesta pasta.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    color: theme.secondaryText)),
                            const SizedBox(height: 4),
                            Text(storagePath,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: theme.secondaryText)),
                          ]),
                    );
                  }
                  final items = snapshot.data!.items;
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (ctx, i) =>
                        Divider(color: theme.alternate),
                    itemBuilder: (context, index) {
                      final ref = items[index];
                      return ListTile(
                        leading:
                            Icon(Icons.description, color: theme.primaryText),
                        title: Text(ref.name,
                            style: GoogleFonts.inter(
                                color: theme.primaryText, fontSize: 14)),
                        trailing: const Icon(Icons.download,
                            color: Color(0xFF39D2C0)),
                        onTap: () async {
                          try {
                            String url = await ref.getDownloadURL();
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Erro ao abrir arquivo: $e')));
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Fechar",
                      style: GoogleFonts.inter(
                          color: const Color(0xFF39D2C0),
                          fontWeight: FontWeight.bold)))
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> data) {
    final theme = FlutterFlowTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    String sala = data['SALA'] ?? 'Sem Local';
    String dataServico = data['DATA_TERMINO'] ?? '';
    String os = data['NUMERO_OS'] ?? 'S/N';
    String mes = data['MES'] ?? '';
    String equipamento = data['EQUIPAMENTO'] ?? '';
    String defeito = data['DEFEITO'] ?? 'Não informado';

    double valItem = _calcularValorItem(data['VALOR']);
    String valItemFmt =
        "R\$ ${valItem.toStringAsFixed(2).replaceAll('.', ',')}";

    return InkWell(
      onTap: () => _showDetalhesPopup(context, data),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          boxShadow: getElevationShadow(isDark),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Text(sala,
                    style: GoogleFonts.inter(
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14))),
            Text(valItemFmt,
                style: GoogleFonts.inter(
                    color: theme.tertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text("Nº DA O.S: $os",
                style: GoogleFonts.inter(
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
          Divider(height: 12, color: theme.alternate),
          const SizedBox(height: 4),
          _buildItemRow(const Color(0xFF39D2C0), equipamento, theme),
          const SizedBox(height: 4),
          _buildItemRow(theme.error, "Defeito: $defeito", theme),
          const SizedBox(height: 4),
          _buildItemRow(theme.warning, "Data: $dataServico  ($mes)", theme),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF14181B)
        : Theme.of(context).scaffoldBackgroundColor;

    return SafeArea(
      child: Container(
        width: widget.width,
        height: widget.height,
        color: backgroundColor,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('CORRETIVAS')
              .where('EMAIL', isEqualTo: widget.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF39D2C0)));

            final allDocs = snapshot.data!.docs;

            if (allDocs.isEmpty)
              return Center(
                  child: Text('Nenhum registro encontrado.',
                      style: GoogleFonts.inter(color: theme.secondaryText)));

            Set<String> anosDisponiveis = {};
            for (var doc in allDocs) {
              var data = doc.data() as Map<String, dynamic>;
              if (data['ANO'] != null)
                anosDisponiveis.add(data['ANO'].toString());
            }
            List<String> listaAnos = anosDisponiveis.toList()..sort();

            var docsFiltrados = allDocs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              bool passaAno = _filtroAno == null ||
                  _filtroAno == 'Todos' ||
                  data['ANO'] == _filtroAno;
              bool passaMes = _filtroMes == null ||
                  _filtroMes == 'Todos' ||
                  (data['MES']?.toString().toUpperCase() ==
                      _filtroMes?.toUpperCase());
              bool passaSearch = true;
              if (_searchQuery.isNotEmpty) {
                String search = _searchQuery.toLowerCase();
                String os = (data['NUMERO_OS']?.toString() ??
                        data['OS']?.toString() ??
                        "")
                    .toLowerCase();
                String setor = (data['SETOR']?.toString() ?? "").toLowerCase();
                String patrimonio =
                    (data['PATRIMONIO']?.toString() ?? "").toLowerCase();
                String sala = (data['SALA']?.toString() ?? "").toLowerCase();
                passaSearch = os.contains(search) ||
                    setor.contains(search) ||
                    patrimonio.contains(search) ||
                    sala.contains(search);
              }
              return passaAno && passaMes && passaSearch;
            }).toList();

            Map<String, List<QueryDocumentSnapshot>> itensPorSetor = {};
            Map<String, double> somaPorSetor = {};
            double totalGeral = 0.0;

            for (var doc in docsFiltrados) {
              var data = doc.data() as Map<String, dynamic>;
              String setor = data['SETOR']?.toString().toUpperCase() ?? 'GERAL';
              double valorDoc = _calcularValorItem(data['VALOR']);
              if (!itensPorSetor.containsKey(setor)) {
                itensPorSetor[setor] = [];
                somaPorSetor[setor] = 0.0;
              }
              itensPorSetor[setor]!.add(doc);
              somaPorSetor[setor] = (somaPorSetor[setor] ?? 0.0) + valorDoc;
              totalGeral += valorDoc;
            }

            var setoresOrdenados = itensPorSetor.keys.toList()..sort();
            String totalGeralFormatado =
                "R\$ ${totalGeral.toStringAsFixed(2).replaceAll('.', ',')}";

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      boxShadow: getElevationShadow(isDark)),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Filtros",
                                style: GoogleFonts.inter(
                                    color: theme.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            if (_filtroAno != null ||
                                _filtroMes != null ||
                                _searchQuery.isNotEmpty)
                              InkWell(
                                  onTap: () => setState(() {
                                        _filtroAno = null;
                                        _filtroMes = null;
                                        _searchQuery = "";
                                        _searchController.clear();
                                      }),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text("Limpar",
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF39D2C0),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))))
                          ]),
                      const SizedBox(height: 10),
                      Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.alternate)),
                          child: TextField(
                              controller: _searchController,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: theme.primaryText),
                              decoration: InputDecoration(
                                  hintText:
                                      "Pesquisar por O.S, Setor, Patrimônio ou Sala...",
                                  hintStyle: GoogleFonts.inter(
                                      fontSize: 13, color: theme.secondaryText),
                                  prefixIcon: Icon(Icons.search,
                                      size: 20, color: theme.secondaryText),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8)))),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: _buildDropdown(context,
                                hint: "Ano",
                                value: _filtroAno,
                                items: listaAnos,
                                onChanged: (val) =>
                                    setState(() => _filtroAno = val))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildDropdown(context,
                                hint: "Mês",
                                value: _filtroMes,
                                items: _listaMeses,
                                onChanged: (val) =>
                                    setState(() => _filtroMes = val))),
                      ]),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: backgroundColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text('Relatório Detalhado',
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF39D2C0),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold))),
                          if (docsFiltrados.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF39D2C0),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      IconButton(
                                        icon: const Icon(Icons.receipt_long,
                                            color: Colors.white),
                                        tooltip: "Notas Fiscais",
                                        onPressed: () =>
                                            _showNotasFiscaisPopup(context),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share,
                                            color: Colors.white),
                                        tooltip: "Compartilhar Relatório",
                                        onPressed: () =>
                                            _generatePdf(docsFiltrados),
                                      ),
                                    ]),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Resumo Geral",
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 14)),
                                              Text(totalGeralFormatado,
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 20)),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          const SizedBox(height: 20),
                          if (docsFiltrados.isEmpty)
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Column(children: [
                                      Icon(Icons.search_off,
                                          size: 40, color: theme.secondaryText),
                                      const SizedBox(height: 10),
                                      Text("Nenhum dado encontrado.",
                                          style: GoogleFonts.inter(
                                              color: theme.secondaryText))
                                    ]))),
                          ...setoresOrdenados.map((setor) {
                            double totalSetor = somaPorSetor[setor] ?? 0.0;
                            String totalSetorString =
                                "R\$ ${totalSetor.toStringAsFixed(2).replaceAll('.', ',')}";
                            List<QueryDocumentSnapshot> listaDoSetor =
                                itensPorSetor[setor]!;
                            var listaPreview = listaDoSetor.take(3).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: theme.alternate,
                                              width: 1))),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(setor,
                                                style: GoogleFonts.inter(
                                                    color: theme.primaryText,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(totalSetorString,
                                                  style: GoogleFonts.inter(
                                                      color: theme.tertiary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15)),
                                              Text(
                                                  "${listaDoSetor.length} serviços",
                                                  style: GoogleFonts.inter(
                                                      color:
                                                          theme.secondaryText,
                                                      fontSize: 10))
                                            ])
                                      ]),
                                ),
                                ...listaPreview.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return _buildServiceCard(context, data);
                                }).toList(),
                                if (listaDoSetor.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () => _showSetorCompletoPopup(
                                            context, setor, listaDoSetor),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                              color: theme.secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFF39D2C0))),
                                          child: Text(
                                            "Ver todos os ${listaDoSetor.length} itens",
                                            style: GoogleFonts.inter(
                                                color: const Color(0xFF39D2C0),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context,
      {required String hint,
      required String? value,
      required List<String> items,
      required Function(String?) onChanged}) {
    final theme = FlutterFlowTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      height: 45,
      decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.alternate),
          boxShadow: getElevationShadow(isDark)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (items.contains(value)) ? value : null,
          hint: Text(hint,
              style:
                  GoogleFonts.inter(color: theme.secondaryText, fontSize: 13)),
          dropdownColor: theme.secondaryBackground,
          icon: Icon(Icons.arrow_drop_down, color: theme.secondaryText),
          style: GoogleFonts.inter(color: theme.primaryText, fontSize: 13),
          isExpanded: true,
          items: items
              .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child:
                      Text(item, maxLines: 1, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildItemRow(Color iconColor, String text, FlutterFlowTheme theme) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style:
                    GoogleFonts.inter(color: theme.secondaryText, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
