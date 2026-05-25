import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'midiasocial_model.dart';
export 'midiasocial_model.dart';

class MidiasocialWidget extends StatefulWidget {
  const MidiasocialWidget({super.key});

  @override
  State<MidiasocialWidget> createState() => _MidiasocialWidgetState();
}

class _MidiasocialWidgetState extends State<MidiasocialWidget> {
  late MidiasocialModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MidiasocialModel());

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
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(
                  0.0,
                  2.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondary,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close_sharp,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nossas midias sociais',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await launchURL(
                              'https://www.instagram.com/hpsrefri/');
                        },
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/instagram.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await launchURL(
                              'https://youtube.com/@hpsrefrigeracao?si=L3-ne8b5Py-mdZ4b');
                        },
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/youtube.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await launchURL('https://wa.me/5577988612447');
                        },
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/whatsapp.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B5998), Color(0xFF2F477A)],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(1.0, -1.0),
                          end: AlignmentDirectional(-1.0, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: FlutterFlowIconButton(
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.facebook,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await launchURL('https://www.facebook.com/hpsrefri');
                        },
                      ),
                    ),
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00F2EA), Color(0xFFFF0050)],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(1.0, -1.0),
                          end: AlignmentDirectional(-1.0, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: FlutterFlowIconButton(
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.tiktok,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await launchURL(
                              'https://www.tiktok.com/@hpsrefrigeracao?_t=8rBSqI5dSf2&_r=1');
                        },
                      ),
                    ),
                  ].divide(SizedBox(width: 6.0)),
                ),
                Text(
                  'Fique conectado conosco nas redes sociais para obter as últimas atualizações e novidades!',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
        ),
      ),
    );
  }
}
