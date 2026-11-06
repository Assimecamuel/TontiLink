import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../models/meeting_model.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';

class ReunionsScreen extends StatefulWidget {
  final String activeRole;

  const ReunionsScreen({
    super.key,
    this.activeRole = 'Président',
  });

  @override
  State<ReunionsScreen> createState() => _ReunionsScreenState();
}

class _ReunionsScreenState extends State<ReunionsScreen> {
  late MeetingModel currentMeeting;
  bool _meetingReady = false;
  int? _updatingAttendanceIndex;
  int? _recordingCashIndex;

  @override
  void initState() {
    super.initState();
    if (MockTontiData.meetings.isNotEmpty) {
      currentMeeting = MockTontiData.meetings.first;
      _meetingReady = true;
    }
  }

  Future<void> _setAttendance(int index, bool isPresent) async {
    setState(() => _updatingAttendanceIndex = index);
    final updated = await LocalTontiDataSource().updateMeetingAttendance(
      meetingId: currentMeeting.id,
      memberIndex: index,
      isPresent: isPresent,
    );
    if (!mounted) return;
    setState(() => _updatingAttendanceIndex = null);
    if (!updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La présence n’a pas été enregistrée par le serveur.'),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }
    setState(() {});
  }

  Future<void> _recordCashPayment(int index) async {
    final attendee = currentMeeting.attendanceList[index];
    final adhesionId =
        int.tryParse(attendee.memberId.replaceAll(RegExp(r'[^0-9]'), ''));
    if (adhesionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identifiant d’adhésion manquant pour ce membre.'),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }

    // Montant = cotisation de la tontine concernée (base de données).
    double due = 0;
    for (final t in LocalTontiDataSource().tontines) {
      if (t.id == currentMeeting.tontineId) due = t.contributionAmount;
    }
    if (due <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant de cotisation introuvable pour cette tontine.'),
          backgroundColor: TontiColors.alertRed,
        ),
      );
      return;
    }
    setState(() => _recordingCashIndex = index);
    final now = DateTime.now();
    final transaction = TransactionEntity(
      id: 'TXN-${now.millisecondsSinceEpoch}',
      tontineName: currentMeeting.tontineName,
      memberName: attendee.memberName,
      type: TransactionType.cotisation,
      amount: due,
      paymentMethod: PaymentMethod.especes,
      status: TransactionStatus.aVerifier,
      date: now,
      reference: 'RECU-${now.millisecondsSinceEpoch}',
      note: 'Cotisation en espèces reçue pendant une réunion',
    );
    final saved = await LocalTontiDataSource().recordPayment(
      transaction,
      adhesionId: adhesionId,
      reunionId: LocalTontiDataSource.numericId(currentMeeting.id),
    );
    if (!mounted) return;
    setState(() => _recordingCashIndex = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Versement de ${Formatters.formatFCFA(due)} enregistré pour ${attendee.memberName}.'
              : 'Le versement en espèces n’a pas été enregistré par le serveur.',
        ),
        backgroundColor:
            saved ? TontiColors.successGreen : TontiColors.alertRed,
      ),
    );
  }

  String? get _nextMeetingLabel {
    final now = DateTime.now();
    DateTime? next;
    for (final m in MockTontiData.meetings) {
      if (m.dateTime.isAfter(now) && (next == null || m.dateTime.isBefore(next))) next = m.dateTime;
    }
    if (next == null) return null;
    final d = next.difference(now).inDays;
    return d <= 0 ? 'Séance prochaine : aujourd\'hui' : 'Séance prochaine : dans $d jours';
  }

  Future<void> _showCreateMeetingDialog(BuildContext context) async {
    final tontines = MockTontiData.tontines;
    if (tontines.isEmpty) return;
    var tontineId = tontines.first.id;
    DateTime? date;
    final lieu = TextEditingController();
    final ordre = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Planifier une réunion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    final Map<String, String> uniqueTontinesMap = {};
                    for (final t in tontines) {
                      if (t.id.isNotEmpty) {
                        uniqueTontinesMap.putIfAbsent(t.id, () => t.name);
                      }
                    }
                    final bool hasTontines = uniqueTontinesMap.isNotEmpty;
                    final String validTontineId = hasTontines
                        ? (uniqueTontinesMap.containsKey(tontineId) ? tontineId : uniqueTontinesMap.keys.first)
                        : '';
                    return DropdownButtonFormField<String>(
                      value: validTontineId,
                      items: !hasTontines
                          ? const [DropdownMenuItem(value: '', child: Text('Aucune tontine disponible'))]
                          : uniqueTontinesMap.entries
                              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                              .toList(),
                      onChanged: (v) => setLocal(() => tontineId = v ?? tontineId),
                      decoration: const InputDecoration(labelText: 'Tontine'),
                    );
                  },
                ),
                TextField(controller: lieu, decoration: const InputDecoration(labelText: 'Lieu')),
                TextField(controller: ordre, decoration: const InputDecoration(labelText: 'Ordre du jour')),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(date == null
                      ? 'Choisir date et heure'
                      : '${date!.day}/${date!.month}/${date!.year} ${date!.hour}h${date!.minute.toString().padLeft(2, '0')}'),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (d == null || !ctx.mounted) return;
                    final t = await showTimePicker(context: ctx, initialTime: const TimeOfDay(hour: 18, minute: 0));
                    if (t == null) return;
                    setLocal(() => date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (date == null || lieu.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Renseignez le lieu, la date et l\'heure.')),
                  );
                  return;
                }
                final id = LocalTontiDataSource.numericId(tontineId);
                if (id == null) return;
                final res = await LocalTontiDataSource().createMeeting(
                  tontineId: id,
                  date: date!,
                  lieu: lieu.text.trim(),
                  ordreDuJour: ordre.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(ctx);
                setState(() {
                  _meetingReady = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.isOk ? 'Réunion planifiée.' : (res.message ?? 'Refusé par le serveur.')),
                    backgroundColor: res.isOk ? TontiColors.successGreen : TontiColors.alertRed,
                  ),
                );
              },
              child: const Text('Planifier'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_meetingReady) {
      if (MockTontiData.meetings.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Aucune réunion planifiée pour vos tontines.'),
                const SizedBox(height: 16),
                if (MockTontiData.tontines.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _showCreateMeetingDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Planifier une réunion'),
                  ),
              ],
            ),
          ),
        );
      }
      currentMeeting = MockTontiData.meetings.first;
      _meetingReady = true;
    }
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Réunions Présentielles & Émargement',
                          style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Mode séance en direct : tenue de réunion physique, présence et collecte cash rapide',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_nextMeetingLabel != null) ...[
                        TontiBadge(
                          label: _nextMeetingLabel!,
                          variant: BadgeVariant.gold,
                          icon: Icons.event,
                        ),
                        const SizedBox(width: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => _showCreateMeetingDialog(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Planifier'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Carte de la réunion active
              TontiCard(
                padding: const EdgeInsets.all(24),
                hasGoldBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TontiColors.goldSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.groups,
                                  color: TontiColors.primaryGold, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentMeeting.title,
                                    style: TontiTypography.headingLarge),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 16,
                                        color: TontiColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(currentMeeting.location,
                                        style: TontiTypography.bodySmall),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.person_outline,
                                        size: 16,
                                        color: TontiColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('Hôte : ${currentMeeting.hostName}',
                                        style: TontiTypography.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        TontiButton(
                          label: 'Ouvrir la séance en direct',
                          icon: Icons.play_arrow,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Séance ouverte ! La feuille d\'émargement est synchronisée.')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: TontiColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TontiColors.border),
                      ),
                      child: Text(
                        currentMeeting.minutesSummary,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: TontiColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Feuille d'émargement et Saisie rapide en direct
              Text('Feuille d\'émargement & Saisie des espèces en séance',
                  style: TontiTypography.headingMedium),
              const SizedBox(height: 4),
              const Text(
                'Cochez la présence et saisissez les montants reçus en direct par le trésorier',
                style:
                    TextStyle(fontSize: 12, color: TontiColors.textSecondary),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: TontiColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TontiColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentMeeting.attendanceList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = currentMeeting.attendanceList[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.isPresent,
                            activeColor: TontiColors.primaryGold,
                            onChanged: (widget.activeRole == 'Secrétaire' ||
                                        widget.activeRole == 'Président') &&
                                    _updatingAttendanceIndex == null
                                ? (val) {
                                    if (val != null) {
                                      _setAttendance(index, val);
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.memberName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: item.isPresent
                                        ? TontiColors.textPrimary
                                        : TontiColors.textSecondary,
                                  ),
                                ),
                                if (item.note.isNotEmpty)
                                  Text(
                                    item.note,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: TontiColors.darkGold,
                                        fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (widget.activeRole == 'Trésorier' ||
                                  widget.activeRole == 'Président') ...[
                                TontiButton(
                                  label: 'Encaisser Cash (100k)',
                                  icon: Icons.attach_money,
                                  type: TontiButtonType.secondary,
                                  height: 34,
                                  onPressed: _recordingCashIndex == null
                                      ? () => _recordCashPayment(index)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.print_outlined,
                                      size: 20),
                                  tooltip: 'Imprimer reçu thermique',
                                  onPressed: () {},
                                ),
                              ] else
                                const TontiBadge(
                                  label: 'Émargé en séance',
                                  variant: BadgeVariant.neutral,
                                  isSmall: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
