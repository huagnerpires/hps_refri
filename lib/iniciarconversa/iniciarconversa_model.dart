import '/components/iniciar_conversa_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'iniciarconversa_widget.dart' show IniciarconversaWidget;
import 'package:flutter/material.dart';

class IniciarconversaModel extends FlutterFlowModel<IniciarconversaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for iniciar_conversa component.
  late IniciarConversaModel iniciarConversaModel;

  @override
  void initState(BuildContext context) {
    iniciarConversaModel = createModel(context, () => IniciarConversaModel());
  }

  @override
  void dispose() {
    iniciarConversaModel.dispose();
  }
}
