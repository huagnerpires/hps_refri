import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'cadastro_widget.dart' show CadastroWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroModel extends FlutterFlowModel<CadastroWidget> {
  ///  Local state fields for this page.

  int? logicaVisivel = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  bool isDataUploading_uploadData5oj = false;
  FFUploadedFile uploadedLocalFile_uploadData5oj =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadData5oj = '';

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for nomeusuario widget.
  FocusNode? nomeusuarioFocusNode;
  TextEditingController? nomeusuarioTextController;
  String? Function(BuildContext, String?)? nomeusuarioTextControllerValidator;
  // State field(s) for cnpjoucpf widget.
  FocusNode? cnpjoucpfFocusNode;
  TextEditingController? cnpjoucpfTextController;
  String? Function(BuildContext, String?)? cnpjoucpfTextControllerValidator;
  // State field(s) for cnp widget.
  FocusNode? cnpFocusNode;
  TextEditingController? cnpTextController;
  late MaskTextInputFormatter cnpMask;
  String? Function(BuildContext, String?)? cnpTextControllerValidator;
  // State field(s) for tipodecontrato widget.
  FocusNode? tipodecontratoFocusNode;
  TextEditingController? tipodecontratoTextController;
  String? Function(BuildContext, String?)?
      tipodecontratoTextControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for password_confirmar widget.
  FocusNode? passwordConfirmarFocusNode;
  TextEditingController? passwordConfirmarTextController;
  late bool passwordConfirmarVisibility;
  String? Function(BuildContext, String?)?
      passwordConfirmarTextControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  UsuariosRecord? joj;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    passwordConfirmarVisibility = false;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    nomeusuarioFocusNode?.dispose();
    nomeusuarioTextController?.dispose();

    cnpjoucpfFocusNode?.dispose();
    cnpjoucpfTextController?.dispose();

    cnpFocusNode?.dispose();
    cnpTextController?.dispose();

    tipodecontratoFocusNode?.dispose();
    tipodecontratoTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    passwordConfirmarFocusNode?.dispose();
    passwordConfirmarTextController?.dispose();
  }
}
