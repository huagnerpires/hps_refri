import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'lista_de_equipamentos_model.dart';
export 'lista_de_equipamentos_model.dart';

class ListaDeEquipamentosWidget extends StatefulWidget {
  const ListaDeEquipamentosWidget({
    super.key,
    required this.patrimonio,
  });

  final String? patrimonio;

  @override
  State<ListaDeEquipamentosWidget> createState() =>
      _ListaDeEquipamentosWidgetState();
}

class _ListaDeEquipamentosWidgetState extends State<ListaDeEquipamentosWidget> {
  late ListaDeEquipamentosModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaDeEquipamentosModel());

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
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeIn,
        decoration: BoxDecoration(),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.EquipamentosEmpresaWidget(
                width: double.infinity,
                height: double.infinity,
                emailFiltro: currentUserEmail,
                patrimonioFiltro: widget.patrimonio,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
