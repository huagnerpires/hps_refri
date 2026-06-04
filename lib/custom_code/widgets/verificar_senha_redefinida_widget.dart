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

/// Widget invisivel — coloque na HOME com width:1 height:1 Ele verifica
/// automaticamente no initState e abre o popup se necessario
class VerificarSenhaRedefinidaWidget extends StatefulWidget {
  const VerificarSenhaRedefinidaWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<VerificarSenhaRedefinidaWidget> createState() =>
      _VerificarSenhaRedefinidaWidgetState();
}

class _VerificarSenhaRedefinidaWidgetState
    extends State<VerificarSenhaRedefinidaWidget> {
  bool _executado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_executado) {
        _executado = true;
        _verificar();
      }
    });
  }

  Future<void> _verificar() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (userEmail.isEmpty) return;

      final snap = await FirebaseFirestore.instance
          .collection('NOTIFICACAO')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snap.docs.isEmpty) return;

      final notifsSenha = snap.docs.where((doc) {
        final d = doc.data();
        final tipo = (d['tipo'] as String? ?? '').toLowerCase().trim();
        final visto = (d['visto'] as bool? ?? false);
        final titulo = (d['titulo'] as String? ?? '').toLowerCase();
        return tipo == 'sistema' &&
            !visto &&
            (titulo.contains('senha redefinida') ||
                titulo.contains('senha foi redefinida'));
      }).toList();

      if (notifsSenha.isEmpty) return;
      if (!mounted) return;

      // Apaga antes de abrir — evita loop
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in notifsSenha) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PopupNovaSenha(email: userEmail),
      );
    } catch (e) {
      debugPrint('Erro verificarSenhaRedefinida: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

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
      setState(() => _erro = 'Minimo 6 caracteres.');
      return;
    }
    if (nova != conf) {
      setState(() => _erro = 'As senhas nao coincidem.');
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
                    ])),
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
                        'Por seguranca, defina uma nova senha antes de continuar.',
                        style: TextStyle(
                            fontSize: 12, color: subColor, height: 1.5),
                      )),
                    ]),
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
              _campo(_novaSenhaCtrl, 'Minimo 6 caracteres', !_showNova, isDark,
                  () => setState(() => _showNova = !_showNova)),
              const SizedBox(height: 14),
              Text('Confirmar Nova Senha',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subColor)),
              const SizedBox(height: 6),
              _campo(
                  _confirmarCtrl,
                  'Repita a nova senha',
                  !_showConfirmar,
                  isDark,
                  () => setState(() => _showConfirmar = !_showConfirmar)),
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
            ]),
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
