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

import 'package:cloud_firestore/cloud_firestore.dart';

class PopupDemonstrativo extends StatefulWidget {
  const PopupDemonstrativo({
    Key? key,
    this.width,
    this.height,
    required this.emailParam,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String emailParam;

  @override
  _PopupDemonstrativoState createState() => _PopupDemonstrativoState();
}

class _PopupDemonstrativoState extends State<PopupDemonstrativo> {
  String formatarNome(String text) {
    if (text.isEmpty) return "Indefinido";
    try {
      text = text.trim();
      return text.split(' ').map((word) {
        if (word.isEmpty) return '';
        if (word.length == 1) return word.toUpperCase();
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    } catch (e) {
      return text;
    }
  }

  String buscarNomeValido(Map<String, dynamic> data) {
    List<String> camposParaChecar = [
      'NOME',
      'EQUIPAMENTO',
      'nome',
      'equipamento',
      'CATEGORIA'
    ];

    for (String campo in camposParaChecar) {
      if (data.containsKey(campo) && data[campo] != null) {
        String valor = data[campo].toString().trim();
        if (valor.isNotEmpty) return valor;
      }
    }
    return "Outros";
  }

  bool buscarContrato(Map<String, dynamic> data) {
    if (data.containsKey('CONTRATO') && data['CONTRATO'] != null) {
      return data['CONTRATO'] == true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color brandColor = const Color(0xFF68DDC5);
    final Color contractColor = const Color(0xFF4CAF82);
    final Color noContractColor = const Color(0xFFFF7043);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: widget.width ?? 360,
      constraints: BoxConstraints(
        maxHeight: widget.height ?? (screenHeight * 0.82),
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            color: Colors.black.withOpacity(0.18),
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('EQUIPAMENTOS_EMPRESA')
              .where('EMAIL', isEqualTo: widget.emailParam)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    color: brandColor,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            // Estrutura: { label: { total, comContrato } }
            Map<String, Map<String, int>> categoriasInfo = {};
            int totalEquipamentos = 0;
            int totalComContrato = 0;

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;

              String rawName = buscarNomeValido(data);
              String label = formatarNome(rawName);
              bool temContrato = buscarContrato(data);

              if (!categoriasInfo.containsKey(label)) {
                categoriasInfo[label] = {'total': 0, 'comContrato': 0};
              }
              categoriasInfo[label]!['total'] =
                  categoriasInfo[label]!['total']! + 1;
              if (temContrato) {
                categoriasInfo[label]!['comContrato'] =
                    categoriasInfo[label]!['comContrato']! + 1;
                totalComContrato++;
              }

              totalEquipamentos++;
            }

            var sortedKeys = categoriasInfo.keys.toList()..sort();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── HEADER com gradiente ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brandColor.withOpacity(isDark ? 0.25 : 0.15),
                        brandColor.withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícone
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: brandColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: brandColor.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demonstrativo',
                              style: theme.headlineMedium.override(
                                fontFamily: 'Outfit',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Resumo de equipamentos',
                              style: theme.bodySmall.override(
                                fontFamily: 'Outfit',
                                color: theme.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botão Fechar
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryText.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: theme.secondaryText,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── CORPO ──
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cards de totais
                        Row(
                          children: [
                            // Total geral
                            Expanded(
                              child: _StatCard(
                                label: 'Total',
                                value: '$totalEquipamentos',
                                icon: Icons.devices_rounded,
                                accentColor: brandColor,
                                theme: theme,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Com contrato
                            Expanded(
                              child: _StatCard(
                                label: 'C/ Contrato',
                                value: '$totalComContrato',
                                icon: Icons.verified_rounded,
                                accentColor: contractColor,
                                theme: theme,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Sem contrato
                            Expanded(
                              child: _StatCard(
                                label: 'S/ Contrato',
                                value:
                                    '${totalEquipamentos - totalComContrato}',
                                icon: Icons.cancel_rounded,
                                accentColor: noContractColor,
                                theme: theme,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Título da lista
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 16,
                              decoration: BoxDecoration(
                                color: brandColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Por Categoria',
                              style: theme.titleSmall.override(
                                fontFamily: 'Outfit',
                                color: theme.primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Lista de categorias
                        ...sortedKeys.map((key) {
                          final info = categoriasInfo[key]!;
                          final total = info['total']!;
                          final comContrato = info['comContrato']!;
                          final semContrato = total - comContrato;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.04)
                                    : Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.07)
                                      : Colors.black.withOpacity(0.06),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Nome da categoria
                                  Expanded(
                                    child: Text(
                                      key,
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'Outfit',
                                        color: theme.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Badge contrato
                                  if (comContrato > 0)
                                    _ContractBadge(
                                      label: 'Contrato $comContrato',
                                      color: contractColor,
                                      icon: Icons.check_circle_rounded,
                                    ),
                                  if (comContrato > 0 && semContrato > 0)
                                    const SizedBox(width: 6),
                                  // Badge sem contrato
                                  if (semContrato > 0)
                                    _ContractBadge(
                                      label: 'S/contrato $semContrato',
                                      color: noContractColor,
                                      icon:
                                          Icons.radio_button_unchecked_rounded,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
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
}

// ── Widget auxiliar: card de estatística ──
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final dynamic theme;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: theme.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget auxiliar: badge de contrato ──
class _ContractBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _ContractBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
