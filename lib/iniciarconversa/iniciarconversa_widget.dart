import '/components/iniciar_conversa_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'iniciarconversa_model.dart';
export 'iniciarconversa_model.dart';

class IniciarconversaWidget extends StatefulWidget {
  const IniciarconversaWidget({super.key});

  static String routeName = 'iniciarconversa';
  static String routePath = '/iniciarconversa';

  @override
  State<IniciarconversaWidget> createState() => _IniciarconversaWidgetState();
}

class _IniciarconversaWidgetState extends State<IniciarconversaWidget> {
  late IniciarconversaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IniciarconversaModel());

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
          child: wrapWithModel(
            model: _model.iniciarConversaModel,
            updateCallback: () => safeSetState(() {}),
            child: IniciarConversaWidget(),
          ),
        ),
      ),
    );
  }
}
