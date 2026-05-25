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
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GerenciarAcesso extends StatefulWidget {
  const GerenciarAcesso({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<GerenciarAcesso> createState() => _GerenciarAcessoState();
}

class _GerenciarAcessoState extends State<GerenciarAcesso> {
  static const Color _primary = Color(0xFF39D2C0);
  static const Color _dark = Color(0xFF00897B);

  String _busca = '';
  String _filtro = 'todos'; // todos | liberados | bloqueados
  final _buscaCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  // ── Liberar ou bloquear acesso ───────────────────────────────────────────
  Future<void> _togglePermissao(
    DocumentReference ref,
    bool atual,
    String nome,
    String email,
  ) async {
    final novoValor = !atual;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(
            novoValor ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: novoValor ? _primary : Colors.red,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              novoValor ? 'Liberar Acesso' : 'Bloquear Acesso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: novoValor ? _primary : Colors.red,
              ),
            ),
          ),
        ]),
        content: Text(
          novoValor
              ? 'Liberar acesso ao financeiro para $nome?'
              : 'Bloquear acesso ao financeiro de $nome?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: novoValor ? _primary : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              novoValor ? 'Liberar' : 'Bloquear',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ref.update({
        'permissao': novoValor,
        'PERMISSAO': novoValor,
      });

      // Notificar o usuário via OneSignal se liberado
      if (novoValor && email.isNotEmpty) {
        try {
          // Buscar apikey
          String apiKey = '';
          final snapU = await FirebaseFirestore.instance
              .collection('USUARIOS')
              .where('email', isEqualTo: 'hpsrefri@gmail.com')
              .limit(1)
              .get();
          if (snapU.docs.isNotEmpty) {
            apiKey = (snapU.docs.first.data()['apibrevo'] ?? '').toString();
          }

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
                  'value': email,
                }
              ],
              'headings': {'en': 'Acesso Liberado'},
              'contents': {
                'en':
                    'Seu acesso ao financeiro foi liberado! Abra o app e acesse a aba Financeiro.'
              },
              'android_channel_id': '577bba44-d1bf-4ac9-9d11-20d89e09a61a',
              'priority': 10,
            }),
          );
        } catch (_) {}

        // Notificação no Firestore para o usuário
        try {
          await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
            'email': email,
            'titulo': 'Acesso ao Financeiro Liberado',
            'mensagem':
                'Seu acesso ao financeiro foi liberado! Acesse a aba Financeiro no app.',
            'tipo': 'sistema',
            'visto': false,
            'data': Timestamp.now(),
            'status': 'ativo',
            'os': '',
          });
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(novoValor
              ? 'Acesso liberado para $nome'
              : 'Acesso bloqueado para $nome'),
          backgroundColor: novoValor ? _primary : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Excluir usuário ──────────────────────────────────────────────────────
  Future<void> _excluir(DocumentReference ref, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.delete_forever_rounded, color: Colors.red, size: 22),
          SizedBox(width: 10),
          Text('Excluir Usuário',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ]),
        content: Text('Excluir $nome da área restrita?',
            style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ref.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$nome removido'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? double.infinity;

    return SizedBox(
      width: w,
      height: h,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _dark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Gerenciar Acesso Financeiro',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 12),
                // Barra de busca
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (v) => setState(() => _busca = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou email...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white, size: 18),
                      suffixIcon: _busca.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                              onPressed: () {
                                _buscaCtrl.clear();
                                setState(() => _busca = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filtros
                Row(children: [
                  _filtroChip('todos', 'Todos', Icons.people_rounded),
                  const SizedBox(width: 8),
                  _filtroChip(
                      'liberados', 'Liberados', Icons.lock_open_rounded),
                  const SizedBox(width: 8),
                  _filtroChip('bloqueados', 'Bloqueados', Icons.lock_rounded),
                ]),
              ],
            ),
          ),

          // ── Lista ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('AREA_RESTRITA')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _primary));
                }

                var docs = snapshot.data!.docs;

                // Filtrar por permissão
                if (_filtro == 'liberados') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['permissao'] == true ||
                        data['PERMISSAO'] == true;
                  }).toList();
                } else if (_filtro == 'bloqueados') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['permissao'] != true &&
                        data['PERMISSAO'] != true;
                  }).toList();
                }

                // Filtrar por busca
                if (_busca.isNotEmpty) {
                  final q = _busca.toLowerCase();
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final nome =
                        (data['NOMEDOUSUARIO'] ?? '').toString().toLowerCase();
                    final email =
                        (data['ID_DO_CELULAR'] ?? '').toString().toLowerCase();
                    final cargo =
                        (data['cargo'] ?? '').toString().toLowerCase();
                    return nome.contains(q) ||
                        email.contains(q) ||
                        cargo.contains(q);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 48,
                            color: theme.secondaryText.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text('Nenhum usuário encontrado',
                            style: GoogleFonts.inter(
                                color: theme.secondaryText, fontSize: 14)),
                      ],
                    ),
                  );
                }

                // Contar totais
                final total = snapshot.data!.docs.length;
                final liberados = snapshot.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['permissao'] == true || data['PERMISSAO'] == true;
                }).length;

                return Column(
                  children: [
                    // Resumo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.grey.withOpacity(0.06),
                      child: Row(children: [
                        _resumoBadge('$total', 'Total', Colors.grey, theme),
                        const SizedBox(width: 12),
                        _resumoBadge(
                            '$liberados', 'Liberados', _primary, theme),
                        const SizedBox(width: 12),
                        _resumoBadge('${total - liberados}', 'Bloqueados',
                            Colors.red, theme),
                      ]),
                    ),
                    // Cards
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final doc = docs[i];
                          final data = doc.data() as Map<String, dynamic>;
                          final nome =
                              (data['NOMEDOUSUARIO'] ?? 'Sem nome').toString();
                          final email =
                              (data['ID_DO_CELULAR'] ?? '').toString();
                          final cargo = (data['cargo'] ?? '').toString();
                          final temPerm = data['permissao'] == true ||
                              data['PERMISSAO'] == true;
                          final temUid =
                              (data['UID'] ?? '').toString().isNotEmpty;
                          final temDevice =
                              (data['DEVICE_ID'] ?? '').toString().isNotEmpty;

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: temPerm
                                    ? _primary.withOpacity(0.3)
                                    : theme.alternate,
                                width: temPerm ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.2 : 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    // Avatar
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: temPerm
                                            ? _primary.withOpacity(0.12)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: temPerm ? _primary : Colors.red,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(nome,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: theme.primaryText)),
                                          if (cargo.isNotEmpty)
                                            Text(cargo,
                                                style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color:
                                                        theme.secondaryText)),
                                        ],
                                      ),
                                    ),
                                    // Badge de status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: temPerm
                                            ? _primary.withOpacity(0.12)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: temPerm
                                              ? _primary.withOpacity(0.4)
                                              : Colors.red.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        temPerm ? 'Liberado' : 'Bloqueado',
                                        style: TextStyle(
                                          color:
                                              temPerm ? _primary : Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 10),
                                  // Email
                                  Row(children: [
                                    Icon(Icons.email_outlined,
                                        size: 13,
                                        color: theme.secondaryText
                                            .withOpacity(0.6)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        email.isNotEmpty ? email : '-',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: theme.secondaryText),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 4),
                                  // Indicadores de dispositivo
                                  Row(children: [
                                    _indicador('UID', temUid, theme),
                                    const SizedBox(width: 8),
                                    _indicador('Device', temDevice, theme),
                                  ]),
                                  const SizedBox(height: 12),
                                  // Botões
                                  Row(children: [
                                    // Toggle permissão
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _togglePermissao(
                                          doc.reference,
                                          temPerm,
                                          nome,
                                          email,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: temPerm
                                                  ? [
                                                      Colors.red,
                                                      Colors.red.shade700
                                                    ]
                                                  : [_primary, _dark],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                temPerm
                                                    ? Icons.lock_rounded
                                                    : Icons.lock_open_rounded,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                temPerm
                                                    ? 'Bloquear'
                                                    : 'Liberar',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Excluir
                                    GestureDetector(
                                      onTap: () =>
                                          _excluir(doc.reference, nome),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color:
                                                  Colors.red.withOpacity(0.3)),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String valor, String label, IconData icon) {
    final ativo = _filtro == valor;
    return GestureDetector(
      onTap: () => setState(() => _filtro = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ativo ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 13, color: ativo ? _dark : Colors.white.withOpacity(0.8)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ativo ? _dark : Colors.white.withOpacity(0.9),
              )),
        ]),
      ),
    );
  }

  Widget _resumoBadge(
      String valor, String label, Color cor, FlutterFlowTheme theme) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text('$valor $label',
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.secondaryText)),
    ]);
  }

  Widget _indicador(String label, bool ativo, FlutterFlowTheme theme) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(
        ativo ? Icons.check_circle_outline : Icons.radio_button_unchecked,
        size: 11,
        color: ativo ? _primary : theme.secondaryText.withOpacity(0.4),
      ),
      const SizedBox(width: 3),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              color: ativo ? _primary : theme.secondaryText.withOpacity(0.4))),
    ]);
  }
}
