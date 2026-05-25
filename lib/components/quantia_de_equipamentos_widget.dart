import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'quantia_de_equipamentos_model.dart';
export 'quantia_de_equipamentos_model.dart';

class QuantiaDeEquipamentosWidget extends StatefulWidget {
  const QuantiaDeEquipamentosWidget({super.key});

  @override
  State<QuantiaDeEquipamentosWidget> createState() =>
      _QuantiaDeEquipamentosWidgetState();
}

class _QuantiaDeEquipamentosWidgetState
    extends State<QuantiaDeEquipamentosWidget> {
  late QuantiaDeEquipamentosModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuantiaDeEquipamentosModel());

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
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600.0,
          ),
          decoration: BoxDecoration(),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: custom_widgets.PopupDemonstrativo(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        emailParam: currentUserEmail,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
