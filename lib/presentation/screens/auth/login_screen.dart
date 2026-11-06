import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/public_palette.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/flag_icon.dart';
import '../../widgets/common/public_controls.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../widgets/common/tonti_button.dart';

/// Page de connexion / création de compte (thème Or & Blanc, clair ou sombre).
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onBack;
  final bool initialRegister;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    this.onBack,
    this.initialRegister = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Parcours d'inscription : créer sa tontine (président) ou rejoindre via code.
enum _RegisterIntention { create, join }

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();

  _RegisterIntention? registerIntention;
  final TextEditingController inviteCodeController = TextEditingController();

  late bool isLoginMode;
  bool isOtpStep = false;
  bool obscurePassword = true;
  bool isSubmitting = false;
  bool rememberMe = true;
  bool acceptTerms = true;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String detectedOperator = 'MTN';

  @override
  void initState() {
    super.initState();
    isLoginMode = !widget.initialRegister;
    _detectOperator(phoneController.text);
    phoneController.addListener(() => _detectOperator(phoneController.text));
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    emailController.dispose();
    otpController.dispose();
    inviteCodeController.dispose();
    super.dispose();
  }

  void _detectOperator(String text) {
    final clean = text.replaceAll(RegExp(r'\D'), '');
    String op = '';
    if (clean.startsWith('67') ||
        clean.startsWith('68') ||
        clean.startsWith('650') ||
        clean.startsWith('651') ||
        clean.startsWith('652') ||
        clean.startsWith('653') ||
        clean.startsWith('654')) {
      op = 'MTN';
    } else if (clean.startsWith('69') ||
        clean.startsWith('655') ||
        clean.startsWith('656') ||
        clean.startsWith('657') ||
        clean.startsWith('658') ||
        clean.startsWith('659')) {
      op = 'Orange';
    } else if (clean.startsWith('62')) {
      op = 'Camtel';
    }

    if (op != detectedOperator) {
      setState(() => detectedOperator = op);
    }
  }

  // ------------------------------------------------------------------ Build

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: isDesktop ? _buildDesktop(p) : _buildMobile(p),
      ),
    );
  }

  Widget _buildDesktop(Pal p) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(flex: 5, child: _buildHeroPanel()),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 48),
                      isOtpStep ? _buildOtpView(p) : _buildFormView(p),
                      const SizedBox(height: 28),
        
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(Pal p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 28),
              isOtpStep ? _buildOtpView(p) : _buildFormView(p),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  /// Barre du haut : logo, thème (soleil / lune), langue (FR / EN) et retour à l'accueil.
  Widget _buildTopBar() {
    final p = Pal.of(context);
    return Row(
      children: [
        Flexible(
          child: TontiLogo(
            size: 38,
            showText: MediaQuery.of(context).size.width >= 520,
          ),
        ),
        const Spacer(),
        const ThemeToggleButton(),
        const SizedBox(width: 10),
        const LanguageDropdown(),
        if (widget.onBack != null) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: tr('back'),
            onPressed: widget.onBack,
            icon: Icon(Icons.arrow_back_rounded, color: p.goldText),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------ Panneau Or

  Widget _buildHeroPanel() {
    Widget chip(String label) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        );

    Widget bullet(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldAccent, AppColors.primaryGold, AppColors.deepGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(44),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(0.0, c.maxHeight - 88)),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.diversity_3_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'TontiLink',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      tr('login_hero_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('login_hero_sub'),
                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [chip(tr('chip1')), chip(tr('chip2'))],
                    ),
                    const SizedBox(height: 28),
                    bullet(Icons.lock_clock, tr('bul1')),
                    bullet(Icons.phone_android, tr('bul2')),
                    bullet(Icons.gavel, tr('bul3')),
                    const Spacer(),
                    Text(
                      tr('panel_foot'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------ Formulaire

  Widget _buildFormView(Pal p) {
    String operatorLabel() {
      if (detectedOperator == 'MTN') return 'MTN MoMo';
      if (detectedOperator == 'Orange') return 'Orange Money';
      return detectedOperator;
    }

    return Container(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Onglets Connexion / Inscription
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeTab(
                    p,
                    title: tr('tab_login'),
                    isSelected: isLoginMode,
                    onTap: () => setState(() => isLoginMode = true),
                  ),
                ),
                Expanded(
                  child: _buildModeTab(
                    p,
                    title: tr('tab_signup'),
                    isSelected: !isLoginMode,
                    onTap: () => setState(() {
                      isLoginMode = false;
                      registerIntention = null;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          Text(
            isLoginMode ? tr('title_login') : tr('title_signup'),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: p.text,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isLoginMode ? tr('sub_login') : tr('sub_signup'),
            style: TextStyle(fontSize: 15, height: 1.5, color: p.muted),
          ),
          const SizedBox(height: 26),

          if (!isLoginMode && registerIntention == null)
            ..._buildIntentionChoice(p)
          else ...[
          if (!isLoginMode) ...[
            _buildIntentionBanner(p),
            const SizedBox(height: 14),
            TextFormField(
              controller: nameController,
              style: TextStyle(color: p.text),
              decoration: InputDecoration(
                labelText: tr('f_name'),
                hintText: tr('f_name_hint'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              style: TextStyle(color: p.text),
              decoration: InputDecoration(
                labelText: tr('f_email'),
                hintText: tr('f_email_hint'),
                prefixIcon: const Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            if (registerIntention == _RegisterIntention.join) ...[
              TextFormField(
                controller: inviteCodeController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(color: p.text),
                decoration: InputDecoration(
                  labelText: tr('f_invite_code'),
                  hintText: tr('f_invite_code_hint'),
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],

          // Téléphone ou E-mail (identifiant) / Téléphone Cameroun en inscription
          TextFormField(
            controller: phoneController,
            keyboardType: isLoginMode ? TextInputType.text : TextInputType.phone,
            style: TextStyle(color: p.text),
            decoration: InputDecoration(
              labelText: isLoginMode ? 'Téléphone ou E-mail' : tr('f_phone'),
              prefixIcon: !isLoginMode
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FlagIcon(flag: FlagType.cameroon, width: 24),
                          const SizedBox(width: 6),
                          Text(
                            '+237',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: p.text),
                          ),
                        ],
                      ),
                    )
                  : const Icon(Icons.person_outline),
              suffixIcon: (!isLoginMode && detectedOperator.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TontiBadge(
                        label: operatorLabel(),
                        variant: detectedOperator == 'Orange' ? BadgeVariant.warning : BadgeVariant.gold,
                        isSmall: true,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: TextStyle(color: p.text),
            decoration: InputDecoration(
              labelText: tr('f_password'),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 22,
                ),
                onPressed: () => setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (isLoginMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: AppColors.primaryGold,
                        onChanged: (v) => setState(() => rememberMe = v ?? true),
                      ),
                      Flexible(
                        child: Text(tr('remember'), style: TextStyle(fontSize: 13, color: p.text)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: Text(
                    tr('forgot'),
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.goldText),
                  ),
                ),
              ],
            )
          else
            CheckboxListTile(
              value: acceptTerms,
              activeColor: AppColors.primaryGold,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(tr('terms'), style: TextStyle(fontSize: 12.5, color: p.text)),
              onChanged: (v) => setState(() => acceptTerms = v ?? true),
            ),

          const SizedBox(height: 14),

          TontiButton(
            label: isLoginMode ? tr('btn_login') : tr('btn_signup'),
            icon: isLoginMode ? Icons.login : Icons.arrow_forward,
            isFullWidth: true,
            height: 52,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : _handleSubmit,
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                isLoginMode = !isLoginMode;
                registerIntention = null;
              }),
              child: Text(
                isLoginMode ? tr('no_account') : tr('have_account'),
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.goldText),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 14, color: p.muted),
                const SizedBox(width: 6),
                Text(tr('secure_note'), style: TextStyle(fontSize: 12.5, color: p.muted)),
              ],
            ),
          ),
          ],
        ],
      ),
    );
  }

  /// Étape 0 de l'inscription : créer sa tontine ou participer à une tontine.
  List<Widget> _buildIntentionChoice(Pal p) {
    Widget card(IconData icon, String title, String desc, _RegisterIntention value) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => registerIntention = value),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: kGoldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: p.text)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(fontSize: 13, height: 1.4, color: p.muted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.goldText),
            ],
          ),
        ),
      );
    }

    return [
      Text(tr('reg_choice_title'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text)),
      const SizedBox(height: 14),
      card(Icons.add_business_rounded, tr('reg_create_title'), tr('reg_create_desc'),
          _RegisterIntention.create),
      const SizedBox(height: 12),
      card(Icons.group_add_rounded, tr('reg_join_title'), tr('reg_join_desc'),
          _RegisterIntention.join),
    ];
  }

  /// Rappel du parcours choisi + possibilité de le changer.
  Widget _buildIntentionBanner(Pal p) {
    final isCreate = registerIntention == _RegisterIntention.create;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Icon(isCreate ? Icons.workspace_premium_outlined : Icons.group_add_rounded,
              color: p.goldText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCreate ? tr('reg_president_note') : tr('reg_join_title'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.text),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => registerIntention = null),
            child: Text(tr('reg_change_choice'),
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.goldText)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(
    Pal p, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? kGoldGradient : null,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : p.muted,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------- OTP

  Widget _buildOtpView(Pal p) {
    final phone = phoneController.text.trim();
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final targetPhone = cleanPhone.startsWith('+') ? cleanPhone : '+237$cleanPhone';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: p.text),
              onPressed: () => setState(() => isOtpStep = false),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                tr('otp_title'),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: p.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Code de validation expédié par WhatsApp (+237697951571) et par e-mail à ${emailController.text.trim().isNotEmpty ? emailController.text.trim() : phone}.',
          style: TextStyle(fontSize: 13.5, height: 1.4, color: p.muted),
        ),
        const SizedBox(height: 14),

        // Carte d'info officielle WhatsApp (+237697951571)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDCF8C6).withOpacity(p.dark ? 0.2 : 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF25D366).withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Expéditeur officiel : +237 697 95 15 71',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: p.dark ? Colors.white : const Color(0xFF075E54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Consultez votre WhatsApp sur le $targetPhone pour récupérer votre code à 6 chiffres.',
                style: TextStyle(fontSize: 12, color: p.dark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () async {
                  final text = Uri.encodeComponent('Votre code de validation TontiLink');
                  final url = Uri.parse('https://wa.me/237697951571?text=$text');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('Ouvrir WhatsApp (+237697951571)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        TextFormField(
          controller: otpController,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            letterSpacing: 8,
            fontWeight: FontWeight.w800,
            color: p.gold,
          ),
          decoration: InputDecoration(
            labelText: tr('otp_label'),
            hintText: '••••••',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: isSubmitting ? null : _resendCode,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Renvoyer par E-mail', style: TextStyle(fontSize: 12)),
            ),
            TextButton.icon(
              onPressed: isSubmitting ? null : () async {
                final inputPhone = phoneController.text.trim();
                if (inputPhone.isEmpty) return;
                setState(() => isSubmitting = true);
                final ds = LocalTontiDataSource();
                final res = await ds.requestOtpWhatsApp(telephone: inputPhone, objectif: 'INSCRIPTION');
                if (!mounted) return;
                setState(() => isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res.message ?? 'Code WhatsApp demandé au +237697951571 !')),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF25D366)),
              label: const Text('Renvoyer par WhatsApp', style: TextStyle(fontSize: 12, color: Color(0xFF25D366))),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TontiButton(
          label: tr('otp_confirm'),
          icon: Icons.check_circle_outline,
          isFullWidth: true,
          height: 52,
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : _verifyRegistration,
        ),
      ],
    );
  }

  Future<void> _resendCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showAuthError('Adresse e-mail manquante pour renvoyer le code.');
      return;
    }
    setState(() => isSubmitting = true);
    final result = await _authController.resendCode(email);
    if (!mounted) return;
    setState(() => isSubmitting = false);
    if (result != null) {
      final codePreview = result['code_preview']?.toString();
      final msg = result['message']?.toString() ?? 'Un nouveau code a été envoyé.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(codePreview != null ? '$msg (Code test: $codePreview)' : msg),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showAuthError(_authController.errorMessage ?? 'Échec lors du renvoi du code.');
    }
  }

  // ---------------------------------------------------------------- Actions

  Future<void> _handleSubmit() async {
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('phone_required'))),
      );
      return;
    }

    if (passwordController.text.isEmpty ||
        (!isLoginMode &&
            (nameController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty))) {
      _showAuthError('Veuillez renseigner tous les champs obligatoires.');
      return;
    }

    if (!isLoginMode &&
        registerIntention == _RegisterIntention.join &&
        inviteCodeController.text.trim().isEmpty) {
      _showAuthError(tr('invite_code_required'));
      return;
    }

    setState(() => isSubmitting = true);
    final succeeded = isLoginMode
        ? await _authController.login(
            phoneController.text.trim(),
            passwordController.text,
          )
        : await _authController.register(
            fullName: nameController.text.trim(),
            phone: phoneController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            intention: registerIntention == _RegisterIntention.join
                ? 'REJOINDRE_TONTINE'
                : 'CREER_TONTINE',
            invitationCode: inviteCodeController.text.trim(),
          );

    if (!mounted) return;
    setState(() => isSubmitting = false);
    if (!succeeded) {
      _showAuthError(
        _authController.errorMessage ?? 'Le serveur a refusé la demande.',
      );
      return;
    }
    if (isLoginMode) {
      widget.onLoginSuccess();
    } else {
      setState(() => isOtpStep = true);
    }
  }

  Future<void> _verifyRegistration() async {
    final code = otpController.text.trim();
    if (code.isEmpty) {
      _showAuthError('Veuillez saisir le code de vérification reçu par e-mail.');
      return;
    }

    setState(() => isSubmitting = true);
    final succeeded = await _authController.verifyRegistrationEmail(
      emailController.text.trim(),
      code,
    );
    if (!mounted) return;
    setState(() => isSubmitting = false);
    if (!succeeded) {
      _showAuthError(
        _authController.errorMessage ?? 'La vérification a échoué.',
      );
      return;
    }
    widget.onLoginSuccess();
  }

  void _showAuthError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.alertRed),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('forgot_title')),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr('forgot_text')),
                const SizedBox(height: 14),
                TextField(
                  decoration: InputDecoration(
                    labelText: tr('forgot_phone'),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('forgot_done'))),
              );
            },
            child: Text(tr('forgot_send')),
          ),
        ],
      ),
    );
  }
}
