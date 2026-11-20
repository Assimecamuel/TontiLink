import 'package:flutter/material.dart' hide Text;
import '../../../core/i18n/tonti_text.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../models/transaction_model.dart';
import '../../widgets/common/tonti_button.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../domain/entities/member_entity.dart';
import '../../../domain/entities/tontine_entity.dart';
import '../../../core/i18n/l10n.dart';

class RecordPaymentModal extends StatefulWidget {
  final ValueChanged<TransactionModel> onPaymentRecorded;

  const RecordPaymentModal({
    super.key,
    required this.onPaymentRecorded,
  });

  @override
  State<RecordPaymentModal> createState() => _RecordPaymentModalState();
}

class _RecordPaymentModalState extends State<RecordPaymentModal> {
  String selectedTontineId = '';
  String selectedMemberId = '';
  double amount = 0;
  PaymentMethod selectedMethod = PaymentMethod.mtnMoMo;
  String externalReference = '';
  String note = '';
  bool _isSaving = false;

  /// Tontines uniques pour éviter tout doublon dans le dropdown.
  List<TontineEntity> get _uniqueTontines {
    final Map<String, TontineEntity> map = {};
    for (final t in MockTontiData.tontines) {
      if (t.id.isNotEmpty) {
        map.putIfAbsent(t.id, () => t);
      }
    }
    return map.values.toList();
  }

  @override
  void initState() {
    super.initState();
    final tontines = _uniqueTontines;
    selectedTontineId = tontines.isNotEmpty ? tontines.first.id : '';
    _onTontineChanged(selectedTontineId, refresh: false);
    externalReference = 'MOMO-CMR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  TontineEntity? get _tontine {
    final tontines = _uniqueTontines;
    for (final t in tontines) {
      if (t.id == selectedTontineId) return t;
    }
    return tontines.isNotEmpty ? tontines.first : null;
  }

  /// Membres de la tontine sélectionnée uniquement (données uniques).
  List<MemberEntity> get _members {
    final list = _tontine?.members ?? const [];
    final Map<String, MemberEntity> map = {};
    for (final m in list) {
      if (m.id.isNotEmpty) {
        map.putIfAbsent(m.id, () => m);
      }
    }
    return map.values.toList();
  }

  MemberEntity? get _selectedPayer {
    final list = _members;
    for (final m in list) {
      if (m.id == selectedMemberId) return m;
    }
    return list.isNotEmpty ? list.first : null;
  }

  bool _hasAlreadyContributedThisPeriod(MemberEntity payer, TontineEntity tontine) {
    final now = DateTime.now();
    final freq = (tontine.frequency?.toString() ?? 'MENSUELLE').toUpperCase();
    
    return MockTontiData.transactions.any((t) {
      if (t.type != TransactionType.cotisation) return false;
      if (t.tontineName.isNotEmpty && t.tontineName != tontine.name) return false;
      if (t.memberName != payer.fullName) return false;
      
      final d = t.date;
      if (freq == 'HEBDOMADAIRE') {
        return d.difference(now).inDays.abs() < 7;
      } else if (freq == 'ANNUELLE') {
        return d.year == now.year;
      } else if (freq == 'QUINZOMADAIRE') {
        return d.year == now.year && d.month == now.month && ((d.day <= 15) == (now.day <= 15));
      }
      return d.year == now.year && d.month == now.month;
    });
  }

  void _onTontineChanged(String tontineId, {bool refresh = true}) {
    void apply() {
      selectedTontineId = tontineId;
      final t = _tontine;
      amount = t?.contributionAmount ?? 0;
      final membersList = _members;
      selectedMemberId = membersList.isNotEmpty ? membersList.first.id : '';
    }

    if (refresh) {
      setState(apply);
    } else {
      apply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tontines = _uniqueTontines;
    final bool hasTontines = tontines.isNotEmpty;
    final String validTontineValue = hasTontines
        ? (tontines.any((t) => t.id == selectedTontineId) ? selectedTontineId : tontines.first.id)
        : '';

    final membersList = _members;
    final bool hasMembers = membersList.isNotEmpty;
    final String validMemberValue = hasMembers
        ? (membersList.any((m) => m.id == selectedMemberId) ? selectedMemberId : membersList.first.id)
        : '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du formulaire
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TontiColors.goldSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.payments, color: TontiColors.primaryGold),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('Enregistrer une Cotisation'), style: TontiTypography.headingMedium),
                          Text(tr('Saisie et rapprochement comptable'), style: TextStyle(fontSize: 12, color: TontiColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Sélection de la tontine
              Text(tr('Groupe / Tontine concernée'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey('tontine-$validTontineValue'),
                value: validTontineValue,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance, color: TontiColors.primaryGold)),
                items: !hasTontines
                    ? [DropdownMenuItem(value: '', child: Text(tr('Aucune tontine disponible')))]
                    : tontines.map((t) {
                        return DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis));
                      }).toList(),
                onChanged: (val) {
                  if (val != null && val.isNotEmpty) _onTontineChanged(val);
                },
              ),
              const SizedBox(height: 14),

              // Sélection du membre
              Text(tr('Membre cotisant'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey('mem-$validTontineValue-$validMemberValue'),
                value: validMemberValue,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person, color: TontiColors.primaryGold)),
                items: !hasMembers
                    ? [DropdownMenuItem(value: '', child: Text(tr('Aucun membre disponible')))]
                    : membersList.map((m) {
                        return DropdownMenuItem(
                          value: m.id,
                          child: Text(m.canContribute ? m.fullName : tr('{fullName} (pénalités impayées)', {'fullName': m.fullName})),
                        );
                      }).toList(),
                onChanged: (val) {
                  if (val != null && val.isNotEmpty) setState(() => selectedMemberId = val);
                },
              ),
              if (_selectedPayer != null && !_selectedPayer!.canContribute) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TontiColors.alertSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TontiColors.alertRed.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block_rounded, color: TontiColors.alertRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr('Cotisation bloquée : {fullName} a {unpaidPenaltiesCount} pénalité(s) impayée(s) ({unpaidPenaltiesAmount}). Soldez les pénalités avant de cotiser.', {'fullName': _selectedPayer!.fullName, 'unpaidPenaltiesCount': _selectedPayer!.unpaidPenaltiesCount, 'unpaidPenaltiesAmount': Formatters.formatFCFA(_selectedPayer!.unpaidPenaltiesAmount)}),
                          style: TextStyle(fontSize: 12, color: TontiColors.alertRed, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_selectedPayer != null && _tontine != null && _hasAlreadyContributedThisPeriod(_selectedPayer!, _tontine!)) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TontiColors.warningSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TontiColors.warningOrange.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_available_rounded, color: TontiColors.warningOrange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr('Période déjà réglée : {fullName} a déjà cotisé pour cette période ({frequency}). Prochaine cotisation possible à la période suivante.', {'fullName': _selectedPayer!.fullName, 'frequency': _tontine?.frequency ?? 'Mensuelle'}),
                          style: TextStyle(fontSize: 12, color: TontiColors.warningText, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Montant en FCFA
              Text(tr('Montant versé (FCFA)'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                key: ValueKey('amt-$validTontineValue'),
                initialValue: amount > 0 ? amount.toInt().toString() : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money, color: TontiColors.primaryGold),
                  suffixText: 'FCFA',
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => amount = parsed);
                },
              ),
              if (_tontine != null && _tontine!.contributionAmount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  tr('Plafond mensuel / période : {contributionAmount} max', {'contributionAmount': Formatters.formatFCFA(_tontine!.contributionAmount)}),
                  style: TextStyle(fontSize: 11, color: TontiColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),

              // Mode de paiement
              Text(tr('Moyen de paiement utilisé'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentChip(PaymentMethod.mtnMoMo, tr('MTN MoMo'), Icons.phone_android),
                  const SizedBox(width: 8),
                  _buildPaymentChip(PaymentMethod.orangeMoney, tr('Orange Money'), Icons.mobile_friendly),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentChip(PaymentMethod.especes, tr('Espèces (Réunion)'), Icons.attach_money),
                  const SizedBox(width: 8),
                  _buildPaymentChip(PaymentMethod.virement, tr('Virement Bancaire'), Icons.account_balance),
                ],
              ),
              const SizedBox(height: 16),

              // Note de sécurité : Jamais de code PIN
              if (selectedMethod == PaymentMethod.mtnMoMo || selectedMethod == PaymentMethod.orangeMoney)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TontiColors.infoSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TontiColors.infoBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: TontiColors.infoBlue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr('Sécurité TontiLink : Aucun code secret PIN ne sera jamais demandé. Le débit est validé sur le téléphone du membre via USSD.'),
                          style: TextStyle(fontSize: 11, color: TontiColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),

              if (selectedMethod == PaymentMethod.especes)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TontiColors.warningSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TontiColors.warningBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.handshake_outlined, size: 16, color: TontiColors.warningOrange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr('Paiement en espèces : Le montant sera marqué "À vérifier" jusqu\'au rapprochement officiel par le Trésorier.'),
                          style: TextStyle(fontSize: 11, color: TontiColors.warningText),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Référence de transaction
              TextFormField(
                initialValue: externalReference,
                decoration: InputDecoration(
                  labelText: tr('Référence externe / Reçu papier'),
                  hintText: tr('ex: MOMO-CMR-9921 ou RECU-089'),
                ),
                onChanged: (val) => externalReference = val,
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TontiButton(
                    label: tr('Annuler'),
                    type: TontiButtonType.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  TontiButton(
                    label: (_selectedPayer != null && _tontine != null && _hasAlreadyContributedThisPeriod(_selectedPayer!, _tontine!))
                        ? tr('Période déjà réglée')
                        : (_selectedPayer != null && !_selectedPayer!.canContribute)
                            ? tr('Cotisation bloquée (Pénalités)')
                            : tr('Enregistrer le versement'),
                    icon: (_selectedPayer != null && _tontine != null && _hasAlreadyContributedThisPeriod(_selectedPayer!, _tontine!))
                        ? Icons.check_circle
                        : (_selectedPayer != null && !_selectedPayer!.canContribute)
                            ? Icons.block
                            : Icons.check_circle_outline,
                    isLoading: _isSaving,
                    onPressed: (_isSaving || _selectedPayer == null || !_selectedPayer!.canContribute || (_tontine != null && _hasAlreadyContributedThisPeriod(_selectedPayer!, _tontine!))) ? null : _submitPayment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentChip(PaymentMethod method, String label, IconData icon) {
    final isSelected = selectedMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedMethod = method),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? TontiColors.goldSoft : TontiColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? TontiColors.primaryGold : TontiColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? TontiColors.darkGold : TontiColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPayment() async {
    final tontine = _tontine;
    final payer = _members.firstWhere(
      (m) => m.id == selectedMemberId,
      orElse: () => _members.isNotEmpty ? _members.first : MemberEntity(
        id: '', fullName: '', phone: '', role: MemberRole.membre, status: MemberStatus.actif,
        avatarInitials: '', totalContributed: 0, totalExpected: 0, joinedDate: DateTime.now(), payoutTurn: 0,
      ),
    );
    if (tontine == null || payer.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Sélectionnez une tontine et un membre.'))),
      );
      return;
    }

    final newTxn = TransactionModel(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      tontineName: tontine.name,
      memberName: payer.fullName,
      type: TransactionType.cotisation,
      amount: amount,
      paymentMethod: selectedMethod,
      status: selectedMethod == PaymentMethod.especes
          ? TransactionStatus.aVerifier
          : TransactionStatus.confirme,
      date: DateTime.now(),
      reference: externalReference,
      validatedBy: selectedMethod == PaymentMethod.especes ? null : tr('Automate Paiement'),
      note: note,
    );

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Saisissez un montant supérieur à 0.'))),
      );
      return;
    }
    if (tontine.contributionAmount > 0 && amount > tontine.contributionAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Montant invalide : Le versement ({amount}) dépasse le plafond défini pour ce mois ({contributionAmount}).', {'amount': Formatters.formatFCFA(amount), 'contributionAmount': Formatters.formatFCFA(tontine.contributionAmount)}),
          ),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }
    if (!payer.canContribute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Cotisation bloquée : {fullName} a {unpaidPenaltiesCount} pénalité(s) impayée(s) ({unpaidPenaltiesAmount}). Soldez-les d\'abord.', {'fullName': payer.fullName, 'unpaidPenaltiesCount': payer.unpaidPenaltiesCount, 'unpaidPenaltiesAmount': Formatters.formatFCFA(payer.unpaidPenaltiesAmount)}),
          ),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }
    if (_tontine != null && _hasAlreadyContributedThisPeriod(payer, _tontine!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Paiement refusé : {fullName} a déjà cotisé pour cette période ({toLowerCase}). Prochaine contribution permise à la période suivante.', {'fullName': payer.fullName, 'toLowerCase': (_tontine?.frequency?.toString() ?? 'Mensuelle').toLowerCase()}),
          ),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }
    final adhesionId = LocalTontiDataSource.numericId(payer.id);
    if (adhesionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Adhésion introuvable pour ce membre.'))),
      );
      return;
    }
    setState(() => _isSaving = true);
    final saved = await LocalTontiDataSource().recordPayment(
      newTxn,
      adhesionId: adhesionId,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (!saved) {
      final errorMsg = LocalTontiDataSource().lastSyncError ??
          'Le backend a refusé la cotisation. Elle n’a pas été enregistrée.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }

    widget.onPaymentRecorded(newTxn);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Paiement de {amount} enregistré avec succès !', {'amount': Formatters.formatFCFA(amount)})),
        backgroundColor: TontiColors.successGreen,
      ),
    );
  }
}
