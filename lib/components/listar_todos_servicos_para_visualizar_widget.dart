import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'listar_todos_servicos_para_visualizar_model.dart';
export 'listar_todos_servicos_para_visualizar_model.dart';

class ListarTodosServicosParaVisualizarWidget extends StatefulWidget {
  const ListarTodosServicosParaVisualizarWidget({super.key});

  @override
  State<ListarTodosServicosParaVisualizarWidget> createState() =>
      _ListarTodosServicosParaVisualizarWidgetState();
}

class _ListarTodosServicosParaVisualizarWidgetState
    extends State<ListarTodosServicosParaVisualizarWidget> {
  late ListarTodosServicosParaVisualizarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => ListarTodosServicosParaVisualizarModel());

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
        width: 500.0,
        height: 500.0,
        child: custom_widgets.MaintenanceReport(
          width: 500.0,
          height: 500.0,
          userEmail: 'calçados@grupodass.com.br',
        ),
      ),
    );
  }
}
