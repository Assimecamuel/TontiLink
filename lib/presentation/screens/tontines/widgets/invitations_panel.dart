import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../data/datasources/local_tonti_datasource.dart';
import '../../../widgets/common/invite_member_dialog.dart';

/// Panneau « Invitations & utilisateurs visibles » d'une tontine.
///
/// - Le président / fondateur peut inviter (lien ou e-mail) et voit les
///   invitations qu'il a émises.
/// - Les utilisateurs listés viennent de GET /api/comptes/utilisateurs/ :
///   le serveur ne renvoie que les personnes invitées par l'utilisateur
///   connecté (ou les membres des tontines partagées).
class InvitationsPanel extends StatefulWidget {
  final int? tontineNumericId;
  final bool canInvite;
  final VoidCallback? onChanged;

  const InvitationsPanel({
    super.key,
    required this.tontineNumericId,
    required this.canInvite,
    this.onChanged,
  });

  @override
  State<InvitationsPanel> createState() => _InvitationsPanelState();
}

class _InvitationsPanelState extends State<InvitationsPanel> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await LocalTontiDataSource().syncFromBackend();
    if (!mounted) return;
    setState(() => _refreshing = false);
    widget.onChanged?.call();
  }

  Future<void> _openInviteDialog() async {
    final tid = widget.tontineNumericId;
    if (tid == null) return;
    await InviteMemberDialog.show(
      context,
      tontineId: tid,
      onInviteSuccess: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = LocalTontiDataSource();
    final invites = ds.sentInvites;
    final users = ds.visibleUsers;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TontiColors.goldSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TontiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group_add_outlined, color: TontiColors.darkGold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Invitations & utilisateurs',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              IconButton(
                tooltip: 'Actualiser',
                onPressed: _refreshing ? null : _refresh,
                icon: _refreshing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
              ),
              if (widget.canInvite)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
                  onPressed: _openInviteDialog,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Inviter'),
                ),
            ],
          ),
          if (widget.canInvite && invites.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Invitations envoyées', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ...invites.map((i) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mark_email_read_outlined, size: 20),
                  title: Text((i['destinataire'] ?? i['email'] ?? '—').toString()),
                  subtitle: Text('Code : ${i['code'] ?? '—'}'),
                  trailing: Text((i['statut'] ?? '').toString(),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                )),
          ],
          if (users.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              widget.canInvite ? 'Utilisateurs que vous avez invités' : 'Utilisateurs visibles',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            ...users.map((u) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline, size: 20),
                  title: Text((u['nom'] ?? '—').toString()),
                  subtitle: Text((u['email'] ?? u['telephone'] ?? '').toString()),
                )),
          ],
          if (invites.isEmpty && users.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucune invitation pour le moment.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }
}
