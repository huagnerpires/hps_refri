import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'acao_model.dart';
export 'acao_model.dart';

class AcaoWidget extends StatefulWidget {
  const AcaoWidget({super.key});

  @override
  State<AcaoWidget> createState() => _AcaoWidgetState();
}

class _AcaoWidgetState extends State<AcaoWidget> {
  late AcaoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AcaoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50.0,
              child: Divider(
                thickness: 5.0,
                indent: 5.0,
                endIndent: 5.0,
                color: Color(0xFF616368),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(9.0, 9.0, 9.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(7.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Não há manutenção',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Lottie.asset(
                'assets/jsons/Animation_-_1727032094538.json',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.contain,
                repeat: false,
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
