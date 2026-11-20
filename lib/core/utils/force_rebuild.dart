import 'package:flutter/widgets.dart';

/// Force la reconstruction de TOUT l'arbre de widgets (écrans, dialogues,
/// widgets `const`…) tout en conservant l'état des écrans.
///
/// Nécessaire quand la langue ou le thème changent : les textes et couleurs
/// sont lus depuis des singletons globaux ([L10n], [AppColors]) et non depuis
/// le contexte, donc Flutter ne sait pas de lui-même qu'il faut redessiner.
class ForceRebuild {
  ForceRebuild._();

  static bool _scheduled = false;

  static void run() {
    if (_scheduled) return;
    _scheduled = true;
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      _scheduled = false;
      final root = binding.rootElement;
      if (root == null) return;
      void rebuild(Element el) {
        el.markNeedsBuild();
        el.visitChildren(rebuild);
      }

      root.visitChildren(rebuild);
    });
    // Garantit qu'une frame est produite même si rien d'autre n'est « sale ».
    binding.scheduleFrame();
  }
}
