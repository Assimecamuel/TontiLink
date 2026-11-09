import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../models/tontine_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';

class CreateTontineWizardScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<TontineModel> onComplete;

  const CreateTontineWizardScreen({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  State<CreateTontineWizardScreen> createState() =>
      _CreateTontineWizardScreenState();
}

class _CreateTontineWizardScreenState extends State<CreateTontineWizardScreen> {
  int currentStep = 1;
  static const int totalSteps = 6;

  // Form State
  // Aucune valeur par défaut : l'utilisateur renseigne tout lui-même.
  String tontineName = '';
  String tontineDescription = '';
  bool isPrivate = true;
  TontineType selectedType = TontineType.rotative;
  double contributionAmount = 0;
  TontineFrequency selectedFrequency = TontineFrequency.mensuelle;
  int memberCount = 0;
  double latePenaltyAmount = 0;
  DistributionMethod selectedDistribution = DistributionMethod.ordrePredefini;
  bool rulesAccepted = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête du Wizard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créer une nouvelle Tontine',
                        style: TontiTypography.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assistant de configuration guidée en 6 étapes simples',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiButton(
                    label: 'Fermer',
                    type: TontiButtonType.ghost,
                    icon: Icons.close,
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barre d'avancement par étape
              _buildStepperIndicator(),
              const SizedBox(height: 28),

              // Contenu de l'étape courante
              TontiCard(
                padding: const EdgeInsets.all(28),
                child: _buildCurrentStepContent(),
              ),
              const SizedBox(height: 24),

              // Actions de navigation (Précédent / Continuer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 1)
                    TontiButton(
                      label: 'Étape précédente',
                      type: TontiButtonType.outline,
                      icon: Icons.arrow_back,
                      onPressed: () => setState(() => currentStep--),
                    )
                  else
                    const SizedBox.shrink(),
                  TontiButton(
                    label: currentStep == totalSteps
                        ? 'Confirmer & Publier la tontine'
                        : 'Continuer',
                    icon: currentStep == totalSteps
                        ? Icons.check_circle
                        : Icons.arrow_forward,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _handleNextStep,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Étape $currentStep sur $totalSteps : ${_getStepTitle(currentStep)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TontiColors.primaryGold,
              ),
            ),
            Text(
              '${((currentStep / totalSteps) * 100).toInt()}% complété',
              style: const TextStyle(
                  fontSize: 12, color: TontiColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 8,
            backgroundColor: TontiColors.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(TontiColors.primaryGold),
          ),
        ),
      ],
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Informations générales';
      case 2:
        return 'Choix du modèle de tontine';
      case 3:
        return 'Règles financières & Cotisations';
      case 4:
        return 'Mécanisme de distribution';
      case 5:
        return 'Membres fondateurs & Rôles';
      case 6:
        return 'Règlement intérieur & Validation';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 1:
        return _buildStep1Info();
      case 2:
        return _buildStep2Type();
      case 3:
        return _buildStep3Finance();
      case 4:
        return _buildStep4Distribution();
      case 5:
        return _buildStep5Members();
      case 6:
        return _buildStep6Summary();
      default:
        return const SizedBox.shrink();
    }
  }

  // Étape 1 : Informations générales
  Widget _buildStep1Info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations de base de la tontine',
            style: TontiTypography.headingMedium),
        const SizedBox(height: 4),
        const Text(
          'Donnez un nom clair et reconnaissable pour vos membres au Cameroun.',
          style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: tontineName,
          decoration: const InputDecoration(
            labelText: 'Nom du groupe / de la tontine',
            hintText: 'Nom de votre tontine',
            prefixIcon:
                Icon(Icons.group_outlined, color: TontiColors.primaryGold),
          ),
          onChanged: (val) => tontineName = val,
        ),
        const SizedBox(height: 18),
        TextFormField(
          initialValue: tontineDescription,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description et objectifs du groupe',
            hintText:
                'Précisez l\'objet : épargne rotative, soutien familial, investissement...',
          ),
          onChanged: (val) => tontineDescription = val,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('Tontine privée (sur invitation uniquement)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text(
              'Seuls les membres disposant du code ou du lien peuvent adhérer.'),
          value: isPrivate,
          activeColor: TontiColors.primaryGold,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => setState(() => isPrivate = val),
        ),
      ],
    );
  }

  // Étape 2 : Choix du type
  Widget _buildStep2Type() {
    final types = [
      {
        'type': TontineType.rotative,
        'title': 'Tontine Rotative (Tour par Tour)',
        'desc':
            'Chaque membre cotise à chaque période. La cagnotte totale est remise successivement à un membre selon un ordre.',
        'icon': Icons.sync,
      },
      {
        'type': TontineType.cumulative,
        'title': 'Tontine Cumulative (Caisse d\'épargne)',
        'desc':
            'Les fonds s\'accumulent dans la caisse commune et sont redistribués à la fin du cycle annuel ou lors des fêtes.',
        'icon': Icons.savings,
      },
      {
        'type': TontineType.avecPrets,
        'title': 'Tontine avec Prêts & Micro-Crédits',
        'desc':
            'La caisse permet d\'octroyer des crédits aux membres avec un taux d\'intérêt voté par l\'assemblée générale.',
        'icon': Icons.request_quote,
      },
      {
        'type': TontineType.entraide,
        'title': 'Fonds de Solidarité & Entraide (Assistance)',
        'desc':
            'Caisse dédiée au soutien social lors des événements de la vie (naissances, mariages, deuils, maladies).',
        'icon': Icons.volunteer_activism,
      },
      {
        'type': TontineType.projetCollectif,
        'title': 'Projet Commercial ou Investissement Collectif',
        'desc':
            'Financement d\'un projet commun (immobilier, commerce, agriculture) avec répartition convenue des résultats.',
        'icon': Icons.hub,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sélectionnez le modèle financier',
            style: TontiTypography.headingMedium),
        const SizedBox(height: 4),
        const Text(
          'Les règles de calcul et de suivi s\'adapteront automatiquement à ce choix.',
          style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
        ),
        const SizedBox(height: 18),
        ...types.map((item) {
          final type = item['type'] as TontineType;
          final isSelected = selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: isSelected ? TontiColors.goldSoft : TontiColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isSelected ? TontiColors.primaryGold : TontiColors.border,
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => setState(() => selectedType = type),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TontiColors.primaryGold
                              : TontiColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : TontiColors.primaryGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? TontiColors.darkGold
                                    : TontiColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['desc'] as String,
                              style: TontiTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Radio<TontineType>(
                        value: type,
                        groupValue: selectedType,
                        activeColor: TontiColors.primaryGold,
                        onChanged: (val) => setState(() => selectedType = val!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Étape 3 : Règles financières
  Widget _buildStep3Finance() {
    final cagnotteTotal = contributionAmount * memberCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Règles financières & Cotisations',
            style: TontiTypography.headingMedium),
        const SizedBox(height: 4),
        const Text(
          'Définissez les montants en FCFA, les fréquences et les pénalités applicables.',
          style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: contributionAmount > 0 ? contributionAmount.toInt().toString() : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant de la cotisation (FCFA)',
                  suffixText: 'FCFA',
                  prefixIcon:
                      Icon(Icons.attach_money, color: TontiColors.primaryGold),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null)
                    setState(() => contributionAmount = parsed);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: memberCount > 0 ? memberCount.toString() : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de membres prévu',
                  suffixText: 'Membres',
                  prefixIcon: Icon(Icons.people_outline,
                      color: TontiColors.primaryGold),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null) setState(() => memberCount = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Fréquence
        const Text('Fréquence des séances et versements :',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFrequencyOption(
                'Hebdomadaire', TontineFrequency.hebdomadaire),
            const SizedBox(width: 12),
            _buildFrequencyOption('Bimensuelle', TontineFrequency.bimensuelle),
            const SizedBox(width: 12),
            _buildFrequencyOption('Mensuelle', TontineFrequency.mensuelle),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: latePenaltyAmount > 0 ? latePenaltyAmount.toInt().toString() : '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Pénalité forfaitaire en cas de retard (FCFA)',
            suffixText: 'FCFA',
            prefixIcon:
                Icon(Icons.timer_off_outlined, color: TontiColors.alertRed),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null) setState(() => latePenaltyAmount = parsed);
          },
        ),
        const SizedBox(height: 24),
        // Récapitulatif calculé
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TontiColors.goldSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TontiColors.primaryGold.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cagnotte théorique par séance :',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('Montant remis à chaque tour de table',
                      style: TextStyle(
                          fontSize: 11, color: TontiColors.textSecondary)),
                ],
              ),
              Text(
                Formatters.formatFCFA(cagnotteTotal),
                style: TontiTypography.amountMedium
                    .copyWith(color: TontiColors.darkGold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyOption(String title, TontineFrequency freq) {
    final isSelected = selectedFrequency == freq;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? TontiColors.goldSoft : TontiColors.white,
          side: BorderSide(
            color: isSelected ? TontiColors.primaryGold : TontiColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        onPressed: () => setState(() => selectedFrequency = freq),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? TontiColors.darkGold : TontiColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Étape 4 : Distribution
  Widget _buildStep4Distribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mécanisme d\'attribution des tours',
            style: TontiTypography.headingMedium),
        const SizedBox(height: 4),
        const Text(
          'Comment sera déterminé l\'ordre des bénéficiaires pour les levées de cagnotte ?',
          style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
        ),
        const SizedBox(height: 18),
        RadioListTile<DistributionMethod>(
          title: const Text('Ordre fixe prédéfini à l\'adhésion',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text(
              'Les membres choisissent leur mois de passage selon leur besoin de trésorerie.'),
          value: DistributionMethod.ordrePredefini,
          groupValue: selectedDistribution,
          activeColor: TontiColors.primaryGold,
          onChanged: (val) => setState(() => selectedDistribution = val!),
        ),
        RadioListTile<DistributionMethod>(
          title: const Text('Tirage au sort transparent lors de l\'assemblée',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text(
              'Le système ou la première réunion physique procède au tirage au sort aléatoire.'),
          value: DistributionMethod.tirageAuSort,
          groupValue: selectedDistribution,
          activeColor: TontiColors.primaryGold,
          onChanged: (val) => setState(() => selectedDistribution = val!),
        ),
        RadioListTile<DistributionMethod>(
          title: const Text('Méthode personnalisée selon accord du groupe',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text(
              'Attribution sur dossier d\'urgence sociale ou par enchères traditionnelles.'),
          value: DistributionMethod.personnalise,
          groupValue: selectedDistribution,
          activeColor: TontiColors.primaryGold,
          onChanged: (val) => setState(() => selectedDistribution = val!),
        ),
      ],
    );
  }

  // Étape 5 : Gouvernance (le créateur est automatiquement Président)
  Widget _buildStep5Members() {
    final me = LocalTontiDataSource().currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gouvernance du bureau', style: TontiTypography.headingMedium),
        const SizedBox(height: 4),
        const Text(
          'Vous n\'avez rien à renseigner ici : le créateur de la tontine en devient automatiquement le Président.',
          style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TontiColors.goldSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TontiColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield, color: TontiColors.primaryGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  me.fullName.isEmpty
                      ? 'Vous serez Président(e) de cette tontine.'
                      : '${me.fullName} sera Président(e) de cette tontine.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Le Trésorier et le Secrétaire pourront être désignés plus tard, depuis l\'onglet Membres, parmi les personnes que vous aurez invitées.',
          style: TextStyle(fontSize: 12.5, color: TontiColors.textSecondary),
        ),
      ],
    );
  }

  // Étape 6 : Règlement intérieur & Résumé
  Widget _buildStep6Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified,
                color: TontiColors.primaryGold, size: 28),
            const SizedBox(width: 10),
            Text('Récapitulatif & Règlement intérieur',
                style: TontiTypography.headingMedium),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TontiColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TontiColors.border),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Nom :', tontineName),
              _buildSummaryRow(
                  'Type de tontine :', selectedType.name.toUpperCase()),
              _buildSummaryRow('Cotisation par membre :',
                  Formatters.formatFCFA(contributionAmount)),
              _buildSummaryRow('Nombre de membres :', '$memberCount membres'),
              _buildSummaryRow('Cagnotte par cycle :',
                  Formatters.formatFCFA(contributionAmount * memberCount),
                  isHighlight: true),
              _buildSummaryRow(
                  'Fréquence :', selectedFrequency.name.toUpperCase()),
              _buildSummaryRow('Pénalité de retard :',
                  Formatters.formatFCFA(latePenaltyAmount)),
              _buildSummaryRow('Président(e) :', 'Vous (automatique)'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: rulesAccepted,
          activeColor: TontiColors.primaryGold,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Je certifie que les règles financières et le mode de distribution ont été approuvés par les membres fondateurs.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'TontiLink garantit la traçabilité des signatures et le respect des traditions de tontine camerounaises.',
            style: TextStyle(fontSize: 11.5),
          ),
          onChanged: (val) => setState(() => rulesAccepted = val ?? false),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: TontiColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight
                  ? TontiColors.primaryGold
                  : TontiColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateStep(int step) {
    if (step == 1 && tontineName.trim().isEmpty) {
      return 'Veuillez saisir le nom de la tontine.';
    }
    if (step == 3) {
      if (contributionAmount <= 0) return 'Veuillez saisir le montant de la cotisation.';
      if (memberCount < 2) return 'Veuillez saisir un nombre de membres d\'au moins 2.';
    }
    return null;
  }

  Future<void> _handleNextStep() async {
    if (currentStep < totalSteps) {
      final problem = _validateStep(currentStep);
      if (problem != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(problem), backgroundColor: TontiColors.alertRed),
        );
        return;
      }
      setState(() => currentStep++);
    } else {
      final problem = _validateStep(1) ?? _validateStep(3);
      if (problem != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(problem), backgroundColor: TontiColors.alertRed),
        );
        return;
      }
      if (!rulesAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez accepter le règlement intérieur avant de publier.'),
            backgroundColor: TontiColors.alertRed,
          ),
        );
        return;
      }

      // Finalisation et création du modèle
      final newTontine = TontineModel(
        id: 'tontine-pending',
        name: tontineName,
        description: tontineDescription,
        type: selectedType,
        frequency: selectedFrequency,
        status: TontineStatus.active,
        distributionMethod: selectedDistribution,
        contributionAmount: contributionAmount,
        totalCycleAmount: contributionAmount * memberCount,
        memberCount: memberCount,
        maxMembers: memberCount,
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
        nextBeneficiaryName: '—',
        nextBeneficiaryAvatar: '—',
        currentCycle: 1,
        totalCycles: memberCount,
        collectedAmountThisPeriod: 0,
        cashReserveBalance: 0,
        isPrivate: isPrivate,
        coverTag: 'Nouveau',
      );

      setState(() => _isSubmitting = true);
      String? serverId;
      try {
        final response = await LocalTontiDataSource().createTontine({
          'nom': tontineName.trim(),
          'description': tontineDescription.trim(),
          'type': switch (selectedType) {
            TontineType.rotative => 'ROTATIVE',
            TontineType.cumulative => 'CUMULATIVE',
            TontineType.avecPrets => 'PRET',
            TontineType.entraide => 'ENTRAIDE',
            TontineType.projetCollectif => 'PROJET_COMMERCIAL',
          },
          // Champs alignés sur le contrat d'API (POST /api/tontines/)
          'categorie': 'COMMUNAUTAIRE',
          'cotisation': contributionAmount.toInt(),
          'frequence': switch (selectedFrequency) {
            TontineFrequency.hebdomadaire => 'HEBDOMADAIRE',
            TontineFrequency.bimensuelle => 'QUINZOMADAIRE',
            TontineFrequency.mensuelle => 'MENSUELLE',
          },
          'membreMin': 2,
          'membreMax': memberCount < 2 ? 2 : memberCount,
          'dureeCycle': memberCount < 2 ? 2 : memberCount,
          'fonctionnementTraditionnel': false,
          'modesPaiementAcceptes': 'ESPECES,MOBILE_MONEY',
          'penaliteRetard': latePenaltyAmount.toInt(),
          'modeDistribution': switch (selectedDistribution) {
            DistributionMethod.ordrePredefini => 'ORDRE_FIXE',
            DistributionMethod.tirageAuSort => 'TIRAGE_SORT',
            DistributionMethod.personnalise => 'ACCORD_MUTUEL',
          },
          'privee': isPrivate,
        });

        if (response.isOk && response.data != null) {
          final responseData = response.data;
          final createdData = responseData is Map<String, dynamic> &&
                  responseData['tontine'] is Map<String, dynamic>
              ? responseData['tontine'] as Map<String, dynamic>
              : responseData is Map<String, dynamic>
                  ? responseData
                  : const <String, dynamic>{};
          serverId = createdData['id']?.toString() ??
              createdData['tontine_id']?.toString() ??
              (responseData is Map<String, dynamic>
                  ? (responseData['id']?.toString() ??
                      responseData['tontine_id']?.toString())
                  : null);
        }
      } catch (_) {
        // En cas de déconnexion ou erreur serveur
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final finalId = (serverId != null && serverId.isNotEmpty)
          ? 'tontine-$serverId'
          : 'tontine-${DateTime.now().millisecondsSinceEpoch}';

      final finalTontine = newTontine.copyWith(id: finalId);
      widget.onComplete(finalTontine);
    }
  }
}
