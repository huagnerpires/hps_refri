import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'politiccas_model.dart';
export 'politiccas_model.dart';

class PoliticcasWidget extends StatefulWidget {
  const PoliticcasWidget({super.key});

  @override
  State<PoliticcasWidget> createState() => _PoliticcasWidgetState();
}

class _PoliticcasWidgetState extends State<PoliticcasWidget> {
  late PoliticcasModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PoliticcasModel());

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
          child: custom_widgets.PoliticaPrivacidadeWidget(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
