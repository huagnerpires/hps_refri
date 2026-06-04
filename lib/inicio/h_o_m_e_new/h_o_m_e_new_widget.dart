import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'h_o_m_e_new_model.dart';
export 'h_o_m_e_new_model.dart';

class HOMENewWidget extends StatefulWidget {
  const HOMENewWidget({super.key});

  static String routeName = 'HOME_new';
  static String routePath = '/hOMENew';

  @override
  State<HOMENewWidget> createState() => _HOMENewWidgetState();
}

class _HOMENewWidgetState extends State<HOMENewWidget> {
  late HOMENewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HOMENewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.999,
                  height: MediaQuery.sizeOf(context).height * 0.999,
                  child: custom_widgets.TelaPrincipalWidget(
                    width: MediaQuery.sizeOf(context).width * 0.999,
                    height: MediaQuery.sizeOf(context).height * 0.999,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
