import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'jinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnj_model.dart';
export 'jinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnj_model.dart';

class JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjWidget
    extends StatefulWidget {
  const JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjWidget(
      {super.key});

  static String routeName =
      'JINHBGFCRXSZRETYRYTIUIHOPKKPMONIBUVYCFTXRZEEZSRXTCFYVGKUBLHNJ';
  static String routePath =
      '/jinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnj';

  @override
  State<JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjWidget>
      createState() =>
          _JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjWidgetState();
}

class _JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjWidgetState
    extends State<
        JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjWidget> {
  late JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjModel
      _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context,
        () =>
            JinhbgfcrxszretyrytiuihopkkpmonibuvycftxrzeezsrxtcfyvgkublhnjModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          automaticallyImplyLeading: false,
          title: Text(
            'Page Title',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(),
              child: Container(
                width: double.infinity,
                height: 800.0,
                child: custom_widgets.RelatorioCard(
                  width: double.infinity,
                  height: 800.0,
                  email: 'calçados@grupodass.com.br',
                  mes: 'FEVEREIRO',
                  ano: '2026',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
