import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/i18n/l10n.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/landing/landing_screen.dart';
import 'presentation/screens/shell_navigation_screen.dart';

class TontiHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    HttpOverrides.global = TontiHttpOverrides();
  }
  runApp(const TontiLinkApp());
}

class TontiLinkApp extends StatefulWidget {
  const TontiLinkApp({super.key});

  @override
  State<TontiLinkApp> createState() => _TontiLinkAppState();
}

class _TontiLinkAppState extends State<TontiLinkApp> with WidgetsBindingObserver {
  final AuthController _authController = AuthController();
  final ThemeController _themeController = ThemeController.instance;
  final L10n _l10n = L10n.instance;

  // Pages publiques : accueil -> connexion / création de compte
  bool _showAuthPage = false;
  bool _startInRegisterMode = false;

  void _openAuth({required bool register}) {
    setState(() {
      _startInRegisterMode = register;
      _showAuthPage = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authController.dispose();
    super.dispose();
  }

  /// Le téléphone / navigateur passe en mode sombre ou clair : en mode
  /// « Système », toute l'interface doit suivre immédiatement.
  @override
  void didChangePlatformBrightness() {
    _themeController.onPlatformBrightnessChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_authController, _themeController, _l10n]),
      builder: (context, _) {
        final authenticated = _authController.isAuthenticated;

        Widget home;
        if (authenticated) {
          home = const ShellNavigationScreen();
        } else if (_showAuthPage) {
          home = LoginScreen(
            // La clé force la création d'un nouvel état selon l'onglet demandé.
            key: ValueKey<bool>(_startInRegisterMode),
            initialRegister: _startInRegisterMode,
            onBack: () => setState(() => _showAuthPage = false),
            onLoginSuccess: () => setState(() => _showAuthPage = false),
          );
        } else {
          home = LandingScreen(
            onLogin: () => _openAuth(register: false),
            onSignup: () => _openAuth(register: true),
          );
        }

        return MaterialApp(
          // Titre de l'onglet du navigateur : suit la langue choisie.
          onGenerateTitle: (_) => tr('app_title'),
          title: tr('TontiLink'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Le thème sombre s'applique harmonieusement sur toute l'application.
          themeMode: _themeController.mode,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: true,
          ),
          home: home,
        );
      },
    );
  }
}
