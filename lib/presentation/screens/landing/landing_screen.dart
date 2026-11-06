import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/public_palette.dart';
import '../../widgets/common/public_controls.dart';

/// Page d'accueil publique de TontiLink : donne envie de créer sa tontine
/// et mène vers la connexion / création de compte.
class LandingScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const LandingScreen({
    super.key,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _featKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();
  final GlobalKey _payKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: p.bg,
      body: Column(
        children: [
          _buildNavBar(p, isDesktop, isMobile),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  _buildHero(p, isDesktop, isMobile),
                  _buildStats(p, isMobile),
                  _buildFeatures(p, isDesktop, isMobile),
                  _buildHow(p, isDesktop, isMobile),
                  _buildPayments(p, isDesktop, isMobile),
                  _buildFinalCta(p, isMobile),
                  _buildFooter(p, isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- Helpers

  Widget _wrap(Widget child, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
          child: child,
        ),
      ),
    );
  }

  Widget _grid(double maxWidth, int cols, double gap, List<Widget> children) {
    final itemW = (maxWidth - (cols - 1) * gap) / cols;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [for (final c in children) SizedBox(width: itemW, child: c)],
    );
  }

  Widget _sectionHeader(Pal p, String kicker, String title, String? sub, bool isMobile) {
    return Column(
      children: [
        Text(
          kicker,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: p.goldText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 28 : 38,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.8,
            color: p.text,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.6, color: p.muted),
            ),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------------ Navbar

  Widget _buildNavBar(Pal p, bool isDesktop, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: p.navBg,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 76,
          child: _wrap(
            Row(
              children: [
                TontiLogo(size: isMobile ? 36 : 42, showText: MediaQuery.of(context).size.width >= 480),
                if (isDesktop) ...[
                  const SizedBox(width: 40),
                  _navLink(p, tr('nav_features'), () => _goTo(_featKey)),
                  const SizedBox(width: 28),
                  _navLink(p, tr('nav_how'), () => _goTo(_howKey)),
                  const SizedBox(width: 28),
                  _navLink(p, tr('nav_payments'), () => _goTo(_payKey)),
                ],
                const Spacer(),
                // Thème (soleil / demi-lune) puis langue (FR / EN)
                const ThemeToggleButton(),
                const SizedBox(width: 10),
                const LanguageDropdown(),
                if (isDesktop) ...[
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: widget.onLogin,
                    child: Text(
                      tr('nav_login'),
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: p.goldText),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PrimaryButton(label: tr('nav_signup'), onTap: widget.onSignup, height: 46),
                ] else ...[
                  const SizedBox(width: 6),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.menu_rounded, color: p.text),
                    color: p.surface,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: p.border),
                    ),
                    onSelected: (v) {
                      switch (v) {
                        case 'feat':
                          _goTo(_featKey);
                          break;
                        case 'how':
                          _goTo(_howKey);
                          break;
                        case 'login':
                          widget.onLogin();
                          break;
                        case 'signup':
                          widget.onSignup();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'feat', child: Text(tr('nav_features'), style: TextStyle(color: p.text))),
                      PopupMenuItem(value: 'how', child: Text(tr('nav_how'), style: TextStyle(color: p.text))),
                      PopupMenuItem(value: 'login', child: Text(tr('nav_login'), style: TextStyle(color: p.text))),
                      PopupMenuItem(
                        value: 'signup',
                        child: Text(tr('nav_signup'), style: TextStyle(color: p.goldText, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            isMobile,
          ),
        ),
      ),
    );
  }

  Widget _navLink(Pal p, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.goldText),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------- Hero

  Widget _buildHero(Pal p, bool isDesktop, bool isMobile) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: p.goldSoft,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: p.gold.withOpacity(0.35)),
          ),
          child: Text(
            tr('hero_badge'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: p.goldText,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 22 : 30),
        Text(
          tr('hero_title_1'),
          style: TextStyle(
            fontSize: isMobile ? 38 : (isDesktop ? 56 : 50),
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.8,
            color: p.text,
          ),
        ),
        Text(
          tr('hero_title_2'),
          style: TextStyle(
            fontSize: isMobile ? 38 : (isDesktop ? 56 : 50),
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -1.8,
            color: p.gold,
          ),
        ),
        SizedBox(height: isMobile ? 18 : 26),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            tr('hero_sub'),
            style: TextStyle(fontSize: isMobile ? 16 : 18, height: 1.65, color: p.muted),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _PrimaryButton(
              label: tr('hero_cta_create'),
              icon: Icons.arrow_forward_rounded,
              onTap: widget.onSignup,
              height: 54,
              large: true,
            ),
            _OutlineButton(
              label: tr('hero_cta_discover'),
              onTap: () => _goTo(_featKey),
              height: 54,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          tr('hero_tags'),
          style: TextStyle(fontSize: 14, color: p.muted, letterSpacing: 0.3),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.heroGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _wrap(
        Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: 56),
                    Expanded(flex: 5, child: _buildPreviewCard(p)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 40),
                    _buildPreviewCard(p),
                  ],
                ),
        ),
        isMobile,
      ),
    );
  }

  Widget _buildPreviewCard(Pal p) {
    final rows = <List<dynamic>>[
      [Icons.payments_rounded, tr('preview_r1_t'), tr('preview_r1_s')],
      [Icons.autorenew_rounded, tr('preview_r2_t'), tr('preview_r2_s')],
      [Icons.event_note_rounded, tr('preview_r3_t'), tr('preview_r3_s')],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A2C0B), Color(0xFF1B1507)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.goldAccent.withOpacity(0.35)),
        boxShadow: [p.shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: kGoldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr('preview_title'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: p.dark ? const Color(0xFF2A2316) : Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('preview_kicker'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.goldText),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('preview_hello'),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: p.text, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(tr('preview_sub'), style: TextStyle(fontSize: 15, color: p.muted)),
                const SizedBox(height: 18),
                for (final r in rows) ...[
                  _previewRow(p, r[0] as IconData, r[1] as String, r[2] as String),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4CC38A), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr('preview_foot'),
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ),
              Text(
                tr('preview_tag'),
                style: const TextStyle(color: Colors.white54, fontSize: 10.5, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewRow(Pal p, IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.dark ? const Color(0xFF332A1A) : const Color(0xFFFAF8F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: p.goldSoft, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: p.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: p.text)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 12.5, color: p.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.muted),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------- Stats

  Widget _buildStats(Pal p, bool isMobile) {
    final stats = [
      ['stat1_v', 'stat1_l'],
      ['stat2_v', 'stat2_l'],
      ['stat3_v', 'stat3_l'],
      ['stat4_v', 'stat4_l'],
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.symmetric(horizontal: BorderSide(color: p.border)),
      ),
      child: _wrap(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 34),
          child: LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 760 ? 4 : 2;
              return _grid(c.maxWidth, cols, 16, [
                for (final s in stats)
                  Column(
                    children: [
                      Text(
                        tr(s[0]),
                        style: TextStyle(
                          fontSize: isMobile ? 30 : 38,
                          fontWeight: FontWeight.w800,
                          color: p.gold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(s[1]),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: p.muted),
                      ),
                    ],
                  ),
              ]);
            },
          ),
        ),
        isMobile,
      ),
    );
  }

  // ---------------------------------------------------------------- Features

  Widget _buildFeatures(Pal p, bool isDesktop, bool isMobile) {
    final feats = <List<dynamic>>[
      [Icons.payments_rounded, 'f1_t', 'f1_d'],
      [Icons.autorenew_rounded, 'f2_t', 'f2_d'],
      [Icons.shield_rounded, 'f3_t', 'f3_d'],
      [Icons.event_note_rounded, 'f4_t', 'f4_d'],
      [Icons.volunteer_activism_rounded, 'f5_t', 'f5_d'],
      [Icons.account_balance_rounded, 'f6_t', 'f6_d'],
    ];
    return Container(
      key: _featKey,
      child: _wrap(
        Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 56 : 96),
          child: Column(
            children: [
              _sectionHeader(p, tr('feat_kicker'), tr('feat_title'), tr('feat_sub'), isMobile),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth >= 960 ? 3 : (c.maxWidth >= 600 ? 2 : 1);
                  return _grid(c.maxWidth, cols, 20, [
                    for (final f in feats)
                      _HoverCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: kGoldGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(f[0] as IconData, color: Colors.white, size: 26),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              tr(f[1] as String),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr(f[2] as String),
                              style: TextStyle(fontSize: 14.5, height: 1.6, color: p.muted),
                            ),
                          ],
                        ),
                      ),
                  ]);
                },
              ),
            ],
          ),
        ),
        isMobile,
      ),
    );
  }

  // --------------------------------------------------------------------- How

  Widget _buildHow(Pal p, bool isDesktop, bool isMobile) {
    final steps = [
      ['01', Icons.add_circle_outline_rounded, 's1_t', 's1_d'],
      ['02', Icons.group_add_outlined, 's2_t', 's2_d'],
      ['03', Icons.savings_outlined, 's3_t', 's3_d'],
    ];
    return Container(
      key: _howKey,
      color: p.surface,
      child: _wrap(
        Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 56 : 96),
          child: Column(
            children: [
              _sectionHeader(p, tr('how_kicker'), tr('how_title'), null, isMobile),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth >= 860 ? 3 : 1;
                  return _grid(c.maxWidth, cols, 24, [
                    for (final s in steps)
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: p.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: p.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  s[0] as String,
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    color: p.gold.withOpacity(0.45),
                                    letterSpacing: -1,
                                  ),
                                ),
                                const Spacer(),
                                Icon(s[1] as IconData, color: p.gold, size: 30),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tr(s[2] as String),
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: p.text),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr(s[3] as String),
                              style: TextStyle(fontSize: 14.5, height: 1.6, color: p.muted),
                            ),
                          ],
                        ),
                      ),
                  ]);
                },
              ),
            ],
          ),
        ),
        isMobile,
      ),
    );
  }

  // ---------------------------------------------------------------- Payments

  Widget _buildPayments(Pal p, bool isDesktop, bool isMobile) {
    Widget pill(String label, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
          child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 14)),
        );

    return Container(
      key: _payKey,
      child: _wrap(
        Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 72),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 28 : 52),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkGold, AppColors.deepGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [p.shadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('pay_title'),
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    tr('pay_sub'),
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 26),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    pill('MTN MoMo', AppColors.mtnYellow, const Color(0xFF202124)),
                    pill('Orange Money', AppColors.orangeMoney, Colors.white),
                    pill('FCFA', Colors.white, AppColors.deepGold),
                    pill('OHADA', Colors.white, AppColors.deepGold),
                  ],
                ),
              ],
            ),
          ),
        ),
        isMobile,
      ),
    );
  }

  // --------------------------------------------------------------- Final CTA

  Widget _buildFinalCta(Pal p, bool isMobile) {
    return _wrap(
      Padding(
        padding: EdgeInsets.fromLTRB(0, isMobile ? 24 : 40, 0, isMobile ? 56 : 96),
        child: Column(
          children: [
            Text(
              tr('cta_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 28 : 42,
                fontWeight: FontWeight.w800,
                color: p.text,
                letterSpacing: -1,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                tr('cta_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.5, height: 1.6, color: p.muted),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                _PrimaryButton(
                  label: tr('cta_btn'),
                  icon: Icons.arrow_forward_rounded,
                  onTap: widget.onSignup,
                  height: 56,
                  large: true,
                ),
                _OutlineButton(label: tr('cta_login'), onTap: widget.onLogin, height: 56),
              ],
            ),
          ],
        ),
      ),
      isMobile,
    );
  }

  Widget _buildFooter(Pal p, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: _wrap(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 14,
            spacing: 20,
            children: [
              const TontiLogo(size: 32),
              Text(tr('footer_rights'), style: TextStyle(fontSize: 13, color: p.muted)),
            ],
          ),
        ),
        isMobile,
      ),
    );
  }
}

// ---------------------------------------------------------------- Widgets

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;
  final bool large;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 48,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: large ? 30 : 22),
          decoration: BoxDecoration(
            gradient: kGoldGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC99A2E).withOpacity(0.38),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: large ? 16 : 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const _OutlineButton({required this.label, required this.onTap, this.height = 48});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _hover ? p.gold : p.border, width: _hover ? 1.4 : 1),
          boxShadow: _hover ? [p.shadow] : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
