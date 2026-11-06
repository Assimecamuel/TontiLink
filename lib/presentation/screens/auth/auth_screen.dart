import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isOtpStep = false;
  String phone = '';
  String otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TontiColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Marque
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TontiColors.primaryGold, TontiColors.darkGold],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: TontiColors.primaryGold.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.diversity_3_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    text: 'Tonti',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: TontiColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Link',
                        style: TextStyle(
                          color: TontiColors.primaryGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Transparence, sécurité et traditions camerounaises',
                  style: TextStyle(
                    fontSize: 13,
                    color: TontiColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Carte du formulaire
                TontiCard(
                  padding: const EdgeInsets.all(28),
                  child: isOtpStep ? _buildOtpForm() : _buildPhoneForm(),
                ),
                const SizedBox(height: 20),

                // Lien basculer Connexion / Inscription
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                      isOtpStep = false;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Pas encore de compte ? Créer un compte'
                        : 'Déjà inscrit ? Se connecter',
                    style: const TextStyle(
                      color: TontiColors.darkGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLogin ? 'Connexion sécurisée' : 'Créer votre compte',
          style: TontiTypography.headingLarge,
        ),
        const SizedBox(height: 6),
        Text(
          isLogin
              ? 'Entrez votre numéro de téléphone pour recevoir le code OTP.'
              : 'Rejoignez votre groupe de tontine en quelques secondes.',
          style: TontiTypography.bodySmall,
        ),
        const SizedBox(height: 24),
        if (!isLogin) ...[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              hintText: 'Nom complet',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextFormField(
          initialValue: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Numéro de téléphone (+237)',
            prefixText: '+237 ',
            prefixIcon: Icon(Icons.phone_outlined, color: TontiColors.primaryGold),
          ),
          onChanged: (v) => phone = v,
        ),
        const SizedBox(height: 24),
        TontiButton(
          label: 'Recevoir le code SMS / WhatsApp',
          isFullWidth: true,
          icon: Icons.send_rounded,
          onPressed: () => setState(() => isOtpStep = true),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => isOtpStep = false),
            ),
            const SizedBox(width: 8),
            Text('Vérification OTP', style: TontiTypography.headingMedium),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Un code de confirmation a été envoyé au +237 $phone.',
          style: TontiTypography.bodySmall,
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: otp,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(
            labelText: 'Code à 4 chiffres',
            hintText: '••••',
          ),
        ),
        const SizedBox(height: 24),
        TontiButton(
          label: 'Confirmer & Accéder à TontiLink',
          isFullWidth: true,
          icon: Icons.lock_open_rounded,
          onPressed: widget.onLoginSuccess,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('Renvoyer le code SMS', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

