import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ver_manutencao_model.dart';
export 'ver_manutencao_model.dart';

class VerManutencaoWidget extends StatefulWidget {
  const VerManutencaoWidget({
    super.key,
    this.status,
    required this.email,
  });

  final String? status;
  final String? email;

  @override
  State<VerManutencaoWidget> createState() => _VerManutencaoWidgetState();
}

class _VerManutencaoWidgetState extends State<VerManutencaoWidget> {
  late VerManutencaoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerManutencaoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: AlignmentDirectional(0.0, -1.0),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(),
          alignment: AlignmentDirectional(0.0, -1.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.ManutencaoGridWidget(
              width: double.infinity,
              height: double.infinity,
              statusFiltro: widget.status!,
              senhaAppState: FFAppState().variavelUSUARIO.senha,
              emailFiltro: currentUserEmail,
            ),
          ),
        ),
      ),
    );
  }
}
