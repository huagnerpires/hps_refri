import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/componentes/dark/dark_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'homebackup_widget.dart' show HomebackupWidget;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'
    show TutorialCoachMark;
import 'package:flutter/material.dart';

class HomebackupModel extends FlutterFlowModel<HomebackupWidget> {
  ///  Local state fields for this page.

  int? codigoqr;

  int? quantidadeNotificacao = 0;

  int? logica = 0;

  /// INSTA
  double? instalacaso;

  double? adm = 0.0;

  /// manutencao
  double? manutencao = 0.0;

  double? producao = 0.0;

  double? borracha = 0.0;

  double? pre = 0.0;

  double? refeitorio = 0.0;

  double? pav15 = 0.0;

  ///  State fields for stateful widgets in this page.

  TutorialCoachMark? homeController;
  // Model for dark component.
  late DarkModel darkModel1;
  // Model for dark component.
  late DarkModel darkModel2;
  // Stores action output result for [Firestore Query - Query a collection] action in FloatingActionButton widget.
  int? conversa;
  // Stores action output result for [Firestore Query - Query a collection] action in Container widget.
  int? resultadosEmailL;
  // State field(s) for TabBar widget.
  TabController? tabBarController1;
  int get tabBarCurrentIndex1 =>
      tabBarController1 != null ? tabBarController1!.index : 0;
  int get tabBarPreviousIndex1 =>
      tabBarController1 != null ? tabBarController1!.previousIndex : 0;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Stores action output result for [Firestore Query - Query a collection] action in Tab widget.
  AreaRestritaRecord? permissao58718;
  // Model for dark component.
  late DarkModel darkModel3;
  // Stores action output result for [Firestore Query - Query a collection] action in Container widget.
  int? resultadosEmailL2;
  // State field(s) for TabBar widget.
  TabController? tabBarController2;
  int get tabBarCurrentIndex2 =>
      tabBarController2 != null ? tabBarController2!.index : 0;
  int get tabBarPreviousIndex2 =>
      tabBarController2 != null ? tabBarController2!.previousIndex : 0;

  var qrcode = '';
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Stores action output result for [Firestore Query - Query a collection] action in Tab widget.
  AreaRestritaRecord? permissao587183;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? sETORadministrativo1547;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? sETORmanutencao1847;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? setorborracha7889;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? pree971;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? central5474;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? refeit458;
  // Stores action output result for [Custom Action - somarvaloresnalistadofirebase] action in Tab widget.
  double? pav1558774;
  // Stores action output result for [Backend Call - API (enviar)] action in Button widget.
  ApiCallResponse? apiResultjgi875;

  @override
  void initState(BuildContext context) {
    darkModel1 = createModel(context, () => DarkModel());
    darkModel2 = createModel(context, () => DarkModel());
    darkModel3 = createModel(context, () => DarkModel());
  }

  @override
  void dispose() {
    homeController?.finish();
    darkModel1.dispose();
    darkModel2.dispose();
    tabBarController1?.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    darkModel3.dispose();
    tabBarController2?.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
