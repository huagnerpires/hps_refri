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
import 'package:firebase_auth/firebase_auth.dart';

class BuscaPreventivasModal extends StatefulWidget {
  const BuscaPreventivasModal({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _BuscaPreventivasModalState createState() => _BuscaPreventivasModalState();
}

class _BuscaPreventivasModalState extends State<BuscaPreventivasModal> {
  List<String> _mesesDisponiveis = [];
  List<String> _anosDisponiveis = [];
  String? _mesSelecionado;
  String? _anoSelecionado;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('PREVENTIVAS').get();
      Set<String> mesesSet = {};
      Set<String> anosSet = {};

      for (var doc in querySnapshot.docs) {
        // --- CORREÇÃO AQUI: Cast super seguro para Web e Mobile ---
        final rawData = doc.data();
        if (rawData == null) continue;

        final Map<String, dynamic> data =
            Map<String, dynamic>.from(rawData as Map);
        // ----------------------------------------------------------

        if (data.containsKey('MES') && data['MES'] != null) {
          mesesSet.add(data['MES'].toString().toUpperCase());
        }
        if (data.containsKey('ANO') && data['ANO'] != null) {
          anosSet.add(data['ANO'].toString());
        }
      }

      const ordemMeses = {
        'JANEIRO': 1,
        'FEVEREIRO': 2,
        'MARÇO': 3,
        'ABRIL': 4,
        'MAIO': 5,
        'JUNHO': 6,
        'JULHO': 7,
        'AGOSTO': 8,
        'SETEMBRO': 9,
        'OUTUBRO': 10,
        'NOVEMBRO': 11,
        'DEZEMBRO': 12,
      };

      setState(() {
        _mesesDisponiveis = mesesSet.toList()
          ..sort((a, b) => (ordemMeses[b] ?? 0).compareTo(ordemMeses[a] ?? 0));
        _anosDisponiveis = anosSet.toList()..sort((a, b) => b.compareTo(a));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── CORES MODERNAS E ADAPTATIVAS ──────────────────────
    final bgColor = isDark ? const Color(0xFF181824) : const Color(0xFFFFFFFF);
    final textPrimary =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textHint = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    final borderColor =
        isDark ? const Color(0xFF2D2D3F) : const Color(0xFFE2E8F0);
    final dropdownBg =
        isDark ? const Color(0xFF222232) : const Color(0xFFF8FAFC);
    final iconColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final closeBg = isDark ? const Color(0xFF222232) : const Color(0xFFF1F5F9);
    final closeIcon =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final dividerColor =
        isDark ? const Color(0xFF2D2D3F) : const Color(0xFFF1F5F9);

    // Cores da Marca / Primary
    final primaryColor = const Color(0xFF39D2C0);
    final primaryDarker = const Color(0xFF2BA898);

    return Container(
      width: widget.width ?? double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 100 : 20),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── DRAG HANDLE ──────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF33334D)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withAlpha(40),
                                      primaryColor.withAlpha(10),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryColor.withAlpha(50),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(Icons.tune_rounded,
                                    color: primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Filtrar Preventivas',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Selecione o período do relatório',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botão fechar
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.pop(context),
                            child: Ink(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: closeBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded,
                                  size: 16, color: closeIcon),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(height: 1, thickness: 1.5, color: dividerColor),
                    const SizedBox(height: 16),

                    // ── CONTEÚDO ─────────────────────────────
                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 3,
                                  backgroundColor: primaryColor.withAlpha(30),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Carregando períodos disponíveis...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_errorMessage.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withAlpha(20),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.redAccent.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_rounded,
                                  color: Colors.redAccent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // ── Dropdown Mês ──────────────────────
                      Text(
                        'Mês Referência',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        hint: 'Selecione o mês',
                        value: _mesSelecionado,
                        items: _mesesDisponiveis,
                        iconData: Icons.calendar_month_rounded,
                        onChanged: (val) =>
                            setState(() => _mesSelecionado = val),
                        isDark: isDark,
                        bgColor: dropdownBg,
                        borderColor: borderColor,
                        textColor: textPrimary,
                        hintColor: textHint,
                        iconColor: iconColor,
                        primaryColor: primaryColor,
                      ),

                      const SizedBox(height: 16),

                      // ── Dropdown Ano ──────────────────────
                      Text(
                        'Ano Referência',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        hint: 'Selecione o ano',
                        value: _anoSelecionado,
                        items: _anosDisponiveis,
                        iconData: Icons.access_time_filled_rounded,
                        onChanged: (val) =>
                            setState(() => _anoSelecionado = val),
                        isDark: isDark,
                        bgColor: dropdownBg,
                        borderColor: borderColor,
                        textColor: textPrimary,
                        hintColor: textHint,
                        iconColor: iconColor,
                        primaryColor: primaryColor,
                      ),

                      const SizedBox(height: 24),

                      // ── Botão Buscar Animado ──────────────────────
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: (_mesSelecionado != null &&
                                  _anoSelecionado != null)
                              ? LinearGradient(
                                  colors: [primaryColor, primaryDarker],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: (_mesSelecionado == null ||
                                  _anoSelecionado == null)
                              ? (isDark
                                  ? const Color(0xFF2D2D3F)
                                  : const Color(0xFFE2E8F0))
                              : null,
                          boxShadow: (_mesSelecionado != null &&
                                  _anoSelecionado != null)
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withAlpha(80),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: (_mesSelecionado == null ||
                                    _anoSelecionado == null)
                                ? null
                                : () async {
                                    final currentUser =
                                        FirebaseAuth.instance.currentUser;
                                    final String userEmail =
                                        currentUser?.email ?? '';
                                    Navigator.pop(context);
                                    if (context.mounted) {
                                      context.pushNamed(
                                        'visualizar_preventiva',
                                        queryParameters: {
                                          'mes': _mesSelecionado!,
                                          'ano': _anoSelecionado!,
                                          'email': userEmail,
                                        },
                                      );
                                    }
                                  },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: (_mesSelecionado == null ||
                                            _anoSelecionado == null)
                                        ? textHint
                                        : Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Buscar Relatórios',
                                    style: TextStyle(
                                      color: (_mesSelecionado == null ||
                                              _anoSelecionado == null)
                                          ? textHint
                                          : Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData iconData,
    required Function(String?) onChanged,
    required bool isDark,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
    required Color iconColor,
    required Color primaryColor,
  }) {
    final bool isSelected = value != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withAlpha(10) : bgColor,
        border: Border.all(
          color: isSelected ? primaryColor : borderColor,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: 8,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isSelected ? primaryColor : iconColor,
            size: 22,
          ),
          hint: Row(
            children: [
              Icon(iconData, size: 16, color: hintColor),
              const SizedBox(width: 8),
              Text(
                hint,
                style: TextStyle(
                  color: hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          value: value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Row(
                children: [
                  Icon(
                    iconData,
                    size: 16,
                    color:
                        value == val ? primaryColor : iconColor.withAlpha(150),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    val,
                    style: TextStyle(
                      color: value == val ? primaryColor : textColor,
                      fontWeight:
                          value == val ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
