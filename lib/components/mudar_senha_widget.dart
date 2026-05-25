import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'mudar_senha_model.dart';
export 'mudar_senha_model.dart';

class MudarSenhaWidget extends StatefulWidget {
  const MudarSenhaWidget({super.key});

  @override
  State<MudarSenhaWidget> createState() => _MudarSenhaWidgetState();
}

class _MudarSenhaWidgetState extends State<MudarSenhaWidget> {
  late MudarSenhaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MudarSenhaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: custom_widgets.EsqueciSenhaWidget(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
