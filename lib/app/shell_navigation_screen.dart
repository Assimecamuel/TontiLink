import 'package:flutter/material.dart';
import '../core/theme/tonti_colors.dart';
import '../core/utils/responsive_helper.dart';
import '../injection_container.dart';
import '../features/tontines/domain/entities/tontine.dart';
import '../features/cotisations/domain/entities/transaction.dart';
import '../shared/widgets/navigation/tonti_sidebar.dart';
import '../shared/widgets/navigation/tonti_bottom_nav.dart';
import '../shared/widgets/navigation/tonti_app_bar.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/tontines/presentation/screens/tontines_screen.dart';
import '../features/tontines/presentation/screens/tontine_detail_screen.dart';
import '../features/tontines/presentation/screens/create_tontine_wizard_screen.dart';
import '../features/cotisations/presentation/screens/cotisations_screen.dart';
import '../features/cotisations/presentation/screens/record_payment_modal.dart';
import '../features/distributions/presentation/screens/distributions_screen.dart';
import '../features/caisse/presentation/screens/caisse_screen.dart';
import '../features/prets_entraide/presentation/screens/prets_entraide_screen.dart';
import '../features/reunions/presentation/screens/reunions_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

class ShellNavigationScreen extends StatefulWidget {
  const ShellNavigationScreen({super.key});

  @override
  State<ShellNavigationScreen> createState() => _ShellNavigationScreenState();
}

class _ShellNavigationScreenState extends State<ShellNavigationScreen> {
  int _currentIndex = 0;
  String _activeRole = 'Président';
  Tontine? _selectedTontine;
  bool _isCreatingTontine = false;

  /// Reconstruit le shell (et ses pages) dès qu'un controller de données change.
  late final Listenable _dataChanges = Listenable.merge([
    sl.tontinesController,
    sl.membersController,
    sl.cotisationsController,
    sl.distributionsController,
    sl.caisseController,
    sl.pretsEntraideController,
    sl.reunionsController,
  ]);

  @override
  void initState() {
    super.initState();
    _dataChanges.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataChanges.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
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
        onPaymentRecorded: (newTxn) {
          sl.cotisationsController.recordTransaction(newTxn);
        },
      ),
    );
  }

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
            color: TontiColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [TontiColors.softShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: TontiColors.goldSoft,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: TontiColors.darkGold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: TontiColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

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
                    const Icon(Icons.shield_outlined, size: 16, color: TontiColors.darkGold),
                    const SizedBox(width: 6),
                    Text(
                      'Rôle : $role',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TontiColors.darkGold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                              color: TontiColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.email_outlined, size: 18, color: TontiColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Adresse email', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                                Text(email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TontiColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (email.isNotEmpty && phone.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: TontiColors.divider, height: 1),
                      ),
                    if (phone.isNotEmpty)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TontiColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.phone_outlined, size: 18, color: TontiColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Téléphone', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                                Text(phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TontiColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TontiColors.goldLightest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TontiColors.primaryGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: TontiColors.darkGold),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Votre rôle est attribué et géré par le président de la tontine selon les statuts officiels.',
                        style: TextStyle(fontSize: 12, color: TontiColors.textPrimary, height: 1.35, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                  child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTile(String role) {
    return ListTile(
      title: Text(role, style: const TextStyle(fontWeight: FontWeight.w600)),
      leading: Icon(
        _activeRole == role ? Icons.radio_button_checked : Icons.radio_button_off,
        color: _activeRole == role ? TontiColors.primaryGold : TontiColors.textSecondary,
      ),
      onTap: () {
        setState(() => _activeRole = role);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle changé pour : $role')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Titres de page dynamiques
    String pageTitle = 'Tableau de bord';
    String? pageSubtitle = 'Bienvenue, Paul Eric Kamdem';

    if (_isCreatingTontine) {
      pageTitle = 'Créer une Tontine';
      pageSubtitle = 'Configuration des paramètres & règles';
    } else if (_selectedTontine != null) {
      pageTitle = _selectedTontine!.name;
      pageSubtitle = 'Gestion détaillée du cycle';
    } else {
      switch (_currentIndex) {
        case 0:
          pageTitle = 'Tableau de bord';
          pageSubtitle = 'Situation financière synthétique';
          break;
        case 1:
          pageTitle = 'Mes Tontines';
          pageSubtitle = 'Tous vos cercles d\'épargne et d\'entraide';
          break;
        case 2:
          pageTitle = 'Cotisations & Paiements';
          pageSubtitle = 'Versements et échéances';
          break;
        case 3:
          pageTitle = 'Distributions';
          pageSubtitle = 'Levées de cagnotte et bénéficiaires';
          break;
        case 4:
          pageTitle = 'Caisse & Comptabilité';
          pageSubtitle = 'Trésorerie et rapprochements';
          break;
        case 5:
          pageTitle = 'Prêts & Entraide';
          pageSubtitle = 'Solidarité et micro-crédits';
          break;
        case 6:
          pageTitle = 'Réunions Présentielles';
          pageSubtitle = 'Émargement et séances physiques';
          break;
        case 7:
          pageTitle = 'Paramètres & Profil';
          pageSubtitle = 'Sécurité et gestion du compte';
          break;
      }
    }

    // Contenu actif
    Widget bodyContent;
    if (_isCreatingTontine) {
      bodyContent = CreateTontineWizardScreen(
        onCancel: () => setState(() => _isCreatingTontine = false),
        onComplete: (newTontine) {
          sl.tontinesController.addTontine(newTontine);
          setState(() {
            _isCreatingTontine = false;
            _selectedTontine = newTontine;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La tontine "${newTontine.name}" a été créée avec succès !'),
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
          bodyContent = CotisationsScreen(onRecordPayment: _openRecordPaymentModal);
          break;
        case 3:
          bodyContent = DistributionsScreen(activeRole: _activeRole);
          break;
        case 4:
          bodyContent = const CaisseScreen();
          break;
        case 5:
          bodyContent = const PretsEntraideScreen();
          break;
        case 6:
          bodyContent = const ReunionsScreen();
          break;
        case 7:
          bodyContent = SettingsScreen(
            activeRole: _activeRole,
            onRoleChanged: (newRole) => setState(() => _activeRole = newRole),
          );
          break;
        default:
          bodyContent = const SizedBox.shrink();
      }
    }

    return Scaffold(
      backgroundColor: TontiColors.background,
      drawer: isDesktop
          ? null
          : Drawer(
              child: TontiSidebar(
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
                  onNotificationsPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Centre de notifications : Toutes les alertes sont à jour.')),
                    );
                  },
                ),

                // Contenu de la page
                Expanded(child: bodyContent),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : TontiBottomNav(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToIndex,
            ),
    );
  }
}

