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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

// ─────────────────────────────────────────────────────────
//  HELPER GLOBAL — abre qualquer gráfico em tela cheia
// ─────────────────────────────────────────────────────────
void _showFullscreen(BuildContext context, String title, Widget chartContent) {
  final theme = FlutterFlowTheme.of(context);
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: theme.primaryBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      )),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit,
                      color: Color(0xFF26A69A), size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              Divider(color: theme.alternate, height: 16),
              Expanded(child: chartContent),
            ],
          ),
        ),
      ),
    ),
  );
}

class MaintenanceReport extends StatefulWidget {
  const MaintenanceReport({
    Key? key,
    this.width,
    this.height,
    required this.userEmail,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String userEmail;

  @override
  _MaintenanceReportState createState() => _MaintenanceReportState();
}

class _MaintenanceReportState extends State<MaintenanceReport> {
  int? selectedYear;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year;
  }

  int _convertMonthStringToInt(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.contains('jan')) return 1;
    if (lower.contains('fev')) return 2;
    if (lower.contains('mar')) return 3;
    if (lower.contains('abr')) return 4;
    if (lower.contains('mai')) return 5;
    if (lower.contains('jun')) return 6;
    if (lower.contains('jul')) return 7;
    if (lower.contains('ago')) return 8;
    if (lower.contains('set')) return 9;
    if (lower.contains('out')) return 10;
    if (lower.contains('nov')) return 11;
    if (lower.contains('dez')) return 12;
    return 0;
  }

  DateTime? _extractDateRobust(dynamic rawDate) {
    if (rawDate is Timestamp) return rawDate.toDate();
    if (rawDate is String) {
      final match = RegExp(r'\b(20\d{2})\b').firstMatch(rawDate);
      if (match != null)
        return DateTime(
          int.parse(match.group(1)!),
          _convertMonthStringToInt(rawDate) == 0
              ? 1
              : _convertMonthStringToInt(rawDate),
          1,
        );
    }
    return null;
  }

  String _getMonthAbbr(int m) => [
        "JAN",
        "FEV",
        "MAR",
        "ABR",
        "MAI",
        "JUN",
        "JUL",
        "AGO",
        "SET",
        "OUT",
        "NOV",
        "DEZ"
      ][m - 1];

  String _getMonthName(int m) => [
        "Janeiro",
        "Fevereiro",
        "Março",
        "Abril",
        "Maio",
        "Junho",
        "Julho",
        "Agosto",
        "Setembro",
        "Outubro",
        "Novembro",
        "Dezembro"
      ][m - 1];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('CORRETIVAS')
            .where('EMAIL', isEqualTo: widget.userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(color: theme.primary));
          }

          final docs = snapshot.data!.docs;
          Set<int> availableYears = {};
          Set<int> availableMonthsInSelectedYear = {};
          Map<int, List<DocumentSnapshot>> docsByMonth = {};
          for (int i = 1; i <= 12; i++) docsByMonth[i] = [];

          Map<String, double> gasMap = {};
          List<DocumentSnapshot> gasDocs = [];
          Map<int, double> gasoPorMes = {for (int i = 1; i <= 12; i++) i: 0.0};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            int? docYear;
            int? docMonth;

            if (data['ANO'] != null)
              docYear = int.tryParse(data['ANO'].toString());
            if (data['MES'] != null)
              docMonth = _convertMonthStringToInt(data['MES'].toString());

            if (docYear == null || docMonth == null) {
              DateTime? fb = _extractDateRobust(data['DATADAMANUTENCAO']);
              if (fb != null) {
                docYear = fb.year;
                docMonth = fb.month;
              }
            }

            if (docYear != null && docMonth != null) {
              availableYears.add(docYear);
              if (docYear == selectedYear) {
                availableMonthsInSelectedYear.add(docMonth);
                docsByMonth[docMonth]?.add(doc);

                final qtdMes =
                    double.tryParse(data['QUANTIDADE']?.toString() ?? '') ?? 0;
                if (qtdMes > 0) {
                  gasoPorMes[docMonth] = (gasoPorMes[docMonth] ?? 0) + qtdMes;
                }

                bool monthMatch =
                    selectedMonth == null || selectedMonth == docMonth;
                if (monthMatch) {
                  final fluido = data['FLUIDO']?.toString().trim() ?? '';
                  final qtd =
                      double.tryParse(data['QUANTIDADE']?.toString() ?? '') ??
                          0;
                  if (fluido.isNotEmpty && qtd > 0) {
                    gasMap[fluido] = (gasMap[fluido] ?? 0) + qtd;
                    gasDocs.add(doc);
                  }
                }
              }
            }
          }

          List<int> sortedYears = availableYears.toList()
            ..sort((a, b) => b.compareTo(a));
          if (sortedYears.isEmpty) sortedYears.add(DateTime.now().year);
          if (!sortedYears.contains(selectedYear))
            selectedYear = sortedYears.first;
          List<int> sortedMonths = availableMonthsInSelectedYear.toList()
            ..sort();

          int totalDisplay = 0;
          if (selectedMonth == null) {
            docsByMonth.forEach((_, list) => totalDisplay += list.length);
          } else {
            totalDisplay = docsByMonth[selectedMonth]?.length ?? 0;
          }

          int maxCount = 1;
          docsByMonth.forEach((_, list) {
            if (list.length > maxCount) maxCount = list.length;
          });

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ══ FILTROS ══════════════════════════════
                SizedBox(
                  height: 40,
                  child: Row(children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: theme.alternate),
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: (selectedMonth != null &&
                                    sortedMonths.contains(selectedMonth))
                                ? selectedMonth
                                : null,
                            isExpanded: true,
                            dropdownColor: theme.secondaryBackground,
                            hint: Text("Todos",
                                style: theme.bodyMedium.override(
                                    fontFamily: 'Readex Pro', fontSize: 12)),
                            items: [
                              DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("Todos",
                                      style: theme.bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold))),
                              ...sortedMonths.map((m) => DropdownMenuItem<int?>(
                                  value: m,
                                  child: Text(_getMonthName(m),
                                      style: theme.bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 13)))),
                            ],
                            onChanged: (v) => setState(() => selectedMonth = v),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: theme.alternate),
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedYear,
                            isExpanded: true,
                            dropdownColor: theme.secondaryBackground,
                            items: sortedYears
                                .map((y) => DropdownMenuItem<int>(
                                    value: y,
                                    child: Text("$y",
                                        style: theme.bodyMedium.override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold))))
                                .toList(),
                            onChanged: (v) => setState(() {
                              selectedYear = v;
                              selectedMonth = null;
                            }),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),

                // ══ GRÁFICO 1 — SERVIÇOS POR MÊS ═════════
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.alternate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        const Icon(Icons.build_circle_outlined,
                            color: Color(0xFF7986CB), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text("Ordens de Serviço Corretivas",
                                style: theme.bodyLarge.override(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                        InkWell(
                          onTap: () => _showFullscreen(
                            context,
                            "Ordens de Serviço Corretivas — $selectedYear",
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(
                                    12,
                                    (i) => _buildBarColumn(
                                        context,
                                        _getMonthAbbr(i + 1),
                                        docsByMonth[i + 1]!.length,
                                        maxCount,
                                        docsByMonth[i + 1]!,
                                        selectedMonth != null &&
                                            selectedMonth != (i + 1),
                                        theme)),
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.fullscreen,
                                color: theme.secondaryText, size: 20),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("$selectedYear",
                              style: theme.bodySmall.override(
                                  fontFamily: 'Readex Pro',
                                  color: theme.secondaryText)),
                          Text("Total: $totalDisplay serviços",
                              style: theme.bodySmall.override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF7986CB),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                              12,
                              (i) => _buildBarColumn(
                                  context,
                                  _getMonthAbbr(i + 1),
                                  docsByMonth[i + 1]!.length,
                                  maxCount,
                                  docsByMonth[i + 1]!,
                                  selectedMonth != null &&
                                      selectedMonth != (i + 1),
                                  theme)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ══ GRÁFICO 2 — CONSUMO DE GASES ══════════
                _GasChart(
                  gasMap: gasMap,
                  gasDocs: gasDocs,
                  gasoPorMes: gasoPorMes,
                  selectedMonth: selectedMonth,
                  selectedYear: selectedYear,
                  theme: theme,
                  getMonthName: _getMonthName,
                ),
                const SizedBox(height: 12),

                // ══ GRÁFICO 3 — PREVENTIVAS POR MÊS ══════
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('PREVENTIVAS')
                      .where('EMAIL', isEqualTo: widget.userEmail)
                      .snapshots(),
                  builder: (context, snapPrev) {
                    if (!snapPrev.hasData) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: theme.primary),
                      ));
                    }

                    final prevDocs = snapPrev.data!.docs;
                    Map<int, int> prevPorMes = {
                      for (int i = 1; i <= 12; i++) i: 0
                    };

                    for (var doc in prevDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      int? docYear;
                      int? docMonth;

                      if (data['ANO'] != null)
                        docYear = int.tryParse(data['ANO'].toString());
                      if (data['MES'] != null)
                        docMonth =
                            _convertMonthStringToInt(data['MES'].toString());

                      if (docYear == null || docMonth == null) {
                        DateTime? fb =
                            _extractDateRobust(data['DATADAMANUTENCAO']);
                        if (fb != null) {
                          docYear = fb.year;
                          docMonth = fb.month;
                        }
                      }

                      if (docYear == selectedYear &&
                          docMonth != null &&
                          docMonth >= 1 &&
                          docMonth <= 12) {
                        prevPorMes[docMonth] = (prevPorMes[docMonth] ?? 0) + 1;
                      }
                    }

                    int totalPrev = selectedMonth == null
                        ? prevPorMes.values.fold(0, (a, b) => a + b)
                        : prevPorMes[selectedMonth] ?? 0;

                    int maxPrev = 1;
                    prevPorMes.forEach((_, v) {
                      if (v > maxPrev) maxPrev = v;
                    });

                    return _PreventiveChart(
                      prevPorMes: prevPorMes,
                      totalPrev: totalPrev,
                      maxPrev: maxPrev,
                      selectedMonth: selectedMonth,
                      selectedYear: selectedYear,
                      theme: theme,
                      getMonthAbbr: _getMonthAbbr,
                      getMonthName: _getMonthName,
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarColumn(
      BuildContext context,
      String label,
      int count,
      int maxCount,
      List<DocumentSnapshot> docs,
      bool isDimmed,
      FlutterFlowTheme theme) {
    return Expanded(
        child: Opacity(
            opacity: isDimmed ? 0.3 : 1.0,
            child: InkWell(
                onTap: () {
                  if (count > 0 && !isDimmed)
                    _showMonthlyList(context, label, docs);
                },
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (count > 0)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF9FA8DA),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text("$count",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold))),
                  Flexible(
                      child: FractionallySizedBox(
                          heightFactor: count == 0 ? 0.01 : (count / maxCount),
                          child: Container(
                              width: 10,
                              decoration: BoxDecoration(
                                  color: count > 0
                                      ? const Color(0xFF7986CB)
                                      : theme.alternate,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)))))),
                  const SizedBox(height: 4),
                  Text(label, style: theme.bodySmall.override(fontSize: 8)),
                ]))));
  }

  void _showMonthlyList(
      BuildContext context, String monthLabel, List<DocumentSnapshot> docs) {
    final theme = FlutterFlowTheme.of(context);
    showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: 600,
                    maxHeight: MediaQuery.of(context).size.height * 0.90),
                decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: MaintenanceListWidget(
                    docs: docs,
                    monthName: monthLabel,
                    year: selectedYear.toString()),
              ),
            ));
  }
}

// ═════════════════════════════════════════════════════════
//  WIDGET: GRÁFICO DE PREVENTIVAS POR MÊS
// ═════════════════════════════════════════════════════════
class _PreventiveChart extends StatelessWidget {
  final Map<int, int> prevPorMes;
  final int totalPrev;
  final int maxPrev;
  final int? selectedMonth;
  final int? selectedYear;
  final FlutterFlowTheme theme;
  final String Function(int) getMonthAbbr;
  final String Function(int) getMonthName;

  const _PreventiveChart({
    required this.prevPorMes,
    required this.totalPrev,
    required this.maxPrev,
    required this.selectedMonth,
    required this.selectedYear,
    required this.theme,
    required this.getMonthAbbr,
    required this.getMonthName,
  });

  static const Color _barColor = Color(0xFF26A69A);
  static const Color _barDimColor = Color(0xFF80CBC4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF26A69A), size: 18),
            const SizedBox(width: 6),
            Expanded(
                child: Text("Manutenções Preventivas",
                    style: theme.bodyLarge.override(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
            InkWell(
              onTap: () => _showFullscreen(
                context,
                "Manutenções Preventivas — $selectedYear",
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(12, (i) {
                      final mes = i + 1;
                      final count = prevPorMes[mes] ?? 0;
                      final isDimmed =
                          selectedMonth != null && selectedMonth != mes;
                      final heightFactor = count == 0 ? 0.01 : count / maxPrev;
                      return Expanded(
                        child: Opacity(
                          opacity: isDimmed ? 0.3 : 1.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (count > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  margin: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                      color: _barColor,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text("$count",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold)),
                                ),
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: heightFactor,
                                  child: Container(
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: count > 0
                                          ? _barColor
                                          : theme.alternate,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(getMonthAbbr(mes),
                                  style:
                                      theme.bodySmall.override(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.fullscreen,
                    color: theme.secondaryText, size: 20),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$selectedYear",
                  style: theme.bodySmall.override(
                      fontFamily: 'Readex Pro', color: theme.secondaryText)),
              Text(
                  totalPrev == 0
                      ? "Nenhum registro"
                      : "Total: $totalPrev preventivas",
                  style: theme.bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: totalPrev == 0
                          ? theme.secondaryText
                          : const Color(0xFF26A69A),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final mes = i + 1;
                final count = prevPorMes[mes] ?? 0;
                final isDimmed = selectedMonth != null && selectedMonth != mes;
                final heightFactor = count == 0 ? 0.01 : count / maxPrev;

                return Expanded(
                  child: Opacity(
                    opacity: isDimmed ? 0.3 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                                color: _barColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text("$count",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          ),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: heightFactor,
                            child: Container(
                              width: 10,
                              decoration: BoxDecoration(
                                color: count > 0 ? _barColor : theme.alternate,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(getMonthAbbr(mes),
                            style: theme.bodySmall.override(fontSize: 8)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  WIDGET: GRÁFICO DE GASES + GRÁFICO DE LINHA + BOTÃO PDF
// ═════════════════════════════════════════════════════════
class _GasChart extends StatelessWidget {
  final Map<String, double> gasMap;
  final List<DocumentSnapshot> gasDocs;
  final Map<int, double> gasoPorMes;
  final int? selectedMonth;
  final int? selectedYear;
  final FlutterFlowTheme theme;
  final String Function(int) getMonthName;

  const _GasChart({
    required this.gasMap,
    required this.gasDocs,
    required this.gasoPorMes,
    required this.selectedMonth,
    required this.selectedYear,
    required this.theme,
    required this.getMonthName,
  });

  static const List<Color> _palette = [
    Color(0xFF26A69A),
    Color(0xFF7986CB),
    Color(0xFFEF5350),
    Color(0xFFFFB300),
    Color(0xFF29B6F6),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
  ];
  Color _color(int i) => _palette[i % _palette.length];

  static const List<String> _abrevMeses = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  String get _periodoLabel {
    if (selectedMonth != null)
      return "${getMonthName(selectedMonth!).substring(0, 3).toUpperCase()} / $selectedYear";
    return "Ano $selectedYear";
  }

  Widget _buildLineChart() {
    final maxY = gasoPorMes.values.fold(0.0, (a, b) => a > b ? a : b);
    final effectiveMax = maxY > 0 ? (maxY * 1.3) : 10.0;
    final spots = List.generate(
        12, (i) => FlSpot(i.toDouble(), gasoPorMes[i + 1] ?? 0.0));

    return SizedBox(
      height: 180,
      child: LineChart(LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: effectiveMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: effectiveMax / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: effectiveMax / 4,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                  style: TextStyle(fontSize: 9, color: theme.secondaryText)),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx > 11) return const SizedBox();
                final isSelected =
                    selectedMonth != null && selectedMonth == (idx + 1);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_abrevMeses[idx],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF26A69A)
                            : theme.secondaryText,
                      )),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF26A69A),
            getTooltipItems: (spots) => spots.map((s) {
              final mes = getMonthName(s.x.toInt() + 1);
              return LineTooltipItem(
                  '$mes\n${s.y.toStringAsFixed(2)} kg',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11));
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF26A69A),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                final isSelected = selectedMonth != null &&
                    selectedMonth == (spot.x.toInt() + 1);
                return FlDotCirclePainter(
                  radius: isSelected ? 5 : 3,
                  color: isSelected ? const Color(0xFF26A69A) : Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF26A69A),
                );
              },
            ),
            belowBarData: BarAreaData(
                show: true, color: const Color(0xFF26A69A).withOpacity(0.12)),
          ),
        ],
      )),
    );
  }

  Future<void> _generateGasPdf(BuildContext context) async {
    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(0xFF26A69A);
    final companyBlue = PdfColor.fromInt(0xFF1565C0);

    Map<String, List<Map<String, dynamic>>> byFluido = {};
    for (var doc in gasDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final fluido = data['FLUIDO']?.toString().trim() ?? '';
      final qtd = double.tryParse(data['QUANTIDADE']?.toString() ?? '') ?? 0;
      if (fluido.isEmpty || qtd <= 0) continue;
      byFluido.putIfAbsent(fluido, () => []).add(data);
    }

    double totalGeral = gasMap.values.fold(0.0, (a, b) => a + b);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 20, marginBottom: 20, marginLeft: 20, marginRight: 20),
      build: (pw.Context ctx) => [
        pw.Column(children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("RELATÓRIO DE CONSUMO DE FLUÍDOS REFRIGERANTES",
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: themeColor)),
                    pw.SizedBox(height: 2),
                    pw.Text("HPS REFRIGERAÇÃO",
                        style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: companyBlue)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                        "AV. Pará 486 - Ibirapuera, Vitória da Conquista - BA",
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("Tel: 77 98819-4630 ou 98861-2447",
                        style: const pw.TextStyle(fontSize: 9)),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.RichText(
                        text: pw.TextSpan(
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
                      children: [
                        pw.TextSpan(
                            text: "Período: ",
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.TextSpan(
                            text: _periodoLabel,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    )),
                    pw.SizedBox(height: 2),
                    pw.Text(
                        "Emissão: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
                        style: const pw.TextStyle(fontSize: 8)),
                  ]),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Divider(thickness: 1.5, color: themeColor),
          pw.SizedBox(height: 10),
        ]),
        pw.Text("RESUMO POR FLUIDO REFRIGERANTE",
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: themeColor)),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: themeColor),
              children: [
                _cell("FLUIDO / GÁS", bold: true, white: true),
                _cell("QTDE TOTAL", bold: true, white: true),
                _cell("Nº OS", bold: true, white: true),
              ],
            ),
            ...byFluido.entries.map((e) {
              double tot = e.value.fold(
                  0,
                  (s, d) =>
                      s +
                      (double.tryParse(d['QUANTIDADE']?.toString() ?? '') ??
                          0));
              return pw.TableRow(children: [
                _cell(e.key),
                _cell("${tot.toStringAsFixed(2)} kg", bold: true),
                _cell("${e.value.length}"),
              ]);
            }),
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _cell("TOTAL GERAL", bold: true),
                _cell("${totalGeral.toStringAsFixed(2)} kg", bold: true),
                _cell("${gasDocs.length}", bold: true),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text("DETALHAMENTO POR ORDEM DE SERVIÇO",
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: themeColor)),
        pw.SizedBox(height: 8),
        ...byFluido.entries
            .expand((entry) => [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFE0F2F1),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text("Fluido: ${entry.key}",
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: themeColor)),
                  ),
                  pw.SizedBox(height: 6),
                  ...entry.value.map((data) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8, left: 8),
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.grey300, width: 0.5),
                            borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: pw.BoxDecoration(
                                          color: themeColor,
                                          borderRadius:
                                              pw.BorderRadius.circular(2)),
                                      child: pw.Text(
                                          "OS: ${data['NUMERO_OS'] ?? '-'}",
                                          style: pw.TextStyle(
                                              color: PdfColors.white,
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 8)),
                                    ),
                                    pw.Text(
                                        "Quantidade: ${data['QUANTIDADE'] ?? '-'} kg",
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9)),
                                  ]),
                              pw.SizedBox(height: 6),
                              pw.Row(children: [
                                pw.Expanded(
                                    child: _infoBlock(
                                        "Equipamento", data['EQUIPAMENTO'])),
                                pw.Expanded(
                                    child: _infoBlock(
                                        "Patrimônio", data['PATRIMONIO'])),
                                pw.Expanded(
                                    child: _infoBlock("Setor", data['SETOR'])),
                              ]),
                              pw.SizedBox(height: 4),
                              pw.Row(children: [
                                pw.Expanded(
                                    child: _infoBlock(
                                        "Técnico", data['TECNICORESPONSAVEL'])),
                                pw.Expanded(
                                    child: _infoBlock(
                                        "Data Término", data['DATA_TERMINO'])),
                                pw.Expanded(
                                    child: _infoBlock("Marca/Modelo",
                                        "${data['MARCA'] ?? '-'} / ${data['MODELO'] ?? '-'}")),
                              ]),
                              pw.SizedBox(height: 4),
                              pw.Row(children: [
                                pw.Expanded(
                                    child: _infoBlock("Serviço Realizado",
                                        data['SERVICOREALIZADO'])),
                                pw.Expanded(
                                  child: _infoBlockColored(
                                    "Status",
                                    data['STATUS']?.toString() ?? '-',
                                    (data['STATUS']
                                                ?.toString()
                                                .toLowerCase()
                                                .contains('conclu') ==
                                            true)
                                        ? PdfColor.fromInt(0xFF26A69A)
                                        : PdfColor.fromInt(0xFFFFB300),
                                  ),
                                ),
                              ]),
                            ]),
                      )),
                  pw.SizedBox(height: 8),
                ])
            .toList(),
      ],
    ));

    String fileMonth = selectedMonth != null
        ? getMonthName(selectedMonth!).substring(0, 3).toUpperCase()
        : "ANUAL";
    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Relatorio_Gases_HPS_${fileMonth}_$selectedYear.pdf');
  }

  pw.Widget _cell(String text, {bool bold = false, bool white = false}) =>
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Text(text,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: white ? PdfColors.white : PdfColors.black)));

  pw.Widget _infoBlock(String label, dynamic value) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label.toUpperCase(),
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Text(value?.toString() ?? '-',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ]);

  pw.Widget _infoBlockColored(String label, String value, PdfColor color) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label.toUpperCase(),
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: color)),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    final entries = gasMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalGas = gasMap.values.fold(0.0, (s, v) => s + v);
    final temDadosLinha = gasoPorMes.values.any((v) => v > 0);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.gas_meter_outlined,
              color: Color(0xFF26A69A), size: 18),
          const SizedBox(width: 6),
          Expanded(
              child: Text("Consumo de Fluídos Refrigerantes",
                  style: theme.bodyLarge.override(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.bold))),
          InkWell(
            onTap: () => _showFullscreen(context,
                "Consumo de Fluídos — $_periodoLabel", _buildLineChart()),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child:
                  Icon(Icons.fullscreen, color: theme.secondaryText, size: 20),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _generateGasPdf(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFF26A69A),
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text("Baixar PDF",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Align(
            alignment: Alignment.centerRight,
            child: Text(
                entries.isEmpty
                    ? "Nenhum registro no período"
                    : "Total: ${totalGas.toStringAsFixed(2)} kg",
                style: theme.bodySmall.override(
                    fontFamily: 'Readex Pro',
                    color: entries.isEmpty
                        ? theme.secondaryText
                        : const Color(0xFF26A69A),
                    fontWeight: FontWeight.bold))),
        if (temDadosLinha) ...[
          const SizedBox(height: 12),
          Text("Consumo mensal em $selectedYear",
              style: theme.bodySmall.override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                  color: theme.secondaryText)),
          const SizedBox(height: 8),
          _buildLineChart(),
        ],
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Icon(Icons.info_outline, color: theme.secondaryText, size: 28),
              const SizedBox(height: 6),
              Text("Nenhum dado de gás encontrado\npara o período selecionado",
                  textAlign: TextAlign.center, style: theme.bodySmall),
            ]),
          )
        else
          ...entries.asMap().entries.map((e) {
            final idx = e.key;
            final fluido = e.value.key;
            final qtd = e.value.value;
            final barFrac = totalGas > 0 ? qtd / entries.first.value : 0.0;
            final color = _color(idx);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(fluido,
                              style: theme.bodyMedium.override(
                                  fontFamily: 'Readex Pro', fontSize: 12),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text("${qtd.toStringAsFixed(2)} kg",
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 5),
                    Stack(children: [
                      Container(
                          height: 10,
                          decoration: BoxDecoration(
                              color: theme.alternate,
                              borderRadius: BorderRadius.circular(8))),
                      FractionallySizedBox(
                        widthFactor: barFrac.toDouble(),
                        child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ]),
                  ]),
            );
          }).toList(),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════
//  MAINTENANCE LIST WIDGET
// ═════════════════════════════════════════════════════════
class MaintenanceListWidget extends StatelessWidget {
  final List<DocumentSnapshot> docs;
  final String monthName;
  final String year;

  const MaintenanceListWidget(
      {Key? key,
      required this.docs,
      required this.monthName,
      required this.year})
      : super(key: key);

  Future<void> _generateAndSharePdf(BuildContext context) async {
    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(0xFF26A69A);
    final companyBlue = PdfColor.fromInt(0xFF1565C0);

    String displayMonth = monthName.length > 3
        ? monthName.substring(0, 3).toUpperCase()
        : monthName.toUpperCase();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 20, marginBottom: 20, marginLeft: 20, marginRight: 20),
      build: (pw.Context context) {
        return [
          pw.Column(children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("RELATÓRIO TÉCNICO DE MANUTENÇÃO",
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: themeColor)),
                      pw.SizedBox(height: 2),
                      pw.Text("HPS REFRIGERAÇÃO",
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: companyBlue)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                          "AV. Pará 486 - Ibirapuera, Vitória da Conquista - BA",
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text("Tel: 77 98819-4630 ou 98861-2447",
                          style: const pw.TextStyle(fontSize: 10)),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.RichText(
                          text: pw.TextSpan(
                              style: pw.TextStyle(
                                  fontSize: 11, color: PdfColors.black),
                              children: [
                            pw.TextSpan(
                                text: "Período: ",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.TextSpan(
                                text: "$displayMonth / $year",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ])),
                      pw.SizedBox(height: 2),
                      pw.Text(
                          "Emissão: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
                          style: const pw.TextStyle(fontSize: 9)),
                    ]),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(thickness: 1.5, color: themeColor),
            pw.SizedBox(height: 10),
          ]),
          ...docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.white),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: pw.BoxDecoration(
                                  color: themeColor,
                                  borderRadius: pw.BorderRadius.circular(2)),
                              child: pw.Text(
                                  "ORDEM DE SERVIÇO: ${data['NUMERO_OS'] ?? '-'}",
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 9))),
                          pw.Text("Término: ${data['DATA_TERMINO'] ?? '-'}",
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ]),
                    pw.SizedBox(height: 8),
                    pw.Row(children: [
                      pw.Expanded(
                          child: _pdfInfoBlock(
                              "Equipamento", data['EQUIPAMENTO'])),
                      pw.Expanded(
                          child:
                              _pdfInfoBlock("Patrimônio", data['PATRIMONIO'])),
                      pw.Expanded(child: _pdfInfoBlock("Setor", data['SETOR'])),
                    ]),
                    pw.SizedBox(height: 6),
                    pw.Row(children: [
                      pw.Expanded(child: _pdfInfoBlock("Sala", data['SALA'])),
                      pw.Expanded(
                          child: _pdfInfoBlock(
                              "Técnico", data['TECNICORESPONSAVEL'])),
                      pw.Expanded(
                          child: _pdfInfoBlock("Marca/Modelo",
                              "${data['MARCA'] ?? ''} / ${data['MODELO'] ?? ''}")),
                    ]),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey200),
                    pw.SizedBox(height: 4),
                    pw.Text("SERVIÇO REALIZADO:",
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: themeColor)),
                    pw.Text("${data['SERVICOREALIZADO'] ?? '-'}",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text("DETALHES/DESCRIÇÃO:",
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text("${data['DESCRICAODOSERVICO'] ?? 'Sem descrição'}",
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey700)),
                  ]),
            );
          }).toList(),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(color: PdfColors.grey100),
                  child: pw.Text(
                      "TOTAL DE ATENDIMENTOS NO PERÍODO: ${docs.length}",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)))),
        ];
      },
    ));
    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Relatorio_HPS_${monthName}_$year.pdf');
  }

  pw.Widget _pdfInfoBlock(String label, dynamic value) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label.toUpperCase(),
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Text(value?.toString() ?? '-',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))
      ]);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Map<String, List<DocumentSnapshot>> groupedData = {};
    for (var doc in docs) {
      String name = (doc.data() as Map<String, dynamic>)['SERVICOREALIZADO']
              ?.toString() ??
          'Não Informado';
      groupedData.putIfAbsent(name, () => []).add(doc);
    }
    final keys = groupedData.keys.toList();

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ── Cabeçalho moderno com gradiente ──────────────
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF00796B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.build_circle_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$monthName / $year",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${docs.length} ${docs.length == 1 ? 'serviço' : 'serviços'}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded,
                color: Colors.white, size: 20),
            onPressed: () => _generateAndSharePdf(context),
            tooltip: "Compartilhar PDF",
          ),
          IconButton(
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ]),
      ),

      // ── Lista de serviços ────────────────────────────
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: keys.length,
          itemBuilder: (context, i) {
            final k = keys[i];
            final items = groupedData[k]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDetailsModal(context, items),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.alternate, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(children: [
                      // Ícone com fundo colorido
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(_getIcon(k),
                            color: const Color(0xFF26A69A), size: 18),
                      ),
                      const SizedBox(width: 12),
                      // Nome do serviço
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryText,
                                )),
                            if (items.length > 1)
                              Text("${items.length} ocorrências",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.secondaryText,
                                  )),
                          ],
                        ),
                      ),
                      // Badge de quantidade
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${items.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded,
                          color: theme.secondaryText, size: 20),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════
  //  MODAL DE DETALHES — Layout igual à imagem 2
  //  • Foto do equipamento no topo
  //  • Linhas "Label | Valor" alinhadas (label esquerda, valor direita)
  //  • Grupos separados por Divider
  // ══════════════════════════════════════════════════════════
  void _showDetailsModal(BuildContext context, List<DocumentSnapshot> items) {
    final theme = FlutterFlowTheme.of(context);
    showDialog(
        context: context,
        builder: (context) => Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                    maxWidth: 550,
                    maxHeight: MediaQuery.of(context).size.height * 0.92),
                decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // ── Cabeçalho gradiente ─────────────────
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF26A69A), Color(0xFF00796B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_outlined,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Serviço Realizado",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2)),
                            Text(
                              "${items.length} ${items.length == 1 ? 'registro' : 'registros'}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context)),
                    ]),
                  ),
                  // ── Lista de OS ─────────────────────────
                  Flexible(
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (c, i) => Divider(
                              height: 1,
                              thickness: 6,
                              color: theme.primaryBackground),
                          itemBuilder: (c, i) =>
                              _buildDetailCard(items[i], theme))),
                ]),
              ),
            ));
  }

  // ──────────────────────────────────────────────────────────
  //  Card de detalhe — moderno com seções, badges e ícones
  // ──────────────────────────────────────────────────────────
  Widget _buildDetailCard(DocumentSnapshot doc, FlutterFlowTheme theme) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['STATUS']?.toString() ?? '-';
    final isConcluida = status.toLowerCase().contains('conclu');
    final patrimonio = data['PATRIMONIO']?.toString() ?? '';

    final rawPecas = data['PECAS'] ?? data['pecas'];
    List<String> listaPecas = [];
    if (rawPecas is List) {
      listaPecas = rawPecas.map((e) => e.toString()).toList();
    } else if (rawPecas != null && rawPecas.toString().trim().isNotEmpty) {
      listaPecas.add(rawPecas.toString());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Foto via coleção IMAGENS ─────────────────────
        FutureBuilder<QuerySnapshot>(
          future: patrimonio.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('IMAGENS')
                  .where('PATRIMONIO', isEqualTo: patrimonio)
                  .limit(1)
                  .get()
              : Future.value(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                color: theme.primaryBackground,
                child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A))),
              );
            }
            String? urlImagem;
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.docs.isNotEmpty) {
              final docImg =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;
              urlImagem = docImg['IMAGEM']?.toString();
            }
            if (urlImagem != null && urlImagem.isNotEmpty) {
              return Stack(children: [
                Image.network(
                  urlImagem,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fotoPlaceholder(theme),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 210,
                      color: theme.primaryBackground,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: const Color(0xFF26A69A),
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null)),
                    );
                  },
                ),
                // Overlay com OS + Status sobre a foto
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "OS: ${data['NUMERO_OS'] ?? '-'}",
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
            return _fotoPlaceholder(theme);
          },
        ),

        // ── Campos ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quando não há foto, mostra OS+Status aqui
              FutureBuilder<QuerySnapshot>(
                future: patrimonio.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('IMAGENS')
                        .where('PATRIMONIO', isEqualTo: patrimonio)
                        .limit(1)
                        .get()
                    : Future.value(null),
                builder: (context, snapshot) {
                  final temFoto = snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.docs.isNotEmpty &&
                      ((snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>)['IMAGEM']
                              ?.toString()
                              .isNotEmpty ==
                          true);
                  if (temFoto ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  // Sem foto: mostra OS + status em card compacto
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("OS: ${data['NUMERO_OS'] ?? '-'}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: theme.primaryText)),
                        _statusBadge(status, isConcluida),
                      ],
                    ),
                  );
                },
              ),

              // ── Seção: Localização ─────────────────────
              _sectionHeader("Localização", Icons.location_on_outlined, theme),
              _modernRow("Setor", data['SETOR']?.toString() ?? '-', theme),
              _modernRow(
                  "Sala / Local", data['SALA']?.toString() ?? '-', theme),

              // ── Seção: Equipamento ─────────────────────
              _sectionHeader("Equipamento", Icons.ac_unit_outlined, theme),
              _modernRow(
                  "Equipamento", data['EQUIPAMENTO']?.toString() ?? '-', theme),
              _modernRow("Marca", data['MARCA']?.toString() ?? '-', theme),
              _modernRow("Modelo", data['MODELO']?.toString() ?? '-', theme),
              _modernRow(
                  "Patrimônio", patrimonio.isEmpty ? '-' : patrimonio, theme),
              if (_hasValue(data['BTUS']))
                _modernRow("BTUs/Potência", data['BTUS'].toString(), theme),
              if (_hasValue(data['FLUIDO']))
                _modernRow("Fluido", data['FLUIDO'].toString(), theme),

              // ── Seção: Datas & Técnico ─────────────────
              _sectionHeader(
                  "Datas & Técnico", Icons.calendar_today_outlined, theme),
              _modernRow("Data Manutenção",
                  _formatDate(data['DATADAMANUTENCAO']), theme),
              _modernRow(
                  "Data Término", _formatDate(data['DATA_TERMINO']), theme),
              _modernRow("Mês/Ano",
                  "${data['MES'] ?? '-'} / ${data['ANO'] ?? '-'}", theme),
              _modernRow("Técnico",
                  data['TECNICORESPONSAVEL']?.toString() ?? '-', theme),

              // ── Seção: Serviço ─────────────────────────
              _sectionHeader("Serviço", Icons.build_outlined, theme),
              _modernRow(
                  "Defeito Relatado",
                  data['DEFEITO']?.toString() ??
                      data['DEFEITORELATADO']?.toString() ??
                      '-',
                  theme),
              _modernRow("Serviço Realizado",
                  data['SERVICOREALIZADO']?.toString() ?? '-', theme),
              _modernRow("Descrição Detalhada",
                  data['DESCRICAODOSERVICO']?.toString() ?? '-', theme),

              // ── Seção: Peças ───────────────────────────
              if (listaPecas.isNotEmpty) ...[
                _sectionHeader(
                    "Peças Utilizadas", Icons.handyman_outlined, theme),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.alternate),
                  ),
                  child: Column(
                    children: listaPecas.asMap().entries.map((e) {
                      final isLast = e.key == listaPecas.length - 1;
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF26A69A),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.primaryText,
                                  )),
                            ),
                          ]),
                        ),
                        if (!isLast) Divider(height: 1, color: theme.alternate),
                      ]);
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers de UI ───────────────────────────────────────

  /// Badge colorido para status
  Widget _statusBadge(String status, bool isConcluida) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:
              isConcluida ? const Color(0xFF26A69A) : const Color(0xFFFF8F00),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
      );

  /// Título de seção com ícone e linha divisora
  Widget _sectionHeader(String title, IconData icon, FlutterFlowTheme theme) =>
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(children: [
          Icon(icon, color: const Color(0xFF26A69A), size: 15),
          const SizedBox(width: 6),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF26A69A),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
          const SizedBox(width: 8),
          Expanded(
              child: Divider(
                  height: 1, color: const Color(0xFF26A69A).withOpacity(0.3))),
        ]),
      );

  /// Linha label | valor — sem fundo alternado, clean
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

  // ── helpers ─────────────────────────────────────────────

  /// Formata qualquer campo de data — aceita Timestamp, String ou null
  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    if (raw is Timestamp) {
      final dt = raw.toDate();
      return DateFormat('dd/MM/yyyy').format(dt);
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return '-';
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(trimmed)) return trimmed;
      try {
        final dt = DateTime.parse(trimmed);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        return trimmed.split(' ').first;
      }
    }
    return raw.toString();
  }

  bool _hasValue(dynamic v) => v != null && v.toString().trim().isNotEmpty;

  Widget _fotoPlaceholder(FlutterFlowTheme theme) => Container(
        height: 160,
        color: theme.primaryBackground,
        child: Center(
          child: Icon(Icons.ac_unit,
              color: const Color(0xFF26A69A).withOpacity(0.25), size: 60),
        ),
      );

  /// Mantido para compatibilidade com código antigo
  Widget _infoRow(String label, String value, FlutterFlowTheme theme,
          {Color? valueColor, bool valueBold = false}) =>
      _modernRow(label, value, theme);

  Widget _groupDivider(FlutterFlowTheme theme) => const SizedBox.shrink();

  IconData _getIcon(String n) {
    final l = n.toLowerCase();
    if (l.contains('ar')) return Icons.ac_unit;
    if (l.contains('instala')) return Icons.build;
    return Icons.build_circle_outlined;
  }
}
