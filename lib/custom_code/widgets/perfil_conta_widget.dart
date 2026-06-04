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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilContaWidget extends StatefulWidget {
  const PerfilContaWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<PerfilContaWidget> createState() => _PerfilContaWidgetState();
}

class _PerfilContaWidgetState extends State<PerfilContaWidget>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF39D2C0);
  static const Color _dark = Color(0xFF00897B);
  static const Color _verde = Color(0xFF1A3C34);
  static const Color _red = Color(0xFFEF5350);
  static const Color _orange = Color(0xFFFF8F00);

  String get _email => FirebaseAuth.instance.currentUser?.email ?? '';

  // Dados perfil
  Map<String, dynamic>? _dados;
  bool _carregandoDados = true;

  // Dica senha
  String _dicaMascarada = '';
  int _tamanhoSenha = 0;
  bool _mostrandoDica = false;

  // Tab
  late TabController _tabCtrl;

  // Alterar senha
  final _atualCtrl = TextEditingController();
  final _novaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _showAtual = false;
  bool _showNova = false;
  bool _showConfirmar = false;
  bool _carregandoSenha = false;
  bool _sucessoSenha = false;
  String _erroSenha = '';

  // Solicitar reset
  final _nomeCtrl = TextEditingController();
  final _detalheCtrl = TextEditingController();
  String? _motivoSelecionado;
  final List<String> _motivos = [
    'Esqueci minha senha',
    'Senha não funciona mais',
    'Primeiro acesso',
    'Outro',
  ];
  bool _carregandoReset = false;
  bool _resetEnviado = false;
  String _erroReset = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _atualCtrl.dispose();
    _novaCtrl.dispose();
    _confirmarCtrl.dispose();
    _nomeCtrl.dispose();
    _detalheCtrl.dispose();
    super.dispose();
  }

  // ── Carregar dados ────────────────────────────────────────────────────────
  Future<void> _carregar() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: _email)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty && mounted) {
        final d = snap.docs.first.data();
        final senha = (d['senha'] ?? '').toString().trim();
        String dica = '';
        int tam = 0;
        if (senha.isNotEmpty) {
          tam = senha.length;
          if (tam == 1)
            dica = '*';
          else if (tam == 2)
            dica = '${senha[0]}*';
          else
            dica = '${senha[0]}${'*' * (tam - 2)}${senha[tam - 1]}';
        }
        setState(() {
          _dados = d;
          _dicaMascarada = dica;
          _tamanhoSenha = tam;
          _carregandoDados = false;
        });
      } else {
        if (mounted) setState(() => _carregandoDados = false);
      }
    } catch (_) {
      if (mounted) setState(() => _carregandoDados = false);
    }
  }

  // ── Alterar senha ─────────────────────────────────────────────────────────
  Future<void> _alterarSenha() async {
    final atual = _atualCtrl.text.trim();
    final nova = _novaCtrl.text.trim();
    final conf = _confirmarCtrl.text.trim();

    if (atual.isEmpty || nova.isEmpty || conf.isEmpty) {
      setState(() => _erroSenha = 'Preencha todos os campos.');
      return;
    }
    if (nova.length < 6) {
      setState(() =>
          _erroSenha = 'A nova senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (nova != conf) {
      setState(() => _erroSenha = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _carregandoSenha = true;
      _erroSenha = '';
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: _email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        setState(() {
          _erroSenha = 'Usuário não encontrado.';
          _carregandoSenha = false;
        });
        return;
      }

      final senhaFS = (snap.docs.first.data()['senha'] ?? '').toString().trim();
      if (atual != senhaFS) {
        setState(() {
          _erroSenha = 'Senha atual incorreta.';
          _carregandoSenha = false;
        });
        return;
      }

      await snap.docs.first.reference.update({'senha': nova});
      try {
        await FirebaseAuth.instance.currentUser?.updatePassword(nova);
      } catch (_) {}
      try {
        await http.post(
          Uri.parse(
              'https://us-central1-h-p-s-modificado-emdcp0.cloudfunctions.net/alterarSenha'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {'email': _email, 'senhaAtual': atual, 'novaSenha': nova}
          }),
        );
      } catch (_) {}

      _atualCtrl.clear();
      _novaCtrl.clear();
      _confirmarCtrl.clear();
      setState(() {
        _sucessoSenha = true;
        _carregandoSenha = false;
      });
      await _carregar();
    } catch (e) {
      setState(() {
        _erroSenha = 'Erro: $e';
        _carregandoSenha = false;
      });
    }
  }

  // ── Solicitar reset ───────────────────────────────────────────────────────
  Future<void> _enviarSolicitacao() async {
    final nome = _nomeCtrl.text.trim();
    final detalhe = _detalheCtrl.text.trim();
    final motivo = _motivoSelecionado;

    if (nome.isEmpty) {
      setState(() => _erroReset = 'Informe seu nome.');
      return;
    }
    if (motivo == null) {
      setState(() => _erroReset = 'Selecione o motivo.');
      return;
    }

    setState(() {
      _carregandoReset = true;
      _erroReset = '';
    });

    try {
      await FirebaseFirestore.instance.collection('SOLICITACOES_SENHA').add({
        'email': _email,
        'nome': nome,
        'motivo': motivo,
        'detalhe': detalhe,
        'status': 'pendente',
        'criadoEm': FieldValue.serverTimestamp(),
        'resolvidoEm': null,
        'resolvidoPor': null,
        'novaSenha': null,
      });

      await _notificarAdmins(nome: nome, motivo: motivo);
      await _emailHPS(nome: nome, motivo: motivo, detalhe: detalhe);

      setState(() {
        _carregandoReset = false;
        _resetEnviado = true;
      });
    } catch (e) {
      setState(() {
        _erroReset = 'Erro: $e';
        _carregandoReset = false;
      });
    }
  }

  Future<void> _notificarAdmins(
      {required String nome, required String motivo}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();
      final lista = <String>['hpsrefri@gmail.com'];
      if (snap.docs.isNotEmpty) {
        final field = snap.docs.first.data()['emailteste'];
        if (field is List) {
          for (final e in field) {
            final s = (e ?? '').toString().trim();
            if (s.isNotEmpty) lista.add(s);
          }
        } else if (field is String && field.trim().isNotEmpty) {
          lista.add(field.trim());
        }
      }
      for (final adm in lista) {
        await FirebaseFirestore.instance.collection('NOTIFICACAO').add({
          'email': adm,
          'titulo': 'Solicitação de Reset de Senha',
          'mensagem':
              '$nome ($_email) solicitou redefinição de senha. Motivo: $motivo.',
          'tipo': 'sistema',
          'visto': false,
          'data': Timestamp.now(),
          'status': 'pendente',
          'os': '',
          'solicitanteEmail': _email,
          'solicitanteNome': nome,
        });
      }
    } catch (e) {
      debugPrint('Erro notificação: $e');
    }
  }

  Future<void> _emailHPS(
      {required String nome,
      required String motivo,
      required String detalhe}) async {
    String apiKey = '';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty)
        apiKey = (snap.docs.first.data()['apibrevo'] ?? '').toString().trim();
    } catch (_) {}
    if (apiKey.isEmpty) return;

    const img =
        'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
    final det = detalhe.isNotEmpty
        ? '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;">Detalhe</td><td style="padding:10px 14px;color:#1f2937;">$detalhe</td></tr>'
        : '';
    final msgHtml =
        '<h2 style="margin:0 0 16px;color:#1A3C34;">Nova Solicitação de Reset de Senha</h2>'
        '<p style="font-size:15px;color:#374151;line-height:1.7;">O usuário <strong>$nome</strong> (<strong>$_email</strong>) solicitou a redefinição de senha.</p>'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;border:1px solid #e2e8f0;font-size:14px;margin-bottom:16px;">'
        '<tr><td colspan="2" style="background:#1A3C34;padding:10px 14px;"><span style="color:#fff;font-weight:bold;">DETALHES DA SOLICITAÇÃO</span></td></tr>'
        '<tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;width:140px;border-bottom:1px solid #e2e8f0;">Nome</td><td style="padding:10px 14px;border-bottom:1px solid #e2e8f0;">$nome</td></tr>'
        '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">E-mail</td><td style="padding:10px 14px;border-bottom:1px solid #e2e8f0;">$_email</td></tr>'
        '<tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Motivo</td><td style="padding:10px 14px;color:#c0392b;font-weight:bold;border-bottom:1px solid #e2e8f0;">$motivo</td></tr>'
        '$det</table>'
        '<p style="background:#fff3cd;border-left:4px solid #FF8F00;padding:12px;color:#856404;margin:0;">Acesse o aplicativo como administrador para redefinir a senha.</p>';

    final htmlFull =
        '<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><title>Solicitação de Senha</title></head>'
        '<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,sans-serif;">'
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#f4f6f8;padding:20px 0;"><tr><td align="center">'
        '<table width="600" cellpadding="0" cellspacing="0" border="0" style="background:#fff;border-radius:12px;overflow:hidden;max-width:1400px;width:100%;">'
        '<tr><td style="padding:0;line-height:0;"><img src="$img" width="600" style="display:block;width:100%;max-width:1400px;height:auto;border:0;"/></td></tr>'
        '<tr><td style="background:#1A3C34;padding:12px 24px;"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td></td>'
        '<td align="right"><span style="background:#ffffff20;color:#fff;font-size:11px;font-weight:bold;padding:4px 10px;border-radius:20px;">Notificação Automática</span></td></tr></table></td></tr>'
        '<tr><td style="padding:28px;color:#333;font-size:15px;line-height:1.7;">$msgHtml</td></tr>'
        '<tr><td style="padding:0 28px;"><hr style="border:none;border-top:1px solid #e8ecf0;margin:0;"></td></tr>'
        '<tr><td style="padding:20px 28px;"><table cellpadding="0" cellspacing="0" border="0"><tr>'
        '<td style="width:44px;vertical-align:top;"><div style="width:40px;height:40px;background:#1A3C34;border-radius:50%;text-align:center;line-height:40px;">'
        '<span style="color:#fff;font-size:18px;font-weight:bold;">H</span></div></td>'
        '<td style="padding-left:12px;vertical-align:top;">'
        '<span style="font-size:15px;font-weight:bold;color:#1A3C34;">Huagner Pires</span><br>'
        '<span style="font-size:13px;color:#555;">Especialista em Refrigeração</span><br>'
        '<span style="font-size:12px;color:#888;">hpsrefri.com.br</span>'
        '</td></tr></table></td></tr>'
        '<tr><td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;border-top:1px solid #e2e8f0;">'
        '&copy; 2026 HPS Refrigeração &middot; Todos os direitos reservados<br>'
        '<span style="font-size:11px;">Esta é uma mensagem automática, por favor não responda diretamente.</span>'
        '</td></tr></table></td></tr></table></body></html>';

    await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'api-key': apiKey
      },
      body: jsonEncode({
        'sender': {
          'name': 'HPS Refrigeração',
          'email': 'equipe@hpsrefri.com.br'
        },
        'replyTo': {
          'name': 'HPS Refrigeração',
          'email': 'equipe@hpsrefri.com.br'
        },
        'to': [
          {'email': 'hpsrefri@gmail.com'}
        ],
        'subject': 'Solicitação de Reset de Senha - $nome',
        'htmlContent': htmlFull,
      }),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF151A22) : const Color(0xFFF4F6F8);
    final cardColor = isDark ? const Color(0xFF1E2530) : Colors.white;

    if (_carregandoDados) {
      return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
              child:
                  CircularProgressIndicator(color: _primary, strokeWidth: 2)));
    }

    final d = _dados ?? {};
    final nome = d['display_name']?.toString() ?? '-';
    final email = d['email']?.toString() ?? _email;
    final cnpj = d['CNPJ']?.toString() ?? '';
    final bairro = d['BAIRRO']?.toString() ?? '';
    final endereco = d['ENDERECO']?.toString() ?? '';
    final numero = d['NUMERO']?.toString() ?? '';
    final telefone = d['TELEFONE']?.toString() ?? '';
    final emailNotif = d['emailnotificacao']?.toString() ?? '';
    final contrato = d['tipodecontrato']?.toString() ?? '';
    final empresa = d['empresa'] == true;
    final photoUrl = d['photo_url']?.toString() ?? '';
    final endCompleto = [
      endereco,
      numero.isNotEmpty ? 'Nº $numero' : '',
      bairro
    ].where((e) => e.isNotEmpty).join(', ');

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: bgColor,
      child: Column(children: [
        // ── Header verde ────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [_primary, const Color(0xFF1A1A2E)]
                  : [_primary, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(children: [
            // Botao fechar
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 17,
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.35)
                        : _primary.withOpacity(0.5),
                    width: 3),
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : _primary.withOpacity(0.12),
              ),
              child: ClipOval(
                child: photoUrl.startsWith('http')
                    ? Image.network(photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _letraAvatar(nome))
                    : _letraAvatar(nome),
              ),
            ),
            const SizedBox(height: 12),
            Text(nome,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 3),
            Text(email,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withOpacity(0.65)
                        : Colors.black54)),
            const SizedBox(height: 10),
            Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (empresa)
                    _badge(
                        'Empresa',
                        Icons.business_rounded,
                        isDark
                            ? _primary.withOpacity(0.2)
                            : _primary.withOpacity(0.12),
                        _primary),
                  if (contrato.isNotEmpty)
                    _badge(
                        contrato,
                        Icons.verified_rounded,
                        isDark
                            ? _primary.withOpacity(0.25)
                            : _primary.withOpacity(0.12),
                        _primary),
                ]),
          ]),
        ),

        // ── Tabs ────────────────────────────────────────────────────────────
        Container(
          color: cardColor,
          child: TabBar(
            dividerColor: Colors.transparent,
            controller: _tabCtrl,
            labelColor: _primary,
            unselectedLabelColor: theme.secondaryText,
            indicatorColor: _primary,
            indicatorWeight: 2.5,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(text: 'PERFIL'),
              Tab(text: 'ALTERAR SENHA'),
              Tab(text: 'REDEFINIR'),
            ],
          ),
        ),
        Divider(height: 1, color: theme.alternate),

        // ── Conteudo das tabs ────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _tabPerfil(d, nome, email, cnpj, endCompleto, telefone,
                  emailNotif, contrato, isDark, theme, cardColor),
              _tabAlterarSenha(isDark, theme, cardColor),
              _tabRedefinir(isDark, theme, cardColor),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Tab Perfil ─────────────────────────────────────────────────────────────
  Widget _tabPerfil(
      Map d,
      String nome,
      String email,
      String cnpj,
      String end,
      String tel,
      String emailNotif,
      String contrato,
      bool isDark,
      FlutterFlowTheme theme,
      Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (tel.isNotEmpty)
          _secao('CONTATO', cardColor, isDark, [
            _infoLinha(
                Icons.phone_rounded, 'Telefone', _fmtTel(tel), isDark, theme),
            if (emailNotif.isNotEmpty)
              _infoLinha(Icons.email_outlined, 'E-mail de Notificação',
                  emailNotif, isDark, theme),
          ]),
        if (end.isNotEmpty) ...[
          const SizedBox(height: 12),
          _secao('ENDEREÇO', cardColor, isDark, [
            _infoLinha(
                Icons.location_on_outlined, 'Logradouro', end, isDark, theme),
          ]),
        ],
        if (cnpj.isNotEmpty) ...[
          const SizedBox(height: 12),
          _secao('DADOS FISCAIS', cardColor, isDark, [
            _infoLinha(Icons.receipt_long_outlined, 'CNPJ', _fmtCnpj(cnpj),
                isDark, theme),
          ]),
        ],
        if (contrato.isNotEmpty) ...[
          const SizedBox(height: 12),
          _secaoContrato(contrato, isDark, theme, cardColor),
        ],
        const SizedBox(height: 16),
        // Dica senha
        if (_dicaMascarada.isNotEmpty) ...[
          GestureDetector(
            onTap: () => setState(() => _mostrandoDica = !_mostrandoDica),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.key_rounded, color: _primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Dica da Senha',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.secondaryText)),
                      if (_mostrandoDica) ...[
                        const SizedBox(height: 4),
                        Text('$_dicaMascarada  •  $_tamanhoSenha caracteres',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                                letterSpacing: 2)),
                      ],
                    ])),
                Icon(
                    _mostrandoDica
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _primary,
                    size: 18),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ]),
    );
  }

  // ── Tab Alterar Senha ──────────────────────────────────────────────────────
  Widget _tabAlterarSenha(
      bool isDark, FlutterFlowTheme theme, Color cardColor) {
    if (_sucessoSenha) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: _primary, size: 42),
            ),
            const SizedBox(height: 20),
            Text('Senha Alterada com Sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryText)),
            const SizedBox(height: 10),
            Text('Sua senha foi atualizada. Use-a no próximo acesso.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: theme.secondaryText, height: 1.5)),
            const SizedBox(height: 24),
            _btnPrimario('Alterar Novamente', Icons.lock_reset_rounded, () {
              setState(() => _sucessoSenha = false);
            }),
          ]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 4),
        // Banner info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primary.withOpacity(isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withOpacity(0.25)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline_rounded, color: _primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
              'Informe sua senha atual para confirmar a identidade e definir uma nova senha.',
              style: TextStyle(
                  fontSize: 12, color: theme.secondaryText, height: 1.5),
            )),
          ]),
        ),
        const SizedBox(height: 20),

        if (_erroSenha.isNotEmpty) _bannerErro(_erroSenha),

        _label('Senha Atual', theme),
        const SizedBox(height: 6),
        _campoSenha(_atualCtrl, 'Digite sua senha atual', !_showAtual, isDark,
            theme, () => setState(() => _showAtual = !_showAtual)),

        const SizedBox(height: 14),
        _label('Nova Senha', theme),
        const SizedBox(height: 6),
        _campoSenha(_novaCtrl, 'Mínimo 6 caracteres', !_showNova, isDark, theme,
            () => setState(() => _showNova = !_showNova)),

        const SizedBox(height: 14),
        _label('Confirmar Nova Senha', theme),
        const SizedBox(height: 6),
        _campoSenha(
            _confirmarCtrl,
            'Repita a nova senha',
            !_showConfirmar,
            isDark,
            theme,
            () => setState(() => _showConfirmar = !_showConfirmar)),

        const SizedBox(height: 24),
        _btnCarregando('Salvar Nova Senha', Icons.save_rounded,
            _carregandoSenha, _alterarSenha),
        const SizedBox(height: 8),
      ]),
    );
  }

  // ── Tab Redefinir ─────────────────────────────────────────────────────────
  Widget _tabRedefinir(bool isDark, FlutterFlowTheme theme, Color cardColor) {
    if (_resetEnviado) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _orange.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: _orange, size: 40),
            ),
            const SizedBox(height: 20),
            Text('Solicitação Enviada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryText)),
            const SizedBox(height: 10),
            Text(
              'A equipe HPS recebeu sua solicitação\ne entrará em contato em breve.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: theme.secondaryText, height: 1.5),
            ),
          ]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _orange.withOpacity(isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _orange.withOpacity(0.3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.support_agent_rounded, color: _orange, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
              'Solicite a redefinição pela equipe HPS. Você será notificado quando a senha for redefinida.',
              style: TextStyle(
                  fontSize: 12, color: theme.secondaryText, height: 1.5),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        if (_erroReset.isNotEmpty) _bannerErro(_erroReset),
        _label('Seu Nome', theme),
        const SizedBox(height: 6),
        _campoTexto(_nomeCtrl, 'Como você se chama', isDark, theme),
        const SizedBox(height: 14),
        _label('Motivo', theme),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _motivoSelecionado,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E2530) : Colors.white,
              hint: Text('Selecione o motivo',
                  style: TextStyle(
                      fontSize: 13,
                      color: theme.secondaryText.withOpacity(0.5))),
              style: TextStyle(fontSize: 14, color: theme.primaryText),
              items: _motivos
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _motivoSelecionado = v),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _label('Detalhe (opcional)', theme),
        const SizedBox(height: 6),
        _campoTexto(_detalheCtrl, 'Descreva o problema', isDark, theme,
            maxLines: 3),
        const SizedBox(height: 24),
        _btnCarregando('Enviar Solicitação', Icons.send_rounded,
            _carregandoReset, _enviarSolicitacao,
            cor: _orange),
        const SizedBox(height: 8),
      ]),
    );
  }

  // ── Helpers UI ─────────────────────────────────────────────────────────────
  Widget _letraAvatar(String nome) {
    final isDarkCtx = false; // cor sempre primaria
    return Container(
      color: _primary.withOpacity(0.3),
      child: Center(
          child: Text(nome.isNotEmpty ? nome[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white))),
    );
  }

  Widget _badge(String label, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: fg, size: 12),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }

  Widget _secao(
      String titulo, Color cardColor, bool isDark, List<Widget> itens) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 8),
          child: Row(children: [
            Container(
                width: 3,
                height: 13,
                decoration: BoxDecoration(
                    color: _primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                    letterSpacing: 0.8)),
          ]),
        ),
        Divider(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05)),
        ...itens,
      ]),
    );
  }

  Widget _secaoContrato(
      String contrato, bool isDark, FlutterFlowTheme theme, Color cardColor) {
    Color cor;
    IconData icon;
    switch (contrato.toUpperCase()) {
      case 'ANUAL':
        cor = const Color(0xFF1565C0);
        icon = Icons.workspace_premium_rounded;
        break;
      case 'SEMESTRAL':
        cor = const Color(0xFF6A1B9A);
        icon = Icons.star_rounded;
        break;
      default:
        cor = _primary;
        icon = Icons.autorenew_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: cor, size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tipo de Contrato',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText.withOpacity(0.6))),
          const SizedBox(height: 2),
          Text(contrato,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: cor)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cor.withOpacity(0.3))),
          child: Text('Ativo',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: cor)),
        ),
      ]),
    );
  }

  Widget _infoLinha(IconData icon, String label, String valor, bool isDark,
      FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: _primary.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _primary, size: 17)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText.withOpacity(0.6))),
          const SizedBox(height: 2),
          Text(valor,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryText)),
        ])),
      ]),
    );
  }

  Widget _label(String text, FlutterFlowTheme theme) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.secondaryText.withOpacity(0.7)));
  }

  Widget _bannerErro(String msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _red.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: _red, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child:
                Text(msg, style: const TextStyle(color: _red, fontSize: 12))),
      ]),
    );
  }

  Widget _campoSenha(TextEditingController ctrl, String hint, bool obscure,
      bool isDark, FlutterFlowTheme theme, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(fontSize: 14, color: theme.primaryText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: theme.secondaryText.withOpacity(0.4)),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: _primary.withOpacity(0.6), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: theme.secondaryText.withOpacity(0.4),
                size: 18),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController ctrl, String hint, bool isDark,
      FlutterFlowTheme theme,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14, color: theme.primaryText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: theme.secondaryText.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _btnPrimario(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _btnCarregando(
      String label, IconData icon, bool carregando, VoidCallback onTap,
      {Color? cor}) {
    final c = cor ?? _primary;
    return GestureDetector(
      onTap: carregando ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: carregando ? c.withOpacity(0.4) : c,
          borderRadius: BorderRadius.circular(12),
          boxShadow: carregando
              ? []
              : [
                  BoxShadow(
                      color: c.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
        ),
        child: Center(
          child: carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ]),
        ),
      ),
    );
  }

  String _fmtTel(String t) {
    final d = t.replaceAll(RegExp(r'\D'), '');
    if (d.length == 11)
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
    if (d.length == 10)
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
    return t;
  }

  String _fmtCnpj(String c) {
    final d = c.replaceAll(RegExp(r'\D'), '');
    if (d.length == 14) {
      return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8, 12)}-${d.substring(12)}';
    }
    return c;
  }
}
