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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

class PoliticaPrivacidadeWidget extends StatefulWidget {
  const PoliticaPrivacidadeWidget({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  State<PoliticaPrivacidadeWidget> createState() =>
      _PoliticaPrivacidadeWidgetState();
}

class _PoliticaPrivacidadeWidgetState extends State<PoliticaPrivacidadeWidget> {
  static const Color _primary = Color(0xFF39D2C0);
  static const Color _verde = Color(0xFF1A3C34);

  // Secoes expansiveis
  final Map<int, bool> _expandido = {};

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF151A22) : const Color(0xFFF4F6F8);
    final cardColor = isDark ? const Color(0xFF1E2530) : Colors.white;
    final textColor = theme.primaryText;
    final subColor = theme.secondaryText;

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: bgColor,
      child: Column(children: [
        // ── Header ───────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [_primary, const Color(0xFF1A1A2E)]
                  : [_primary, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 17,
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withOpacity(0.4), width: 2),
              ),
              child:
                  const Icon(Icons.shield_rounded, color: _primary, size: 30),
            ),
            const SizedBox(height: 12),
            Text('Política de Privacidade',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text('HPS Refrigeração',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Última atualização: 19 de abril de 2026',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _primary : _verde)),
            ),
          ]),
        ),

        // ── Conteudo ──────────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Introducao
              _card(cardColor, isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tituloSecao(
                          'Introdução', Icons.info_outline_rounded, textColor),
                      const SizedBox(height: 10),
                      _paragrafo(
                        'A HPS Refrigeração ("nós", "nosso" ou "empresa") está comprometida '
                        'em proteger a privacidade dos usuários do aplicativo de Gestão de '
                        'Ordens de Serviço ("App"). Esta Política de Privacidade descreve como '
                        'coletamos, usamos, armazenamos e protegemos suas informações pessoais '
                        'de acordo com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018) '
                        'e as políticas do Google Play.',
                        subColor,
                      ),
                    ],
                  )),

              const SizedBox(height: 12),

              // Dados coletados
              _secaoExpansivel(
                index: 0,
                titulo: 'Dados que Coletamos',
                icone: Icons.storage_outlined,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subtitulo('Dados fornecidos pelo usuário:', subColor),
                    _item('Nome completo ou razão social', subColor),
                    _item('Endereço de e-mail', subColor),
                    _item('Número de telefone', subColor),
                    _item('CNPJ (para clientes empresariais)', subColor),
                    _item('Endereço físico', subColor),
                    _item('Foto de perfil (opcional)', subColor),
                    const SizedBox(height: 10),
                    _subtitulo('Dados gerados automaticamente:', subColor),
                    _item('Informações de ordens de serviço (OS)', subColor),
                    _item('Registros de acesso e atividade no app', subColor),
                    _item('Tokens de notificação push (OneSignal)', subColor),
                    _item(
                        'Dados de dispositivo e sistema operacional', subColor),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Como usamos
              _secaoExpansivel(
                index: 1,
                titulo: 'Como Usamos os Dados',
                icone: Icons.settings_outlined,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _item(
                        'Gerenciar e executar ordens de serviço de manutenção',
                        subColor),
                    _item(
                        'Enviar notificações sobre status de serviços e alertas importantes',
                        subColor),
                    _item(
                        'Comunicação por e-mail sobre relatórios e atualizações',
                        subColor),
                    _item('Autenticação e segurança da conta', subColor),
                    _item('Gerar relatórios de manutenção preventiva em PDF',
                        subColor),
                    _item('Melhorar a experiência do usuário no aplicativo',
                        subColor),
                    _item('Cumprir obrigações legais e contratuais', subColor),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Compartilhamento
              _secaoExpansivel(
                index: 2,
                titulo: 'Compartilhamento de Dados',
                icone: Icons.share_outlined,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _paragrafo(
                      'Não vendemos, alugamos ou compartilhamos seus dados pessoais '
                      'com terceiros para fins comerciais. Compartilhamos dados apenas com:',
                      subColor,
                    ),
                    const SizedBox(height: 8),
                    _itemDestaque(
                        'Firebase (Google)',
                        'Autenticação, banco de dados e armazenamento de arquivos',
                        subColor),
                    _itemDestaque(
                        'OneSignal', 'Envio de notificações push', subColor),
                    _itemDestaque('Brevo (Sendinblue)',
                        'Envio de e-mails transacionais', subColor),
                    const SizedBox(height: 8),
                    _paragrafo(
                      'Todos os parceiros são obrigados a manter a confidencialidade '
                      'dos dados e utilizá-los apenas para os fins contratados.',
                      subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Armazenamento
              _secaoExpansivel(
                index: 3,
                titulo: 'Armazenamento e Segurança',
                icone: Icons.lock_outline_rounded,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _paragrafo(
                      'Seus dados são armazenados em servidores seguros do Google Firebase '
                      'com criptografia em trânsito (TLS/SSL) e em repouso. Adotamos '
                      'medidas técnicas e organizacionais adequadas para proteger seus '
                      'dados contra acesso não autorizado, perda ou destruição.',
                      subColor,
                    ),
                    const SizedBox(height: 10),
                    _subtitulo('Retenção de dados:', subColor),
                    _item(
                        'Dados de conta: mantidos enquanto a conta estiver ativa',
                        subColor),
                    _item(
                        'Registros de OS: mantidos por 5 anos conforme legislação fiscal',
                        subColor),
                    _item('Logs de acesso: mantidos por 6 meses', subColor),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Direitos do usuario
              _secaoExpansivel(
                index: 4,
                titulo: 'Seus Direitos (LGPD)',
                icone: Icons.verified_user_outlined,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _paragrafo(
                      'Conforme a Lei Geral de Proteção de Dados (LGPD), você tem direito a:',
                      subColor,
                    ),
                    const SizedBox(height: 8),
                    _item('Confirmar a existência de tratamento de seus dados',
                        subColor),
                    _item('Acessar seus dados pessoais', subColor),
                    _item(
                        'Corrigir dados incompletos, inexatos ou desatualizados',
                        subColor),
                    _item(
                        'Solicitar a anonimização, bloqueio ou eliminação de dados',
                        subColor),
                    _item('Solicitar a portabilidade dos dados', subColor),
                    _item(
                        'Revogar o consentimento a qualquer momento', subColor),
                    _item(
                        'Opor-se ao tratamento em caso de descumprimento da LGPD',
                        subColor),
                    const SizedBox(height: 8),
                    _paragrafo(
                      'Para exercer seus direitos, entre em contato pelo e-mail: '
                      'hpsrefri@gmail.com',
                      subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Notificacoes
              _secaoExpansivel(
                index: 5,
                titulo: 'Notificações Push',
                icone: Icons.notifications_outlined,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _paragrafo(
                      'O aplicativo pode enviar notificações push sobre atualizações '
                      'de ordens de serviço, relatórios e comunicados importantes. '
                      'Você pode desativar as notificações a qualquer momento nas '
                      'configurações do seu dispositivo.',
                      subColor,
                    ),
                    const SizedBox(height: 8),
                    _paragrafo(
                      'As notificações são gerenciadas pelo serviço OneSignal, '
                      'que processa apenas o token do dispositivo para entrega das mensagens.',
                      subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Permissoes
              _secaoExpansivel(
                index: 6,
                titulo: 'Permissões do Aplicativo',
                icone: Icons.phonelink_setup_outlined,
                textColor: textColor,
                subColor: subColor,
                cardColor: cardColor,
                isDark: isDark,
                conteudo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _itemDestaque(
                        'Câmera / Galeria',
                        'Para envio de fotos de equipamentos e foto de perfil',
                        subColor),
                    _itemDestaque(
                        'Armazenamento',
                        'Para salvar relatórios em PDF no dispositivo',
                        subColor),
                    _itemDestaque(
                        'Internet',
                        'Para sincronização de dados e envio de notificações',
                        subColor),
                    _itemDestaque(
                        'Notificações',
                        'Para receber alertas sobre ordens de serviço',
                        subColor),
                    const SizedBox(height: 8),
                    _paragrafo(
                      'Nenhuma permissão é utilizada para fins diferentes dos descritos acima.',
                      subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Criancas
              _card(cardColor, isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tituloSecao('Público-Alvo', Icons.people_outline_rounded,
                          textColor),
                      const SizedBox(height: 10),
                      _paragrafo(
                        'Este aplicativo é destinado exclusivamente a usuários maiores de 18 anos, '
                        'no contexto de atividades profissionais de gestão de manutenção. '
                        'Não coletamos intencionalmente dados de menores de idade. '
                        'Caso identifiquemos dados de menor coletados sem consentimento, '
                        'excluiremos imediatamente.',
                        subColor,
                      ),
                    ],
                  )),

              const SizedBox(height: 12),

              // Alteracoes
              _card(cardColor, isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tituloSecao('Alterações nesta Política',
                          Icons.update_rounded, textColor),
                      const SizedBox(height: 10),
                      _paragrafo(
                        'Podemos atualizar esta Política de Privacidade periodicamente. '
                        'Notificaremos sobre mudanças significativas através do aplicativo '
                        'ou por e-mail. O uso continuado do aplicativo após as alterações '
                        'constitui aceitação da nova política.',
                        subColor,
                      ),
                    ],
                  )),

              const SizedBox(height: 12),

              // Contato
              _card(cardColor, isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tituloSecao('Contato e DPO',
                          Icons.contact_support_outlined, textColor),
                      const SizedBox(height: 10),
                      _paragrafo(
                        'Para dúvidas, solicitações ou exercício dos seus direitos relacionados '
                        'a esta Política de Privacidade, entre em contato com nosso '
                        'Encarregado de Proteção de Dados (DPO):',
                        subColor,
                      ),
                      const SizedBox(height: 12),
                      _infoContato(Icons.business_rounded, 'Empresa',
                          'HPS Refrigeração', textColor, subColor),
                      _infoContato(Icons.email_outlined, 'E-mail',
                          'hpsrefri@gmail.com', textColor, subColor),
                      _infoContato(Icons.language_rounded, 'Site',
                          'hpsrefri.com.br', textColor, subColor),
                      _infoContato(Icons.location_on_outlined, 'CNPJ',
                          '28.340.152/0001-52', textColor, subColor),
                    ],
                  )),

              const SizedBox(height: 12),

              // Rodape legal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primary.withOpacity(0.2)),
                ),
                child: Column(children: [
                  const Icon(Icons.gavel_rounded, color: _primary, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    'Esta política está em conformidade com a LGPD (Lei nº 13.709/2018), '
                    'o Marco Civil da Internet (Lei nº 12.965/2014) e as diretrizes '
                    'de privacidade do Google Play.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11, color: subColor, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text('© 2026 HPS Refrigeração — Todos os direitos reservados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primary)),
                ]),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _card(Color cardColor, bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _secaoExpansivel({
    required int index,
    required String titulo,
    required IconData icone,
    required Color textColor,
    required Color subColor,
    required Color cardColor,
    required bool isDark,
    required Widget conteudo,
  }) {
    final aberto = _expandido[index] ?? false;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expandido[index] = !aberto),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: _primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(titulo,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor))),
              AnimatedRotation(
                turns: aberto ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: _primary, size: 22),
              ),
            ]),
          ),
        ),
        if (aberto) ...[
          Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: conteudo,
          ),
        ],
      ]),
    );
  }

  Widget _tituloSecao(String titulo, IconData icone, Color textColor) {
    return Row(children: [
      Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icone, color: _primary, size: 18)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(titulo,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor))),
    ]);
  }

  Widget _paragrafo(String texto, Color subColor) {
    return Text(texto,
        style: TextStyle(fontSize: 13, color: subColor, height: 1.65));
  }

  Widget _subtitulo(String texto, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(texto,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: subColor.withOpacity(0.85))),
    );
  }

  Widget _item(String texto, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: BoxDecoration(color: _primary, shape: BoxShape.circle)),
        Expanded(
            child: Text(texto,
                style: TextStyle(fontSize: 13, color: subColor, height: 1.5))),
      ]),
    );
  }

  Widget _itemDestaque(String titulo, String descricao, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: BoxDecoration(color: _primary, shape: BoxShape.circle)),
        Expanded(
            child: RichText(
                text: TextSpan(children: [
          TextSpan(
              text: '$titulo: ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: subColor.withOpacity(0.9))),
          TextSpan(
              text: descricao,
              style: TextStyle(fontSize: 13, color: subColor, height: 1.5)),
        ]))),
      ]),
    );
  }

  Widget _infoContato(IconData icon, String label, String valor,
      Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, color: _primary, size: 16),
        const SizedBox(width: 10),
        Text('$label: ',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: subColor)),
        Expanded(
            child:
                Text(valor, style: TextStyle(fontSize: 13, color: textColor))),
      ]),
    );
  }
}
