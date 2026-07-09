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
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

enum _ViewState { list, details, request, create }

class EquipamentosEmpresaWidget extends StatefulWidget {
  const EquipamentosEmpresaWidget({
    Key? key,
    this.width,
    this.height,
    required this.emailFiltro,
    this.patrimonioFiltro,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String emailFiltro;
  final String? patrimonioFiltro;

  @override
  State<EquipamentosEmpresaWidget> createState() =>
      _EquipamentosEmpresaWidgetState();
}

class _EquipamentosEmpresaWidgetState extends State<EquipamentosEmpresaWidget>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFF00897B);
  static const Color _primaryDark = Color(0xFF00695C);
  static const Color _red = Color(0xFFEF5350);

  static const String _oneSignalAppId = '7b01186f-cf76-4b5d-8354-87d83737d40c';
  static const String _oneSignalApiKey =
      'ZTdlNjIwZWItMjEyMC00M2RhLWJlZmYtMzc2NTBmNzNmMDdj';
  static const String _emailHPS = 'hpsrefri@gmail.com';
  static const String _androidChannel = '577bba44-d1bf-4ac9-9d11-20d89e09a61a';

  static const List<String> _tiposDefeito = [
    'NÃO GELA',
    'NÃO LIGA',
    'BARULHO EXCESSIVO',
    'VAZAMENTO DE ÁGUA',
    'INSTALAÇÃO',
    'REMOÇÃO',
    'MUDANÇA DE LAYOUT',
    'CHEIRO RUIM',
    'GELO NO EVAPORADOR',
    'CONTROLE COM DEFEITO',
    'SUPERAQUECIMENTO',
    'MANUTENÇÃO PREVENTIVA',
    'DESLIGANDO SOZINHO',
    'OUTRO',
  ];

  static const List<String> _meses = [
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

  _ViewState _viewState = _ViewState.list;
  Map<String, dynamic>? _selectedData;
  String? _selectedDocId;
  String? _selectedImg;

  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, String> _imgCache = {};

  final TextEditingController _osCtrl = TextEditingController();
  final TextEditingController _defeitoCtrl = TextEditingController();
  final TextEditingController _descricaoCtrl = TextEditingController();
  bool _gerandoOs = false;
  bool _enviandoSolicitacao = false;
  String _etapaEnvio = '';
  double _progressoEnvio = 0.0;

  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _patrimonioCtrl = TextEditingController();
  final TextEditingController _salaCtrl = TextEditingController();
  final TextEditingController _setorCtrl = TextEditingController();
  final TextEditingController _responsavelCtrl = TextEditingController();
  final TextEditingController _tipoCtrl = TextEditingController();
  final TextEditingController _marcaCtrl = TextEditingController();
  final TextEditingController _modeloCtrl = TextEditingController();
  final TextEditingController _btusCtrl = TextEditingController();
  final TextEditingController _fluidoCtrl = TextEditingController();
  final TextEditingController _tensaoCtrl = TextEditingController();

  // ── Tema ──────────────────────────────────────────────────────────────────
  Color _bg(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFF0F1A1A) : const Color(0xFFF0F4F4);
  }

  Color _cardColor(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFF1A2626) : Colors.white;
  }

  Color _surfaceColor(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFF243030) : const Color(0xFFF5F9F9);
  }

  Color _textPrimary(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFFE0F2F1) : const Color(0xFF1A2626);
  }

  Color _textSecondary(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFF80CBC4) : const Color(0xFF546E7A);
  }

  Color _dividerColor(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFF2C3E3E) : const Color(0xFFE0EDED);
  }

  Color _chipBg(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const Color(0xFF1E3030) : const Color(0xFFE0F2F1);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _osCtrl.dispose();
    _defeitoCtrl.dispose();
    _descricaoCtrl.dispose();
    _nomeCtrl.dispose();
    _patrimonioCtrl.dispose();
    _salaCtrl.dispose();
    _setorCtrl.dispose();
    _responsavelCtrl.dispose();
    _tipoCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _btusCtrl.dispose();
    _fluidoCtrl.dispose();
    _tensaoCtrl.dispose();
    super.dispose();
  }

  // ── Cache de imagem ────────────────────────────────────────────────────────
  Future<String?> _getImagem(String patrimonio) async {
    if (patrimonio.isEmpty) return null;
    if (_imgCache.containsKey(patrimonio)) {
      final cached = _imgCache[patrimonio]!;
      return cached.isEmpty ? null : cached;
    }
    try {
      final q = await FirebaseFirestore.instance
          .collection('IMAGENS')
          .where('PATRIMONIO', isEqualTo: patrimonio)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final url = (q.docs.first['IMAGEM'] as String?) ?? '';
        _imgCache[patrimonio] = url;
        return url.isEmpty ? null : url;
      }
    } catch (_) {}
    _imgCache[patrimonio] = '';
    return null;
  }

  String? _imgFromCache(String patrimonio) {
    final v = _imgCache[patrimonio];
    if (v == null || v.isEmpty) return null;
    return v;
  }

  // ── Gerar OS sequencial ────────────────────────────────────────────────────
  Future<void> _gerarOS() async {
    if (_gerandoOs) return;
    setState(() {
      _gerandoOs = true;
      _osCtrl.text = '...';
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SERVICOSREALIZADOS')
          .orderBy('DATA', descending: true)
          .limit(1)
          .get();

      int proximo = 1000;
      if (snap.docs.isNotEmpty) {
        final last = int.tryParse(
            snap.docs.first.data()['NUMERODAOS']?.toString() ?? '');
        if (last != null) proximo = last + 1;
      }

      while (true) {
        final check = await FirebaseFirestore.instance
            .collection('SERVICOSREALIZADOS')
            .where('NUMERODAOS', isEqualTo: proximo.toString())
            .limit(1)
            .get();
        if (check.docs.isEmpty) break;
        proximo++;
      }

      if (mounted) {
        setState(() {
          _osCtrl.text = proximo.toString();
          _gerandoOs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gerandoOs = false;
          _osCtrl.clear();
        });
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Erro ao gerar O.S. Tente novamente.'),
            backgroundColor: Color(0xFFEF5350),
          ),
        );
      }
    }
  }

  Future<void> _notificarHPS(String equip, String sala, String os) async {
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
              'value': _emailHPS
            },
          ],
          'android_channel_id': _androidChannel,
          'headings': {'en': 'Nova Solicitação de Atendimento'},
          'contents': {'en': 'OS #$os · $equip — Sala: $sala'},
          'priority': 10,
        }),
      );
    } catch (_) {}
  }

  Future<void> _criarNotificacaoFirebase({
    required String email,
    required String os,
    required String equip,
    required String sala,
    required String setor,
    required String defeito,
    required int mes,
    required int ano,
  }) async {
    if (email.isEmpty) return;
    final isCadastro = os.isEmpty;
    final titulo = isCadastro
        ? '✅ Equipamento Cadastrado'
        : '🔧 Nova Solicitação de Atendimento';
    final mensagem = isCadastro
        ? 'Equipamento $equip cadastrado — Sala: $sala, Setor: $setor.'
        : 'O.S #$os aberta pelo cliente — Equipamento: $equip, Sala: $sala, Setor: $setor. Defeito: $defeito.';
    final tipo = isCadastro ? 'sistema' : 'corretiva';
    final status = isCadastro ? 'cadastrado' : 'AGUARDANDO AVALIAÇÃO';

    try {
      await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
        'email': email,
        'titulo': titulo,
        'mensagem': mensagem,
        'tipo': tipo,
        'visto': false,
        'data': Timestamp.now(),
        'mes': _meses[mes],
        'ano': ano,
        'status': status,
        'os': os,
      });
    } catch (e) {
      debugPrint('Erro ao criar notificação Firebase: $e');
    }
  }

  Future<List<String>> _buscarEmailsHPS() async {
    const principal = _emailHPS;
    final lista = <String>[principal];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: principal)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final field = snap.docs.first.data()['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty && !lista.contains(s)) lista.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          final s = field.trim();
          if (!lista.contains(s)) lista.add(s);
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar emailteste HPS: $e');
    }
    return lista;
  }

  Future<void> _sendEmailEquipamentosWidget({
    required String toEmail,
    required String tipo,
    required String os,
    required String equip,
    required String sala,
    required String setor,
    required String defeito,
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

    final bool isSolicitacao = tipo == 'solicitacao';
    final emoji = isSolicitacao ? '🔧' : '✅';
    final titulo = isSolicitacao
        ? 'Nova Solicitação de Atendimento — O.S #$os'
        : 'Novo Equipamento Cadastrado';
    final tagline = isSolicitacao
        ? 'Um cliente abriu um chamado de manutenção.'
        : 'Um novo equipamento foi registrado no sistema.';
    final corHex = isSolicitacao ? '#F59E0B' : '#10B981';
    final corpo = isSolicitacao
        ? 'O cliente <strong>$cliente</strong> abriu uma <strong>solicitação de atendimento</strong> para o equipamento <strong>$equip</strong>. Acesse o sistema para iniciar a avaliação.'
        : 'O equipamento <strong>$equip</strong> foi <strong>cadastrado com sucesso</strong> pelo cliente <strong>$cliente</strong>. O equipamento já está disponível no sistema.';
    final detalhe = isSolicitacao
        ? '⚠️&nbsp;&nbsp;Defeito relatado: <strong>$defeito</strong>. Acesse o app para atribuir um técnico.'
        : '📋&nbsp;&nbsp;O equipamento foi cadastrado e está pronto para receber ordens de serviço.';
    final barraStatus = isSolicitacao ? 'NOVA SOLICITAÇÃO' : 'NOVO EQUIPAMENTO';
    final tituloTabela =
        isSolicitacao ? 'DETALHES DA SOLICITAÇÃO' : 'DETALHES DO EQUIPAMENTO';

    final linhasTabela = isSolicitacao
        ? '''
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;width:160px;border-bottom:1px solid #e2e8f0;">N° da O.S</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;"><strong>#$os</strong></td></tr>
              <tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Cliente</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$cliente</td></tr>
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Equipamento</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$equip</td></tr>
              <tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Sala</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$sala</td></tr>
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Setor</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$setor</td></tr>
              <tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Patrimônio</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$patrimonio</td></tr>
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;">Defeito</td><td style="padding:10px 14px;color:#1f2937;">$defeito</td></tr>'''
        : '''
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;width:160px;border-bottom:1px solid #e2e8f0;">Cliente</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$cliente</td></tr>
              <tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Equipamento</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$equip</td></tr>
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Sala</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$sala</td></tr>
              <tr><td style="padding:10px 14px;font-weight:bold;color:#374151;">Setor</td><td style="padding:10px 14px;color:#1f2937;">$setor</td></tr>
              <tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;">Patrimônio</td><td style="padding:10px 14px;color:#1f2937;">$patrimonio</td></tr>''';

    final htmlBody =
        '''<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><title>$titulo</title></head>
<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">
<tr><td align="center"><table width="600" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;border-radius:12px;overflow:hidden;max-width:600px;width:100%;">
<tr><td style="padding:0;margin:0;line-height:0;"><img src="$imgUrl" alt="HPS" width="600" style="display:block;width:100%;height:auto;border:0;"/></td></tr>
<tr><td style="background-color:$corHex;padding:12px 24px;"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
<td><span style="color:#ffffff;font-size:13px;font-weight:bold;">$emoji&nbsp;&nbsp;$barraStatus</span></td>
<td align="right"><span style="background:#ffffff20;color:#ffffff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;">Notificação Automática</span></td>
</tr></table></td></tr>
<tr><td style="padding:28px 28px 12px 28px;text-align:center;"><h1 style="margin:0 0 8px 0;font-size:20px;font-weight:bold;color:#1A3C34;">$titulo</h1><p style="margin:0;font-size:13px;color:#64748b;">$tagline</p></td></tr>
<tr><td style="padding:12px 28px 20px 28px;"><p style="margin:0 0 20px 0;font-size:15px;color:#374151;line-height:1.7;">$corpo</p>
<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#f0fdf4;border-left:4px solid $corHex;border-radius:0 8px 8px 0;margin-bottom:24px;"><tr><td style="padding:14px 16px;font-size:14px;color:#14532d;line-height:1.6;">$detalhe</td></tr></table>
<table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;border:1px solid #e2e8f0;margin-bottom:24px;font-size:14px;">
<tr><td colspan="2" style="background:#1A3C34;padding:10px 14px;"><span style="color:#ffffff;font-size:13px;font-weight:bold;">$tituloTabela</span></td></tr>
$linhasTabela
</table></td></tr>
<tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>
<tr><td style="padding:20px 28px;"><table cellpadding="0" cellspacing="0" border="0"><tr>
<td style="width:44px;vertical-align:top;"><div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;text-align:center;line-height:40px;"><span style="color:#ffffff;font-size:18px;font-weight:bold;">H</span></div></td>
<td style="padding-left:12px;vertical-align:top;"><span style="font-size:15px;font-weight:bold;color:#1A3C34;">Huagner Pires</span><br><span style="font-size:13px;color:#555555;">Especialista em Refrigeração</span><br><span style="font-size:12px;color:#888888;">hpsrefri.com.br</span></td>
</tr></table></td></tr>
<tr><td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;border-top:1px solid #e2e8f0;">&copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados</td></tr>
</table></td></tr></table></body></html>''';

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
      debugPrint('Erro ao enviar e-mail ($tipo): $e');
    }
  }

  // ── Navegação ──────────────────────────────────────────────────────────────
  void _goTo(
      _ViewState state, Map<String, dynamic>? data, String? id, String? img) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (data != null) _selectedData = data;
      if (id != null) _selectedDocId = id;
      if (img != null && img.isNotEmpty) {
        _selectedImg = img;
      } else if (data != null) {
        final pat = data['PATRIMONIO']?.toString() ?? '';
        final cached = _imgFromCache(pat);
        if (cached != null) _selectedImg = cached;
      }
      _viewState = state;
    });
  }

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (_viewState == _ViewState.request && _selectedData != null) {
        _viewState = _ViewState.details;
        _osCtrl.clear();
        _defeitoCtrl.clear();
        _descricaoCtrl.clear();
        _gerandoOs = false;
      } else {
        _viewState = _ViewState.list;
        _selectedData = null;
        _selectedDocId = null;
        _selectedImg = null;
      }
    });
  }

  Color _tipoColor(String tipo) {
    final t = tipo.toUpperCase();
    if (t.contains('INVERTER')) return const Color(0xFF1E88E5);
    if (t.contains('CONVENC')) return const Color(0xFF1E88E5);
    if (t.contains('SPLIT')) return const Color(0xFF00897B);
    if (t.contains('CHILLER')) return const Color(0xFF00ACC1);
    if (t.contains('VRF') || t.contains('VRV')) return const Color(0xFFFF7043);
    if (t.contains('CÂMARA') || t.contains('CAMARA')) {
      return const Color(0xFF43A047);
    }
    if (t.contains('ILHA')) return const Color(0xFF1565C0);
    if (t.contains('CAIXA')) return const Color(0xFF795548);
    return const Color(0xFF607D8B);
  }

  IconData _equipIcon(String equip) {
    final e = equip.toUpperCase();
    if (e.contains('AR CONDICIONADO') || e.contains('SPLIT')) {
      return Icons.ac_unit_rounded;
    }
    if (e.contains('CÂMARA') || e.contains('CAMARA')) {
      return Icons.kitchen_rounded;
    }
    if (e.contains('ILHA') || e.contains('REFRIGERADA')) {
      return Icons.shopping_cart_rounded;
    }
    if (e.contains('CHILLER')) return Icons.device_thermostat_rounded;
    if (e.contains('CONDENSADORA')) return Icons.blur_on_rounded;
    if (e.contains('EVAPORADORA')) return Icons.air_rounded;
    return Icons.thermostat_outlined;
  }

  List<QueryDocumentSnapshot> _filtrar(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final d = doc.data() as Map<String, dynamic>;
      final q = _search.toLowerCase();
      if (q.isNotEmpty) {
        final fields = [
          d['NOME'],
          d['EQUIPAMENTO'],
          d['SALA'],
          d['SETOR'],
          d['PATRIMONIO'],
          d['MARCA'],
          d['MODELO'],
          d['TIPO'],
          d['RESPONSAVEL'],
        ].map((v) => (v?.toString() ?? '').toLowerCase()).join(' ');
        if (!fields.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final da = a.data() as Map<String, dynamic>;
        final db = b.data() as Map<String, dynamic>;
        return (da['SALA'] ?? '')
            .toString()
            .compareTo((db['SALA'] ?? '').toString());
      });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Pegando a altura exata do teclado para garantir visibilidade no formulário.
    // Alteramos resizeToAvoidBottomInset para false no Scaffold root, para aplicar
    // o padding manualmente dentro dos campos com ScrollPadding.
    return Scaffold(
      backgroundColor: _bg(context),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewState) {
      case _ViewState.list:
        return _buildListView(context);
      case _ViewState.details:
        return _buildDetailsView(context);
      case _ViewState.request:
        return _buildRequestView(context);
      case _ViewState.create:
        return _buildCreateView(context);
    }
  }

  // ── App Bar interna ────────────────────────────────────────────────────────
  Widget _internalAppBar(String title, {bool closeIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: _cardColor(context),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surfaceColor(context),
                shape: BoxShape.circle,
                border: Border.all(color: _dividerColor(context)),
              ),
              child: Icon(
                closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
                color: _textPrimary(context),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textPrimary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TELA 1 — LISTA
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildListView(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('EQUIPAMENTOS_EMPRESA')
        .where('EMAIL', isEqualTo: widget.emailFiltro);

    if (widget.patrimonioFiltro != null &&
        widget.patrimonioFiltro!.isNotEmpty) {
      query = query.where('PATRIMONIO', isEqualTo: widget.patrimonioFiltro);
    }

    return Column(
      key: const ValueKey('view_list'),
      children: [
        _buildHeader(context),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            key: ValueKey(widget.emailFiltro),
            stream: query.snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: _primary, strokeWidth: 2));
              }
              if (snap.hasError) {
                return Center(
                    child: Text('Erro ao carregar',
                        style: TextStyle(color: _textSecondary(ctx))));
              }
              final allDocs = snap.data?.docs ?? [];
              final docs = _filtrar(allDocs);
              return Column(
                children: [
                  _buildContador(ctx, docs.length, allDocs.length),
                  Expanded(
                    child: docs.isEmpty
                        ? _buildEmpty(ctx)
                        : isMobile
                            ? _buildLista(ctx, docs)
                            : _buildGrid(ctx, docs),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext ctx) {
    final temFiltro =
        widget.patrimonioFiltro != null && widget.patrimonioFiltro!.isNotEmpty;

    return Container(
      color: _cardColor(ctx),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(ctx),
            child: Container(
              width: 46,
              height: 46,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _surfaceColor(ctx),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _dividerColor(ctx)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: _textPrimary(ctx), size: 22),
            ),
          ),
          if (!temFiltro)
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: _surfaceColor(ctx),
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
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  scrollPadding: const EdgeInsets.only(bottom: 120),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  style: TextStyle(
                      fontSize: 13,
                      color: _textPrimary(ctx),
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Buscar equipamento...',
                    hintStyle:
                        TextStyle(color: _textSecondary(ctx), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: _primary, size: 20),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                size: 18, color: _textSecondary(ctx)),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded,
                        color: _primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Resultado para o Patrimônio',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _textSecondary(ctx))),
                        Text(widget.patrimonioFiltro!,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary(ctx))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              _goTo(_ViewState.create, null, null, null);
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: _primary.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContador(BuildContext ctx, int filtrado, int total) {
    return Container(
      color: _cardColor(ctx),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _chipBg(ctx),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.devices_rounded, size: 13, color: _primary),
                const SizedBox(width: 5),
                Text(
                  filtrado == total
                      ? '$total equipamentos'
                      : '$filtrado de $total equipamentos',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(BuildContext ctx, List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
      itemCount: docs.length,
      itemBuilder: (ctx, i) {
        final doc = docs[i];
        final d = doc.data() as Map<String, dynamic>;
        final pat = d['PATRIMONIO']?.toString() ?? '';
        return FutureBuilder<String?>(
          future: _getImagem(pat),
          builder: (ctx, snap) {
            if (snap.hasData && snap.data != null && snap.data!.isNotEmpty) {
              _imgCache[pat] = snap.data!;
            }
            final imageUrl = snap.hasData && snap.data!.isNotEmpty
                ? snap.data
                : _imgFromCache(pat);
            return _buildListCard(ctx, d, doc.id, imageUrl);
          },
        );
      },
    );
  }

  Widget _buildGrid(BuildContext ctx, List<QueryDocumentSnapshot> docs) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cols = constraints.maxWidth > 1100
            ? 4
            : (constraints.maxWidth > 750 ? 3 : 2);
        const spacing = 10.0;
        final cardW = (constraints.maxWidth - 28 - spacing * (cols - 1)) / cols;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final pat = d['PATRIMONIO']?.toString() ?? '';
              return SizedBox(
                width: cardW,
                child: FutureBuilder<String?>(
                  future: _getImagem(pat),
                  builder: (ctx, snap) {
                    if (snap.hasData &&
                        snap.data != null &&
                        snap.data!.isNotEmpty) {
                      _imgCache[pat] = snap.data!;
                    }
                    final imageUrl = snap.hasData && snap.data!.isNotEmpty
                        ? snap.data
                        : _imgFromCache(pat);
                    return _buildGridCard(ctx, d, doc.id, imageUrl);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildListCard(
      BuildContext ctx, Map<String, dynamic> d, String docId, String? img) {
    final equip = d['EQUIPAMENTO']?.toString() ?? d['NOME']?.toString() ?? '—';
    final tipo = d['TIPO']?.toString() ?? '';
    final tColor = _tipoColor(tipo);
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _goTo(_ViewState.details, d, docId, img),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: _cardColor(ctx),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(60)
                  : Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: img != null
                  ? CachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imgPlaceholder(tColor, isDark),
                      errorWidget: (_, __, ___) =>
                          _imgPlaceholder(tColor, isDark),
                    )
                  : _imgPlaceholder(tColor, isDark),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(equip,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary(ctx)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: _chipBg(ctx),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(d['PATRIMONIO']?.toString() ?? '—',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryDark,
                                  letterSpacing: 0.3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 10, color: _primary),
                      const SizedBox(width: 3),
                      Flexible(
                          child: Text(d['SALA']?.toString() ?? '—',
                              style: TextStyle(
                                  fontSize: 10, color: _textSecondary(ctx)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      if (tipo.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: tColor.withAlpha(isDark ? 35 : 18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: tColor.withAlpha(60)),
                          ),
                          child: Text(tipo,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: tColor,
                                  letterSpacing: 0.3)),
                        ),
                      const SizedBox(width: 8),
                      if ((d['MARCA']?.toString() ?? '').isNotEmpty)
                        Text(d['MARCA']!.toString(),
                            style: TextStyle(
                                fontSize: 10,
                                color: _textSecondary(ctx),
                                fontStyle: FontStyle.italic)),
                    ]),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded,
                  color: _textSecondary(ctx).withAlpha(100), size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
      BuildContext ctx, Map<String, dynamic> d, String docId, String? img) {
    final equip = d['EQUIPAMENTO']?.toString() ?? d['NOME']?.toString() ?? '—';
    final tipo = d['TIPO']?.toString() ?? '';
    final tColor = _tipoColor(tipo);
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _goTo(_ViewState.details, d, docId, img),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor(ctx),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(60)
                  : Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(children: [
                Positioned.fill(
                  child: img != null
                      ? CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              _imgPlaceholder(tColor, isDark),
                          errorWidget: (_, __, ___) =>
                              _imgPlaceholder(tColor, isDark),
                        )
                      : _imgPlaceholder(tColor, isDark),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(height: 2, color: tColor)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(equip,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(ctx)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 9, color: _primary),
                    const SizedBox(width: 3),
                    Flexible(
                        child: Text(d['SALA']?.toString() ?? '—',
                            style: TextStyle(
                                fontSize: 9, color: _textSecondary(ctx)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.qr_code_scanner_outlined,
                        size: 9, color: _primary),
                    const SizedBox(width: 3),
                    Text(d['PATRIMONIO']?.toString() ?? '—',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _primaryDark)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder(Color tColor, bool isDark) {
    return Container(
      color: tColor.withAlpha(isDark ? 40 : 22),
      child: Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: tColor.withAlpha(120), size: 28)),
    );
  }

  Widget _buildEmpty(BuildContext ctx) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _primary.withAlpha(15), shape: BoxShape.circle),
              child: Icon(Icons.devices_outlined,
                  size: 40, color: _primary.withAlpha(120)),
            ),
            const SizedBox(height: 16),
            Text(
              _search.isNotEmpty
                  ? 'Nenhum equipamento encontrado para "$_search"'
                  : 'Nenhum equipamento encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary(ctx),
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TELA 2 — DETALHES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDetailsView(BuildContext context) {
    final d = _selectedData ?? {};
    final equip = d['EQUIPAMENTO']?.toString() ?? d['NOME']?.toString() ?? '—';
    final tipo = d['TIPO']?.toString() ?? '';
    final tColor = _tipoColor(tipo);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfBg = _surfaceColor(context);
    final textMain = _textPrimary(context);
    final textSub = _textSecondary(context);
    final divColor = _dividerColor(context);
    final pat = d['PATRIMONIO']?.toString() ?? '';
    final imgUrl = (_selectedImg != null && _selectedImg!.isNotEmpty)
        ? _selectedImg
        : _imgFromCache(pat);

    return Column(
      key: const ValueKey('view_details'),
      children: [
        _internalAppBar('Detalhes do Equipamento'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Stack(children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: imgUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                              color: tColor.withAlpha(isDark ? 60 : 25),
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: _primary))),
                          errorWidget: (_, __, ___) => Container(
                              color: tColor.withAlpha(isDark ? 60 : 25),
                              child: Center(
                                  child: Icon(_equipIcon(equip),
                                      color: tColor, size: 48))),
                        )
                      : Container(
                          color: tColor.withAlpha(isDark ? 60 : 25),
                          child: Center(
                              child: Icon(_equipIcon(equip),
                                  color: tColor, size: 64))),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(180)
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: _cardColor(context),
                  border: Border(bottom: BorderSide(color: divColor)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: tColor.withAlpha(isDark ? 80 : 20),
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: tColor.withAlpha(100), width: 2),
                      ),
                      child: Icon(_equipIcon(equip), color: tColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tipo.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tColor.withAlpha(isDark ? 60 : 30),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: tColor.withAlpha(100)),
                              ),
                              child: Text(tipo,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: tColor,
                                      letterSpacing: 0.4)),
                            ),
                          Text(equip,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textMain,
                                  height: 1.2)),
                          const SizedBox(height: 6),
                          Row(children: [
                            Icon(Icons.tag_rounded, size: 13, color: textSub),
                            const SizedBox(width: 4),
                            Text('Patrimônio: ${d['PATRIMONIO'] ?? '—'}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: textSub,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sheetSection(context, Icons.location_on_outlined, 'Localização',
                  divColor, textMain, isDark),
              _sheetGrid2(context, [
                _sheetCell(context, 'SALA', d['SALA'], surfBg, textMain,
                    textSub, Icons.meeting_room_outlined),
                _sheetCell(context, 'SETOR', d['SETOR'], surfBg, textMain,
                    textSub, Icons.domain_outlined),
                _sheetCell(context, 'RESPONSÁVEL', d['RESPONSAVEL'], surfBg,
                    textMain, textSub, Icons.person_outline_rounded),
              ]),
              const SizedBox(height: 8),
              _sheetSection(context, Icons.settings_outlined, 'Dados Técnicos',
                  divColor, textMain, isDark),
              _sheetGrid2(context, [
                _sheetCell(context, 'MARCA', d['MARCA'], surfBg, textMain,
                    textSub, Icons.label_outline_rounded),
                _sheetCell(context, 'MODELO', d['MODELO'], surfBg, textMain,
                    textSub, Icons.devices_outlined),
                _sheetCell(context, 'TIPO', d['TIPO'], surfBg, textMain,
                    textSub, Icons.category_outlined),
                _sheetCell(context, 'BTUS', d['BTUS'], surfBg, textMain,
                    textSub, Icons.thermostat_outlined),
                _sheetCell(context, 'FLUIDO', d['FLUIDO'], surfBg, textMain,
                    textSub, Icons.water_drop_outlined),
                _sheetCell(context, 'TENSÃO', d['TENSAO'], surfBg, textMain,
                    textSub, Icons.bolt_outlined),
              ]),
              const SizedBox(height: 20),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () =>
                        _goTo(_ViewState.request, _selectedData, null, null),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF26A69A), Color(0xFF00695C)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: _primary.withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_circle_outlined,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('SOLICITAR ATENDIMENTO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TELA 3 — ABRIR CHAMADO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRequestView(BuildContext context) {
    final d = _selectedData ?? {};
    final equip = (d['EQUIPAMENTO'] ?? d['NOME'] ?? '—').toString();
    final patrimonio = (d['PATRIMONIO'] ?? '—').toString();
    final tColor = _tipoColor(d['TIPO']?.toString() ?? '');
    final surfBg = _surfaceColor(context);
    final textMain = _textPrimary(context);
    final textSub = _textSecondary(context);
    final divColor = _dividerColor(context);

    final overlayEnvio = _enviandoSolicitacao
        ? Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(160),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2520),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF00897B).withAlpha(80),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF00897B).withAlpha(60),
                          blurRadius: 36,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                              colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF00897B).withAlpha(100),
                                blurRadius: 20,
                                spreadRadius: 2)
                          ],
                        ),
                        child: _progressoEnvio >= 0.99
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 36)
                            : const Icon(Icons.send_rounded,
                                color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 22),
                      const Text('Enviando Solicitação',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(_etapaEnvio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(160),
                              height: 1.4)),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progressoEnvio,
                          minHeight: 8,
                          backgroundColor: Colors.white.withAlpha(25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF26A69A)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            _stepDot(_progressoEnvio >= 0.30),
                            const SizedBox(width: 4),
                            _stepDot(_progressoEnvio >= 0.55),
                            const SizedBox(width: 4),
                            _stepDot(_progressoEnvio >= 0.72),
                            const SizedBox(width: 4),
                            _stepDot(_progressoEnvio >= 0.99),
                          ]),
                          Text('${(_progressoEnvio * 100).toInt()}%',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF80CBC4),
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : null;

    final col = Column(
      key: const ValueKey('view_request'),
      children: [
        _internalAppBar('Abrir Chamado'),
        Expanded(
          // Utilizado SingleChildScrollView com Padding explicito do ViewInsets
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, 40 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _solicitLabel(Icons.ac_unit_outlined, 'Equipamento', textSub),
                const SizedBox(height: 6),
                _solicitReadOnly(equip, surfBg, textMain, tColor),
                const SizedBox(height: 16),
                _solicitLabel(Icons.tag_rounded, 'Patrimônio', textSub),
                const SizedBox(height: 6),
                _solicitReadOnly(patrimonio, surfBg, textMain, _primary),
                const SizedBox(height: 16),
                Row(children: [
                  _solicitLabel(
                      Icons.receipt_long_outlined, 'Número da O.S.', textSub),
                  const Spacer(),
                  GestureDetector(
                    onTap: _gerandoOs ? null : _gerarOS,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: _gerandoOs
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF26A69A), Color(0xFF00695C)]),
                        color: _gerandoOs ? _primary.withAlpha(60) : null,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_gerandoOs)
                            const SizedBox(
                                width: 11,
                                height: 11,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                          else
                            const Icon(Icons.casino_outlined,
                                color: Colors.white, size: 13),
                          const SizedBox(width: 5),
                          Text(_gerandoOs ? 'Gerando...' : 'Gerar O.S.',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: surfBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withAlpha(40)),
                  ),
                  child: TextField(
                    controller: _osCtrl,
                    keyboardType: TextInputType.number,
                    scrollPadding: const EdgeInsets.only(bottom: 120), // ADD
                    style: TextStyle(
                        fontSize: 14,
                        color: textMain,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Digite o número da ordem de serviço',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: textSub,
                          fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.tag_outlined,
                          color: _primary, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _solicitLabel(Icons.build_outlined, 'Tipo de Defeito', textSub),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _mostrarDialogDefeito(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: surfBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primary.withAlpha(40)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.build_outlined,
                          color: _primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(
                              _defeitoCtrl.text.isEmpty
                                  ? 'Escolha um defeito'
                                  : _defeitoCtrl.text,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: _defeitoCtrl.text.isEmpty
                                      ? textSub
                                      : textMain,
                                  fontWeight: _defeitoCtrl.text.isEmpty
                                      ? FontWeight.w400
                                      : FontWeight.w600))),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: textSub, size: 22),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                _solicitLabel(Icons.info_outline_rounded,
                    'Informações Adicionais', textSub),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: surfBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: divColor),
                  ),
                  child: TextField(
                    controller: _descricaoCtrl,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [UpperCaseTextFormatter()],
                    textCapitalization: TextCapitalization.characters,
                    scrollPadding: const EdgeInsets.only(bottom: 120), // ADD
                    style: TextStyle(fontSize: 13, color: textMain),
                    decoration: InputDecoration(
                      hintText:
                          'Descreva detalhes do problema ou observações importantes',
                      hintStyle: TextStyle(fontSize: 13, color: textSub),
                      contentPadding: const EdgeInsets.all(14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SafeArea(
                  top: false,
                  child: Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: divColor, width: 1.5),
                          ),
                          child: Center(
                              child: Text('Cancelar',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textSub))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => _enviarSolicitacao(context, context, d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF26A69A), Color(0xFF00695C)]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: _primary.withAlpha(80),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Solicitar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (overlayEnvio != null) {
      return Stack(children: [col, overlayEnvio]);
    }
    return col;
  }

  Widget _stepDot(bool ativo) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: ativo ? 10 : 6,
      height: ativo ? 10 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ativo ? const Color(0xFF26A69A) : Colors.white.withAlpha(50),
      ),
    );
  }

  // Dialog de defeito
  void _mostrarDialogDefeito(BuildContext ctx) {
    FocusManager.instance.primaryFocus?.unfocus();
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final cardBg = _cardColor(ctx);
    final textMain = _textPrimary(ctx);
    final divColor = _dividerColor(ctx);

    showDialog(
      context: ctx,
      builder: (dCtx) => SafeArea(
        child: AlertDialog(
          backgroundColor: cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primary.withAlpha(isDark ? 40 : 20),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.build_outlined, size: 16, color: _primary),
            ),
            const SizedBox(width: 10),
            Text('Tipo de Defeito',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textMain)),
          ]),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _tiposDefeito.length,
              itemBuilder: (context, index) {
                final tipo = _tiposDefeito[index];
                final selected = _defeitoCtrl.text == tipo;
                return InkWell(
                  onTap: () {
                    setState(() => _defeitoCtrl.text = tipo);
                    Navigator.pop(dCtx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? _primary.withAlpha(isDark ? 35 : 15)
                          : Colors.transparent,
                      border: Border(
                          bottom: BorderSide(color: divColor, width: 0.5)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? _primary : Colors.transparent,
                          border: Border.all(
                              color: selected ? _primary : divColor, width: 2),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Text(tipo,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected ? _primary : textMain)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TELA 4 — CADASTRO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCreateView(BuildContext context) {
    final surfBg = _surfaceColor(context);
    final textMain = _textPrimary(context);
    final textSub = _textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('view_create'),
      children: [
        _internalAppBar('Novo Equipamento', closeIcon: true),
        Expanded(
          // Utilizado SingleChildScrollView com Padding explicito
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, 40 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(
                    'Identificação', Icons.label_outline_rounded, isDark),
                _campo('Equipamento *', _nomeCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: AR CONDICIONADO'),
                _campo(
                    'Patrimônio *', _patrimonioCtrl, surfBg, textMain, textSub,
                    tipo: TextInputType.number, hint: 'Ex: 168938'),
                _sectionLabel(
                    'Localização', Icons.location_on_outlined, isDark),
                _campo('Sala *', _salaCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: ADM DA MANUTENÇÃO'),
                _campo('Setor *', _setorCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: MANUTENÇÃO'),
                _campo('Responsável *', _responsavelCtrl, surfBg, textMain,
                    textSub,
                    hint: 'Nome do responsável'),
                _sectionLabel(
                    'Dados Técnicos', Icons.settings_outlined, isDark),
                _campo('Tipo *', _tipoCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: INVERTER / CONVENCIONAL'),
                _campo('Marca *', _marcaCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: LG'),
                _campo('Modelo *', _modeloCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: SPLIT'),
                _campo(
                    'BTUs/CAPACIDADE *', _btusCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: 24K BTUS/LITROS'),
                _campo('Fluido *', _fluidoCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: R410A'),
                _campo('Tensão *', _tensaoCtrl, surfBg, textMain, textSub,
                    hint: 'Ex: 220 V'),
                const SizedBox(height: 10),
                SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: () => _salvarEquipamento(context, context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF26A69A), Color(0xFF00695C)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: _primary.withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('SALVAR EQUIPAMENTO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Widgets auxiliares ─────────────────────────────────────────────────────
  Widget _solicitLabel(IconData icon, String label, Color textSub) {
    return Row(children: [
      Icon(icon, size: 14, color: _primary),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: 0.3)),
    ]);
  }

  Widget _solicitReadOnly(
      String value, Color surfBg, Color textMain, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withAlpha(40)),
      ),
      child: Text(value,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: textMain)),
    );
  }

  Widget _sectionLabel(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _primary.withAlpha(isDark ? 40 : 20),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 13, color: _primary),
        ),
        const SizedBox(width: 7),
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: 0.7)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: const Color(0xFFE0EDED))),
      ]),
    );
  }

  Widget _campo(String label, TextEditingController ctrl, Color surfBg,
      Color textMain, Color textSub,
      {TextInputType tipo = TextInputType.text, String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: 0.6)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: surfBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withAlpha(40)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: tipo,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [UpperCaseTextFormatter()],
            scrollPadding: const EdgeInsets.only(bottom: 120), // ADD
            style: TextStyle(fontSize: 13, color: textMain),
            decoration: InputDecoration(
              hintText: hint.isNotEmpty ? hint : label,
              hintStyle: TextStyle(
                  color: textSub, fontSize: 13, fontStyle: FontStyle.italic),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _sheetSection(BuildContext ctx, IconData icon, String title,
      Color divColor, Color textMain, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _primary.withAlpha(isDark ? 40 : 20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: _primary),
        ),
        const SizedBox(width: 8),
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: 0.8)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: divColor)),
      ]),
    );
  }

  Widget _sheetGrid2(BuildContext ctx, List<Widget> cells) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 2) {
      final hasNext = i + 1 < cells.length;
      rows.add(Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: Row(children: [
          Expanded(child: cells[i]),
          const SizedBox(width: 6),
          Expanded(child: hasNext ? cells[i + 1] : const SizedBox()),
        ]),
      ));
    }
    return Column(children: rows);
  }

  Widget _sheetCell(BuildContext ctx, String label, dynamic value, Color surfBg,
      Color textMain, Color textSub, IconData icon) {
    final val = value?.toString() ?? '';
    if (val.isEmpty || val == '—') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surfBg.withAlpha(80),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 10, color: textSub.withAlpha(120)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: textSub.withAlpha(120),
                    letterSpacing: 0.4)),
          ]),
          const SizedBox(height: 3),
          Text('—',
              style: TextStyle(fontSize: 13, color: textSub.withAlpha(100))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surfBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primary.withAlpha(20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 10, color: _primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                  letterSpacing: 0.4)),
        ]),
        const SizedBox(height: 3),
        Text(val,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: textMain)),
      ]),
    );
  }

  // ── Dialogs de erro ────────────────────────────────────────────────────────
  void _mostrarErroValidacao(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withAlpha(120),
      builder: (dCtx) => SafeArea(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: _cardColor(ctx),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: _red.withAlpha(15), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded,
                    color: _red, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Campos Obrigatórios',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary(ctx))),
              const SizedBox(height: 10),
              Text('Todos os campos precisam ser preenchidos antes de salvar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: _textSecondary(ctx), height: 1.5)),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Entendi',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── NOVO: Popup O.S. duplicada ─────────────────────────────────────────────
  void _mostrarErroOsDuplicada(BuildContext ctx, String os) {
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withAlpha(120),
      builder: (dCtx) => SafeArea(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: _cardColor(ctx),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    color: Color(0xFFF59E0B), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'O.S. Já Cadastrada',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary(ctx)),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 13, color: _textSecondary(ctx), height: 1.5),
                  children: [
                    const TextSpan(text: 'A O.S. número '),
                    TextSpan(
                      text: '#$os',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF59E0B)),
                    ),
                    const TextSpan(
                        text:
                            ' já foi cadastrada no sistema.\nGere ou informe um número diferente.'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Entendi',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _step(double alvo, String label) async {
    if (!mounted) return;
    setState(() => _etapaEnvio = label);
    final ini = _progressoEnvio;
    final delta = alvo - ini;
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => _progressoEnvio = ini + delta * (i / 20));
    }
  }

  Future<void> _enviarSolicitacao(
      BuildContext ctx, BuildContext bCtx, Map<String, dynamic> d) async {
    final os = _osCtrl.text.trim();
    final defeito = _defeitoCtrl.text.trim();

    if (os.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('Informe ou gere o Número da O.S.'),
          backgroundColor: Color(0xFFEF5350)));
      return;
    }
    if (defeito.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('Selecione o Tipo de Defeito'),
          backgroundColor: Color(0xFFEF5350)));
      return;
    }

    // ── Verifica duplicidade com popup ────────────────────────────────────
    try {
      final existing = await FirebaseFirestore.instance
          .collection('MANUTENCAO')
          .where('NUMERO_OS', isEqualTo: os)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        _mostrarErroOsDuplicada(ctx, os);
        return;
      }
    } catch (_) {}

    setState(() {
      _enviandoSolicitacao = true;
      _progressoEnvio = 0.0;
      _etapaEnvio = 'Preparando solicitação...';
    });

    try {
      await _step(0.10, 'Buscando dados do cliente...');

      final now = DateTime.now();
      final dia = now.day.toString().padLeft(2, '0');
      final mes = now.month.toString().padLeft(2, '0');
      final dataStr = '$dia/$mes/${now.year}';
      final mesNome = _meses[now.month];
      final equip = (d['EQUIPAMENTO'] ?? d['NOME'] ?? '').toString();
      final patrimonio = (d['PATRIMONIO'] ?? '').toString();
      final sala = (d['SALA'] ?? '').toString();
      final setor = (d['SETOR'] ?? '').toString();
      final infoAdd = _descricaoCtrl.text.trim();

      String clienteNome = widget.emailFiltro;
      try {
        final userQuery = await FirebaseFirestore.instance
            .collection('USUARIOS')
            .where('email', isEqualTo: widget.emailFiltro)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          if (userData['display_name'] != null &&
              userData['display_name'].toString().isNotEmpty) {
            clienteNome = userData['display_name'].toString().toUpperCase();
          }
        }
      } catch (e) {
        debugPrint('Erro ao buscar USUARIOS: $e');
      }

      await _step(0.30, 'Registrando O.S. no sistema...');

      await FirebaseFirestore.instance.collection('MANUTENCAO').add({
        'NUMERO_OS': os,
        'STATUS': 'AGUARDANDO AVALIAÇÃO',
        'EMAIL': widget.emailFiltro,
        'CLIENTE': clienteNome,
        'EQUIPAMENTO': equip,
        'NOME': equip,
        'PATRIMONIO': patrimonio,
        'SALA': sala,
        'SETOR': setor,
        'MARCA': (d['MARCA'] ?? '').toString(),
        'MODELO': (d['MODELO'] ?? '').toString(),
        'TIPO': (d['TIPO'] ?? '').toString(),
        'FLUIDO': (d['FLUIDO'] ?? '').toString(),
        'BTUS': (d['BTUS'] ?? '').toString(),
        'RESPONSAVEL': (d['RESPONSAVEL'] ?? '').toString(),
        'DEFEITO': defeito,
        'DESCRICAODOSERVICO': infoAdd,
        'DATADAMANUTENÇÃO': dataStr,
        'MES': mesNome,
        'ANO': now.year.toString(),
        'TECNICORESPONSAVEL': 'NÃO DEFINIDO',
        'DATA_TERMINO': '',
        'PREVISAODAPECA': '',
        'Empresa': true,
        'DATA': FieldValue.serverTimestamp(),
      });

      await _step(0.55, 'Salvando histórico de serviços...');

      await FirebaseFirestore.instance.collection('SERVICOSREALIZADOS').add({
        'CADASTRO': dataStr,
        'DATA': FieldValue.serverTimestamp(),
        'ANO': now.year.toString(),
        'EMAIL': widget.emailFiltro,
        'CLIENTE': clienteNome,
        'EMPRESA': true,
        'EQUIPAMENTO': equip,
        'NOME': equip,
        'MARCA': (d['MARCA'] ?? '').toString(),
        'MODELO': (d['MODELO'] ?? '').toString(),
        'BTUS': (d['BTUS'] ?? '').toString(),
        'TIPO': (d['TIPO'] ?? '').toString(),
        'FLUIDO': (d['FLUIDO'] ?? '').toString(),
        'RESPONSAVEL': (d['RESPONSAVEL'] ?? '').toString(),
        'NUMERODAOS': os,
        'PATRIMONIO': patrimonio,
        'SALA': sala,
        'SETOR': setor,
        'MES': mesNome,
        'SERVICO': defeito,
        'SERVICOREALIZADO': '',
        'DESCRICAO': infoAdd,
        'STATUS': 'AGUARDANDO AVALIAÇÃO',
        'TECNICORESPONSAVEL': 'NÃO DEFINIDO', // Ajustado padrão Firebase
        'PECAS': '', // Ajustado padrão Firebase
        'PONTOS': 0,
        'TERMINO': '',
      });

      await _step(0.72, 'Enviando notificação push...');
      await _notificarHPS(equip, sala, os);

      await _step(0.85, 'Criando notificações e enviando e-mail...');

      await _criarNotificacaoFirebase(
          email: widget.emailFiltro,
          os: os,
          equip: equip,
          sala: sala,
          setor: setor,
          defeito: defeito,
          mes: now.month,
          ano: now.year);
      await _criarNotificacaoFirebase(
          email: _emailHPS,
          os: os,
          equip: equip,
          sala: sala,
          setor: setor,
          defeito: defeito,
          mes: now.month,
          ano: now.year);

      final destinos = await _buscarEmailsHPS();
      for (final mail in destinos) {
        unawaited(_sendEmailEquipamentosWidget(
          toEmail: mail,
          tipo: 'solicitacao',
          os: os,
          equip: equip,
          sala: sala,
          setor: setor,
          defeito: defeito,
          cliente: clienteNome,
          patrimonio: patrimonio,
        ));
      }

      await _step(1.0, 'Solicitação enviada! ✓');
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      setState(() {
        _enviandoSolicitacao = false;
        _progressoEnvio = 0.0;
      });

      final equip2 = equip;
      final os2 = os;
      _osCtrl.clear();
      _defeitoCtrl.clear();
      _descricaoCtrl.clear();

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _SolicitacaoSucessoOverlay(
          os: os2,
          equip: equip2,
          onDone: () {
            if (entry.mounted) entry.remove();
            setState(() => _viewState = _ViewState.list);
          },
        ),
      );
      Overlay.of(ctx).insert(entry);
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviandoSolicitacao = false;
          _progressoEnvio = 0.0;
        });
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('Erro ao enviar: $e'),
            backgroundColor: const Color(0xFFEF5350)));
      }
    }
  }

  Future<void> _salvarEquipamento(BuildContext ctx, BuildContext bCtx) async {
    final campos = [
      _nomeCtrl,
      _patrimonioCtrl,
      _salaCtrl,
      _setorCtrl,
      _responsavelCtrl,
      _tipoCtrl,
      _marcaCtrl,
      _modeloCtrl,
      _btusCtrl,
      _fluidoCtrl,
      _tensaoCtrl
    ];
    if (campos.any((c) => c.text.trim().isEmpty)) {
      _mostrarErroValidacao(ctx);
      return;
    }

    final novoEquip = {
      'EQUIPAMENTO': _nomeCtrl.text.trim().toUpperCase(),
      'NOME': _nomeCtrl.text.trim().toUpperCase(),
      'PATRIMONIO': _patrimonioCtrl.text.trim().toUpperCase(),
      'SALA': _salaCtrl.text.trim().toUpperCase(),
      'SETOR': _setorCtrl.text.trim().toUpperCase(),
      'RESPONSAVEL': _responsavelCtrl.text.trim().toUpperCase(),
      'TIPO': _tipoCtrl.text.trim().toUpperCase(),
      'MARCA': _marcaCtrl.text.trim().toUpperCase(),
      'MODELO': _modeloCtrl.text.trim().toUpperCase(),
      'BTUS': _btusCtrl.text.trim().toUpperCase(),
      'FLUIDO': _fluidoCtrl.text.trim().toUpperCase(),
      'TENSAO': _tensaoCtrl.text.trim().toUpperCase(),
    };

    String clienteNome = widget.emailFiltro;
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: widget.emailFiltro)
          .limit(1)
          .get();
      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        if (userData['display_name'] != null &&
            userData['display_name'].toString().isNotEmpty) {
          clienteNome = userData['display_name'].toString().toUpperCase();
        }
      }
    } catch (_) {}

    late OverlayEntry entry;
    entry = OverlayEntry(
        builder: (_) => _SalvandoOverlay(onDone: () {
              if (entry.mounted) entry.remove();
            }));
    Overlay.of(ctx).insert(entry);

    try {
      await FirebaseFirestore.instance.collection('EQUIPAMENTOS_EMPRESA').add({
        'EMAIL': widget.emailFiltro,
        'EQUIPAMENTO': novoEquip['EQUIPAMENTO'],
        'NOME': novoEquip['NOME'],
        'PATRIMONIO': novoEquip['PATRIMONIO'],
        'SALA': novoEquip['SALA'],
        'SETOR': novoEquip['SETOR'],
        'RESPONSAVEL': novoEquip['RESPONSAVEL'],
        'TIPO': novoEquip['TIPO'],
        'MARCA': novoEquip['MARCA'],
        'MODELO': novoEquip['MODELO'],
        'BTUS': novoEquip['BTUS'],
        'FLUIDO': novoEquip['FLUIDO'],
        'TENSAO': novoEquip['TENSAO'],
        'CONTRATO': false,
        'numero_pesquisa': '',
        'DATA_CADASTRO': FieldValue.serverTimestamp(),
      });

      await _criarNotificacaoFirebase(
          email: widget.emailFiltro,
          os: '',
          equip: novoEquip['EQUIPAMENTO'] ?? '',
          sala: novoEquip['SALA'] ?? '',
          setor: novoEquip['SETOR'] ?? '',
          defeito: 'Novo equipamento cadastrado no sistema.',
          mes: DateTime.now().month,
          ano: DateTime.now().year);
      await _criarNotificacaoFirebase(
          email: _emailHPS,
          os: '',
          equip: novoEquip['EQUIPAMENTO'] ?? '',
          sala: novoEquip['SALA'] ?? '',
          setor: novoEquip['SETOR'] ?? '',
          defeito: 'Novo equipamento cadastrado pelo cliente.',
          mes: DateTime.now().month,
          ano: DateTime.now().year);

      final destinos = await _buscarEmailsHPS();
      for (final mail in destinos) {
        unawaited(_sendEmailEquipamentosWidget(
          toEmail: mail,
          tipo: 'equipamento',
          os: '',
          equip: novoEquip['EQUIPAMENTO'] ?? '',
          sala: novoEquip['SALA'] ?? '',
          setor: novoEquip['SETOR'] ?? '',
          defeito: '',
          cliente: clienteNome,
          patrimonio: novoEquip['PATRIMONIO'] ?? '',
        ));
      }

      if (!mounted) return;
      setState(() {
        _search = '';
        _searchCtrl.clear();
      });

      await Future.delayed(const Duration(milliseconds: 1800));
      if (entry.mounted) entry.remove();
      if (mounted) _goTo(_ViewState.details, novoEquip, null, null);
    } catch (e) {
      if (entry.mounted) entry.remove();
      debugPrint('Erro ao salvar equipamento: $e');
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('❌ Erro ao salvar: $e'),
            backgroundColor: const Color(0xFFEF5350),
            duration: const Duration(seconds: 5)));
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERLAY: Solicitação Enviada
// ══════════════════════════════════════════════════════════════════════════════
class _SolicitacaoSucessoOverlay extends StatefulWidget {
  const _SolicitacaoSucessoOverlay(
      {required this.os, required this.equip, required this.onDone});
  final String os;
  final String equip;
  final VoidCallback onDone;

  @override
  State<_SolicitacaoSucessoOverlay> createState() =>
      _SolicitacaoSucessoOverlayState();
}

class _SolicitacaoSucessoOverlayState extends State<_SolicitacaoSucessoOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn, _scale, _checkDraw, _fadeOut;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800));
    _fadeIn = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.15, curve: Curves.easeOut));
    _scale = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.30, curve: Curves.elasticOut));
    _checkDraw = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic));
    _fadeOut = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.78, 1.0, curve: Curves.easeIn));
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final opacity = (_fadeIn.value - _fadeOut.value).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Material(
            color: Colors.black.withAlpha(160),
            child: SafeArea(
              child: Center(
                child: Transform.scale(
                  scale: 0.7 + _scale.value * 0.3,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 36),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2520),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: const Color(0xFF00897B).withAlpha(80),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF00897B).withAlpha(60),
                            blurRadius: 40,
                            spreadRadius: 4)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                                colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF00897B).withAlpha(100),
                                  blurRadius: 20,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Opacity(
                            opacity: _checkDraw.value,
                            child: Transform.scale(
                              scale: 0.5 + _checkDraw.value * 0.5,
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text('Solicitação Enviada!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(widget.equip,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF80CBC4),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF00897B).withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_outlined,
                                  color: Color(0xFF80CBC4), size: 15),
                              const SizedBox(width: 7),
                              Text('OS #${widget.os}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF80CBC4),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _ctrl.value < 0.78
                                ? (_ctrl.value / 0.78).clamp(0.0, 1.0)
                                : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF26A69A),
                                  Color(0xFF00E5CC)
                                ]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                            'A HPS foi notificada e irá avaliar sua solicitação.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withAlpha(100),
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERLAY: Salvando
// ══════════════════════════════════════════════════════════════════════════════
class _SalvandoOverlay extends StatefulWidget {
  const _SalvandoOverlay({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_SalvandoOverlay> createState() => _SalvandoOverlayState();
}

class _SalvandoOverlayState extends State<_SalvandoOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn, _scale, _progress, _fadeOut;
  String _label = 'Preparando...';

  static const Color _primary = Color(0xFF00897B);
  static const Color _primaryDark = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _fadeIn = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.15, curve: Curves.easeOut));
    _scale = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.2, curve: Curves.elasticOut));
    _progress = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.75, curve: Curves.easeInOut));
    _fadeOut = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.82, 1.0, curve: Curves.easeIn));

    _ctrl.addListener(() {
      final v = _ctrl.value;
      String next;
      if (v < 0.25) {
        next = 'Preparando...';
      } else if (v < 0.50) {
        next = 'Salvando dados...';
      } else if (v < 0.75) {
        next = 'Sincronizando...';
      } else {
        next = 'Concluído!';
      }
      if (next != _label && mounted) setState(() => _label = next);
    });

    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(_fadeOut),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Material(
            color: Colors.black.withAlpha(170),
            child: SafeArea(
              child: Center(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.7, end: 1.0).animate(_scale),
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: _primary.withAlpha(80),
                            blurRadius: 40,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_primary, _primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: _primary.withAlpha(100),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: _progress.value >= 0.98
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 36)
                              : const Icon(Icons.save_outlined,
                                  color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 22),
                        const Text('Salvando Equipamento',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF263238))),
                        const SizedBox(height: 6),
                        Text(_label,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF546E7A),
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE0F2F1),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('${(_progress.value * 100).toInt()}%',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FORMATADOR MAIÚSCULAS
// ══════════════════════════════════════════════════════════════════════════════
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
