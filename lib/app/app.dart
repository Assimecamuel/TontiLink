import 'package:flutter/material.dart';

import '../core/theme/tonti_theme.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import 'shell_navigation_screen.dart';

class TontiLinkApp extends StatefulWidget {
  const TontiLinkApp({super.key});

  @override
  State<TontiLinkApp> createState() => _TontiLinkAppState();
}

class _TontiLinkAppState extends State<TontiLinkApp> {
  bool _isAuthenticated = true; // Par défaut connecté pour tester directement le Dashboard

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TontiLink - FinTech Africaine & Gestion de Tontines',
      debugShowCheckedModeBanner: false,
      theme: TontiTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
      ),
      home: _isAuthenticated
          ? const ShellNavigationScreen()
          : AuthScreen(
              onLoginSuccess: () {
                setState(() => _isAuthenticated = true);
              },
            ),
    );
  }
}
