import 'package:flutter/material.dart';
import 'core/i18n/l10n.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/landing/landing_screen.dart';
import 'presentation/screens/shell_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TontiLinkApp());
}

class TontiLinkApp extends StatefulWidget {
  const TontiLinkApp({super.key});

  @override
  State<TontiLinkApp> createState() => _TontiLinkAppState();
}

class _TontiLinkAppState extends State<TontiLinkApp> {
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
          title: 'TontiLink',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Le thème sombre s'applique aux pages publiques (accueil, connexion).
          themeMode: authenticated ? ThemeMode.light : _themeController.mode,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: true,
          ),
          home: home,
        );
      },
    );
  }
}
