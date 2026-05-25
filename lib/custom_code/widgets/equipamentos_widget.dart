// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// ─── Variável estática para expor o equipamento selecionado ──────────────────
class EquipamentoSelecionado {
  static Map<String, dynamic> dados = {};
  static String patrimonio = '';
  static String nome = '';
  static String email = '';
  static String numeroOS = '';
}

class EquipamentosWidget extends StatefulWidget {
  const EquipamentosWidget({
    super.key,
    this.width,
    this.height,
    required this.email,
    this.acaoSolicitar,
  });

  final double? width;
  final double? height;
  final String email;
  final Future<dynamic> Function()? acaoSolicitar;

  @override
  State<EquipamentosWidget> createState() => _EquipamentosWidgetState();
}

class _EquipamentosWidgetState extends State<EquipamentosWidget> {
  List<Map<String, dynamic>> _equipamentos = [];
  List<Map<String, dynamic>> _equipamentosFiltrados = [];
  Map<String, String> _imagensMap = {};
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _termoBusca = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _searchController.addListener(_filtrarComAtraso);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarComAtraso);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(EquipamentosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.email != oldWidget.email && widget.email.isNotEmpty) {
      _carregarDados();
    }
  }

  void _filtrarComAtraso() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final termo = _searchController.text.toLowerCase().trim();
      if (_termoBusca != termo) {
        setState(() {
          _termoBusca = termo;
          if (termo.isEmpty) {
            _equipamentosFiltrados = List.from(_equipamentos);
          } else {
            _equipamentosFiltrados = _equipamentos.where((eq) {
              final nome = (eq['NOME'] ?? eq['EQUIPAMENTO'] ?? '')
                  .toString()
                  .toLowerCase();
              final patrimonio =
                  (eq['PATRIMONIO'] ?? '').toString().toLowerCase();
              final marca = (eq['MARCA'] ?? '').toString().toLowerCase();
              final modelo = (eq['MODELO'] ?? '').toString().toLowerCase();
              final setor = (eq['SETOR'] ?? '').toString().toLowerCase();
              final sala = (eq['SALA'] ?? '').toString().toLowerCase();
              return nome.contains(termo) ||
                  patrimonio.contains(termo) ||
                  marca.contains(termo) ||
                  modelo.contains(termo) ||
                  setor.contains(termo) ||
                  sala.contains(termo);
            }).toList();
          }
        });
      }
    });
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;

    if (widget.email.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = _equipamentos.isEmpty;
      _error = null;
    });

    try {
      final equipamentosSnapshot = await FirebaseFirestore.instance
          .collection('EQUIPAMENTOS_EMPRESA')
          .where('EMAIL', isEqualTo: widget.email)
          .get();

      final equipamentos = equipamentosSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      final patrimonios = equipamentos
          .map((e) => e['PATRIMONIO']?.toString() ?? '')
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList();

      // Mantém o cache anterior para a imagem não piscar
      Map<String, String> imagensMap = Map.from(_imagensMap);

      if (patrimonios.isNotEmpty) {
        for (var i = 0; i < patrimonios.length; i += 30) {
          final fim =
              (i + 30 > patrimonios.length) ? patrimonios.length : i + 30;
          final lote = patrimonios.sublist(i, fim);

          final imagensSnapshot = await FirebaseFirestore.instance
              .collection('IMAGENS')
              .where('PATRIMONIO', whereIn: lote)
              .get();

          for (final doc in imagensSnapshot.docs) {
            final data = doc.data();
            final patrimonio = data['PATRIMONIO']?.toString() ?? '';
            final url = data['IMAGEM']?.toString() ?? '';
            if (patrimonio.isNotEmpty && url.isNotEmpty) {
              imagensMap[patrimonio] = url;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _equipamentos = equipamentos;
          _imagensMap = imagensMap;
          _isLoading = false;
        });

        final termo = _searchController.text.toLowerCase().trim();
        _termoBusca = termo;
        setState(() {
          if (termo.isEmpty) {
            _equipamentosFiltrados = List.from(_equipamentos);
          } else {
            _equipamentosFiltrados = _equipamentos.where((eq) {
              final nome = (eq['NOME'] ?? eq['EQUIPAMENTO'] ?? '')
                  .toString()
                  .toLowerCase();
              final patrimonio =
                  (eq['PATRIMONIO'] ?? '').toString().toLowerCase();
              final marca = (eq['MARCA'] ?? '').toString().toLowerCase();
              final modelo = (eq['MODELO'] ?? '').toString().toLowerCase();
              final setor = (eq['SETOR'] ?? '').toString().toLowerCase();
              final sala = (eq['SALA'] ?? '').toString().toLowerCase();
              return nome.contains(termo) ||
                  patrimonio.contains(termo) ||
                  marca.contains(termo) ||
                  modelo.contains(termo) ||
                  setor.contains(termo) ||
                  sala.contains(termo);
            }).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar dados: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onPrepararDados(Map<String, dynamic> eq, String proximoNumeroOs) {
    EquipamentoSelecionado.dados = Map<String, dynamic>.from(eq);
    EquipamentoSelecionado.patrimonio = eq['PATRIMONIO']?.toString() ?? '';
    EquipamentoSelecionado.nome =
        eq['NOME']?.toString() ?? eq['EQUIPAMENTO']?.toString() ?? '';
    EquipamentoSelecionado.email = widget.email;
    EquipamentoSelecionado.numeroOS = proximoNumeroOs;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            final isUnbounded = constraints.maxHeight == double.infinity;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ══════════════════════════════════════════════════════════
                // LINHA DA BARRA DE BUSCA + ÍCONE FECHAR À ESQUERDA
                // Mantém o mesmo visual do original. O ícone de fechar fica
                // colado à esquerda da barra de busca, bem visível.
                // ══════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 12, 4),
                  child: Row(
                    children: [
                      // ── Botão Fechar / Voltar ───────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.blueGrey.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ── Campo de Busca ──────────────────────────────────
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar equipamento...',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: Color(0xFF9E9E9E)),
                            prefixIcon: const Icon(Icons.search,
                                size: 20, color: Color(0xFF9E9E9E)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 18, color: Color(0xFF9E9E9E)),
                                    onPressed: () {
                                      _searchController.clear();
                                      FocusScope.of(context).unfocus();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1565C0), width: 1.5),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ── Botão Atualizar ─────────────────────────────────
                      GestureDetector(
                        onTap: _carregarDados,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.blueGrey.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 20,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Chip contador — igual ao original "124 equipamentos" ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.teal.withOpacity(0.25), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.devices_other,
                            size: 13, color: Colors.teal),
                        const SizedBox(width: 5),
                        Text(
                          '${_equipamentosFiltrados.length} equipamentos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Lista / estados de loading e erro ─────────────────────
                if (_isLoading && _equipamentos.isEmpty)
                  const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                else if (_termoBusca.isNotEmpty &&
                    _equipamentosFiltrados.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Color(0xFFBDBDBD)),
                          SizedBox(height: 10),
                          Text(
                            'Nenhum resultado encontrado',
                            style: TextStyle(
                                color: Color(0xFF757575), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isUnbounded)
                  _buildList(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics())
                else
                  Expanded(child: _buildList()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList({bool shrinkWrap = false, ScrollPhysics? physics}) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      itemCount: _equipamentosFiltrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final eq = _equipamentosFiltrados[index];
        final patrimonio = eq['PATRIMONIO']?.toString() ?? index.toString();
        final imageUrl = _imagensMap[patrimonio];
        return _EquipamentoCard(
          key: ValueKey('eq_$patrimonio'),
          equipamento: eq,
          imageUrl: imageUrl,
          termoBusca: _termoBusca,
          acaoSolicitar: widget.acaoSolicitar,
          onPrepararDados: _onPrepararDados,
          // Passa o mapa inteiro — card relê após voltar da tela
          imagensMap: _imagensMap,
        );
      },
    );
  }
}

// ─── Card do Equipamento ──────────────────────────────────────────────────────

class _EquipamentoCard extends StatefulWidget {
  const _EquipamentoCard({
    super.key,
    required this.equipamento,
    this.imageUrl,
    this.acaoSolicitar,
    required this.onPrepararDados,
    this.termoBusca = '',
    required this.imagensMap,
  });

  final Map<String, dynamic> equipamento;
  final String? imageUrl;
  final Future<dynamic> Function()? acaoSolicitar;
  final void Function(Map<String, dynamic>, String) onPrepararDados;
  final String termoBusca;
  final Map<String, String> imagensMap;

  @override
  State<_EquipamentoCard> createState() => _EquipamentoCardState();
}

class _EquipamentoCardState extends State<_EquipamentoCard> {
  bool _expandido = false;
  bool _gerandoOs = false;

  // ══════════════════════════════════════════════════════════════════════════
  // LÓGICA COMPLETA DO BOTÃO GERAR O.S — portada do CadastrarOsWidget
  // • Ordena por DATA desc para pegar a última OS
  // • Começa em 1000 se não houver nenhuma
  // • Loop de verificação de duplicidade até achar número livre
  // • setState() após retorno da tela para recuperar imagem do mapa
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _gerarOsSequencial() async {
    setState(() => _gerandoOs = true);
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    try {
      // 1. Busca a última OS criada ordenando por DATA decrescente
      final snap = await FirebaseFirestore.instance
          .collection('SERVICOSREALIZADOS')
          .orderBy('DATA', descending: true)
          .limit(1)
          .get();

      int proximoNumero = 1000; // Inicia em 1000 caso não exista nenhuma O.S

      if (snap.docs.isNotEmpty) {
        final lastOsStr =
            snap.docs.first.data()['NUMERODAOS']?.toString() ?? '';
        final lastOsInt = int.tryParse(lastOsStr);
        if (lastOsInt != null) {
          proximoNumero = lastOsInt + 1;
        }
      }

      // 2. Verifica duplicidade — incrementa até achar número livre
      while (true) {
        final check = await FirebaseFirestore.instance
            .collection('SERVICOSREALIZADOS')
            .where('NUMERODAOS', isEqualTo: proximoNumero.toString())
            .limit(1)
            .get();
        if (check.docs.isEmpty) break;
        proximoNumero++;
      }

      // 3. Prepara dados do equipamento com o número da OS gerado
      widget.onPrepararDados(widget.equipamento, proximoNumero.toString());

      await Future.delayed(const Duration(milliseconds: 250));

      // 4. Executa a ação do FlutterFlow (abre tela seguinte)
      if (mounted && widget.acaoSolicitar != null) {
        await widget.acaoSolicitar!();
      }

      // 5. Ao retornar (cancelou ou confirmou), força rebuild para
      //    recuperar a imagem do mapa em memória — corrige sumiço
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Erro ao gerar OS: $e');
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar O.S: $e'),
            duration: const Duration(milliseconds: 3000),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoOs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eq = widget.equipamento;

    final nome =
        eq['NOME']?.toString() ?? eq['EQUIPAMENTO']?.toString() ?? 'Sem nome';
    final patrimonio = eq['PATRIMONIO']?.toString() ?? '—';
    final marca = eq['MARCA']?.toString() ?? '—';
    final modelo = eq['MODELO']?.toString() ?? '—';
    final setor = eq['SETOR']?.toString() ?? '—';
    final sala = eq['SALA']?.toString() ?? '—';
    final tensao = eq['TENSAO']?.toString();
    final btus = eq['BTUS']?.toString();
    final fluido = eq['FLUIDO']?.toString();
    final tipo = eq['TIPO']?.toString();
    final responsavel = eq['RESPONSAVEL']?.toString();
    final contrato = eq['CONTRATO'];

    // Relê sempre do mapa em memória — nunca perde a URL ao voltar da tela
    final imageUrl = widget.imagensMap[eq['PATRIMONIO']?.toString() ?? ''] ??
        widget.imageUrl;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagemEquipamento(imageUrl: imageUrl),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _TextoDestacado(
                              texto: nome,
                              termo: widget.termoBusca,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                            ),
                          ),
                          if (contrato == true)
                            const _Badge(
                                label: 'Contrato',
                                color: Colors.green,
                                icon: Icons.verified_outlined),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(Icons.tag, 'Patrimônio', patrimonio,
                          termo: widget.termoBusca),
                      _InfoRow(Icons.business, 'Marca', marca,
                          termo: widget.termoBusca),
                      _InfoRow(Icons.device_hub, 'Modelo', modelo,
                          termo: widget.termoBusca),
                      _InfoRow(Icons.location_on_outlined, 'Setor', setor,
                          termo: widget.termoBusca),
                      if (tipo != null) ...[
                        const SizedBox(height: 4),
                        _Badge(
                            label: tipo,
                            color: Colors.blue,
                            icon: Icons.label_outline),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_expandido)
            Container(
              width: double.infinity,
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12),
                  const Text(
                    'DETALHES TÉCNICOS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(Icons.meeting_room_outlined, 'Sala', sala),
                  if (responsavel != null)
                    _InfoRow(Icons.person_outline, 'Responsável', responsavel),
                  if (tensao != null) _InfoRow(Icons.bolt, 'Tensão', tensao),
                  if (btus != null) _InfoRow(Icons.ac_unit, 'BTUs', btus),
                  if (fluido != null)
                    _InfoRow(Icons.water_drop, 'Fluido Refrigerante', fluido),
                ],
              ),
            ),
          Material(
            color: const Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _expandido = !_expandido),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _expandido ? 'Ocultar detalhes' : 'Ver detalhes',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _expandido
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.acaoSolicitar != null) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: _gerandoOs ? null : _gerarOsSequencial,
                        icon: _gerandoOs
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.assignment_add, size: 14),
                        label: Text(
                          _gerandoOs ? 'Gerando...' : 'Gerar O.S',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Texto com highlight da busca ─────────────────────────────────────────────

class _TextoDestacado extends StatelessWidget {
  const _TextoDestacado({
    required this.texto,
    required this.termo,
    required this.style,
    this.maxLines,
  });
  final String texto;
  final String termo;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (termo.isEmpty) {
      return Text(texto,
          style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final lowerTexto = texto.toLowerCase();
    final lowerTermo = termo.toLowerCase();
    final spans = <TextSpan>[];
    int inicio = 0;

    while (true) {
      final idx = lowerTexto.indexOf(lowerTermo, inicio);
      if (idx == -1) {
        spans.add(TextSpan(text: texto.substring(inicio)));
        break;
      }
      if (idx > inicio) {
        spans.add(TextSpan(text: texto.substring(inicio, idx)));
      }
      spans.add(TextSpan(
        text: texto.substring(idx, idx + termo.length),
        style: TextStyle(
          backgroundColor: Colors.yellow.withAlpha(180),
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ));
      inicio = idx + termo.length;
    }

    return Text.rich(
      TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─── Imagem do equipamento ────────────────────────────────────────────────────

class _ImagemEquipamento extends StatelessWidget {
  const _ImagemEquipamento({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 155,
      child: Container(
        color: const Color(0xFFEEEEEE),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 36, color: Color(0xFFBDBDBD)),
                ),
              )
            : const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    size: 36, color: Color(0xFFBDBDBD)),
              ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value, {this.termo = ''});
  final IconData icon;
  final String label;
  final String value;
  final String termo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 4),
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          Expanded(
            child: _TextoDestacado(
              texto: value,
              termo: termo,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.icon});
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
