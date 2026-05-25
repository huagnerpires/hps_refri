import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'slaaaaa_copy2_model.dart';
export 'slaaaaa_copy2_model.dart';

/// crie um componente de escolha de mes e um textfield pra eu digita o ano
/// ok?
///
/// e tbm que a escolha do mes seja em dropdown ok? e os meses tudo maisculo
/// ok?
class SlaaaaaCopy2Widget extends StatefulWidget {
  const SlaaaaaCopy2Widget({super.key});

  @override
  State<SlaaaaaCopy2Widget> createState() => _SlaaaaaCopy2WidgetState();
}

class _SlaaaaaCopy2WidgetState extends State<SlaaaaaCopy2Widget> {
  late SlaaaaaCopy2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SlaaaaaCopy2Model());

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
      child: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 480.0,
          maxHeight: 450.0,
        ),
        decoration: BoxDecoration(),
        child: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.BuscaPreventivasModal(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
