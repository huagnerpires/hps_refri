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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget de sino de notificações com badge em tempo real.
///
/// Parâmetros no FlutterFlow: width  – largura do botão (padrão 44) height –
/// altura do botão (padrão 44)
///
/// Ao ser tocado, abre a tela de notificações via showModalBottomSheet (ou
/// substitua pela navegação da sua escolha).
class NotificacaoBellWidget extends StatefulWidget {
  const NotificacaoBellWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NotificacaoBellWidget> createState() => _NotificacaoBellWidgetState();
}

class _NotificacaoBellWidgetState extends State<NotificacaoBellWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  String get _userEmail => FirebaseAuth.instance.currentUser?.email ?? '';

  /// Stream que conta apenas notificações NÃO lidas do usuário atual.
  Stream<int> get _unreadStream => FirebaseFirestore.instance
      .collection('NOTIFICACAO')
      .where('email', isEqualTo: _userEmail)
      .where('visto', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.length);

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _abrirNotificacoes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          // ── Substitua pelo seu widget de notificações ──────────────────
          // child: NotificacaoWidget1(),
          child: NotificacaoWidget1(),
          // ──────────────────────────────────────────────────────────────
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.width ?? widget.height ?? 44.0;

    return StreamBuilder<int>(
      stream: _unreadStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        // Dispara animação de shake quando chegam novas notificações
        if (count > 0 && !_shakeCtrl.isAnimating) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _shakeCtrl.forward(from: 0);
          });
        }

        return GestureDetector(
          onTap: _abrirNotificacoes,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // ── Botão principal ──────────────────────────────────────
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      color: Color(0xFF39D2C0),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4039D2C0),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      count > 0
                          ? Icons.notifications_rounded
                          : Icons.notifications_outlined,
                      size: size * 0.48,
                      color: Colors.white,
                    ),
                  ),
                ),

                // ── Badge com contagem ───────────────────────────────────
                if (count > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _Badge(count: count),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Badge animado
// ---------------------------------------------------------------------------
class _Badge extends StatefulWidget {
  const _Badge({required this.count});
  final int count;

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_Badge old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.count > 99 ? '99+' : '${widget.count}';
    final wide = widget.count > 9;

    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 18,
        constraints: BoxConstraints(minWidth: wide ? 26 : 18),
        padding: EdgeInsets.symmetric(horizontal: wide ? 5 : 0),
        decoration: BoxDecoration(
          color: const Color(0xFFC62828),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
