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

import '/auth/firebase_auth/auth_util.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// ─── OneSignal ───────────────────────────────────────────────────────────────
Future<void> _onesignal(String? email, String? telefone, String? key,
    String? value, String? userId) async {
  if (kIsWeb) return;
  OneSignal.initialize("7b01186f-cf76-4b5d-8354-87d83737d40c");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await Future.delayed(const Duration(milliseconds: 500));
  try {
    if (userId != null && userId.isNotEmpty && userId != "null") {
      OneSignal.login(userId);
    }
    if (email != null && email.isNotEmpty && email != "null") {
      await OneSignal.User.addEmail(email);
    }
    if (telefone != null && telefone.isNotEmpty && telefone != "null") {
      await OneSignal.User.addSms(telefone);
    }
    if (key != null && value != null && key.isNotEmpty && value.isNotEmpty) {
      OneSignal.User.addTagWithKey(key, value);
    }
    await OneSignal.Notifications.requestPermission(true);
  } catch (e) {
    print("OneSignal Erro: $e");
  }
}

// ─── Formatadores ────────────────────────────────────────────────────────────
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final trimmed = newValue.text.trimLeft();
    if (trimmed == newValue.text) return newValue;
    return newValue.copyWith(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// WIDGET PRINCIPAL
/// ═══════════════════════════════════════════════════════════════════════════════
class LoginCompletoWidget extends StatefulWidget {
  const LoginCompletoWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<LoginCompletoWidget> createState() => _LoginCompletoWidgetState();
}

class _LoginCompletoWidgetState extends State<LoginCompletoWidget>
    with SingleTickerProviderStateMixin {
  String _tela = 'login';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  String? _logoUrl;

  // ─── Login ───────────────────────────────────────────────────────────────────
  final _nomeLoginCtrl = TextEditingController();
  final _emailLoginCtrl = TextEditingController();
  final _senhaLoginCtrl = TextEditingController();
  bool _loginShowSenha = false;
  bool _loginCarregando = false;
  String _loginErro = '';

  // ─── Cadastro ────────────────────────────────────────────────────────────────
  final _cadNomeCtrl = TextEditingController();
  final _cadCargoCtrl = TextEditingController();
  final _cadSenhaCtrl = TextEditingController();
  bool _cadShowSenha = false;
  String _cadSenha = ''; // senha vinda da tela login
  String _cadEmail = '';
  bool _cadCarregando = false;
  String _cadErro = '';

  // ─── Senha ───────────────────────────────────────────────────────────────────
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _showAtual = false;
  bool _showNova = false;
  bool _showConfirmar = false;
  bool _senhaCarregando = false;
  bool _senhaAlterada = false;
  String _senhaErro = '';
  String _dicaMascarada = '';
  int _tamanhoSenha = 0;
  bool _mostrandoDica = false;

  bool _mostrarReset = false;
  final _nomeResetCtrl = TextEditingController();
  final _detalheCtrl = TextEditingController();
  String? _motivoSelecionado;
  bool _resetEnviado = false;
  final List<String> _motivos = [
    'Esqueci minha senha',
    'Senha não funciona mais',
    'Primeiro acesso',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Se já tem sessão ativa (ex: reload na web), vai direto para HOME
      final usuarioAtivo = FirebaseAuth.instance.currentUser;
      if (usuarioAtivo != null && mounted) {
        // Restaura nome do AppState (persiste entre reloads via SharedPreferences)
        final nomeGuardado = FFAppState().variavelUSUARIO.nome;
        final emailGuardado = FFAppState().variavelUSUARIO.email;
        // Só redireciona se tiver nome E email salvos (cadastro completo)
        if (nomeGuardado.isNotEmpty &&
            emailGuardado.isNotEmpty &&
            emailGuardado != 'hpsrefri@gmail.com') {
          if (mounted) context.goNamedAuth('HOME_new', context.mounted);
          return;
        }
      }
      _verificarSenhaRedefinida();
      _carregarLogoFirebase();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nomeLoginCtrl.dispose();
    _emailLoginCtrl.dispose();
    _senhaLoginCtrl.dispose();
    _cadNomeCtrl.dispose();
    _cadCargoCtrl.dispose();
    _cadSenhaCtrl.dispose();
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _confirmarCtrl.dispose();
    _nomeResetCtrl.dispose();
    _detalheCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarLogoFirebase() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: 'hpsrefri@gmail.com')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final url =
            (snap.docs.first.data()['photo_url'] ?? '').toString().trim();
        if (url.isNotEmpty && mounted) setState(() => _logoUrl = url);
      }
    } catch (_) {}
  }

  void _irPara(String tela) async {
    await _fadeCtrl.reverse();
    if (!mounted) return;
    setState(() {
      _tela = tela;
      _loginErro = '';
      _senhaErro = '';
    });
    if (tela == 'senha') _carregarDica();
    _fadeCtrl.forward();
  }

  Future<void> _verificarSenhaRedefinida() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (userEmail.isEmpty) return;
      final snap = await FirebaseFirestore.instance
          .collection('NOTIFICACAO')
          .where('email', isEqualTo: userEmail)
          .get();
      final notifs = snap.docs.where((doc) {
        final d = doc.data();
        final tipo = (d['tipo'] as String? ?? '').toLowerCase().trim();
        final visto = (d['visto'] as bool? ?? false);
        final titulo = (d['titulo'] as String? ?? '').toLowerCase();
        return tipo == 'sistema' &&
            !visto &&
            (titulo.contains('senha redefinida') ||
                titulo.contains('senha foi redefinida'));
      }).toList();
      if (notifs.isEmpty || !mounted) return;
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in notifs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PopupNovaSenha(email: userEmail),
      );
    } catch (_) {}
  }

  // ─── LOGIN ───────────────────────────────────────────────────────────────────
  Future<void> _fazerLogin() async {
    final nome = _nomeLoginCtrl.text.trim();
    final email = _emailLoginCtrl.text.trim().toLowerCase();
    final senha = _senhaLoginCtrl.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      await _dialog('Atenção', 'Preencha todos os campos para continuar.');
      return;
    }
    if (!_emailValido(email)) {
      await _dialog('Atenção', 'Digite um e-mail válido.');
      return;
    }

    setState(() {
      _loginCarregando = true;
      _loginErro = '';
    });

    try {
      // Busca na AREA_RESTRITA pelo NOME digitado (novo campo: nome)
      // Fallback: também tenta pelo campo antigo NOMEDOUSUARIO
      final nomeUpper = nome.toUpperCase();
      QuerySnapshot snapNome = await FirebaseFirestore.instance
          .collection('AREA_RESTRITA')
          .where('nome', isEqualTo: nomeUpper)
          .limit(1)
          .get();
      if (snapNome.docs.isEmpty) {
        snapNome = await FirebaseFirestore.instance
            .collection('AREA_RESTRITA')
            .where('NOMEDOUSUARIO', isEqualTo: nomeUpper)
            .limit(1)
            .get();
      }

      DocumentReference? _areaRestritaRef;
      if (snapNome.docs.isNotEmpty) {
        _areaRestritaRef = snapNome.docs.first.reference;
      } else {
        // Nome não encontrado — verifica se email existe em USUARIOS
        final existeNoSistema = await _emailExisteNoSistema(email);
        if (!existeNoSistema) {
          setState(() => _loginCarregando = false);
          await _dialog(
            'Acesso Negado',
            'Este e-mail não está registrado no sistema HPS. '
                'Solicite ao administrador o seu cadastro.',
          );
          return;
        }
        // Email existe em USUARIOS mas sem AREA_RESTRITA — primeiro acesso
        // Faz login PRIMEIRO para garantir que o uid está disponível no cadastro
        try {
          GoRouter.of(context).prepareAuthEvent();
          final userCad =
              await authManager.signInWithEmail(context, email, senha);
          if (userCad == null) {
            setState(() {
              _loginCarregando = false;
              _loginErro = 'Senha incorreta. Verifique e tente novamente.';
            });
            return;
          }
        } catch (signInErrCad) {
          final errStr = signInErrCad.toString().toLowerCase();
          final msg = errStr.contains('wrong-password') ||
                  errStr.contains('invalid-credential') ||
                  errStr.contains('user-not-found')
              ? 'Email ou senha incorretos.'
              : 'Erro ao autenticar. Verifique email e senha.';
          setState(() {
            _loginCarregando = false;
            _loginErro = msg;
          });
          print('SignIn erro (primeiro acesso): $signInErrCad');
          return;
        }
        // Login OK — vai para cadastro (já autenticado)
        setState(() {
          _cadEmail = email;
          _cadSenha = senha;
          _cadNomeCtrl.text = nome;
          _cadErro = '';
          _loginCarregando = false;
        });
        _irPara('cadastro');
        return;
      }

      // Usuário já tem AREA_RESTRITA — faz login normalmente
      final currentEmail =
          FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
      final jaLogadoLogin =
          currentEmail == email.toLowerCase() && currentEmail.isNotEmpty;

      if (!jaLogadoLogin) {
        try {
          GoRouter.of(context).prepareAuthEvent();
          final user = await authManager.signInWithEmail(context, email, senha);
          if (user == null) {
            setState(() {
              _loginCarregando = false;
              _loginErro = 'Senha incorreta. Verifique e tente novamente.';
            });
            return;
          }
        } catch (signInErr) {
          final errStr = signInErr.toString().toLowerCase();
          final msg = errStr.contains('wrong-password') ||
                  errStr.contains('invalid-credential') ||
                  errStr.contains('user-not-found')
              ? 'Email ou senha incorretos.'
              : 'Erro ao autenticar. Verifique email e senha.';
          setState(() {
            _loginCarregando = false;
            _loginErro = msg;
          });
          print('SignIn erro login: $signInErr');
          return;
        }
      }

      // Atualiza apenas último acesso no doc existente
      if (_areaRestritaRef != null) {
        try {
          await _areaRestritaRef.update({
            'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
            'ultimo_acesso': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }

      FFAppState().nomedouser = nome;
      FFAppState().variavelUSUARIO = DadosUsuarioStruct(
        nome: nome,
        senha: senha,
        email: email,
      );

      await _onesignal(
        email,
        '0000000',
        'Email',
        email,
        FirebaseAuth.instance.currentUser?.uid,
      );

      if (mounted) context.goNamedAuth('HOME_new', context.mounted);
    } catch (e) {
      setState(() => _loginErro = 'Erro ao autenticar. Tente novamente.');
      print('Login erro: $e');
    } finally {
      if (mounted) setState(() => _loginCarregando = false);
    }
  }

  // ─── CADASTRO (simplificado) ─────────────────────────────────────────────────
  Future<void> _cadastrar() async {
    final nome = _cadNomeCtrl.text.trim();
    final cargo = _cadCargoCtrl.text.trim();

    if (nome.isEmpty || cargo.isEmpty) {
      setState(() => _cadErro = 'Preencha nome e cargo para continuar.');
      return;
    }
    if (nome.length < 3) {
      setState(() => _cadErro = 'Digite seu nome completo.');
      return;
    }
    if (_cadSenha.isEmpty || _cadSenha.length < 6) {
      setState(
          () => _cadErro = 'Senha inválida. Volte ao login e tente novamente.');
      return;
    }

    setState(() {
      _cadCarregando = true;
      _cadErro = '';
    });

    try {
      final nomeFormatado = getMesMaiusculaA(nome) ?? nome.toUpperCase();
      final senha = _cadSenha;

      // O login já foi feito em _fazerLogin antes de vir para cá.
      // Apenas pega o uid do usuário já autenticado.
      final uidAtual = FirebaseAuth.instance.currentUser?.uid ?? '';

      print(
          '=== CADASTRO DEBUG === uid=$uidAtual email=$_cadEmail nome=$nomeFormatado');
      if (uidAtual.isEmpty) {
        setState(() {
          _cadCarregando = false;
          _cadErro = 'Sessão expirada. Volte ao login e tente novamente.';
        });
        return;
      }
      // Salva no Firestore
      try {
        await FirebaseFirestore.instance.collection('AREA_RESTRITA').add({
          'email': _cadEmail,
          'nome': nomeFormatado,
          'cargo': cargo,
          'uid': uidAtual,
          'cadastrado_em': FieldValue.serverTimestamp(),
          'ultimo_acesso': FieldValue.serverTimestamp(),
        });
      } catch (firestoreErr) {
        setState(() {
          _cadCarregando = false;
          _cadErro = 'Erro ao salvar dados: $firestoreErr';
        });
        print('Firestore erro: $firestoreErr');
        return;
      }

      FFAppState().nomedouser = nomeFormatado;
      FFAppState().variavelUSUARIO = DadosUsuarioStruct(
        nome: nomeFormatado,
        senha: senha,
        email: _cadEmail,
      );

      await _onesignal(
        _cadEmail,
        '0000000',
        'Email',
        _cadEmail,
        uidAtual,
      );

      if (mounted) context.goNamedAuth('HOME_new', context.mounted);
    } catch (e) {
      setState(() {
        _cadCarregando = false;
        _cadErro = 'Erro: $e';
      });
      print('Cadastro erro geral: $e');
    }
  }

  // ─── Verifica email em USUARIOS ──────────────────────────────────────────────
  Future<bool> _emailExisteNoSistema(String email) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _carregarDica() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final senha = (snap.docs.first.data()['senha'] ?? '').toString().trim();
        if (senha.isNotEmpty) {
          String dica;
          if (senha.length == 1) {
            dica = '*';
          } else if (senha.length == 2) {
            dica = '${senha[0]}*';
          } else {
            dica =
                '${senha[0]}${'*' * (senha.length - 2)}${senha[senha.length - 1]}';
          }
          if (mounted) {
            setState(() {
              _dicaMascarada = dica;
              _tamanhoSenha = senha.length;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _alterarSenha() async {
    final atual = _senhaAtualCtrl.text.trim();
    final nova = _novaSenhaCtrl.text.trim();
    final conf = _confirmarCtrl.text.trim();
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    if (atual.isEmpty || nova.isEmpty || conf.isEmpty) {
      setState(() => _senhaErro = 'Preencha todos os campos.');
      return;
    }
    if (nova.length < 6) {
      setState(() =>
          _senhaErro = 'A nova senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (nova != conf) {
      setState(() => _senhaErro = 'As senhas não coincidem.');
      return;
    }
    setState(() {
      _senhaCarregando = true;
      _senhaErro = '';
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() {
          _senhaErro = 'Usuário não encontrado.';
          _senhaCarregando = false;
        });
        return;
      }
      final senhaFS = (snap.docs.first.data()['senha'] ?? '').toString().trim();
      if (atual != senhaFS) {
        setState(() {
          _senhaErro = 'Senha atual incorreta.';
          _senhaCarregando = false;
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
            'data': {'email': userEmail, 'senhaAtual': atual, 'novaSenha': nova}
          }),
        );
      } catch (_) {}
      _senhaAtualCtrl.clear();
      _novaSenhaCtrl.clear();
      _confirmarCtrl.clear();
      setState(() {
        _senhaAlterada = true;
        _senhaCarregando = false;
      });
    } catch (e) {
      setState(() {
        _senhaErro = 'Erro: $e';
        _senhaCarregando = false;
      });
    }
  }

  Future<void> _enviarSolicitacao() async {
    final nome = _nomeResetCtrl.text.trim();
    final motivo = _motivoSelecionado;
    final detalhe = _detalheCtrl.text.trim();
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    if (nome.isEmpty) {
      setState(() => _senhaErro = 'Informe seu nome.');
      return;
    }
    if (motivo == null) {
      setState(() => _senhaErro = 'Selecione o motivo.');
      return;
    }
    setState(() {
      _senhaCarregando = true;
      _senhaErro = '';
    });
    try {
      await FirebaseFirestore.instance.collection('SOLICITACOES_SENHA').add({
        'email': userEmail,
        'nome': nome,
        'motivo': motivo,
        'detalhe': detalhe,
        'status': 'pendente',
        'criadoEm': FieldValue.serverTimestamp(),
        'resolvidoEm': null,
        'resolvidoPor': null,
        'novaSenha': null,
      });
      await _notificarAdmins(nome: nome, motivo: motivo, userEmail: userEmail);
      await _emailHPS(
          nome: nome, motivo: motivo, detalhe: detalhe, userEmail: userEmail);
      setState(() {
        _senhaCarregando = false;
        _resetEnviado = true;
      });
    } catch (e) {
      setState(() {
        _senhaErro = 'Erro: $e';
        _senhaCarregando = false;
      });
    }
  }

  Future<void> _notificarAdmins({
    required String nome,
    required String motivo,
    required String userEmail,
  }) async {
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
              '$nome ($userEmail) solicitou redefinição de senha. Motivo: $motivo.',
          'tipo': 'sistema',
          'visto': false,
          'data': Timestamp.now(),
          'status': 'pendente',
          'os': '',
          'solicitanteEmail': userEmail,
          'solicitanteNome': nome,
        });
      }
    } catch (_) {}
  }

  Future<void> _emailHPS({
    required String nome,
    required String motivo,
    required String detalhe,
    required String userEmail,
  }) async {
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
    } catch (_) {}
    if (apiKey.isEmpty) return;
    const img =
        'https://firebasestorage.googleapis.com/v0/b/h-p-s-modificado-emdcp0.appspot.com/o/Gemini_Generated_Image_2xpdsd2xpdsd2xpd%20(1).png?alt=media&token=be3e052e-a0b8-4e8c-8151-b9365b507ed5';
    final det = detalhe.isNotEmpty
        ? '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;">Detalhe</td><td style="padding:10px 14px;color:#1f2937;">$detalhe</td></tr>'
        : '';
    final htmlFull = '<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><title>Reset de Senha</title></head>' +
        '<body style="margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">' +
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f6f8;padding:20px 0;">' +
        '<tr><td align="center"><table width="600" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;border-radius:12px;overflow:hidden;">' +
        '<tr><td style="padding:0;margin:0;line-height:0;"><img src="$img" alt="HPS" width="600" style="display:block;width:100%;height:auto;border:0;"/></td></tr>' +
        '<tr><td style="background-color:#1A3C34;padding:12px 24px;"><span style="color:#fff;font-size:14px;font-weight:bold;">Notificação Automática</span></td></tr>' +
        '<tr><td style="padding:28px;">' +
        '<h2 style="margin:0 0 16px;color:#1A3C34;">Solicitação de Reset de Senha</h2>' +
        '<p style="margin:0 0 20px;font-size:15px;color:#374151;line-height:1.7;">O usuário <strong>$nome</strong> (<strong>$userEmail</strong>) solicitou a redefinição de senha.</p>' +
        '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;border:1px solid #e2e8f0;border-radius:8px;font-size:14px;">' +
        '<tr><td colspan="2" style="background:#1A3C34;padding:10px 14px;"><span style="color:#fff;font-weight:bold;">DETALHES</span></td></tr>' +
        '<tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;width:160px;border-bottom:1px solid #e2e8f0;">Nome</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$nome</td></tr>' +
        '<tr><td style="padding:10px 14px;font-weight:bold;color:#374151;border-bottom:1px solid #e2e8f0;">Email</td><td style="padding:10px 14px;color:#1f2937;border-bottom:1px solid #e2e8f0;">$userEmail</td></tr>' +
        '<tr style="background:#f8fafc;"><td style="padding:10px 14px;font-weight:bold;color:#374151;">Motivo</td><td style="padding:10px 14px;color:#c0392b;font-weight:bold;">$motivo</td></tr>' +
        '$det</table></td></tr>' +
        '<tr><td style="background:#f1f5f9;padding:14px 28px;text-align:center;font-size:12px;color:#94a3b8;">&copy; 2026 HPS Refrigeração</td></tr>' +
        '</table></td></tr></table></body></html>';
    try {
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
          'to': [
            {'email': 'hpsrefri@gmail.com'}
          ],
          'subject': 'Solicitação de Reset de Senha - $nome',
          'htmlContent': htmlFull,
        }),
      );
    } catch (_) {}
  }

  bool _emailValido(String email) {
    return email.contains('@') && email.split('@').last.contains('.');
  }

  Future<void> _dialog(String titulo, String mensagem) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Ok')),
        ],
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: _buildTela(),
        ),
      ),
    );
  }

  Widget _buildTela() {
    switch (_tela) {
      case 'cadastro':
        return _buildCadastro();
      case 'senha':
        return _buildSenha();
      default:
        return _buildLogin();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TELA LOGIN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLogin() {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            height: 300.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.secondary, theme.secondaryBackground],
                stops: const [1.0, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0x00FFFFFF), theme.secondaryBackground],
                  stops: const [0.0, 1.0],
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: theme.accent4,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        topRight: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(50.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: _logoUrl != null && _logoUrl!.isNotEmpty
                          ? Image.network(
                              _logoUrl!,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: theme.secondaryBackground,
                                child: Icon(Icons.business_rounded,
                                    color: theme.secondaryText, size: 50),
                              ),
                            )
                          : Container(
                              color: theme.secondaryBackground,
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: theme.primary, strokeWidth: 2),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 0.0),
                    child: Text('Soluções em climatização',
                        style: theme.headlineSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: theme.headlineSmall.fontWeight,
                          ),
                          letterSpacing: 0.0,
                        )),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 670.0),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _campoLogin(
                      controller: _nomeLoginCtrl,
                      label: 'Seu Nome',
                      hint: 'Digite seu nome',
                      prefixIcon: Icons.person_outline_rounded,
                      theme: theme,
                      formatters: [
                        _UpperCaseFormatter(),
                        _NoLeadingSpaceFormatter()
                      ],
                    ),
                    const SizedBox(height: 16),
                    _campoLogin(
                      controller: _emailLoginCtrl,
                      label: 'Email',
                      hint: 'seu@email.com',
                      prefixIcon: Icons.email_outlined,
                      theme: theme,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      formatters: [_NoLeadingSpaceFormatter()],
                    ),
                    const SizedBox(height: 16),
                    _campoSenhaLogin(theme),
                    const SizedBox(height: 8),
                    if (_loginErro.isNotEmpty)
                      _bannerErroWidget(_loginErro, theme),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 16.0),
                        child: _loginCarregando
                            ? _botaoCarregando(theme)
                            : _botaoEntrar(theme),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: InkWell(
                        onTap: () => _irPara('senha'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Esqueci / Alterar minha senha',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.inter(
                                  fontWeight: theme.bodyMedium.fontWeight),
                              color: theme.secondary,
                              letterSpacing: 0.0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoLogin({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required FlutterFlowTheme theme,
    TextInputType? keyboardType,
    List<String>? autofillHints,
    List<TextInputFormatter> formatters = const [],
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      autofocus: false,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      inputFormatters: formatters,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
        hintStyle: theme.labelMedium
            .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
        labelStyle: theme.labelMedium
            .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.secondary, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: theme.secondaryBackground,
        contentPadding: const EdgeInsets.all(24.0),
        prefixIcon: Icon(prefixIcon,
            color: theme.secondaryText.withOpacity(0.5), size: 20),
      ),
      style: theme.bodyMedium
          .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
      cursorColor: theme.primaryText,
    );
  }

  Widget _campoSenhaLogin(FlutterFlowTheme theme) {
    return TextFormField(
      controller: _senhaLoginCtrl,
      autofocus: false,
      autofillHints: const [AutofillHints.password],
      obscureText: !_loginShowSenha,
      inputFormatters: [_NoLeadingSpaceFormatter()],
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: theme.labelMedium
            .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primary, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: theme.secondaryBackground,
        contentPadding: const EdgeInsets.all(24.0),
        suffixIcon: InkWell(
          onTap: () => setState(() => _loginShowSenha = !_loginShowSenha),
          focusNode: FocusNode(skipTraversal: true),
          child: Icon(
            _loginShowSenha
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: theme.secondaryText,
            size: 24.0,
          ),
        ),
      ),
      style: theme.bodyMedium
          .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
    );
  }

  Widget _botaoCarregando(FlutterFlowTheme theme) => Container(
        width: 230.0,
        height: 52.0,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: theme.alternate, width: 1),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: theme.secondary, strokeWidth: 2.5),
          ),
        ),
      );

  Widget _botaoEntrar(FlutterFlowTheme theme) => InkWell(
        onTap: _fazerLogin,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 230.0,
          height: 52.0,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 3))
            ],
            border: Border.all(color: Colors.transparent, width: 1),
          ),
          child: Center(
            child: Text('Entrar',
                style: theme.titleSmall.override(
                  font: GoogleFonts.interTight(
                      fontWeight: theme.titleSmall.fontWeight),
                  color: theme.secondary,
                  letterSpacing: 0.0,
                )),
          ),
        ),
      );

  Widget _bannerErroWidget(String msg, FlutterFlowTheme theme) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.error.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: theme.error.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(Icons.error_outline_rounded, color: theme.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(msg,
                    style: TextStyle(
                        color: theme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500))),
          ]),
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // TELA CADASTRO (simplificada — nome, cargo, senha → login automático)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCadastro() {
    final theme = FlutterFlowTheme.of(context);
    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              boxShadow: const [
                BoxShadow(
                    blurRadius: 8.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, 2.0))
              ],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF39D2C0).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF39D2C0).withOpacity(0.4),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded,
                            color: Color(0xFF39D2C0), size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text('Primeiro Acesso',
                          textAlign: TextAlign.center,
                          style: theme.headlineSmall.override(
                            font: GoogleFonts.interTight(
                                fontWeight: theme.headlineSmall.fontWeight),
                            color: const Color(0xFF39D2C0),
                            letterSpacing: 0.0,
                          )),
                      const SizedBox(height: 6),
                      Text('Complete seu cadastro para acessar o sistema.',
                          textAlign: TextAlign.center,
                          style: theme.bodySmall.override(
                            font: GoogleFonts.inter(
                                fontWeight: theme.bodySmall.fontWeight),
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          )),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Badge de email identificado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39D2C0).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF39D2C0).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.verified_user_outlined,
                          color: Color(0xFF39D2C0), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_cadEmail,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.primaryText,
                                  fontWeight: FontWeight.w500))),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // Campos
                  _campoCadastro(
                    label: 'Nome Completo',
                    hint: 'Digite seu nome completo',
                    controller: _cadNomeCtrl,
                    icon: Icons.badge_outlined,
                    theme: theme,
                    formatters: [
                      _UpperCaseFormatter(),
                      _NoLeadingSpaceFormatter()
                    ],
                  ),
                  const SizedBox(height: 14),
                  _campoCadastro(
                    label: 'Cargo / Função',
                    hint: 'Ex: GERENTE ADMINISTRATIVO',
                    controller: _cadCargoCtrl,
                    icon: Icons.work_outline_rounded,
                    theme: theme,
                    formatters: [
                      _UpperCaseFormatter(),
                      _NoLeadingSpaceFormatter()
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Senha mascarada vinda do login (sem campo editável)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39D2C0).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF39D2C0).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: Color(0xFF39D2C0), size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                        _cadSenha.isEmpty
                            ? 'Senha não informada — volte ao login'
                            : '${'•' * _cadSenha.length}  (${_cadSenha.length} caracteres)',
                        style: TextStyle(
                            fontSize: 13,
                            color: theme.secondaryText,
                            letterSpacing: 1.0),
                      )),
                    ]),
                  ),
                  if (_cadErro.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: theme.error.withOpacity(0.35)),
                      ),
                      child: Row(children: [
                        Icon(Icons.error_outline_rounded,
                            color: theme.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_cadErro,
                                style: TextStyle(
                                    color: theme.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Botões
                  _cadCarregando
                      ? Container(
                          width: double.infinity,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF39D2C0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _cadastrar,
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: double.infinity,
                            height: 48.0,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF39D2C0),
                                Color(0xFF00897B)
                              ]),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF39D2C0)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: Center(
                              child: Text('Entrar no Sistema',
                                  style: theme.titleSmall.override(
                                    font: GoogleFonts.interTight(
                                        fontWeight:
                                            theme.titleSmall.fontWeight),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  )),
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _irPara('login'),
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: double.infinity,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: theme.alternate, width: 1.0),
                      ),
                      child: Center(
                        child: Text('Voltar ao Login',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.inter(
                                  fontWeight: theme.bodyMedium.fontWeight),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            )),
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

  Widget _campoCadastro({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required FlutterFlowTheme theme,
    List<TextInputFormatter> formatters = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          inputFormatters: formatters,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.bodySmall
                .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
            prefixIcon: Icon(icon,
                color: const Color(0xFF39D2C0).withOpacity(0.6), size: 18),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.alternate, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFF39D2C0), width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.error, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.error, width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: theme.primaryBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: theme.bodyMedium
              .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
        ),
      ],
    );
  }

  Widget _campoCadastroSenha(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Senha',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _cadSenhaCtrl,
          obscureText: !_cadShowSenha,
          inputFormatters: [_NoLeadingSpaceFormatter()],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
            hintStyle: theme.bodySmall
                .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
            prefixIcon: Icon(Icons.lock_outline_rounded,
                color: const Color(0xFF39D2C0).withOpacity(0.6), size: 18),
            suffixIcon: InkWell(
              onTap: () => setState(() => _cadShowSenha = !_cadShowSenha),
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _cadShowSenha
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.secondaryText.withOpacity(0.5),
                size: 18,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.alternate, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFF39D2C0), width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.error, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.error, width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: theme.primaryBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: theme.bodyMedium
              .override(font: GoogleFonts.inter(), letterSpacing: 0.0),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TELA SENHA (mantida idêntica ao original)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSenha() {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primary = Color(0xFF39D2C0);
    const Color dark = Color(0xFF00897B);
    const Color red = Color(0xFFEF5350);
    const Color orange = Color(0xFFFF8F00);
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    if (_senhaAlterada) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width ?? double.infinity,
            color: theme.primaryBackground,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: primary.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          color: primary, size: 40),
                    ),
                    const SizedBox(height: 22),
                    Text('Senha Alterada!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryText)),
                    const SizedBox(height: 10),
                    Text('Sua senha foi atualizada com sucesso.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.secondaryText,
                            height: 1.6)),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        setState(() => _senhaAlterada = false);
                        _irPara('login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [primary, primary.withOpacity(0.75)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Fechar',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
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

    if (_resetEnviado) {
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width ?? double.infinity,
            color: theme.primaryBackground,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: orange.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: orange, size: 40),
                    ),
                    const SizedBox(height: 22),
                    Text('Solicitação Enviada!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryText)),
                    const SizedBox(height: 10),
                    Text(
                        'A equipe HPS recebeu sua solicitação\ne entrará em contato em breve.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.secondaryText,
                            height: 1.6)),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        setState(() => _resetEnviado = false);
                        _irPara('login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [orange, orange.withOpacity(0.75)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Fechar',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
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

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width ?? double.infinity,
          color: theme.primaryBackground,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 12, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [primary, dark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_person_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gerenciar Senha',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 2),
                        Text(userEmail,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.white.withOpacity(0.8), size: 20),
                    onPressed: () => _irPara('login'),
                  ),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _secaoTitulo(
                          'ALTERAR SENHA', Icons.lock_reset_rounded, primary),
                      const SizedBox(height: 16),
                      _labelSenha('Senha Atual', theme),
                      const SizedBox(height: 6),
                      _campoSenhaForm(
                        ctrl: _senhaAtualCtrl,
                        hint: 'Digite sua senha atual',
                        obscure: !_showAtual,
                        theme: theme,
                        isDark: isDark,
                        toggle: () => setState(() => _showAtual = !_showAtual),
                      ),
                      if (_dicaMascarada.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 2),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _mostrandoDica = !_mostrandoDica),
                            child: Row(children: [
                              Icon(
                                _mostrandoDica
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 12,
                                color: theme.secondaryText.withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _mostrandoDica
                                    ? 'Ocultar dica'
                                    : 'Ver dica da senha',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        theme.secondaryText.withOpacity(0.4)),
                              ),
                            ]),
                          ),
                        ),
                      if (_mostrandoDica && _dicaMascarada.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: theme.alternate.withOpacity(0.5)),
                          ),
                          child: Row(children: [
                            Icon(Icons.vpn_key_outlined,
                                size: 13,
                                color: theme.secondaryText.withOpacity(0.4)),
                            const SizedBox(width: 8),
                            Text('Formato: ',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        theme.secondaryText.withOpacity(0.45))),
                            Text(_dicaMascarada,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryText.withOpacity(0.7),
                                    letterSpacing: 2.5)),
                            const SizedBox(width: 6),
                            Text('• $_tamanhoSenha caracteres',
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        theme.secondaryText.withOpacity(0.35))),
                          ]),
                        ),
                      const SizedBox(height: 14),
                      _labelSenha('Nova Senha', theme),
                      const SizedBox(height: 6),
                      _campoSenhaForm(
                        ctrl: _novaSenhaCtrl,
                        hint: 'Mínimo 6 caracteres',
                        obscure: !_showNova,
                        theme: theme,
                        isDark: isDark,
                        toggle: () => setState(() => _showNova = !_showNova),
                      ),
                      const SizedBox(height: 12),
                      _labelSenha('Confirmar Nova Senha', theme),
                      const SizedBox(height: 6),
                      _campoSenhaForm(
                        ctrl: _confirmarCtrl,
                        hint: 'Repita a nova senha',
                        obscure: !_showConfirmar,
                        theme: theme,
                        isDark: isDark,
                        toggle: () =>
                            setState(() => _showConfirmar = !_showConfirmar),
                      ),
                      if (_senhaErro.isNotEmpty && !_mostrarReset) ...[
                        const SizedBox(height: 12),
                        _bannerErroSenha(_senhaErro, theme),
                      ],
                      const SizedBox(height: 20),
                      _btnPrimario(
                        label: 'Salvar Nova Senha',
                        icon: Icons.save_rounded,
                        carregando: _senhaCarregando && !_mostrarReset,
                        gradient: const [primary, dark],
                        onTap: _alterarSenha,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Row(children: [
                          Expanded(
                              child:
                                  Divider(color: theme.alternate, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('ou',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: theme.secondaryText.withOpacity(0.5),
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                              child:
                                  Divider(color: theme.alternate, height: 1)),
                        ]),
                      ),
                      _secaoTitulo('NÃO LEMBRO A SENHA',
                          Icons.support_agent_rounded, primary),
                      const SizedBox(height: 6),
                      Text(
                        'Solicite a redefinição pela equipe HPS.',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.secondaryText.withOpacity(0.7),
                            height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => setState(() {
                          _mostrarReset = !_mostrarReset;
                          _senhaErro = '';
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: _mostrarReset
                                ? orange.withOpacity(isDark ? 0.15 : 0.08)
                                : theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _mostrarReset
                                  ? orange.withOpacity(0.5)
                                  : theme.alternate,
                              width: _mostrarReset ? 1.5 : 1,
                            ),
                          ),
                          child: Row(children: [
                            Icon(Icons.lock_open_rounded,
                                color: _mostrarReset
                                    ? orange
                                    : theme.secondaryText.withOpacity(0.6),
                                size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Solicitar redefinição de senha',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _mostrarReset
                                        ? orange
                                        : theme.primaryText),
                              ),
                            ),
                            Icon(
                              _mostrarReset
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: _mostrarReset
                                  ? orange
                                  : theme.secondaryText.withOpacity(0.5),
                              size: 20,
                            ),
                          ]),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        child: _mostrarReset
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 16),
                                  _labelSenha('Seu Nome', theme),
                                  const SizedBox(height: 6),
                                  _campoTextoSenha(
                                    ctrl: _nomeResetCtrl,
                                    hint: 'Como você se chama',
                                    icon: Icons.person_outline_rounded,
                                    theme: theme,
                                    isDark: isDark,
                                    formatters: [
                                      _UpperCaseFormatter(),
                                      _NoLeadingSpaceFormatter(),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _labelSenha('Motivo', theme),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: theme.alternate),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _motivoSelecionado,
                                        isExpanded: true,
                                        dropdownColor:
                                            theme.secondaryBackground,
                                        hint: Text('Selecione o motivo',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: theme.secondaryText)),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: theme.primaryText,
                                            fontWeight: FontWeight.w500),
                                        items: _motivos
                                            .map((m) => DropdownMenuItem(
                                                value: m, child: Text(m)))
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => _motivoSelecionado = v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _labelSenha('Detalhes (opcional)', theme),
                                  const SizedBox(height: 6),
                                  _campoTextoSenha(
                                    ctrl: _detalheCtrl,
                                    hint: 'Descreva com mais detalhes',
                                    icon: Icons.notes_rounded,
                                    theme: theme,
                                    isDark: isDark,
                                    maxLines: 3,
                                    formatters: [_NoLeadingSpaceFormatter()],
                                  ),
                                  if (_senhaErro.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _bannerErroSenha(_senhaErro, theme),
                                  ],
                                  const SizedBox(height: 20),
                                  _btnPrimario(
                                    label: 'Enviar Solicitação',
                                    icon: Icons.send_rounded,
                                    carregando:
                                        _senhaCarregando && _mostrarReset,
                                    gradient: [orange, const Color(0xFFE65100)],
                                    onTap: _enviarSolicitacao,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers tela senha ──────────────────────────────────────────────────────
  Widget _secaoTitulo(String texto, IconData icon, Color cor) {
    return Row(children: [
      Icon(icon, size: 14, color: cor),
      const SizedBox(width: 8),
      Text(texto,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: cor,
              letterSpacing: 0.6)),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: cor.withOpacity(0.25), height: 1)),
    ]);
  }

  Widget _labelSenha(String text, FlutterFlowTheme theme) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.primaryText.withOpacity(0.75)));
  }

  Widget _campoSenhaForm({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required FlutterFlowTheme theme,
    required bool isDark,
    required VoidCallback toggle,
  }) {
    const Color primary = Color(0xFF39D2C0);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        inputFormatters: [_NoLeadingSpaceFormatter()],
        style: TextStyle(
            fontSize: 14,
            color: theme.primaryText,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: theme.secondaryText.withOpacity(0.5)),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: primary.withOpacity(0.5), size: 18),
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

  Widget _campoTextoSenha({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required FlutterFlowTheme theme,
    required bool isDark,
    int maxLines = 1,
    List<TextInputFormatter> formatters = const [],
  }) {
    const Color primary = Color(0xFF39D2C0);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        inputFormatters: formatters,
        style: TextStyle(
            fontSize: 14,
            color: theme.primaryText,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: theme.secondaryText.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: primary.withOpacity(0.5), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _bannerErroSenha(String msg, FlutterFlowTheme theme) {
    const Color red = Color(0xFFEF5350);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: red.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline_rounded,
            color: red.withOpacity(0.8), size: 15),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: TextStyle(color: red.withOpacity(0.9), fontSize: 12))),
      ]),
    );
  }

  Widget _btnPrimario({
    required String label,
    required IconData icon,
    required bool carregando,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: carregando ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: carregando ? null : LinearGradient(colors: gradient),
          color: carregando ? gradient[0].withOpacity(0.35) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: carregando
              ? []
              : [
                  BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
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
                  Icon(icon, color: Colors.white, size: 17),
                  const SizedBox(width: 9),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3)),
                ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// POPUP NOVA SENHA (mantido idêntico ao original)
// ═══════════════════════════════════════════════════════════════════════════════
class _PopupNovaSenha extends StatefulWidget {
  const _PopupNovaSenha({required this.email});
  final String email;

  @override
  State<_PopupNovaSenha> createState() => _PopupNovaSenhaState();
}

class _PopupNovaSenhaState extends State<_PopupNovaSenha> {
  static const Color _primary = Color(0xFF39D2C0);
  static const Color _dark = Color(0xFF00897B);
  static const Color _red = Color(0xFFEF5350);

  final _novaSenhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _showNova = false;
  bool _showConfirmar = false;
  bool _carregando = false;
  bool _concluido = false;
  String _erro = '';

  @override
  void dispose() {
    _novaSenhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nova = _novaSenhaCtrl.text.trim();
    final conf = _confirmarCtrl.text.trim();
    if (nova.isEmpty || conf.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    if (nova.length < 6) {
      setState(() => _erro = 'Mínimo 6 caracteres.');
      return;
    }
    if (nova != conf) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = '';
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('USUARIOS')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({'senha': nova});
      }
      try {
        await FirebaseAuth.instance.currentUser?.updatePassword(nova);
      } catch (_) {}
      try {
        await http.post(
          Uri.parse(
              'https://us-central1-h-p-s-modificado-emdcp0.cloudfunctions.net/resetarSenhaAdmin'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': {'novaSenha': nova, 'emailAlvo': widget.email}
          }),
        );
      } catch (_) {}
      setState(() {
        _carregando = false;
        _concluido = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _erro = 'Erro: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2530) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: _concluido
              ? _sucesso(textColor, subColor)
              : _form(isDark, textColor, subColor),
        ),
      ),
    );
  }

  Widget _sucesso(Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _primary.withOpacity(0.4), width: 2),
          ),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: _primary, size: 38),
        ),
        const SizedBox(height: 20),
        Text('Senha Definida!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
        const SizedBox(height: 10),
        Text('Sua nova senha foi salva com sucesso.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: subColor, height: 1.5)),
      ]),
    );
  }

  Widget _form(bool isDark, Color textColor, Color subColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_primary, _dark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Defina sua Nova Senha',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor)),
                    const SizedBox(height: 2),
                    Text('Sua senha foi redefinida pelo administrador',
                        style: TextStyle(fontSize: 12, color: subColor)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(isDark ? 0.1 : 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: _primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Por segurança, defina uma nova senha antes de continuar.',
                      style:
                          TextStyle(fontSize: 12, color: subColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_erro.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _red.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      color: _red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_erro,
                          style: const TextStyle(color: _red, fontSize: 12))),
                ]),
              ),
            Text('Nova Senha',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subColor)),
            const SizedBox(height: 6),
            _campo(_novaSenhaCtrl, 'Mínimo 6 caracteres', !_showNova, isDark,
                () => setState(() => _showNova = !_showNova)),
            const SizedBox(height: 14),
            Text('Confirmar Nova Senha',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subColor)),
            const SizedBox(height: 6),
            _campo(_confirmarCtrl, 'Repita a nova senha', !_showConfirmar,
                isDark, () => setState(() => _showConfirmar = !_showConfirmar)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _carregando ? null : _salvar,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: _carregando
                      ? null
                      : const LinearGradient(colors: [_primary, _dark]),
                  color: _carregando ? _primary.withOpacity(0.4) : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _carregando
                      ? []
                      : [
                          BoxShadow(
                              color: _primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                ),
                child: Center(
                  child: _carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.save_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('SALVAR NOVA SENHA',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3)),
                            ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String hint, bool obscure,
      bool isDark, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        inputFormatters: [_NoLeadingSpaceFormatter()],
        style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: _primary.withOpacity(0.6), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDark ? Colors.white38 : Colors.black38,
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
}
