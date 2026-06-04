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
import 'dart:async';

class DashboardCardsWidget extends StatefulWidget {
  const DashboardCardsWidget({
    Key? key,
    this.width,
    this.height,
    required this.emailParam,
    required this.senhaAppState,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String emailParam;
  final String senhaAppState;

  @override
  _DashboardCardsWidgetState createState() => _DashboardCardsWidgetState();
}

class _DashboardCardsWidgetState extends State<DashboardCardsWidget> {
  int _totalEquipamentos = 0;
  int _osPendentes = 0;
  int _emManutencao = 0;
  int _aguardandoPeca = 0;
  int _concluidasMesAtual = 0;
  int _aguardandoAprovacao = 0;
  bool _loading = true;

  List<Map<String, dynamic>> _corretivas = [];

  StreamSubscription? _equipSub;
  StreamSubscription? _manutSub;
  StreamSubscription? _corretSub;

  final List<String> _mesesOrdem = [
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
    'DEZEMBRO'
  ];

  String get _mesAtual => _mesesOrdem[DateTime.now().month - 1];
  String get _anoAtual => DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    _iniciarListeners();
  }

  @override
  void dispose() {
    _equipSub?.cancel();
    _manutSub?.cancel();
    _corretSub?.cancel();
    super.dispose();
  }

  void _iniciarListeners() {
    _equipSub = FirebaseFirestore.instance
        .collection('EQUIPAMENTOS_EMPRESA')
        .where('EMAIL', isEqualTo: widget.emailParam)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _totalEquipamentos = snap.docs.length;
        _loading = false;
      });
    });

    _manutSub = FirebaseFirestore.instance
        .collection('MANUTENCAO')
        .where('EMAIL', isEqualTo: widget.emailParam)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      int pendentes = 0, emManut = 0, aguPeca = 0, aguAprov = 0;
      for (var doc in snap.docs) {
        final s = (doc.data()['STATUS'] ?? '').toString().trim().toUpperCase();
        if (s == 'AGUARDANDO AVALIAÇÃO')
          pendentes++;
        else if (s == 'INICIOU O SERVIÇO')
          emManut++;
        else if (s == 'AGUARDANDO PEÇA')
          aguPeca++;
        else if (s == 'AGUARDANDO APROVAÇÃO') aguAprov++;
      }
      setState(() {
        _osPendentes = pendentes;
        _emManutencao = emManut;
        _aguardandoPeca = aguPeca;
        _aguardandoAprovacao = aguAprov;
        _loading = false;
      });
    });

    _corretSub = FirebaseFirestore.instance
        .collection('CORRETIVAS')
        .where('EMAIL', isEqualTo: widget.emailParam)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final List<Map<String, dynamic>> corretivasMesAtual = [];
      for (var doc in snap.docs) {
        final data = doc.data();
        final mes = (data['MES'] ?? '').toString().trim().toUpperCase();
        final ano = (data['ANO'] ?? '').toString().trim();
        if (mes == _mesAtual && ano == _anoAtual) {
          corretivasMesAtual.add(data);
        }
      }
      setState(() {
        _concluidasMesAtual = corretivasMesAtual.length;
        _corretivas = corretivasMesAtual;
        _loading = false;
      });
    });
  }

  void _abrirPopupEquipamentos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: PopupDemonstrativo(emailParam: widget.emailParam),
        ),
      ),
    );
  }

  void _abrirManutencao(String statusFiltro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => SafeArea(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: ManutencaoGridWidget(
              statusFiltro: statusFiltro,
              senhaAppState: widget.senhaAppState,
              emailFiltro: widget.emailParam,
            ),
          ),
        ),
      ),
    );
  }

  void _abrirCorretivas() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color verde = Color(0xFF43A047);
    const Color verdeLight = Color(0xFF81C784);

    final sorted = List<Map<String, dynamic>>.from(_corretivas)
      ..sort((a, b) {
        final anoA = int.tryParse((a['ANO'] ?? '').toString()) ?? 0;
        final anoB = int.tryParse((b['ANO'] ?? '').toString()) ?? 0;
        if (anoA != anoB) return anoB.compareTo(anoA);
        final mA = _mesesOrdem
            .indexOf((a['MES'] ?? '').toString().trim().toUpperCase());
        final mB = _mesesOrdem
            .indexOf((b['MES'] ?? '').toString().trim().toUpperCase());
        return mB.compareTo(mA);
      });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.4,
        maxChildSize: 0.96,
        expand: false,
        builder: (__, scrollCtrl) => SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1B2E1C), const Color(0xFF0F1117)]
                          : [const Color(0xFFE8F5E9), const Color(0xFFF5F7FA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: verde.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: verde.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.task_alt_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ordens Concluídas',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A2E1B),
                                    )),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color:
                                        verde.withOpacity(isDark ? 0.2 : 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${sorted.length} registro${sorted.length != 1 ? 's' : ''}  ·  ${_capitalize(_mesAtual)} $_anoAtual',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: verde,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.4),
                                  size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: sorted.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 52, color: verde.withOpacity(0.25)),
                              const SizedBox(height: 12),
                              Text('Nenhum registro encontrado',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.35)
                                        : Colors.black.withOpacity(0.3),
                                  )),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: sorted.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final item = sorted[i];
                            final mes = (item['MES'] ?? '').toString().trim();
                            final ano = (item['ANO'] ?? '').toString().trim();
                            final equip =
                                (item['EQUIPAMENTO'] ?? '').toString().trim();
                            final sala = (item['SALA'] ?? '').toString().trim();
                            final os =
                                (item['NUMERO_OS'] ?? '').toString().trim();
                            final defeito =
                                (item['DEFEITO'] ?? '').toString().trim();
                            final setor =
                                (item['SETOR'] ?? '').toString().trim();
                            final marca =
                                (item['MARCA'] ?? '').toString().trim();
                            final modelo =
                                (item['MODELO'] ?? '').toString().trim();
                            final tipo = (item['TIPO'] ?? '').toString().trim();
                            final btus = (item['BTUS'] ?? '').toString().trim();
                            final fluido =
                                (item['FLUIDO'] ?? '').toString().trim();
                            final tecnico = (item['TECNICORESPONSAVEL'] ?? '')
                                .toString()
                                .trim();
                            final servico = (item['SERVICOREALIZADO'] ?? '')
                                .toString()
                                .trim();
                            final patrimonio =
                                (item['PATRIMONIO'] ?? '').toString().trim();
                            final dataTermino =
                                (item['DATA_TERMINO'] ?? '').toString().trim();
                            final isAtual = mes.toUpperCase() == _mesAtual &&
                                ano == _anoAtual;

                            Widget chip(IconData icon, String text,
                                {Color? color}) {
                              if (text.isEmpty) return const SizedBox.shrink();
                              final c = color ??
                                  (isDark
                                      ? Colors.white.withOpacity(0.55)
                                      : Colors.black.withOpacity(0.45));
                              final bg = color != null
                                  ? color.withOpacity(0.1)
                                  : (isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.05));
                              return Container(
                                margin:
                                    const EdgeInsets.only(right: 6, bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color != null
                                        ? color.withOpacity(0.25)
                                        : (isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.07)),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(icon, size: 10, color: c),
                                      const SizedBox(width: 4),
                                      Text(text,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: c,
                                          )),
                                    ]),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A1F2E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isAtual
                                      ? verde.withOpacity(0.35)
                                      : (isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.black.withOpacity(0.06)),
                                  width: isAtual ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 12, 14, 10),
                                    decoration: BoxDecoration(
                                      color: verde
                                          .withOpacity(isDark ? 0.1 : 0.06),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    child: Row(
                                      children: [
                                        if (os.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2E7D32),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text('OS #$os',
                                                style: const TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                )),
                                          ),
                                        const SizedBox(width: 8),
                                        if (isAtual)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  verdeLight.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: verdeLight
                                                      .withOpacity(0.4)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFF66BB6A),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('mês atual',
                                                    style: TextStyle(
                                                      fontFamily: 'Outfit',
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF388E3C),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.06)
                                                : Colors.black
                                                    .withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${_capitalize(mes)} · $ano',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                      .withOpacity(0.5)
                                                  : Colors.black
                                                      .withOpacity(0.4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 10, 14, 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (equip.isNotEmpty) ...[
                                          Text(equip,
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1A1A2E),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 10),
                                        ],
                                        Wrap(children: [
                                          chip(Icons.location_on_rounded, sala),
                                          chip(Icons.business_rounded, setor),
                                          chip(Icons.qr_code_rounded,
                                              patrimonio),
                                          chip(Icons.person_rounded, tecnico,
                                              color: const Color(0xFF1976D2)),
                                        ]),
                                        if (servico.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1976D2)
                                                  .withOpacity(
                                                      isDark ? 0.1 : 0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color(0xFF1976D2)
                                                      .withOpacity(0.15)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                    Icons.build_circle_outlined,
                                                    size: 13,
                                                    color: Color(0xFF1976D2)),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(servico,
                                                      style: const TextStyle(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF1976D2),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (defeito.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE53935)
                                                  .withOpacity(
                                                      isDark ? 0.1 : 0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color(0xFFE53935)
                                                      .withOpacity(0.15)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .report_problem_outlined,
                                                    size: 13,
                                                    color: Color(0xFFE53935)),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(defeito,
                                                      style: const TextStyle(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFFE53935),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if ([marca, modelo, tipo, btus, fluido]
                                            .any((s) => s.isNotEmpty)) ...[
                                          const SizedBox(height: 8),
                                          Wrap(children: [
                                            chip(
                                                Icons
                                                    .branding_watermark_outlined,
                                                marca),
                                            chip(Icons.category_outlined,
                                                modelo),
                                            chip(Icons.tune_outlined, tipo),
                                            chip(Icons.thermostat_outlined,
                                                btus),
                                            chip(Icons.water_drop_outlined,
                                                fluido),
                                          ]),
                                        ],
                                        if (dataTermino.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          chip(Icons.event_available_outlined,
                                              'Término: $dataTermino',
                                              color: verde),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  // ─── Altura por breakpoint (igual ao TelaPrincipalWidget) ───────────────────
  // mobile  <600px  → 72px
  // tablet  600-991 → 88px
  // desktop ≥992px  → 100px
  double _cardHeightForWidth(double sw) {
    if (sw < 600) return 72.0;
    if (sw < 992) return 88.0;
    return 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const int n = 6;

    final List<_CardData> cards = [
      _CardData(
        label: 'Equip.',
        count: _totalEquipamentos,
        icon: Icons.precision_manufacturing_rounded,
        iconColor: const Color(0xFF5C6BC0),
        onTap: _abrirPopupEquipamentos,
      ),
      _CardData(
        label: 'Pendentes',
        count: _osPendentes,
        icon: Icons.assignment_late_rounded,
        iconColor: const Color(0xFFFF8F00),
        onTap: () => _abrirManutencao('AGUARDANDO AVALIAÇÃO'),
      ),
      _CardData(
        label: 'Manutenção',
        count: _emManutencao,
        icon: Icons.build_rounded,
        iconColor: const Color(0xFFE53935),
        onTap: () => _abrirManutencao('INICIOU O SERVIÇO'),
      ),
      _CardData(
        label: 'Ag. peça',
        count: _aguardandoPeca,
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFFFFB300),
        onTap: () => _abrirManutencao('AGUARDANDO PEÇA'),
      ),
      _CardData(
        label: 'Aprovação',
        count: _aguardandoAprovacao,
        icon: Icons.attach_money_rounded,
        iconColor: const Color(0xFF00ACC1),
        onTap: () => _abrirManutencao('AGUARDANDO APROVAÇÃO'),
      ),
      _CardData(
        label: 'Concluídas',
        count: _concluidasMesAtual,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF43A047),
        onTap: _abrirCorretivas,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double sw = MediaQuery.of(context).size.width;

        // availW: usa constraints reais; fallback para sw se não disponível
        final double availW =
            constraints.maxWidth > 0 ? constraints.maxWidth : sw;

        // gap entre cards: maior em desktop, menor em mobile
        final double gap = sw >= 992
            ? 10.0
            : sw >= 600
                ? 8.0
                : 5.0;

        final double cardW = (availW - gap * (n - 1)) / n;

        // Altura vinda do pai (já calculada por breakpoint) ou fallback local
        final double cardH = (widget.height != null && widget.height! > 0)
            ? widget.height!
            : _cardHeightForWidth(sw);

        if (_loading) {
          return SizedBox(
            width: availW,
            height: cardH,
            child: Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    color: const Color(0xFF68DDC5), strokeWidth: 2),
              ),
            ),
          );
        }

        return SizedBox(
          width: availW,
          height: cardH,
          child: Row(
            children: List.generate(
              n,
              (i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DashCard(
                    data: cards[i],
                    width: cardW,
                    height: cardH,
                    isDark: isDark,
                  ),
                  if (i < n - 1) SizedBox(width: gap),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardData {
  final String label;
  final String? sublabel;
  final int count;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  _CardData({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
    this.sublabel,
    this.onTap,
  });
}

class _DashCard extends StatelessWidget {
  final _CardData data;
  final double width;
  final double height;
  final bool isDark;

  const _DashCard({
    required this.data,
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Tamanhos proporcionais ao card, com clamps por breakpoint
    final double sw = MediaQuery.of(context).size.width;
    final bool isMobile = sw < 600;
    final bool isTablet = sw >= 600 && sw < 992;

    // Ícone: menor em mobile para sobrar espaço para texto
    final double iconBox = isMobile
        ? (width * 0.34).clamp(18.0, 28.0)
        : isTablet
            ? (width * 0.36).clamp(22.0, 34.0)
            : (width * 0.38).clamp(26.0, 40.0);

    final double iconSize = (iconBox * 0.55).clamp(10.0, 22.0);

    // Número: fonte maior em desktop
    final double numSize = isMobile
        ? (width * 0.20).clamp(11.0, 16.0)
        : isTablet
            ? (width * 0.21).clamp(13.0, 18.0)
            : (width * 0.22).clamp(14.0, 22.0);

    // Label: fonte menor em mobile
    final double labelSize = isMobile
        ? (width * 0.11).clamp(6.5, 9.0)
        : isTablet
            ? (width * 0.115).clamp(7.0, 10.0)
            : (width * 0.12).clamp(7.5, 11.0);

    // Espaçamento interno vertical proporcional à altura do card
    final double gapTop = height * 0.04;
    final double gapMid = height * 0.03;

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: data.onTap != null
                ? data.iconColor.withOpacity(0.2)
                : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05)),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: data.iconColor.withOpacity(0.13),
                borderRadius: BorderRadius.circular(iconBox * 0.28),
              ),
              child: Icon(data.icon, color: data.iconColor, size: iconSize),
            ),
            SizedBox(height: gapTop),
            Text(
              '${data.count}',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: numSize,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                height: 1,
              ),
            ),
            SizedBox(height: gapMid),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                data.label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: labelSize,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.36),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
