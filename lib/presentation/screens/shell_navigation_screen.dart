import 'package:flutter/material.dart' hide Text;
import '../../core/i18n/tonti_text.dart';
import '../../core/i18n/l10n.dart';
import '../../core/theme/public_palette.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/tonti_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/tontine_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/datasources/local_tonti_datasource.dart';
import '../controllers/auth_controller.dart';
import '../widgets/navigation/tonti_sidebar.dart';
import '../widgets/navigation/tonti_bottom_nav.dart';
import '../widgets/navigation/tonti_app_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'tontines/tontines_screen.dart';
import 'tontines/tontine_detail_screen.dart';
import 'tontines/create_tontine_wizard_screen.dart';
import 'cotisations/cotisations_screen.dart';
import 'cotisations/record_payment_modal.dart';
import 'distributions/distributions_screen.dart';
import 'caisse/caisse_screen.dart';
import 'prets_entraide/prets_entraide_screen.dart';
import 'repayments/remboursements_screen.dart';
import 'reunions/reunions_screen.dart';
import 'settings/settings_screen.dart';
import 'admin/user_management_screen.dart';
import '../widgets/common/notifications_dialog.dart';

class ShellNavigationScreen extends StatefulWidget {
  const ShellNavigationScreen({super.key});

  @override
  State<ShellNavigationScreen> createState() => _ShellNavigationScreenState();
}

class _ShellNavigationScreenState extends State<ShellNavigationScreen> {
  int _currentIndex = 0;
  String _activeRole = 'Président';
  TontineModel? _selectedTontine;
  bool _isCreatingTontine = false;
  bool _isSyncingBackend = false;
  bool _userManuallyOverrodeRole = false;

  @override
  void initState() {
    super.initState();
    _activeRole = AuthController().currentUser?.roleDisplayName ?? 'Membre';
    _syncBackendData();
  }

  Future<void> _syncBackendData() async {
    if (_isSyncingBackend) return;
    setState(() => _isSyncingBackend = true);
    await LocalTontiDataSource().syncFromBackend();
    final syncedUser = LocalTontiDataSource().currentUser;
    if (!_userManuallyOverrodeRole) {
      AuthController().updateCurrentUser(syncedUser);
    }
    if (mounted) {
      setState(() {
        if (!_userManuallyOverrodeRole) {
          _activeRole = syncedUser.roleDisplayName;
        }
        _isSyncingBackend = false;
        // Rafraîchir la tontine ouverte avec ses membres synchronisés.
        final openId = _selectedTontine?.id;
        if (openId != null) {
          for (final t in LocalTontiDataSource().tontines) {
            if (t.id == openId) _selectedTontine = t;
          }
        }
      });
    }
  }

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
      _selectedTontine = null;
      _isCreatingTontine = false;
    });
  }

  void _openRecordPaymentModal() {
    showDialog(
      context: context,
      builder: (ctx) => RecordPaymentModal(
        onPaymentRecorded: (_) => setState(() {}),
      ),
    );
  }


  /// Modal profil & statut du rôle utilisateur
  void _showRoleSwitchModal() {
    final user = AuthController().currentUser;
    final fullName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Membre TontiLink';
    final initials = user?.avatarInitials.isNotEmpty == true
        ? user!.avatarInitials
        : (fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U');
    final role = user?.roleDisplayName ?? _activeRole;
    final email = user?.email ?? '';
    final phone = user?.phone ?? '';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: TontiColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [TontiColors.softShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar & En-tête Profil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: TontiColors.goldSoft,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: TontiColors.darkGold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: TontiColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: TontiColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Badge de Rôle Officiel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: TontiColors.goldSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TontiColors.primaryGold.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: TontiColors.darkGold),
                    const SizedBox(width: 6),
                    Text(
                      tr('Rôle : {role}', {'role': role}),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TontiColors.darkGold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Carte Informations de Contact
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TontiColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TontiColors.border),
                ),
                child: Column(
                  children: [
                    if (email.isNotEmpty)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TontiColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.email_outlined, size: 18, color: TontiColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr('Adresse email'), style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                                Text(email, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TontiColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (email.isNotEmpty && phone.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: TontiColors.divider, height: 1),
                      ),
                    if (phone.isNotEmpty)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TontiColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.phone_outlined, size: 18, color: TontiColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr('Téléphone'), style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                                Text(phone, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TontiColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Note sur l'attribution du rôle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TontiColors.goldLightest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TontiColors.primaryGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: TontiColors.darkGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr('Votre rôle est attribué et géré par le président de la tontine selon les statuts officiels.'),
                        style: TextStyle(fontSize: 12, color: TontiColors.textPrimary, height: 1.35, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bouton Fermer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TontiColors.primaryGold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('Fermer'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showNotificationsDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    // La coque se reconstruit quand la langue ou le thème changent.
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeController.instance, L10n.instance]),
      builder: (context, _) => _buildShell(context),
    );
  }

  /// Conteneur réactif du canevas principal adaptatif au thème clair et sombre.
  Widget _buildCanvas(Pal p, bool isDesktop, Widget body) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      color: p.bg,
      child: body,
    );
  }

  Widget _buildShell(BuildContext context) {
    final p = Pal.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Titres de page dynamiques
    String pageTitle = tr('nav_dashboard');
    String? pageSubtitle;

    if (_isCreatingTontine) {
      pageTitle = tr('title_create_tontine');
      pageSubtitle = 'Configuration des paramètres & règles';
    } else if (_selectedTontine != null) {
      pageTitle = _selectedTontine!.name;
      pageSubtitle = 'Gestion détaillée du cycle';
    } else {
      switch (_currentIndex) {
        case 0:
          pageTitle = tr('nav_dashboard');
          pageSubtitle = null;
          break;
        case 1:
          pageTitle = tr('nav_tontines');
          pageSubtitle = null;
          break;
        case 2:
          pageTitle = tr('nav_contrib');
          pageSubtitle = null;
          break;
        case 3:
          pageTitle = tr('nav_distrib');
          pageSubtitle = null;
          break;
        case 4:
          pageTitle = tr('nav_cash');
          pageSubtitle = null;
          break;
        case 5:
          pageTitle = tr('nav_loans');
          pageSubtitle = null;
          break;
        case 6:
          pageTitle = tr('nav_meetings');
          pageSubtitle = null;
          break;
        case 7:
          pageTitle = tr('nav_settings');
          pageSubtitle = null;
          break;
      }
    }

    // Contenu actif
    Widget bodyContent;
    if (_isCreatingTontine) {
      bodyContent = CreateTontineWizardScreen(
        onCancel: () => setState(() => _isCreatingTontine = false),
        onComplete: (newTontine) {
          setState(() {
            _isCreatingTontine = false;
            _selectedTontine = newTontine;
          });
          // Le serveur est la source de vérité (membres, rôle de président…).
          _syncBackendData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  tr('La tontine "{name}" a été créée avec succès !', {'name': newTontine.name})),
              backgroundColor: TontiColors.successGreen,
            ),
          );
        },
      );
    } else if (_selectedTontine != null) {
      bodyContent = TontineDetailScreen(
        tontine: _selectedTontine!,
        activeRole: _activeRole,
        onBack: () => setState(() => _selectedTontine = null),
        onRecordPayment: _openRecordPaymentModal,
      );
    } else {
      switch (_currentIndex) {
        case 0:
          bodyContent = DashboardScreen(
            activeRole: _activeRole,
            onNavigateToTontines: () => _navigateToIndex(1),
            onNavigateToCotisations: () => _navigateToIndex(2),
            onNavigateToCaisse: () => _navigateToIndex(4),
            onNavigateToReunions: () => _navigateToIndex(6),
            onRecordPaymentRequested: _openRecordPaymentModal,
          );
          break;
        case 1:
          bodyContent = TontinesScreen(
            onSelectTontine: (t) => setState(() => _selectedTontine = t),
            onCreateTontine: () => setState(() => _isCreatingTontine = true),
            onRecordPayment: _openRecordPaymentModal,
          );
          break;
        case 2:
          bodyContent = CotisationsScreen(
            onRecordPayment: _openRecordPaymentModal,
            activeRole: _activeRole,
          );
          break;
        case 3:
          bodyContent = DistributionsScreen(activeRole: _activeRole);
          break;
        case 4:
          bodyContent = CaisseScreen(activeRole: _activeRole);
          break;
        case 5:
          bodyContent = PretsEntraideScreen(activeRole: _activeRole);
          break;
        case 6:
          bodyContent = ReunionsScreen(activeRole: _activeRole);
          break;
        case 8:
          bodyContent = RemboursementsScreen(activeRole: _activeRole);
          break;
        case 9:
          bodyContent = const UserManagementScreen();
          break;
        case 7:
          bodyContent = SettingsScreen(
            activeRole: _activeRole,
            onRoleChanged: (newRole) {
              setState(() {
                _activeRole = newRole;
                _userManuallyOverrodeRole = true;
              });
              final currentUser = AuthController().currentUser;
              if (currentUser != null) {
                UserRole mappedRole;
                switch (newRole.toLowerCase()) {
                  case 'super admin':
                  case 'superadmin':
                    mappedRole = UserRole.superAdmin;
                    break;
                  case 'président':
                  case 'president':
                    mappedRole = UserRole.president;
                    break;
                  case 'trésorier':
                  case 'tresorier':
                    mappedRole = UserRole.tresorier;
                    break;
                  case 'secrétaire':
                  case 'secretaire':
                    mappedRole = UserRole.secretaire;
                    break;
                  default:
                    mappedRole = UserRole.membre;
                }
                AuthController().updateCurrentUser(currentUser.copyWith(activeRole: mappedRole));
              }
            },
          );
          break;
        default:
          bodyContent = const SizedBox.shrink();
      }
    }

    return Scaffold(
      backgroundColor: p.dark ? p.bg : TontiColors.background,
      drawer: isDesktop
          ? null
          : Drawer(
              child: TontiSidebar(
                showPreferences: true,
                selectedIndex: _currentIndex,
                activeRole: _activeRole,
                onDestinationSelected: (idx) {
                  Navigator.pop(context); // fermer drawer
                  _navigateToIndex(idx);
                },
                onRoleSwitchRequested: () {
                  Navigator.pop(context);
                  _showRoleSwitchModal();
                },
              ),
            ),
      body: Row(
        children: [
          // Barre latérale gauche (Desktop)
          if (isDesktop)
            TontiSidebar(
              selectedIndex: _currentIndex,
              activeRole: _activeRole,
              onDestinationSelected: _navigateToIndex,
              onRoleSwitchRequested: _showRoleSwitchModal,
            ),

          // Zone principale
          Expanded(
            child: Column(
              children: [
                // Header Bar adaptative
                TontiAppBar(
                  title: pageTitle,
                  subtitle: pageSubtitle,
                  activeRole: _activeRole,
                  onNewTontinePressed: () => setState(() {
                    _isCreatingTontine = true;
                    _selectedTontine = null;
                  }),
                  onProfilePressed: _showRoleSwitchModal,
                  onNotificationsPressed: () => _showNotificationsModal(context),
                ),

                // Contenu de la page
                Expanded(child: _buildCanvas(p, isDesktop, bodyContent)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : TontiBottomNav(
              selectedIndex: _currentIndex,
              activeRole: _activeRole,
              onDestinationSelected: _navigateToIndex,
            ),
    );
  }

  Widget _buildBackendStatus() => const SizedBox.shrink();
}
