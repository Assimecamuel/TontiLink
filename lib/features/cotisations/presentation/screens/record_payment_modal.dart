import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction.dart';
import '../../../../shared/widgets/common/tonti_button.dart';

class RecordPaymentModal extends StatefulWidget {
  final ValueChanged<Transaction> onPaymentRecorded;

  const RecordPaymentModal({
    super.key,
    required this.onPaymentRecorded,
  });

  @override
  State<RecordPaymentModal> createState() => _RecordPaymentModalState();
}

class _RecordPaymentModalState extends State<RecordPaymentModal> {
  String selectedMember = 'Paul Eric Kamdem';
  String selectedTontine = 'Tontine des Commerçants Mokolo';
  double amount = 100000;
  PaymentMethod selectedMethod = PaymentMethod.mtnMoMo;
  String externalReference = '';
  String note = 'Cotisation Tour #7';

  @override
  void initState() {
    super.initState();
    externalReference = 'MOMO-CMR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    // Tontines uniques pour le dropdown
    final rawTontines = sl.tontinesController.tontines;
    final Map<String, String> uniqueTontines = {};
    for (final t in rawTontines) {
      if (t.name.isNotEmpty) {
        uniqueTontines.putIfAbsent(t.name, () => t.name);
      }
    }
    final tontineNames = uniqueTontines.keys.toList();
    final bool hasTontines = tontineNames.isNotEmpty;
    final String validTontineValue = hasTontines
        ? (tontineNames.contains(selectedTontine) ? selectedTontine : tontineNames.first)
        : '';

    // Membres uniques pour le dropdown
    final rawMembers = sl.membersController.members;
    final Map<String, String> uniqueMembers = {};
    for (final m in rawMembers) {
      if (m.fullName.isNotEmpty) {
        uniqueMembers.putIfAbsent(m.fullName, () => m.fullName);
      }
    }
    final memberNames = uniqueMembers.keys.toList();
    final bool hasMembers = memberNames.isNotEmpty;
    final String validMemberValue = hasMembers
        ? (memberNames.contains(selectedMember) ? selectedMember : memberNames.first)
        : '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                          Text('Enregistrer une Cotisation', style: TontiTypography.headingMedium),
                          const Text('Saisie et rapprochement comptable', style: TextStyle(fontSize: 12, color: TontiColors.textSecondary)),
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
              const Text('Groupe / Tontine concernée', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey('tontine-$validTontineValue'),
                value: validTontineValue,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance, color: TontiColors.primaryGold)),
                items: !hasTontines
                    ? const [DropdownMenuItem(value: '', child: Text('Aucune tontine disponible'))]
                    : tontineNames.map((name) {
                        return DropdownMenuItem(value: name, child: Text(name, overflow: TextOverflow.ellipsis));
                      }).toList(),
                onChanged: (val) {
                  if (val != null && val.isNotEmpty) setState(() => selectedTontine = val);
                },
              ),
              const SizedBox(height: 14),

              // Sélection du membre
              const Text('Membre cotisant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey('mem-$validMemberValue'),
                value: validMemberValue,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person, color: TontiColors.primaryGold)),
                items: !hasMembers
                    ? const [DropdownMenuItem(value: '', child: Text('Aucun membre disponible'))]
                    : memberNames.map((name) {
                        return DropdownMenuItem(value: name, child: Text(name));
                      }).toList(),
                onChanged: (val) {
                  if (val != null && val.isNotEmpty) setState(() => selectedMember = val);
                },
              ),
              const SizedBox(height: 14),

              // Montant en FCFA
              const Text('Montant versé (FCFA)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: amount.toInt().toString(),
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
              const SizedBox(height: 16),

              // Mode de paiement
              const Text('Moyen de paiement utilisé', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentChip(PaymentMethod.mtnMoMo, 'MTN MoMo', Icons.phone_android),
                  const SizedBox(width: 8),
                  _buildPaymentChip(PaymentMethod.orangeMoney, 'Orange Money', Icons.mobile_friendly),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentChip(PaymentMethod.especes, 'Espèces (Réunion)', Icons.attach_money),
                  const SizedBox(width: 8),
                  _buildPaymentChip(PaymentMethod.virement, 'Virement Bancaire', Icons.account_balance),
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
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: TontiColors.infoBlue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sécurité TontiLink : Aucun code secret PIN ne sera jamais demandé. Le débit est validé sur le téléphone du membre via USSD.',
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
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.handshake_outlined, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paiement en espèces : Le montant sera marqué "À vérifier" jusqu\'au rapprochement officiel par le Trésorier.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Référence de transaction
              TextFormField(
                initialValue: externalReference,
                decoration: const InputDecoration(
                  labelText: 'Référence externe / Reçu papier',
                  hintText: 'ex: MOMO-CMR-9921 ou RECU-089',
                ),
                onChanged: (val) => externalReference = val,
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TontiButton(
                    label: 'Annuler',
                    type: TontiButtonType.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  TontiButton(
                    label: 'Enregistrer le versement',
                    icon: Icons.check_circle_outline,
                    onPressed: _submitPayment,
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
            color: isSelected ? TontiColors.goldSoft : TontiColors.white,
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

  void _submitPayment() {
    final newTxn = Transaction(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      tontineName: selectedTontine,
      memberName: selectedMember,
      type: TransactionType.cotisation,
      amount: amount,
      paymentMethod: selectedMethod,
      status: selectedMethod == PaymentMethod.especes
          ? TransactionStatus.aVerifier
          : TransactionStatus.confirme,
      date: DateTime.now(),
      reference: externalReference,
      validatedBy: selectedMethod == PaymentMethod.especes ? null : 'Automate Paiement',
      note: note,
    );

    widget.onPaymentRecorded(newTxn);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement de ${Formatters.formatFCFA(amount)} enregistré avec succès !'),
        backgroundColor: TontiColors.successGreen,
      ),
    );
  }
}

