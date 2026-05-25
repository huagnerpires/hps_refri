import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      if (prefs.containsKey('ff_variavelUSUARIO')) {
        try {
          final serializedData = prefs.getString('ff_variavelUSUARIO') ?? '{}';
          _variavelUSUARIO = DadosUsuarioStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _idPagamento = prefs.getInt('ff_idPagamento') ?? _idPagamento;
    });
    _safeInit(() {
      _referenciaGarantiaPagamento =
          prefs.getString('ff_referenciaGarantiaPagamento')?.ref ??
              _referenciaGarantiaPagamento;
    });
    _safeInit(() {
      _datanovagarantia = prefs.containsKey('ff_datanovagarantia')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_datanovagarantia')!)
          : _datanovagarantia;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  DateTime? _data;
  DateTime? get data => _data;
  set data(DateTime? value) {
    _data = value;
  }

  DadosUsuarioStruct _variavelUSUARIO = DadosUsuarioStruct();
  DadosUsuarioStruct get variavelUSUARIO => _variavelUSUARIO;
  set variavelUSUARIO(DadosUsuarioStruct value) {
    _variavelUSUARIO = value;
    prefs.setString('ff_variavelUSUARIO', value.serialize());
  }

  void updateVariavelUSUARIOStruct(Function(DadosUsuarioStruct) updateFn) {
    updateFn(_variavelUSUARIO);
    prefs.setString('ff_variavelUSUARIO', _variavelUSUARIO.serialize());
  }

  String _emailPesquisa = 'Buscar email da empresa';
  String get emailPesquisa => _emailPesquisa;
  set emailPesquisa(String value) {
    _emailPesquisa = value;
  }

  DateTime? _dataAgora;
  DateTime? get dataAgora => _dataAgora;
  set dataAgora(DateTime? value) {
    _dataAgora = value;
  }

  DateTime? _dataProduto;
  DateTime? get dataProduto => _dataProduto;
  set dataProduto(DateTime? value) {
    _dataProduto = value;
  }

  int _idPagamento = 0;
  int get idPagamento => _idPagamento;
  set idPagamento(int value) {
    _idPagamento = value;
    prefs.setInt('ff_idPagamento', value);
  }

  DocumentReference? _referenciaGarantiaPagamento;
  DocumentReference? get referenciaGarantiaPagamento =>
      _referenciaGarantiaPagamento;
  set referenciaGarantiaPagamento(DocumentReference? value) {
    _referenciaGarantiaPagamento = value;
    value != null
        ? prefs.setString('ff_referenciaGarantiaPagamento', value.path)
        : prefs.remove('ff_referenciaGarantiaPagamento');
  }

  DateTime? _datanovagarantia;
  DateTime? get datanovagarantia => _datanovagarantia;
  set datanovagarantia(DateTime? value) {
    _datanovagarantia = value;
    value != null
        ? prefs.setInt('ff_datanovagarantia', value.millisecondsSinceEpoch)
        : prefs.remove('ff_datanovagarantia');
  }

  String _nomedouser = '';
  String get nomedouser => _nomedouser;
  set nomedouser(String value) {
    _nomedouser = value;
  }

  int _verificador = 0;
  int get verificador => _verificador;
  set verificador(int value) {
    _verificador = value;
  }

  int _geraros = 0;
  int get geraros => _geraros;
  set geraros(int value) {
    _geraros = value;
  }

  List<double> _instalacaoar = [];
  List<double> get instalacaoar => _instalacaoar;
  set instalacaoar(List<double> value) {
    _instalacaoar = value;
  }

  void addToInstalacaoar(double value) {
    instalacaoar.add(value);
  }

  void removeFromInstalacaoar(double value) {
    instalacaoar.remove(value);
  }

  void removeAtIndexFromInstalacaoar(int index) {
    instalacaoar.removeAt(index);
  }

  void updateInstalacaoarAtIndex(
    int index,
    double Function(double) updateFn,
  ) {
    instalacaoar[index] = updateFn(_instalacaoar[index]);
  }

  void insertAtIndexInInstalacaoar(int index, double value) {
    instalacaoar.insert(index, value);
  }

  FinanceiroStruct _FINANCEIRO = FinanceiroStruct();
  FinanceiroStruct get FINANCEIRO => _FINANCEIRO;
  set FINANCEIRO(FinanceiroStruct value) {
    _FINANCEIRO = value;
  }

  void updateFINANCEIROStruct(Function(FinanceiroStruct) updateFn) {
    updateFn(_FINANCEIRO);
  }

  ValoresFinanceiroStruct _VALORESFINAN = ValoresFinanceiroStruct();
  ValoresFinanceiroStruct get VALORESFINAN => _VALORESFINAN;
  set VALORESFINAN(ValoresFinanceiroStruct value) {
    _VALORESFINAN = value;
  }

  void updateVALORESFINANStruct(Function(ValoresFinanceiroStruct) updateFn) {
    updateFn(_VALORESFINAN);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
