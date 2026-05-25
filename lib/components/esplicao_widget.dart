import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'esplicao_model.dart';
export 'esplicao_model.dart';

class EsplicaoWidget extends StatefulWidget {
  const EsplicaoWidget({super.key});

  @override
  State<EsplicaoWidget> createState() => _EsplicaoWidgetState();
}

class _EsplicaoWidgetState extends State<EsplicaoWidget> {
  late EsplicaoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EsplicaoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, -1.0),
      child: Material(
        color: Colors.transparent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 100.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
          ),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                  child: Text(
                    'Digite seu nome corretamente pois essa informação será utilizada no aplicativo para acessar algumas funcões.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
