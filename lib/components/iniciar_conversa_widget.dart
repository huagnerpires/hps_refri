import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'iniciar_conversa_model.dart';
export 'iniciar_conversa_model.dart';

class IniciarConversaWidget extends StatefulWidget {
  const IniciarConversaWidget({super.key});

  @override
  State<IniciarConversaWidget> createState() => _IniciarConversaWidgetState();
}

class _IniciarConversaWidgetState extends State<IniciarConversaWidget> {
  late IniciarConversaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IniciarConversaModel());

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
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.9,
                constraints: BoxConstraints(
                  maxWidth: 7000.0,
                ),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Iniciar uma conversa?',
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
                      Text(
                        'Gostaria de começar a conversar com nossa equipe de suporte? Estamos aqui para ajudar.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .fontStyle,
                            ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              _model.users = await queryUsuariosRecordOnce(
                                queryBuilder: (usuariosRecord) =>
                                    usuariosRecord.where(
                                  'uid',
                                  isEqualTo: currentUserUid,
                                ),
                                singleRecord: true,
                              ).then((s) => s.firstOrNull);

                              await ChatRecord.collection
                                  .doc()
                                  .set(createChatRecordData(
                                    mensagens:
                                        'Olá! ${_model.users?.displayName}  Estamos aqui para tirar suas dúvidas e oferecer o melhor atendimento. Conte conosco para ajudar você rapidamente. Sua satisfação é a nossa prioridade! 😊',
                                    emailCliente: currentUserEmail,
                                    uid: currentUserUid,
                                    data: getCurrentTimestamp,
                                    adm: true,
                                    lidaOuNao: false,
                                  ));
                              _model.listaChat = await queryListaChatRecordOnce(
                                queryBuilder: (listaChatRecord) =>
                                    listaChatRecord.where(
                                  'email',
                                  isEqualTo: currentUserEmail,
                                ),
                                singleRecord: true,
                              ).then((s) => s.firstOrNull);
                              if (_model.listaChat?.email == currentUserEmail) {
                                context.pushNamed(ChatWidget.routeName);

                                Navigator.pop(context);
                              } else {
                                await ListaChatRecord.collection
                                    .doc()
                                    .set(createListaChatRecordData(
                                      nome: currentUserDisplayName,
                                      email: currentUserEmail,
                                      novaMensagem: true,
                                    ));

                                context.pushNamed(ChatWidget.routeName);

                                Navigator.pop(context);
                              }

                              safeSetState(() {});
                            },
                            text: 'Iniciar bate-papo',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 56.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).secondary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).info,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            text: 'Talvez mais tarde',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 56.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).secondary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ].divide(SizedBox(height: 24.0)),
                  ),
                ),
              ),
            ),
          ].divide(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
