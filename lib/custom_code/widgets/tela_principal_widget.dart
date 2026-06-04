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

import 'index.dart'; // Imports other custom widgets

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/componentes/dark/dark_widget.dart';
import '/components/contato_widget.dart';
import '/components/iniciar_conversa_widget.dart';
import '/components/lista_de_equipamentos_widget.dart';
import '/components/midiasocial_widget.dart';
import '/components/politica_widget.dart';
import '/components/politiccas_widget.dart';
import '/components/slaaaaa_copy2_widget.dart';
import '/components/ver_manutencao_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/walkthroughs/home.dart';
import 'dart:async';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'
    show TutorialCoachMark;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TelaPrincipalWidget extends StatefulWidget {
  const TelaPrincipalWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;
  static String routeName = 'TELA_PRINCIPAL';
  static String routePath = '/tela_principal';
  @override
  State<TelaPrincipalWidget> createState() => _TelaPrincipalWidgetState();
}

class _TelaPrincipalWidgetState extends State<TelaPrincipalWidget>
    with TickerProviderStateMixin {
  int? _quantidadeNotificacao = 0;
  int _mensagensNaoLidas = 0;
  TutorialCoachMark? _homeController;
  InstantTimer? _instantTimer;
  List<NotificacaoRow>? _quantidadeDeNotificacao;
  DarkModel? _darkModel1;
  int? _conversa;
  TabController? _tabBarController1;
  TabController? _tabBarController2;
  String _qrcode = '';
  FocusNode? _textFieldFocusNode1;
  FocusNode? _textFieldFocusNode2;
  TextEditingController? _textController1;
  TextEditingController? _textController2;
  String? Function(BuildContext, String?)? textController1Validator;
  String? Function(BuildContext, String?)? textController2Validator;
  ApiCallResponse? _apiResultjgi875;

  // ─── Cache de setores financeiros (desktop) ─────────────────────────────────
  double? _sETORadministrativo1547, _sETORmanutencao1847, _setorborracha7889;
  double? _pree971, _central5474, _refeit458, _pav1558774;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  Future<void> _sheet(Widget child, {Color bg = Colors.transparent}) =>
      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: bg,
        enableDrag: false,
        context: context,
        builder: (_) => GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child:
              Padding(padding: MediaQuery.viewInsetsOf(context), child: child),
        ),
      ).then((_) => safeSetState(() {}));

  Widget _loading() => Center(
      child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
              color: FlutterFlowTheme.of(context).primary)));

  AnimationInfo _fadeMove() => AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
              curve: Curves.easeInOut,
              delay: 0.ms,
              duration: 600.ms,
              begin: 0,
              end: 1),
          MoveEffect(
              curve: Curves.easeInOut,
              delay: 0.ms,
              duration: 600.ms,
              begin: const Offset(0, 50),
              end: Offset.zero),
        ],
      );

  Future<void> _logout() async {
    unawaited(actions.onesignalLogout());
    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    GoRouter.of(context).clearRedirectLocation();
    FFAppState().variavelUSUARIO = DadosUsuarioStruct();
    safeSetState(() {});
    context.goNamedAuth(LoginWidget.routeName, context.mounted);
  }

  // ─── Verificação de permissão financeiro ────────────────────────────────────
  // Busca por campo 'email' em AREA_RESTRITA — estrutura simplificada do
  // LoginCompletoWidget novo (salva: email, nome, cargo, cadastrado_em,
  // ultimo_acesso).
  //
  // A aba Financeiro exige o campo 'permissao_financeiro == true' no doc.
  // Verifica se doc de AREA_RESTRITA pertence ao usuário logado
  // e tem permissao_financeiro == true.
  // Usa UID (gravado no login). Para docs sem uid ainda,
  // libera qualquer doc com permissao_financeiro=true — o uid
  // será gravado no próximo login automaticamente.
  bool _docTemPermissao(Map<String, dynamic> data) {
    if (data['permissao_financeiro'] != true) return false;
    final uid = currentUserUid;
    final docUid = (data['uid'] ?? '').toString().trim();
    // Doc tem uid: verifica match exato
    if (docUid.isNotEmpty) return uid == docUid;
    // Doc sem uid (primeiro login após simplificação):
    // libera se o usuário tiver permissao_financeiro=true
    // (seguro pois há poucos usuários na coleção)
    return uid.isNotEmpty;
  }

  // ─── Disparado ao clicar na aba Financeiro ────────────────────────────────────
  Future<void> _carregarFinanceiro() async {
    safeSetState(() {}); // força rebuild — o StreamBuilder cuida do resto
  }

  Widget _menuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? animKey,
    double iconBgOpacity = 0.12,
    double iconContainerSize = 60,
  }) {
    Widget card = InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
                blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 16, 10),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(iconBgOpacity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: iconColor, size: iconContainerSize * 0.57),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                        child: Text(title,
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontWeight),
                                  letterSpacing: 0,
                                )),
                      ),
                      Text(subtitle,
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight),
                                    letterSpacing: 0,
                                  )),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
    final animatedCard = animKey != null && animationsMap[animKey] != null
        ? card.animateOnPageLoad(animationsMap[animKey]!)
        : card;
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
        child: animatedCard);
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 0, 20),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Row(children: [
            Icon(icon,
                color: FlutterFlowTheme.of(context).primaryText, size: 24),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
              child: Text(label,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight),
                        letterSpacing: 0,
                      )),
            ),
          ]),
        ),
      );

  // ─── INIT ────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _darkModel1 = createModel(context, () => DarkModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setDarkModeSetting(context, ThemeMode.light);

      _instantTimer = InstantTimer.periodic(
        duration: const Duration(milliseconds: 2000),
        callback: (timer) async {
          _quantidadeDeNotificacao = await NotificacaoTable().queryRows(
            queryFn: (q) => q.eqOrNull('email', currentUserEmail),
          );
          _quantidadeNotificacao =
              valueOrDefault<int>(_quantidadeDeNotificacao?.length, 0);

          final chats = await queryChatRecordOnce(
            queryBuilder: (q) => q
                .where('adm', isEqualTo: true)
                .where('email_cliente', isEqualTo: currentUserEmail)
                .where('lida_ou_nao', isEqualTo: false),
          );
          _mensagensNaoLidas = chats.length;

          safeSetState(() {});
        },
        startImmediately: true,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      final osAguardando = await queryManutencaoRecordOnce(
        queryBuilder: (q) => q
            .where('EMAIL', isEqualTo: currentUserEmail)
            .where('STATUS', isEqualTo: 'AGUARDANDO APROVAÇÃO'),
        limit: 1,
      );
      if (osAguardando.isNotEmpty && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (alertCtx) => AlertDialog(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              Icon(Icons.pending_actions_outlined,
                  color: FlutterFlowTheme.of(context).warning, size: 28),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('O.S. Aguardando Aprovação',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0,
                          ))),
            ]),
            content: Text(
                'Você possui Ordens de Serviço aguardando aprovação. Deseja visualizá-las agora?',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0,
                    )),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertCtx),
                child: Text('Agora não',
                    style: TextStyle(
                        color: FlutterFlowTheme.of(context).secondaryText)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).warning,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(alertCtx);
                  await _sheet(VerManutencaoWidget(
                      email: currentUserEmail, status: 'AGUARDANDO APROVAÇÃO'));
                },
                child: const Text('Ver O.S.',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    });

    _tabBarController1 = TabController(vsync: this, length: 3)
      ..addListener(() => safeSetState(() {}));
    _tabBarController2 = TabController(vsync: this, length: 3)
      ..addListener(() => safeSetState(() {}));
    _textController1 = TextEditingController();
    _textController2 = TextEditingController();
    _textFieldFocusNode1 = FocusNode();
    _textFieldFocusNode2 = FocusNode();

    for (var i = 1; i <= 9; i++) {
      animationsMap['containerOnPageLoadAnimation$i'] = _fadeMove();
    }
    setupAnimations(
      animationsMap.values.where((a) =>
          a.trigger == AnimationTrigger.onActionTrigger ||
          !a.applyInitialState),
      this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _homeController?.finish();
    _instantTimer?.cancel();
    _darkModel1?.dispose();
    _tabBarController1?.dispose();
    _tabBarController2?.dispose();
    _textFieldFocusNode1?.dispose();
    _textFieldFocusNode2?.dispose();
    _textController1?.dispose();
    _textController2?.dispose();
    super.dispose();
  }

  // ─── BUILD PRINCIPAL ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return StreamBuilder<List<UsuariosRecord>>(
      stream: queryUsuariosRecord(
        queryBuilder: (q) => q.where('email', isEqualTo: currentUserEmail),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: Center(
                  child: Text('Erro: ${snapshot.error}',
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).primaryText))));
        if (!snapshot.hasData)
          return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: _loading());
        if (snapshot.data!.isEmpty)
          return Scaffold(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: Center(
                  child: Text('Aguardando sincronização de usuário...',
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).primaryText))));

        final user = snapshot.data!.first;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            floatingActionButton: _buildFAB(user),
            drawer: _buildDrawer(user),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 992;
                return SafeArea(
                  top: true,
                  child: isDesktop ? _buildDesktop(user) : _buildMobile(user),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────────

  Widget _buildFAB(UsuariosRecord user) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
        child: FloatingActionButton(
          backgroundColor: FlutterFlowTheme.of(context).alternate,
          elevation: 8,
          onPressed: () async {
            _conversa = await queryChatRecordCount(
              queryBuilder: (q) =>
                  q.where('email_cliente', isEqualTo: user.email),
            );
            if (_conversa == 0) {
              await _sheet(IniciarConversaWidget());
            } else {
              context.pushNamed(ChatWidget.routeName);
            }
            safeSetState(() {});
          },
          child: badges.Badge(
            badgeContent: Text('$_mensagensNaoLidas',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            showBadge: _mensagensNaoLidas >= 1,
            shape: badges.BadgeShape.circle,
            badgeColor: FlutterFlowTheme.of(context).secondary,
            elevation: 4,
            padding: const EdgeInsets.all(8),
            position: badges.BadgePosition.topStart(),
            animationType: badges.BadgeAnimationType.scale,
            toAnimate: true,
            child: Icon(Icons.chat,
                color: FlutterFlowTheme.of(context).secondary, size: 24),
          ),
        ).addWalkthrough(floatingActionButtonRykuqwpv, _homeController),
      );

  // ─── DRAWER ───────────────────────────────────────────────────────────────────

  Widget _buildDrawer(UsuariosRecord user) => Drawer(
        elevation: 1,
        width: 240,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlutterFlowTheme.of(context).secondary,
                FlutterFlowTheme.of(context).secondaryBackground
              ],
              stops: const [0, 0.3],
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildAvatarRow(user, paddingTop: 20),
              _buildDarkToggle(),
              _navItem(Icons.home, 'Inicio',
                  () => context.pushNamed(TelaPrincipalWidget.routeName)),
              _navItem(
                  Icons.account_circle,
                  'Conta',
                  () => context.pushNamed(PerfilWidget.routeName, extra: {
                        '__transition_info__': TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: const Duration(milliseconds: 100))
                      })),
              _navItem(Icons.call, 'Fale conosco',
                  () => _sheet(ContatoWidget(), bg: const Color(0xB0000000))),
              _navItem(Icons.map_outlined, 'Nossa localização',
                  () => launchURL(_mapsUrl)),
              _navItem(Icons.privacy_tip_sharp, 'Politica de Privacidade',
                  () => _sheet(PoliticcasWidget())),
              _navItem(Icons.logout, 'Deslogar', _logout),
            ]),
          ),
        ),
      );

  Widget _buildAvatarRow(UsuariosRecord user, {double paddingTop = 0}) {
    final hasPhoto = user.photoUrl.isNotEmpty;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, paddingTop, 0, 0),
      child: Row(children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
          child: Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FlutterFlowTheme.of(context).accent1,
            ),
            child: hasPhoto
                ? CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 800),
                    fadeOutDuration: const Duration(milliseconds: 800),
                    imageUrl: user.photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, color: Colors.white),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        Column(children: [
          Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(7, 0, 0, 5),
              child: Text(valueOrDefault<String>(user.displayName, ''),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight),
                        fontSize: 10,
                        letterSpacing: 0,
                      ))),
          Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 0, 0),
              child: Text(FFAppState().variavelUSUARIO.nome,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight),
                        fontSize: 14,
                        letterSpacing: 0,
                      ))),
        ]),
      ]),
    );
  }

  Widget _buildDarkToggle() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => setDarkModeSetting(
          context, isLight ? ThemeMode.dark : ThemeMode.light),
      child: Container(
        width: MediaQuery.sizeOf(context).width * (isLight ? 0.702 : 0.641),
        padding: const EdgeInsets.all(12),
        child: Row(children: [DarkWidget()]),
      ),
    );
  }

  static const _mapsUrl =
      'https://www.google.com/maps/dir/-14.8414528,-40.8698976/hps+refrigera%C3%A7%C3%A3o+localiza%C3%A7%C3%A7ao+para+compartilhar/@-14.8442919,-40.8719229,15z/data=!3m1!4b1!4m9!4m8!1m1!4e1!1m5!1m1!1s0x7463ba32267eba3:c1a11!2m2!1d-40.8538501!2d-14.8470604?entry=ttu&g_ep=EgoyMDI0MDkxOC4xIKXMDSoASAFQAw%3D%3D';

  // ─── TABBAR ────────────────────────────────────────────────────────────────────

  Widget _buildTabBar(TabController ctrl,
      {required Future<void> Function(int) onFinish}) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = w < kBreakpointSmall
        ? 16.0
        : w < kBreakpointMedium
            ? 20.0
            : 25.0;
    return TabBar(
      isScrollable: true,
      controller: ctrl,
      labelColor: FlutterFlowTheme.of(context).success,
      unselectedLabelColor: FlutterFlowTheme.of(context).primaryText,
      labelPadding: const EdgeInsetsDirectional.fromSTEB(25, 0, 25, 0),
      indicatorColor: FlutterFlowTheme.of(context).success,
      unselectedLabelStyle: const TextStyle(),
      labelStyle: FlutterFlowTheme.of(context).titleLarge.override(
            font: GoogleFonts.interTight(
                fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight),
            fontSize: fontSize,
            letterSpacing: 0,
          ),
      tabs: const [
        Tab(text: 'Inicio'),
        Tab(text: 'Estatísticas'),
        Tab(text: 'Financeiro')
      ],
      onTap: (i) async {
        if (i == 2) await onFinish(i);
      },
    );
  }

  // ─── TAB MENU (Inicio) ──────────────────────────────────────────────────

  Widget _buildMenuTab(UsuariosRecord user, {required bool isDesktop}) =>
      SingleChildScrollView(
        child: Align(
          alignment: AlignmentDirectional.center,
          child: Container(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  if (!isDesktop)
                    _menuCard(
                      icon: Icons.qr_code_scanner_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'Hps code',
                      subtitle: 'Escaneie seu equipamento',
                      animKey: 'containerOnPageLoadAnimation5',
                      onTap: () async {
                        _qrcode = await FlutterBarcodeScanner.scanBarcode(
                            '#C62828', 'Cancelar', true, ScanMode.BARCODE);
                        if (_qrcode != '-1') {
                          await _sheet(
                              ListaDeEquipamentosWidget(patrimonio: _qrcode!));
                        }
                        safeSetState(() {});
                      },
                    ),
                  if (user.empresa == true)
                    _menuCard(
                      icon: Icons.search_rounded,
                      iconColor: const Color(0xFF1A73E8),
                      title: 'Buscar equipamento',
                      subtitle: isDesktop
                          ? 'Digite o numero do seu equipamento'
                          : 'Buscar equipamentos cadastrados',
                      animKey: isDesktop
                          ? 'containerOnPageLoadAnimation1'
                          : 'containerOnPageLoadAnimation6',
                      onTap: () =>
                          _sheet(ListaDeEquipamentosWidget(patrimonio: '')),
                    ),
                  _menuCard(
                    icon: Icons.build_rounded,
                    iconColor: const Color(0xFF68DDC5),
                    iconBgOpacity: 0.15,
                    title: 'Manutenções',
                    subtitle: 'Veja os históricos das suas manutenções',
                    animKey: isDesktop
                        ? 'containerOnPageLoadAnimation2'
                        : 'containerOnPageLoadAnimation7',
                    onTap: () => _sheet(VerManutencaoWidget(
                        email: currentUserEmail, status: '')),
                  ),
                  _menuCard(
                    icon: Icons.assignment_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Preventivas',
                    subtitle: 'Relatórios das manutenções',
                    animKey: isDesktop
                        ? 'containerOnPageLoadAnimation3'
                        : 'containerOnPageLoadAnimation8',
                    onTap: () => _sheet(SlaaaaaCopy2Widget()),
                  ),
                  _menuCard(
                    icon: Icons.share_rounded,
                    iconColor: const Color(0xFFE91E63),
                    iconContainerSize: 55,
                    title: 'Nossas redes',
                    subtitle: 'Acompanhe nossas mídias socias',
                    animKey: isDesktop
                        ? 'containerOnPageLoadAnimation4'
                        : 'containerOnPageLoadAnimation9',
                    onTap: () => showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (_) => GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: SizedBox(
                                height: double.infinity,
                                child: MidiasocialWidget())),
                      ),
                    ).then((_) => safeSetState(() {})),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ─── TAB DASHBOARD ────────────────────────────────────────────────────────────

  Widget _buildDashboardTab(UsuariosRecord user) => SingleChildScrollView(
        child: Column(
            children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dashboard',
                    style: FlutterFlowTheme.of(context).headlineLarge.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FontWeight.bold),
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        )),
                FlutterFlowIconButton(
                  borderRadius: 12,
                  buttonSize: 48,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(Icons.refresh_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24),
                  onPressed: () => safeSetState(() {}),
                ),
              ],
            ),
          ),
          Align(
              alignment: AlignmentDirectional.center,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sw = MediaQuery.sizeOf(context).width;
                  // mobile <600  → 72px   tablet 600-991 → 88px   desktop ≥992 → 100px
                  final cardH = sw < 600
                      ? 72.0
                      : sw < 992
                          ? 88.0
                          : 100.0;
                  final availW = sw * 0.98;
                  return SizedBox(
                    width: availW,
                    height: cardH,
                    child: custom_widgets.DashboardCardsWidget(
                      width: availW,
                      height: cardH,
                      emailParam: currentUserEmail,
                      senhaAppState: user.senha,
                    ),
                  );
                },
              )),
          Padding(
            padding: const EdgeInsets.all(2),
            child: StreamBuilder<List<CorretivasRecord>>(
              stream: queryCorretivasRecord(
                queryBuilder: (q) =>
                    q.where('ANO', isEqualTo: functions.anoatual()?.toString()),
              ),
              builder: (_, snap) {
                if (!snap.hasData) return _loading();
                return Container(
                  width: double.infinity,
                  height: 1000,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x17000000)),
                  ),
                  child: custom_widgets.MaintenanceReport(
                      width: double.infinity,
                      height: double.infinity,
                      userEmail: currentUserEmail),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: const [
                BoxShadow(
                    blurRadius: 8,
                    color: Color(0x1A000000),
                    offset: Offset(0, 2))
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Últimas Atividades',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600),
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                            )),
                    StreamBuilder<List<ManutencaoRecord>>(
                      stream: queryManutencaoRecord(
                        queryBuilder: (q) => q
                            .where('EMAIL', isEqualTo: currentUserEmail)
                            .orderBy('DATADAMANUTENCAO', descending: true),
                        limit: 6,
                      ),
                      builder: (_, snap) {
                        if (!snap.hasData) return _loading();
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snap.data!.length,
                          itemBuilder: (_, i) {
                            final rec = snap.data![i];
                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 8, 0, 8),
                              child: Row(
                                  children: [
                                Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .success,
                                        shape: BoxShape.circle)),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text('O.S ${rec.numeroOs} ${rec.status}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.w500),
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.w500,
                                              )),
                                      Text('Equipamento: ${rec.equipamento}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0,
                                              )),
                                      Text(
                                          valueOrDefault<String>(
                                              dateTimeFormat("M/d h:mm a",
                                                  rec.datadamanutencao,
                                                  locale: FFLocalizations.of(
                                                          context)
                                                      .languageCode),
                                              ''),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0,
                                              )),
                                    ])),
                              ].divide(const SizedBox(width: 12))),
                            );
                          },
                        );
                      },
                    ),
                  ].divide(const SizedBox(height: 16))),
            ),
          ),
        ]
                .divide(const SizedBox(height: 10))
                .addToStart(const SizedBox(height: 10))
                .addToEnd(const SizedBox(height: 24))),
      );

  // ─── TAB FINANCEIRO desktop ──────────────────────────────────────────────────

  Widget _buildFinanceiroDesktop() {
    // TelaCustomWidget já gerencia permissão (UID → email → DEVICE_ID)
    // e exibe bloqueio ou conteúdo internamente
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.99,
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: custom_widgets.TelaCustomWidget(
          width: MediaQuery.sizeOf(context).width * 0.99,
          height: MediaQuery.sizeOf(context).height * 0.85,
        ),
      ),
    );
  }

  // ─── TAB FINANCEIRO mobile ───────────────────────────────────────────────────

  Widget _buildFinanceiroMobile(UsuariosRecord user) {
    // TelaCustomWidget já gerencia permissão (UID → email → DEVICE_ID)
    // e exibe bloqueio ou conteúdo internamente
    return custom_widgets.TelaCustomWidget(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      nomeUsuario: FFAppState().variavelUSUARIO.nome,
      emailUsuario: user.email,
      nomeEmpresa: user.displayName,
    );
  }

  // ─── Tela de bloqueio unificada (mobile + desktop) ───────────────────────────
  Widget _buildBloqueioFinanceiro({
    required bool isDesktop,
    UsuariosRecord? user,
  }) {
    return Align(
      alignment: const AlignmentDirectional(0, -0.05),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: FlutterFlowTheme.of(context).error, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent4,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(Icons.lock_rounded,
                      color: FlutterFlowTheme.of(context).error, size: 40),
                ),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Área Restrita',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontWeight),
                                color: FlutterFlowTheme.of(context).error,
                                letterSpacing: 0,
                              )),
                      Text('Você não tem autorização para ver estes valores',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0,
                              )),
                    ].divide(const SizedBox(height: 8))),
                FFButtonWidget(
                  text: 'Solicitar Acesso',
                  onPressed: () async {
                    _apiResultjgi875 = await EnviarCall.call(
                      email: 'hpsrefri@gmail.com',
                      titulo: 'Solicitação do financeiro',
                      mensagem:
                          'O usuário ${FFAppState().variavelUSUARIO.nome} '
                          'da empresa ${user?.displayName ?? ''} '
                          'solicitou acesso ao financeiro do app.',
                    );
                    if (_apiResultjgi875?.succeeded == true) {
                      // Registra solicitação no Firestore para rastreamento
                      await FirebaseFirestore.instance
                          .collection('SOLICITACOES_FINANCEIRO')
                          .add({
                        'email': currentUserEmail,
                        'nome': FFAppState().variavelUSUARIO.nome,
                        'empresa': user?.displayName ?? '',
                        'status': 'pendente',
                        'solicitadoEm': FieldValue.serverTimestamp(),
                      });
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Atenção!'),
                          content: const Text(
                              'Solicitação recebida. Nossa equipe avaliará e liberará o acesso financeiro.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Ok'))
                          ],
                        ),
                      );
                    }
                    safeSetState(() {});
                  },
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    color: FlutterFlowTheme.of(context).error,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .fontWeight),
                          color: FlutterFlowTheme.of(context).info,
                          letterSpacing: 0,
                        ),
                    elevation: 0,
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ].divide(const SizedBox(height: 16)),
            ),
          ),
        ),
      ),
    );
  }

  // ─── DESKTOP ──────────────────────────────────────────────────────────────────

  Widget _buildDesktop(UsuariosRecord user) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FlutterFlowTheme.of(context).secondary,
              FlutterFlowTheme.of(context).secondaryBackground,
            ],
            stops: const [0, 0.2],
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: SizedBox(
                height: 80,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://i.ibb.co/VWKMpYV8/Gemini-Generated-Image.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.ac_unit,
                            size: 70, color: Color(0xFF68DDC5)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Soluções em climatização',
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .displaySmall
                                        .fontWeight,
                                  ),
                                  letterSpacing: 0,
                                ),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: custom_widgets.NotificacaoBellWidget(
                          width: 35, height: 35),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: FlutterFlowTheme.of(context).alternate,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220,
                    child: _buildSidebar(user),
                  ),
                  const VerticalDivider(thickness: 1, width: 62),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 24),
                      child: Column(
                        children: [
                          _buildTabBar(
                            _tabBarController1!,
                            onFinish: (_) => _carregarFinanceiro(),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabBarController1,
                              children: [
                                _buildMenuTab(user, isDesktop: true),
                                _buildDashboardTab(user),
                                _buildFinanceiroDesktop(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ─── SIDEBAR desktop ──────────────────────────────────────────────────────────

  Widget _buildSidebar(UsuariosRecord user) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 32),
              child: _buildAvatarRow(user),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
              child: DarkWidget(),
            ),
            _navItem(Icons.home, 'Inicio',
                () => context.pushNamed(TelaPrincipalWidget.routeName)),
            _navItem(
                Icons.account_circle,
                'Conta',
                () => context.pushNamed(PerfilWidget.routeName, extra: {
                      '__transition_info__': TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 100),
                      ),
                    })),
            _navItem(Icons.call, 'Fale conosco',
                () => _sheet(ContatoWidget(), bg: const Color(0xB0000000))),
            _navItem(Icons.map_outlined, 'Nossa localização',
                () => launchURL(_mapsUrl)),
            _navItem(Icons.privacy_tip_sharp, 'Politica de Privacidade',
                () => _sheet(PoliticcasWidget())),
            _navItem(Icons.logout_outlined, 'Deslogar', _logout),
          ],
        ),
      );

  // ─── MOBILE ───────────────────────────────────────────────────────────────────

  Widget _buildMobile(UsuariosRecord user) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FlutterFlowTheme.of(context).secondary,
              FlutterFlowTheme.of(context).secondaryBackground
            ],
            stops: const [0, 0.2],
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5, 10, 10, 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                child: FlutterFlowIconButton(
                  borderRadius: 20,
                  borderWidth: 1,
                  buttonSize: 50,
                  icon: Icon(Icons.menu_rounded,
                      color: FlutterFlowTheme.of(context).info, size: 24),
                  onPressed: () => scaffoldKey.currentState!.openDrawer(),
                ),
              ),
              SizedBox(
                  width: 35,
                  height: 35,
                  child: custom_widgets.NotificacaoBellWidget(
                      width: 35, height: 35)),
            ]),
            Opacity(
              opacity: 0.7,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://i.ibb.co/VWKMpYV8/Gemini-Generated-Image.png',
                            width: 73.3,
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.ac_unit,
                                size: 60,
                                color: Color(0xFF68DDC5)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 0, 0, 0),
                            child: Text('HPS REFRIGERAÇÃO',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.raleway(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight),
                                      fontSize: 25,
                                      letterSpacing: 0,
                                    )),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 35),
                child: Column(children: [
                  _buildTabBar(_tabBarController2!,
                      onFinish: (_) => _carregarFinanceiro()),
                  Expanded(
                      child: TabBarView(
                    controller: _tabBarController2,
                    children: [
                      _buildMenuTab(user, isDesktop: false),
                      _buildDashboardTab(user),
                      _buildFinanceiroMobile(user),
                    ],
                  )),
                  Offstage(
                    offstage: true,
                    child: SizedBox(
                        width: 1,
                        height: 1,
                        child: custom_widgets.VerificarSenhaRedefinidaWidget(
                            width: 1, height: 1)),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );

  TutorialCoachMark createPageWalkthrough(BuildContext context) =>
      TutorialCoachMark(
        targets: createWalkthroughTargets(context),
        onFinish: () async {
          safeSetState(() => _homeController = null);
          FFAppState().nomedouser = '';
          safeSetState(() {});
        },
        onSkip: () => true,
      );
}
