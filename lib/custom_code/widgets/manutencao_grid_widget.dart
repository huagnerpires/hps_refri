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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'index.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ManutencaoGridWidget extends StatefulWidget {
  const ManutencaoGridWidget({
    Key? key,
    this.width,
    this.height,
    required this.statusFiltro,
    required this.senhaAppState,
    this.emailFiltro = '',
    this.numeroOSInicial,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String statusFiltro;
  final String senhaAppState;
  final String emailFiltro;
  final String? numeroOSInicial;

  @override
  State<ManutencaoGridWidget> createState() => _ManutencaoGridWidgetState();
}

class _ManutencaoGridWidgetState extends State<ManutencaoGridWidget>
    with TickerProviderStateMixin {
  static const String _oneSignalAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const String _oneSignalApiKey =
      'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
  static const String _emailFixo = 'hpsrefri@gmail.com';

  static const Color _primary = Color(0xFF00897B);
  static const Color _primaryDark = Color(0xFF00695C);
  static const Color _red = Color(0xFFEF5350);
  static const Color _orange = Color(0xFFFF7043);
  static const Color _blue = Color(0xFF1E88E5);
  static const Color _green = Color(0xFF43A047);
  static const Color _purple = Color(0xFF8E24AA);
  static const Color _grey = Color(0xFF9E9E9E);

  int _currentView = 0;
  Map<String, dynamic>? _selectedData;
  String? _selectedDocId;
  String? _selectedImg;

  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, String> _imgCache = {};
  late AnimationController _toggleAnim;
  late Stream<QuerySnapshot> _stream;

  bool _initialLoadDone = false;

  Stream<QuerySnapshot> _buildStream() {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('MANUTENCAO')
        .where('EMAIL', isEqualTo: widget.emailFiltro);
    if (widget.statusFiltro.isNotEmpty) {
      q = q.where('STATUS', isEqualTo: widget.statusFiltro);
    }
    return q.snapshots();
  }

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _stream = _buildStream();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _limparConcluidas();
      if ((widget.numeroOSInicial ?? '').isNotEmpty) {
        _abrirOSPorNumero(widget.numeroOSInicial!);
      }
    });
  }

  @override
  void didUpdateWidget(ManutencaoGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emailFiltro != widget.emailFiltro ||
        oldWidget.statusFiltro != widget.statusFiltro) {
      setState(() {
        _stream = _buildStream();
        _currentView = 0;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _toggleAnim.dispose();
    super.dispose();
  }

  Future<void> _abrirOSPorNumero(String numeroOS) async {
    if (_initialLoadDone) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('MANUTENCAO')
          .where('NUMERO_OS', isEqualTo: numeroOS)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        if (mounted) setState(() => _initialLoadDone = true);
        return;
      }

      final doc = snap.docs.first;
      final data = doc.data();
      final pat = data['PATRIMONIO']?.toString() ?? '';
      final img = await _getImagem(pat);

      if (mounted) {
        setState(() {
          _selectedData = data;
          _selectedDocId = doc.id;
          _selectedImg = img;
          _currentView = 1;
          _initialLoadDone = true;
        });
      }
    } catch (e) {
      debugPrint('Erro ao abrir OS #$numeroOS: $e');
      if (mounted) setState(() => _initialLoadDone = true);
    }
  }

  Future<void> _limparConcluidas() async {
    try {
      final limite = DateTime.now().subtract(const Duration(days: 15));
      final snap = await FirebaseFirestore.instance
          .collection('MANUTENCAO')
          .where('STATUS', isEqualTo: 'CONCLUÍDA')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      int count = 0;

      DateTime? extrairData(dynamic raw) {
        if (raw == null) return null;
        if (raw is Timestamp) return raw.toDate();
        if (raw is String && raw.trim().isNotEmpty) {
          try {
            if (raw.contains('/')) {
              final parts = raw.split('/');
              if (parts.length >= 3) {
                final dia = int.parse(parts[0]);
                final mes = int.parse(parts[1]);
                final anoStr = parts[2].trim().split(RegExp(r'\s+'))[0];
                final ano = int.parse(
                    anoStr.length >= 4 ? anoStr.substring(0, 4) : anoStr);
                return DateTime(ano, mes, dia);
              }
            } else {
              return DateTime.tryParse(raw);
            }
          } catch (_) {}
        }
        return null;
      }

      for (final doc in snap.docs) {
        final data = doc.data();
        DateTime? dataBase = extrairData(data['DATA_TERMINO']);
        if (dataBase == null) {
          dataBase =
              extrairData(data['DATADAMANUTENÇÃO'] ?? data['DATADAMANUTENCAO']);
        }

        if (dataBase != null && dataBase.isBefore(limite)) {
          batch.delete(doc.reference);
          count++;
        }
      }

      if (count > 0) await batch.commit();
    } catch (e) {
      debugPrint('Erro ao limpar O.S.: $e');
    }
  }

  Color _cardColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1E2A2A)
          : Colors.white;

  Color _surfaceColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF121C1C)
          : const Color(0xFFF4F7F7);

  Color _textPrimary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF263238);

  Color _textSecondary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF90A4AE)
          : const Color(0xFF546E7A);

  Color _dividerColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white.withAlpha(18)
          : Colors.black.withAlpha(12);

  Color _statusColor(String s) {
    final u = s.toUpperCase();
    if (u.contains('AGUARDANDO AVALIA')) return _blue;
    if (u.contains('AGUARDANDO PE')) return _orange;
    if (u.contains('AGUARDANDO APROVA')) return _orange;
    if (u.contains('APROVADO')) return _green;
    if (u.contains('REPROVA')) return _red;
    if (u.contains('CONCLU')) return _primary;
    if (u.contains('EM ANDAMENTO')) return _purple;
    return _grey;
  }

  IconData _statusIcon(String s) {
    final u = s.toUpperCase();
    if (u.contains('AGUARDANDO AVALIA')) return Icons.rate_review_outlined;
    if (u.contains('AGUARDANDO PE')) return Icons.hourglass_top_rounded;
    if (u.contains('AGUARDANDO APROVA')) return Icons.pending_outlined;
    if (u.contains('APROVADO')) return Icons.check_circle_outline;
    if (u.contains('REPROVA')) return Icons.cancel_outlined;
    if (u.contains('CONCLU')) return Icons.task_alt_outlined;
    if (u.contains('EM ANDAMENTO')) return Icons.autorenew_rounded;
    return Icons.help_outline;
  }

  Future<String?> _getImagem(String patrimonio) async {
    if (patrimonio.isEmpty) return null;
    if (_imgCache.containsKey(patrimonio)) return _imgCache[patrimonio];
    try {
      final q = await FirebaseFirestore.instance
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final url = q.docs.first['IMAGEM'] as String?;
        if (url != null && url.isNotEmpty) {
          _imgCache[patrimonio] = url;
          return url;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _notify(
      String novoStatus, String os, String equip, String sala) async {
    String titulo;
    String mensagem;

    switch (novoStatus.toUpperCase()) {
      case 'APROVADO':
        titulo = '👍 Orçamento Aprovado';
        mensagem =
            'Orçamento da O.S #$os aprovado! Vamos iniciar o serviço em breve.';
        break;
      case 'REPROVADO':
        titulo = '❌ Orçamento Reprovado';
        mensagem =
            'O orçamento da O.S #$os foi reprovado. Entre em contato para mais informações.';
        break;
      default:
        titulo = 'ORÇAMENTO $novoStatus';
        mensagem = 'O.S #$os · $equip — Sala: $sala foi $novoStatus.';
    }

    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'filters': [
            {
              'field': 'tag',
              'key': 'Email',
              'relation': '=',
              'value': _emailFixo
            },
          ],
          'headings': {'en': titulo},
          'contents': {'en': mensagem},
          'android_channel_id': '577bba44-d1bf-4ac9-9d11-20d89e09a61a',
          'priority': 10,
        }),
      );
    } catch (_) {}
  }

  Future<List<String>> _buscarEmailsParaNotificar() async {
    const emailPrincipal = _emailFixo;
    final destinos = <String>[emailPrincipal];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: emailPrincipal)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final field = snap.docs.first.data()['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty && !destinos.contains(s)) destinos.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          final s = field.trim();
          if (!destinos.contains(s)) destinos.add(s);
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar emailteste: $e');
    }
    return destinos;
  }

  Future<void> _sendEmailGrid({
    required String toEmail,
    required String status,
    required String numeroos,
    required String equip,
    required String sala,
    required String cliente,
    required String patrimonio,
  }) async {
    if (toEmail.isEmpty) return;

    const senderEmail = 'equipe@hpsrefri.com.br';
    const senderName = 'HPS Refrigeração';
    const imgUrl =
        'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';

    String apiKey = '';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        apiKey = (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
      }
    } catch (e) {
      debugPrint('Erro ao buscar apibrevo: $e');
    }
    if (apiKey.isEmpty) return;
    final nomeCliente =
        cliente.trim().isNotEmpty ? cliente.trim() : 'o cliente';

    final String emoji;
    final String titulo;
    final String tagline;
    final String corHex;
    final String corpo;
    final String detalhe;

    if (status == 'APROVADO') {
      emoji = '👍';
      titulo = 'Orçamento Aprovado pelo Cliente — O.S #$numeroos';
      tagline = 'O cliente $nomeCliente aprovou o orçamento da O.S #$numeroos.';
      corHex = '#10B981';
      corpo =
          'Informamos que o cliente <strong>$nomeCliente</strong> <strong>aprovou o orçamento</strong> '
          'da <strong>O.S #$numeroos</strong>. '
          'A equipe técnica já pode dar início à execução do serviço.';
      detalhe =
          '🗓️&nbsp;&nbsp;Agende com a equipe técnica a data e horário para início do serviço na O.S #$numeroos.';
    } else {
      emoji = '❌';
      titulo = 'Orçamento Reprovado pelo Cliente — O.S #$numeroos';
      tagline =
          'O cliente $nomeCliente reprovou o orçamento da O.S #$numeroos.';
      corHex = '#EF4444';
      corpo =
          'Informamos que o cliente <strong>$nomeCliente</strong> <strong>reprovou o orçamento</strong> '
          'da <strong>O.S #$numeroos</strong>. '
          'Entre em contato com o cliente para entender os motivos e negociar uma nova proposta.';
      detalhe =
          'ℹ️&nbsp;&nbsp;Analise os itens do orçamento e entre em contato com o cliente para renegociação.';
    }

    final htmlBody = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>$titulo</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0"
         style="background-color:#f4f6f8;padding:20px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" border="0"
             style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">
        <tr>
          <td style="padding:0;margin:0;line-height:0;">
            <img src="$imgUrl" alt="HPS Refrigeração" width="600"
                 style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/>
          </td>
        </tr>
        <tr>
          <td style="background-color:$corHex;padding:12px 24px;">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td>
                  <span style="color:#ffffff;font-size:13px;font-weight:bold;font-family:Arial,sans-serif;">
                    $emoji&nbsp;&nbsp;ORÇAMENTO $status PELO CLIENTE
                  </span>
                </td>
                <td align="right">
                  <span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;
                               padding:4px 10px;border-radius:20px;font-family:Arial,sans-serif;">
                    Notificação Interna
                  </span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="padding:28px 28px 12px 28px;text-align:center;">
            <h1 style="margin:0 0 8px 0;font-size:20px;font-weight:bold;
                       color:#1A3C34;font-family:Arial,sans-serif;">
              $titulo
            </h1>
            <p style="margin:0;font-size:13px;color:#64748b;font-family:Arial,sans-serif;">
              $tagline
            </p>
          </td>
        </tr>
        <tr>
          <td style="padding:12px 28px 20px 28px;font-family:Arial,Helvetica,sans-serif;">
            <p style="margin:0 0 16px 0;font-size:15px;color:#1f2937;line-height:1.7;">
              Equipe HPS Refrigeração,
            </p>
            <p style="margin:0 0 20px 0;font-size:15px;color:#374151;line-height:1.7;">
              $corpo
            </p>
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="background:#f0fdf4;border-left:4px solid $corHex;
                          border-radius:0 8px 8px 0;margin-bottom:24px;">
              <tr>
                <td style="padding:14px 16px;font-size:14px;color:#14532d;
                           line-height:1.6;font-family:Arial,sans-serif;">
                  $detalhe
                </td>
              </tr>
            </table>
            <table width="100%" cellpadding="0" cellspacing="0" border="0"
                   style="border-collapse:collapse;border-radius:8px;overflow:hidden;
                          border:1px solid #e2e8f0;margin-bottom:24px;
                          font-size:14px;font-family:Arial,sans-serif;">
              <tr>
                <td colspan="2" style="background:#1A3C34;padding:10px 14px;">
                  <span style="color:#ffffff;font-size:13px;font-weight:bold;letter-spacing:0.5px;">
                    DETALHES DA ORDEM DE SERVIÇO
                  </span>
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           width:160px;border-bottom:1px solid #e2e8f0;">N° da O.S</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  <strong>#$numeroos</strong>
                </td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Cliente</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  <strong>$nomeCliente</strong>
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Equipamento</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $equip
                </td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Sala</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $sala
                </td>
              </tr>
              <tr>
                <td style="padding:10px 14px;font-weight:bold;color:#374151;
                           border-bottom:1px solid #e2e8f0;">Patrimônio</td>
                <td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">
                  $patrimonio
                </td>
              </tr>
              <tr style="background:#f8fafc;">
                <td style="padding:10px 14px;font-weight:bold;color:#374151;">Situação</td>
                <td style="padding:10px 14px;">
                  <span style="background-color:$corHex;color:#ffffff;font-size:11px;
                               font-weight:bold;padding:4px 10px;border-radius:12px;">
                    $emoji $status PELO CLIENTE
                  </span>
                </td>
              </tr>
            </table>
            <p style="margin:0 0 8px 0;font-size:14px;color:#64748b;line-height:1.6;">
              Este e-mail é de uso interno da equipe HPS Refrigeração.
            </p>
          </td>
        </tr>
        <tr>
          <td style="padding:0 28px;">
            <hr style="border:none;border-top:1px solid #e8ecf0;margin:0;">
          </td>
        </tr>
        <tr>
          <td style="padding:20px 28px;font-family:Arial,Helvetica,sans-serif;">
            <table cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td style="width:44px;vertical-align:top;">
                  <div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;
                              text-align:center;line-height:40px;">
                    <span style="color:#ffffff;font-size:18px;font-weight:bold;
                                 font-family:Arial,sans-serif;">H</span>
                  </div>
                </td>
                <td style="padding-left:12px;vertical-align:top;">
                  <span style="font-size:15px;font-weight:bold;color:#1A3C34;
                               font-family:Arial,sans-serif;">Huagner Pires</span><br>
                  <span style="font-size:13px;color:#555555;font-family:Arial,sans-serif;">
                    Especialista em Refrigeração
                  </span><br>
                  <span style="font-size:12px;color:#888888;font-family:Arial,sans-serif;">
                    hpsrefri.com.br
                  </span>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td style="background:#f1f5f9;padding:14px 28px;text-align:center;
                     font-size:12px;color:#94a3b8;font-family:Arial,Helvetica,sans-serif;
                     border-top:1px solid #e2e8f0;">
            &copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>
            <span style="font-size:11px;">
              Notificação interna automática — não responda diretamente.
            </span>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
''';

    try {
      await http.post(
        Uri.parse('https://api.brevo.com/v3/smtp/email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'api-key': apiKey,
        },
        body: jsonEncode({
          'sender': {'name': senderName, 'email': senderEmail},
          'replyTo': {'name': senderName, 'email': senderEmail},
          'to': [
            {'email': toEmail}
          ],
          'subject': titulo,
          'htmlContent': htmlBody,
        }),
      );
    } catch (e) {
      debugPrint('❌ Erro ao enviar e-mail ($status): $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  _fmt — trata Timestamp, String dd/MM/yyyy e ISO
  // ═══════════════════════════════════════════════════════════════
  String _fmt(dynamic v) {
    if (v == null) return '—';
    if (v is Timestamp) {
      final d = v.toDate();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return '—';
      // Já está no formato dd/MM/yyyy — retorna direto
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(s)) return s;
      // Tenta ISO (yyyy-MM-dd ou similar)
      final parsed = DateTime.tryParse(s);
      if (parsed != null) {
        return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      }
      return s;
    }
    return v.toString();
  }

  void _showImageFullscreen(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withAlpha(220),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                            color: _primary, strokeWidth: 2)),
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 60),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgPlaceholder({Color? bg}) => Container(
        color: bg ?? const Color(0xFFF0F4F4),
        child: const Center(
          child:
              Icon(Icons.ac_unit_outlined, color: Color(0xFFB2DFDB), size: 32),
        ),
      );

  void _abrirDetalhesTela(Map<String, dynamic> d, String docId, String? img) {
    setState(() {
      _selectedData = d;
      _selectedDocId = docId;
      _selectedImg = img;
      _currentView = 1;
    });
  }

  Widget _buildGridCard(
      BuildContext ctx, Map<String, dynamic> d, String docId, String? img) {
    final status = d['STATUS']?.toString() ?? '';
    final sColor = _statusColor(status);
    final sIcon = _statusIcon(status);
    final os = d['NUMERO_OS']?.toString() ?? '';
    final sala = d['SALA']?.toString() ?? '—';
    final pat = d['PATRIMONIO']?.toString() ?? '—';
    final tecnico = d['TECNICORESPONSAVEL']?.toString() ?? '';
    final dataStr = _fmt(d['DATADAMANUTENÇÃO'] ?? d['DATADAMANUTENCAO']);
    final previsaoPeca = d['PREVISAODAPECA']?.toString() ?? '';
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _abrirDetalhesTela(d, docId, img),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor(ctx),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(60)
                  : Colors.black.withAlpha(16),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: img != null
                    ? CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => AspectRatio(
                          aspectRatio: 4 / 3,
                          child: _imgPlaceholder(),
                        ),
                        errorWidget: (_, __, ___) => AspectRatio(
                          aspectRatio: 4 / 3,
                          child: _imgPlaceholder(),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _imgPlaceholder(),
                      ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withAlpha(210), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('OS #$os',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: sColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: sColor.withAlpha(120), blurRadius: 5)
                    ],
                  ),
                  child: Icon(sIcon, color: Colors.white, size: 10),
                ),
              ),
              if (img != null)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _showImageFullscreen(ctx, img),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fullscreen_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              Positioned(
                bottom: 5,
                left: 7,
                right: 7,
                child: Text(d['EQUIPAMENTO']?.toString() ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(color: Colors.black, blurRadius: 3)]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 9, color: _textSecondary(ctx)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(sala,
                          style: TextStyle(
                              fontSize: 9,
                              color: _textSecondary(ctx),
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.qr_code_scanner_outlined,
                        size: 9, color: _textSecondary(ctx)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(pat,
                          style: TextStyle(
                              fontSize: 9,
                              color: _textSecondary(ctx),
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 9, color: _textSecondary(ctx)),
                    const SizedBox(width: 3),
                    Text(dataStr,
                        style: TextStyle(
                            fontSize: 9,
                            color: _textSecondary(ctx),
                            fontWeight: FontWeight.w500)),
                  ]),
                  // ── PREVISÃO DA PEÇA — grid card ──────────────
                  if (previsaoPeca.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 9, color: _orange),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text('Prev: ${_fmt(previsaoPeca)}',
                            style: const TextStyle(
                                fontSize: 8,
                                color: _orange,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                  if (tecnico.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.person_outline,
                          size: 9, color: _textSecondary(ctx)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(tecnico,
                            style: TextStyle(
                                fontSize: 9,
                                color: _textSecondary(ctx),
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: sColor.withAlpha(isDark ? 35 : 18),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: sColor.withAlpha(60), width: 0.8),
                    ),
                    child: Row(children: [
                      Icon(sIcon, size: 9, color: sColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(status.toUpperCase(),
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: sColor,
                                letterSpacing: 0.3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(
      BuildContext ctx, Map<String, dynamic> d, String docId, String? img) {
    final status = d['STATUS']?.toString() ?? '';
    final sColor = _statusColor(status);
    final sIcon = _statusIcon(status);
    final previsaoPeca = d['PREVISAODAPECA']?.toString() ?? '';
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _abrirDetalhesTela(d, docId, img),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _cardColor(ctx),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(60)
                  : Colors.black.withAlpha(12),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 135,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: sColor),
              SizedBox(
                width: 110,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: img != null
                          ? CachedNetworkImage(
                              imageUrl: img,
                              fit: BoxFit.cover,
                              width: 110,
                              height: double.infinity,
                              placeholder: (_, __) => Container(
                                color: isDark
                                    ? const Color(0xFF1A2626)
                                    : const Color(0xFFF0F4F4),
                                child: const Center(
                                  child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: _primary)),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: isDark
                                    ? const Color(0xFF1A2626)
                                    : const Color(0xFFF0F4F4),
                                child: const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        color: Color(0xFFB2DFDB), size: 26)),
                              ),
                            )
                          : Container(
                              color: isDark
                                  ? const Color(0xFF1A2626)
                                  : const Color(0xFFF0F4F4),
                              child: const Center(
                                  child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xFFB2DFDB),
                                      size: 26)),
                            ),
                    ),
                    if (img != null)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.fullscreen_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('OS #${d['NUMERO_OS'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryDark,
                                  letterSpacing: 0.3)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(d['EQUIPAMENTO']?.toString() ?? '—',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary(ctx)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 10, color: _textSecondary(ctx)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(d['SALA']?.toString() ?? '—',
                              style: TextStyle(
                                  fontSize: 10, color: _textSecondary(ctx)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.qr_code_scanner_outlined,
                            size: 10, color: _textSecondary(ctx)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(d['PATRIMONIO']?.toString() ?? '—',
                              style: TextStyle(
                                  fontSize: 10, color: _textSecondary(ctx)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: _textSecondary(ctx)),
                        const SizedBox(width: 4),
                        Text(
                            _fmt(
                                d['DATADAMANUTENÇÃO'] ?? d['DATADAMANUTENCAO']),
                            style: TextStyle(
                                fontSize: 11, color: _textSecondary(ctx))),
                      ]),
                      // ── PREVISÃO DA PEÇA — list card ──────────
                      if (previsaoPeca.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 11, color: _orange),
                          const SizedBox(width: 4),
                          Text('Prev. peça: ${_fmt(previsaoPeca)}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: _orange,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: sColor.withAlpha(isDark ? 35 : 18),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: sColor.withAlpha(60), width: 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(sIcon, size: 10, color: sColor),
                          const SizedBox(width: 4),
                          Text(status,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: sColor,
                                  letterSpacing: 0.3)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  child: Icon(Icons.chevron_right_rounded,
                      color: _textSecondary(ctx).withAlpha(80), size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalhesView(BuildContext context) {
    final d = _selectedData!;
    final docId = _selectedDocId!;
    final img = _selectedImg;

    final status = d['STATUS']?.toString() ?? '';
    final sColor = _statusColor(status);
    final isConcluida = status.toUpperCase().contains('CONCLU');
    final isAguardandoAprovacao =
        status.toUpperCase().contains('AGUARDANDO APROVA');
    final os = d['NUMERO_OS']?.toString() ?? '';
    final mes = (d['MES']?.toString() ?? '').toUpperCase();
    final ano = d['ANO']?.toString() ?? '';
    final patrimonio = d['PATRIMONIO']?.toString() ?? '';
    final previsaoPeca = d['PREVISAODAPECA']?.toString() ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetCardBg = _cardColor(context);
    final sheetDivColor = _dividerColor(context);
    final sheetTextMain = _textPrimary(context);
    final sheetTextSub = _textSecondary(context);
    final sheetSurfBg = _surfaceColor(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: img != null
                        ? CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: sheetCardBg,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: _primary, strokeWidth: 2))),
                            errorWidget: (_, __, ___) => _imgPlaceholder())
                        : _imgPlaceholder(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(90),
                            Colors.transparent,
                            Colors.black.withAlpha(160)
                          ],
                          stops: const [0, 0.4, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 14,
                    left: 14,
                    child: GestureDetector(
                      onTap: () {
                        if ((widget.numeroOSInicial ?? '').isNotEmpty) {
                          Navigator.pop(context);
                        } else {
                          setState(() => _currentView = 0);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: _primary.withAlpha(120),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.qr_code_scanner_outlined,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 5),
                        Text(patrimonio,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  if (mes.isNotEmpty)
                    Positioned(
                      bottom: 60,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black.withAlpha(130),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(mes,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1)),
                              if (ano.isNotEmpty)
                                Text(ano,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withAlpha(180),
                                        fontWeight: FontWeight.w600)),
                            ]),
                      ),
                    ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withAlpha(60), width: 1),
                        ),
                        child: Text('OS #$os',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: sColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: sColor.withAlpha(100),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_statusIcon(status),
                              color: Colors.white, size: 12),
                          const SizedBox(width: 5),
                          Text(status,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ]),
                  ),
                  if (img != null)
                    Positioned(
                      bottom: 60,
                      left: 14,
                      child: GestureDetector(
                        onTap: () => _showImageFullscreen(context, img),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fullscreen_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: sheetCardBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeaderCaptured(
                        sheetCardBg,
                        sheetTextMain,
                        sheetDivColor,
                        isDark,
                        Icons.ac_unit_outlined,
                        'Equipamento'),
                    const SizedBox(height: 12),
                    _infoGridCaptured(sheetSurfBg, sheetTextSub, [
                      _InfoItem(
                          'EQUIPAMENTO', d['EQUIPAMENTO']?.toString() ?? '—'),
                      _InfoItem('FLUÍDO', d['FLUIDO']?.toString() ?? '—'),
                      _InfoItem('MARCA', d['MARCA']?.toString() ?? '—'),
                      _InfoItem('MODELO', d['MODELO']?.toString() ?? '—'),
                      _InfoItem('TIPO', d['TIPO']?.toString() ?? '—'),
                      _InfoItem('CAPACIDADE', d['BTUS']?.toString() ?? '—'),
                      _InfoItem('SALA', d['SALA']?.toString() ?? '—'),
                      _InfoItem('SETOR', d['SETOR']?.toString() ?? '—'),
                    ]),
                    const SizedBox(height: 24),
                    _sectionHeaderCaptured(
                        sheetCardBg,
                        sheetTextMain,
                        sheetDivColor,
                        isDark,
                        Icons.build_circle_outlined,
                        'Ordem de Serviço'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _primary.withAlpha(isDark ? 25 : 10),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: _primary.withAlpha(30), width: 1),
                      ),
                      child: Row(children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_primary, _primaryDark]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.build,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('OS #$os',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _primaryDark)),
                              Text('TÉCNICO',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: sheetTextSub.withAlpha(160))),
                              const SizedBox(height: 2),
                              Text(
                                  d['TECNICORESPONSAVEL']?.toString() ??
                                      'Não informado',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: sheetTextSub)),
                            ])),
                        if (isAguardandoAprovacao)
                          GestureDetector(
                            onTap: () => _showSenhaDialog(context, d, docId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFFF8A65),
                                  Color(0xFFFF5722)
                                ]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: _orange.withAlpha(100),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))
                                ],
                              ),
                              child: const Text('APROVAR\nORÇAMENTO',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      height: 1.4)),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    _sectionHeaderCaptured(
                        sheetCardBg,
                        sheetTextMain,
                        sheetDivColor,
                        isDark,
                        Icons.calendar_month_outlined,
                        'Datas'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _dateCardCaptured(
                            isDark,
                            'INÍCIO',
                            _fmt(
                                d['DATADAMANUTENÇÃO'] ?? d['DATADAMANUTENCAO']),
                            Icons.play_circle_outline,
                            _primary),
                      ),
                      if (isConcluida) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateCardCaptured(
                              isDark,
                              'TÉRMINO',
                              (d['DATA_TERMINO']?.toString() ?? '').isEmpty
                                  ? 'Não informado'
                                  : _fmt(d['DATA_TERMINO']),
                              (d['DATA_TERMINO']?.toString() ?? '').isEmpty
                                  ? Icons.help_outline
                                  : Icons.check_circle_outline,
                              (d['DATA_TERMINO']?.toString() ?? '').isEmpty
                                  ? _grey
                                  : _green),
                        ),
                      ],
                    ]),
                    // ── PREVISÃO DA PEÇA — tela de detalhes ──────
                    if (previsaoPeca.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _dateCardCaptured(
                          isDark,
                          'PREVISÃO DA PEÇA',
                          _fmt(previsaoPeca),
                          Icons.inventory_2_outlined,
                          _orange),
                    ],
                    if ((d['DEFEITO']?.toString() ?? '').isNotEmpty ||
                        (d['DESCRICAODOSERVICO']?.toString() ?? '')
                            .isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionHeaderCaptured(
                          sheetCardBg,
                          sheetTextMain,
                          sheetDivColor,
                          isDark,
                          Icons.report_problem_outlined,
                          'Informações do Serviço'),
                      const SizedBox(height: 12),
                      if ((d['DEFEITO']?.toString() ?? '').isNotEmpty)
                        _descCardCaptured(sheetSurfBg, isDark,
                            'DEFEITO RELATADO', d['DEFEITO'].toString(), _red),
                      if ((d['DESCRICAODOSERVICO']?.toString() ?? '')
                          .isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _descCardCaptured(
                            sheetSurfBg,
                            isDark,
                            'DESCRIÇÃO ADICIONAL',
                            d['DESCRICAODOSERVICO'].toString(),
                            _primary),
                      ],
                    ],
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrcamentoView(BuildContext context) {
    final d = _selectedData!;
    final docId = _selectedDocId!;
    final os = d['NUMERO_OS']?.toString() ?? '';
    final equip = d['EQUIPAMENTO']?.toString() ?? '';
    final sala = d['SALA']?.toString() ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetCardBg = _cardColor(context);
    final sheetDivColor = _dividerColor(context);
    final sheetTextMain = _textPrimary(context);
    final sheetTextSub = _textSecondary(context);
    final sheetSurfBg = _surfaceColor(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              14, MediaQuery.of(context).padding.top + 16, 20, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [_primaryDark, _primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentView = 1),
                child: Container(
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.receipt_long_outlined,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Orçamento para Aprovação',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                            Text('OS #$os  ·  $sala',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ])),
                    ]),
                    const SizedBox(height: 12),
                    Text(equip,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('MANUTENCAO')
                .doc(docId)
                .snapshots(),
            builder: (ctx2, snap) {
              if (!snap.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: _primary, strokeWidth: 2));
              }

              final data = snap.data!.data() as Map<String, dynamic>? ?? {};
              final pecas =
                  (data['PECAS'] as List?)?.map((e) => e.toString()).toList() ??
                      [];
              final valores = (data['VALOR'] as List?)
                      ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
                      .toList() ??
                  [];
              final total = valores.fold(0.0, (a, b) => a + b);

              final marca = data['MARCA']?.toString() ?? '—';
              final modelo = data['MODELO']?.toString() ?? '—';
              final fluido = data['FLUIDO']?.toString() ?? '—';
              final tipo = data['TIPO']?.toString() ?? '—';
              final btus = data['BTUS']?.toString() ?? '—';
              final tecnico = data['TECNICORESPONSAVEL']?.toString() ?? '—';
              // ── PREVISÃO DA PEÇA — tela de orçamento ─────────
              final previsaoPeca = data['PREVISAODAPECA']?.toString() ?? '';
              final previsaoFmt =
                  previsaoPeca.isNotEmpty ? _fmt(previsaoPeca) : '—';

              return Container(
                color: sheetCardBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    _sectionHeaderCaptured(
                        sheetCardBg,
                        sheetTextMain,
                        sheetDivColor,
                        isDark,
                        Icons.ac_unit_outlined,
                        'Dados Técnicos'),
                    const SizedBox(height: 12),
                    _infoGridCaptured(sheetSurfBg, sheetTextSub, [
                      _InfoItem('EQUIPAMENTO', equip),
                      _InfoItem('SALA', sala),
                      _InfoItem('MARCA', marca),
                      _InfoItem('MODELO', modelo),
                      _InfoItem('TIPO', tipo),
                      _InfoItem('FLUÍDO', fluido),
                      _InfoItem('CAPACIDADE', btus),
                      _InfoItem('TÉCNICO', tecnico),
                      _InfoItem('PREVISÃO DA PEÇA', previsaoFmt),
                    ]),
                    const SizedBox(height: 24),
                    _sectionHeaderCaptured(
                        sheetCardBg,
                        sheetTextMain,
                        sheetDivColor,
                        isDark,
                        Icons.build_outlined,
                        'Peças e Valores'),
                    const SizedBox(height: 12),
                    if (pecas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 44, color: sheetTextSub.withAlpha(60)),
                            const SizedBox(height: 8),
                            Text('Nenhuma peça cadastrada.',
                                style: TextStyle(color: sheetTextSub)),
                          ]),
                        ),
                      )
                    else
                      ...List.generate(pecas.length, (i) {
                        final v = i < valores.length ? valores[i] : 0.0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: sheetSurfBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: sheetDivColor),
                          ),
                          child: Row(children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [_primary, _primaryDark]),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(pecas[i],
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: sheetTextMain))),
                            Text('R\$ ${v.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _primary,
                                    fontSize: 13)),
                          ]),
                        );
                      }),
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _primary.withAlpha(isDark ? 30 : 12),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: _primary.withAlpha(40), width: 1),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL DO ORÇAMENTO',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                    color: sheetTextSub)),
                            Text('R\$ ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: _primaryDark)),
                          ]),
                    ),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _red, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.thumb_down_alt_outlined,
                              color: _red, size: 18),
                          label: const Text('REPROVAR',
                              style: TextStyle(
                                  color: _red,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13)),
                          onPressed: () async {
                            setState(() => _currentView = 0);
                            await FirebaseFirestore.instance
                                .collection('MANUTENCAO')
                                .doc(docId)
                                .update({'STATUS': 'REPROVADO'});
                            await _notify('REPROVADO', os, equip, sala);
                            String clienteNome =
                                d['CLIENTE']?.toString().trim() ?? '';
                            if (clienteNome.isEmpty) {
                              try {
                                final emailCliente =
                                    d['EMAIL']?.toString() ?? '';
                                if (emailCliente.isNotEmpty) {
                                  final snap = await FirebaseFirestore.instance
                                      .collection('USUARIOS')
                                      .where('email', isEqualTo: emailCliente)
                                      .limit(1)
                                      .get();
                                  if (snap.docs.isNotEmpty) {
                                    clienteNome = (snap.docs.first
                                                .data()['display_name'] ??
                                            '')
                                        .toString()
                                        .trim();
                                  }
                                }
                              } catch (_) {}
                            }
                            final destinos = await _buscarEmailsParaNotificar();
                            for (final mail in destinos) {
                              unawaited(_sendEmailGrid(
                                toEmail: mail,
                                status: 'REPROVADO',
                                numeroos: os,
                                equip: equip,
                                sala: sala,
                                cliente: clienteNome,
                                patrimonio: d['PATRIMONIO']?.toString() ?? '',
                              ));
                            }
                            if (mounted) _showResultAnim(context, false);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.thumb_up_alt_outlined,
                              color: Colors.white, size: 18),
                          label: const Text('APROVAR',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13)),
                          onPressed: () async {
                            setState(() => _currentView = 0);
                            await FirebaseFirestore.instance
                                .collection('MANUTENCAO')
                                .doc(docId)
                                .update({'STATUS': 'APROVADO'});
                            final srQuery = await FirebaseFirestore.instance
                                .collection('SERVICOSREALIZADOS')
                                .where('NUMERODAOS', isEqualTo: os)
                                .get();
                            for (final sr in srQuery.docs) {
                              await sr.reference.update({'STATUS': 'APROVADO'});
                            }
                            await _notify('APROVADO', os, equip, sala);
                            String clienteNome =
                                d['CLIENTE']?.toString().trim() ?? '';
                            if (clienteNome.isEmpty) {
                              try {
                                final emailCliente =
                                    d['EMAIL']?.toString() ?? '';
                                if (emailCliente.isNotEmpty) {
                                  final snap = await FirebaseFirestore.instance
                                      .collection('USUARIOS')
                                      .where('email', isEqualTo: emailCliente)
                                      .limit(1)
                                      .get();
                                  if (snap.docs.isNotEmpty) {
                                    clienteNome = (snap.docs.first
                                                .data()['display_name'] ??
                                            '')
                                        .toString()
                                        .trim();
                                  }
                                }
                              } catch (_) {}
                            }
                            final destinos = await _buscarEmailsParaNotificar();
                            for (final mail in destinos) {
                              unawaited(_sendEmailGrid(
                                toEmail: mail,
                                status: 'APROVADO',
                                numeroos: os,
                                equip: equip,
                                sala: sala,
                                cliente: clienteNome,
                                patrimonio: d['PATRIMONIO']?.toString() ?? '',
                              ));
                            }
                            if (mounted) _showResultAnim(context, true);
                          },
                        ),
                      ),
                    ]),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHeaderCaptured(Color cardBg, Color textMain, Color divColor,
          bool isDark, IconData icon, String label) =>
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _primary.withAlpha(isDark ? 35 : 18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: _primary),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: textMain)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: divColor, thickness: 1)),
        ],
      );

  Widget _infoGridCaptured(Color surfBg, Color textSub, List<_InfoItem> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final a = items[i];
      final b = i + 1 < items.length ? items[i + 1] : null;
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _infoCellCaptured(surfBg, textSub, a.label, a.value)),
          const SizedBox(width: 8),
          Expanded(
              child: b != null
                  ? _infoCellCaptured(surfBg, textSub, b.label, b.value)
                  : const SizedBox()),
        ]),
      ));
    }
    return Column(children: rows);
  }

  Widget _infoCellCaptured(
          Color surfBg, Color textSub, String label, String value) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: surfBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: textSub,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primaryDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _dateCardCaptured(
          bool isDark, String label, String date, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 30 : 12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40), width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color.withAlpha(180),
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Text(date,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ]),
      );

  Widget _descCardCaptured(
          Color surfBg, bool isDark, String title, String text, Color color) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 25 : 8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(30), width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color.withAlpha(180),
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.4)),
        ]),
      );

  void _showSenhaDialog(
      BuildContext ctx, Map<String, dynamic> d, String docId) {
    final cardBg = _cardColor(ctx);
    final textMain = _textPrimary(ctx);
    final textSub = _textSecondary(ctx);
    final ctrl = TextEditingController();

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dCtx) {
        bool hide = true;
        int erroTipo = 0;
        bool carregando = false;

        return StatefulBuilder(
          builder: (dCtx, ss) => AlertDialog(
            backgroundColor: cardBg,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_primary, _primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _primary.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Acesso Restrito',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textMain)),
              const SizedBox(height: 6),
              Text('Digite sua senha para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: textSub)),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                obscureText: hide,
                autofocus: true,
                style: TextStyle(color: textMain),
                onChanged: (_) {
                  if (erroTipo != 0) ss(() => erroTipo = 0);
                },
                onSubmitted: (_) async {
                  final digitada = ctrl.text.trim();
                  if (digitada.isEmpty) {
                    ss(() => erroTipo = 1);
                    return;
                  }
                  ss(() => carregando = true);
                  try {
                    final snap = await FirebaseFirestore.instance
                        .collection('USUARIOS')
                        .where('email', isEqualTo: _emailFixo)
                        .limit(1)
                        .get();
                    final senhaFirestore = snap.docs.isNotEmpty
                        ? (snap.docs.first.data()['senha'] ?? '')
                            .toString()
                            .trim()
                        : widget.senhaAppState.trim();
                    if (digitada == senhaFirestore) {
                      Navigator.pop(dCtx);
                      setState(() => _currentView = 2);
                    } else {
                      ss(() {
                        erroTipo = 2;
                        carregando = false;
                      });
                    }
                  } catch (_) {
                    final senhaFallback = widget.senhaAppState.trim();
                    if (digitada == senhaFallback) {
                      Navigator.pop(dCtx);
                      setState(() => _currentView = 2);
                    } else {
                      ss(() {
                        erroTipo = 2;
                        carregando = false;
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Senha de Acesso',
                  errorText: erroTipo == 1
                      ? 'Campo obrigatório'
                      : erroTipo == 2
                          ? 'Senha incorreta'
                          : null,
                  prefixIcon:
                      const Icon(Icons.vpn_key_outlined, color: _primary),
                  suffixIcon: IconButton(
                    icon: Icon(hide ? Icons.visibility_off : Icons.visibility,
                        color: _grey),
                    onPressed: () => ss(() => hide = !hide),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _primary, width: 2)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFEF5350), width: 1.5)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFEF5350), width: 2)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(height: 4),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: Text('Cancelar', style: TextStyle(color: textSub)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                onPressed: carregando
                    ? null
                    : () async {
                        final digitada = ctrl.text.trim();
                        if (digitada.isEmpty) {
                          ss(() => erroTipo = 1);
                          return;
                        }
                        ss(() => carregando = true);
                        try {
                          final snap = await FirebaseFirestore.instance
                              .collection('USUARIOS')
                              .where('email', isEqualTo: _emailFixo)
                              .limit(1)
                              .get();
                          final senhaFirestore = snap.docs.isNotEmpty
                              ? (snap.docs.first.data()['senha'] ?? '')
                                  .toString()
                                  .trim()
                              : widget.senhaAppState.trim();
                          if (digitada == senhaFirestore) {
                            Navigator.pop(dCtx);
                            setState(() => _currentView = 2);
                          } else {
                            ss(() {
                              erroTipo = 2;
                              carregando = false;
                            });
                          }
                        } catch (_) {
                          final senhaFallback = widget.senhaAppState.trim();
                          if (digitada == senhaFallback) {
                            Navigator.pop(dCtx);
                            setState(() => _currentView = 2);
                          } else {
                            ss(() {
                              erroTipo = 2;
                              carregando = false;
                            });
                          }
                        }
                      },
                child: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Confirmar',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResultAnim(BuildContext ctx, bool aprovado) {
    final overlay = Overlay.of(ctx);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ResultOverlay(
        aprovado: aprovado,
        onDone: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 1 && _selectedData != null) {
      return Material(
        color: _surfaceColor(context),
        child: _buildDetalhesView(context),
      );
    }
    if (_currentView == 2 && _selectedData != null) {
      return Material(
        color: _surfaceColor(context),
        child: _buildOrcamentoView(context),
      );
    }

    if ((widget.numeroOSInicial ?? '').isNotEmpty && !_initialLoadDone) {
      return Material(
        color: _surfaceColor(context),
        child: const Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: _surfaceColor(context),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        child: Builder(
          builder: (ctx) {
            final screenW = MediaQuery.of(context).size.width;
            final isMobile = screenW < 700;

            return Column(children: [
              Container(
                color: _cardColor(context),
                padding: EdgeInsets.fromLTRB(
                    14, 12 + MediaQuery.of(context).padding.top, 14, 12),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _surfaceColor(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _search.isNotEmpty
                              ? _primary.withAlpha(80)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) =>
                            setState(() => _search = v.toLowerCase()),
                        style: TextStyle(
                            fontSize: 13,
                            color: _textPrimary(context),
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Buscar O.S, sala, patrimônio...',
                          hintStyle: TextStyle(
                              color: _textSecondary(context), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: _primary, size: 20),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      size: 18, color: _textSecondary(context)),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  })
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _red.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _red.withAlpha(40), width: 1),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: _red, size: 22),
                    ),
                  ),
                ]),
              ),
              Container(height: 1, color: _dividerColor(context)),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  key: ValueKey('${widget.statusFiltro}_${widget.emailFiltro}'),
                  stream: _stream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: _primary, strokeWidth: 2));
                    }
                    if (snap.hasError) {
                      return Center(
                          child: Text('Erro: ${snap.error}',
                              style: const TextStyle(color: _red)));
                    }

                    var docs = snap.data?.docs ?? [];
                    if (docs.isEmpty)
                      return _emptyState(context, Icons.construction_outlined,
                          'Nenhum registro', 'Não há manutenções cadastradas.');

                    docs = List.from(docs)
                      ..sort((a, b) {
                        final mapA = a.data() as Map<String, dynamic>;
                        final mapB = b.data() as Map<String, dynamic>;

                        final da = mapA['DATA_ATUALIZACAO'] ??
                            mapA['DATA_ATUALIZACA0'] ??
                            mapA['DATADAMANUTENÇÃO'] ??
                            mapA['DATADAMANUTENCAO'] ??
                            mapA['DATA_TERMINO'];
                        final db = mapB['DATA_ATUALIZACAO'] ??
                            mapB['DATA_ATUALIZACA0'] ??
                            mapB['DATADAMANUTENÇÃO'] ??
                            mapB['DATADAMANUTENCAO'] ??
                            mapB['DATA_TERMINO'];

                        DateTime? ta, tb;
                        if (da is Timestamp)
                          ta = da.toDate();
                        else if (da is String && da.isNotEmpty)
                          ta = DateTime.tryParse(da);
                        if (db is Timestamp)
                          tb = db.toDate();
                        else if (db is String && db.isNotEmpty)
                          tb = DateTime.tryParse(db);

                        if (ta == null && tb == null) return 0;
                        if (ta == null) return 1;
                        if (tb == null) return -1;
                        return tb.compareTo(ta);
                      });

                    if (_search.isNotEmpty) {
                      docs = docs.where((doc) {
                        final m = doc.data() as Map<String, dynamic>;
                        return (m['NUMERO_OS']
                                    ?.toString()
                                    .toLowerCase()
                                    .contains(_search) ??
                                false) ||
                            (m['SALA']
                                    ?.toString()
                                    .toLowerCase()
                                    .contains(_search) ??
                                false) ||
                            (m['PATRIMONIO']
                                    ?.toString()
                                    .toLowerCase()
                                    .contains(_search) ??
                                false) ||
                            (m['EQUIPAMENTO']
                                    ?.toString()
                                    .toLowerCase()
                                    .contains(_search) ??
                                false);
                      }).toList();
                    }

                    if (docs.isEmpty)
                      return _emptyState(context, Icons.search_off_rounded,
                          'Sem resultados', 'Nenhum registro para "$_search".');

                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _primary.withAlpha(isDark ? 35 : 15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _primary.withAlpha(40), width: 1),
                            ),
                            child: Row(children: [
                              const Icon(Icons.assignment_outlined,
                                  size: 12, color: _primary),
                              const SizedBox(width: 5),
                              Text(
                                  '${docs.length} registro${docs.length != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _primary)),
                            ]),
                          ),
                          const Spacer(),
                          if (_search.isNotEmpty)
                            Text('Filtrando: "$_search"',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _textSecondary(context))),
                        ]),
                      ),
                      Expanded(
                        child: isMobile
                            ? _buildList(context, docs)
                            : _buildGrid(context, docs),
                      ),
                    ]);
                  },
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext ctx, List<QueryDocumentSnapshot> docs) {
    return LayoutBuilder(
      builder: (lCtx, constraints) {
        const columns = 4;
        const spacing = 10.0;
        const hPadding = 12.0;
        final cardWidth =
            (constraints.maxWidth - hPadding * 2 - spacing * (columns - 1)) /
                columns;

        final cards = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final pat = data['PATRIMONIO']?.toString() ?? '';
          return SizedBox(
            width: cardWidth,
            child: FutureBuilder<String?>(
              future: _getImagem(pat),
              builder: (c2, img) => _buildGridCard(c2, data, doc.id, img.data),
            ),
          );
        }).toList();

        return SingleChildScrollView(
          key: const ValueKey('grid'),
          padding: const EdgeInsets.fromLTRB(hPadding, 10, hPadding, 24),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: cards,
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext ctx, List<QueryDocumentSnapshot> docs) =>
      ListView.builder(
        key: const ValueKey('list'),
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 24),
        itemCount: docs.length,
        itemBuilder: (c, i) {
          final doc = docs[i];
          final data = doc.data() as Map<String, dynamic>;
          final pat = data['PATRIMONIO']?.toString() ?? '';
          return FutureBuilder<String?>(
            future: _getImagem(pat),
            builder: (c2, img) => _buildListCard(c2, data, doc.id, img.data),
          );
        },
      );

  Widget _emptyState(
          BuildContext ctx, IconData icon, String title, String subtitle) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _primary.withAlpha(12), shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: _primary.withAlpha(100)),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary(ctx))),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _textSecondary(ctx).withAlpha(150))),
          ]),
        ),
      );
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}

class _ResultOverlay extends StatefulWidget {
  const _ResultOverlay({required this.aprovado, required this.onDone});
  final bool aprovado;
  final VoidCallback onDone;

  @override
  State<_ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<_ResultOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl, _cardCtrl, _iconCtrl, _fadeOutCtrl;
  late Animation<double> _bgA, _cardScale, _iconScale, _fadeOut;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeOutCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _bgA = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);
    _cardScale = CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut);
    _iconScale = CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack);
    _fadeOut = CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _bgCtrl.forward();
    await _cardCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _iconCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    await _fadeOutCtrl.forward();
    widget.onDone();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _cardCtrl.dispose();
    _iconCtrl.dispose();
    _fadeOutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aprovado = widget.aprovado;
    final color = aprovado ? const Color(0xFF43A047) : const Color(0xFFEF5350);
    final bgColor =
        aprovado ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final emoji = aprovado ? '😊' : '😔';
    final title = aprovado ? 'Obrigado!' : 'Lamentamos!';
    final subtitle = aprovado
        ? 'Agradecemos por aprovar nosso orçamento.\nIniciaremos o serviço em breve.'
        : 'Lamentamos que nossa proposta não\ntenha sido aprovada.';

    return FadeTransition(
      opacity: ReverseAnimation(_fadeOut),
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _bgA,
          child: Container(
            color: Colors.black.withAlpha(170),
            child: Center(
              child: ScaleTransition(
                scale: _cardScale,
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                          color: color.withAlpha(100),
                          blurRadius: 40,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32)),
                      ),
                      child: Column(children: [
                        ScaleTransition(
                          scale: _iconScale,
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 72)),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _iconCtrl,
                          builder: (_, __) => Opacity(
                            opacity: _iconCtrl.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        aprovado
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        color: Colors.white,
                                        size: 16),
                                    const SizedBox(width: 6),
                                    Text(aprovado ? 'APROVADO' : 'REPROVADO',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5)),
                                  ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      child: AnimatedBuilder(
                        animation: _iconCtrl,
                        builder: (_, __) => Opacity(
                          opacity: _iconCtrl.value,
                          child: Column(children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: color)),
                            const SizedBox(height: 10),
                            Text(subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF607D8B),
                                    height: 1.5)),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _iconCtrl.value,
                                backgroundColor: color.withAlpha(20),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                                minHeight: 4,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
