import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'visualizar_preventiva_model.dart';
export 'visualizar_preventiva_model.dart';

class VisualizarPreventivaWidget extends StatefulWidget {
  const VisualizarPreventivaWidget({
    super.key,
    required this.email,
    this.ano,
    required this.mes,
  });

  final String? email;
  final int? ano;
  final String? mes;

  static String routeName = 'visualizar_preventiva';
  static String routePath = '/visualizarPreventiva';

  @override
  State<VisualizarPreventivaWidget> createState() =>
      _VisualizarPreventivaWidgetState();
}

class _VisualizarPreventivaWidgetState
    extends State<VisualizarPreventivaWidget> {
  late VisualizarPreventivaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VisualizarPreventivaModel());

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
        body: SafeArea(
          top: true,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 15.0, 0.0),
                        child: FlutterFlowIconButton(
                          borderRadius: 8.0,
                          buttonSize: 28.0,
                          fillColor: Color(0xFF64B5F6),
                          icon: Icon(
                            Icons.arrow_back,
                            color: FlutterFlowTheme.of(context).info,
                            size: 12.0,
                          ),
                          onPressed: () async {
                            context.safePop();
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      child: custom_widgets.Visualizar(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        emailCliente: currentUserEmail,
                        filtroAno: widget.ano?.toString(),
                        filtroMes: widget.mes,
                        onClose: () async {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
