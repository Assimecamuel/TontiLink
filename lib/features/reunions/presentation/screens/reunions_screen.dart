import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/meeting.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class ReunionsScreen extends StatefulWidget {
  const ReunionsScreen({super.key});

  @override
  State<ReunionsScreen> createState() => _ReunionsScreenState();
}

class _ReunionsScreenState extends State<ReunionsScreen> {
  Meeting? currentMeeting;

  @override
  void initState() {
    super.initState();
    final meetings = sl.reunionsController.meetings;
    if (meetings.isNotEmpty) {
      currentMeeting = meetings.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final meeting = currentMeeting;

    if (meeting == null) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Aucune réunion enregistrée pour le moment.',
            style: TextStyle(fontSize: 16, color: TontiColors.textSecondary),
          ),
        ),
      );
    }

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
                      Text('Réunions Présentielles & Émargement', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Mode séance en direct : tenue de réunion physique, présence et collecte cash rapide',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiBadge(
                    label: 'Séance Prochaine : Dans 4 jours',
                    variant: BadgeVariant.gold,
                    icon: Icons.event,
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
                              child: const Icon(Icons.groups, color: TontiColors.primaryGold, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meeting.title, style: TontiTypography.headingLarge),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 16, color: TontiColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(meeting.location, style: TontiTypography.bodySmall),
                                    const SizedBox(width: 12),
                                    Icon(Icons.person_outline, size: 16, color: TontiColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('Hôte : ${meeting.hostName}', style: TontiTypography.bodySmall),
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
                              const SnackBar(content: Text('Séance ouverte ! La feuille d\'émargement est synchronisée.')),
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
                        meeting.minutesSummary,
                        style: TextStyle(fontSize: 13, height: 1.5, color: TontiColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Feuille d'émargement et Saisie rapide en direct
              Text('Feuille d\'émargement & Saisie des espèces en séance', style: TontiTypography.headingMedium),
              const SizedBox(height: 4),
              Text(
                'Cochez la présence et saisissez les montants reçus en direct par le trésorier',
                style: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
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
                  itemCount: meeting.attendanceList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = meeting.attendanceList[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.isPresent,
                            activeColor: TontiColors.primaryGold,
                            onChanged: (val) {
                              setState(() {
                                meeting.attendanceList[index] =
                                    item.copyWith(isPresent: val ?? false);
                              });
                            },
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
                                    color: item.isPresent ? TontiColors.textPrimary : TontiColors.textSecondary,
                                  ),
                                ),
                                if (item.note.isNotEmpty)
                                  Text(
                                    item.note,
                                    style: TextStyle(fontSize: 11.5, color: TontiColors.darkGold, fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              TontiButton(
                                label: 'Encaisser Cash (100k)',
                                icon: Icons.attach_money,
                                type: TontiButtonType.secondary,
                                height: 34,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Reçu cash de 100 000 FCFA émis pour ${item.memberName} !'),
                                      backgroundColor: TontiColors.successGreen,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.print_outlined, size: 20),
                                tooltip: 'Imprimer reçu thermique',
                                onPressed: () {},
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

