import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '/components/esplicao_tela_h_o_m_e_buscar_widget.dart';
import '/components/esplicao_chat_widget.dart';

// Focus widget keys for this walkthrough
final container345cov0g = GlobalKey();
final floatingActionButtonRykuqwpv = GlobalKey();

/// HOME
///
///
List<TargetFocus> createWalkthroughTargets(BuildContext context) => [
      /// Step 1
      TargetFocus(
        keyTarget: container345cov0g,
        enableOverlayTab: true,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        color: Colors.black,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, __) => EsplicaoTelaHOMEBuscarWidget(),
          ),
        ],
      ),

      /// chat
      TargetFocus(
        keyTarget: floatingActionButtonRykuqwpv,
        enableOverlayTab: true,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        color: Colors.black,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, __) => EsplicaoChatWidget(),
          ),
        ],
      ),
    ];
