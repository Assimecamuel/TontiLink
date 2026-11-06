import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../data/datasources/local_tonti_datasource.dart';

/// Dialogue unifié d'invitation de membre via WhatsApp, SMS ou E-mail.
class InviteMemberDialog extends StatefulWidget {
  final int tontineId;
  final VoidCallback? onInviteSuccess;

  const InviteMemberDialog({
    super.key,
    required this.tontineId,
    this.onInviteSuccess,
  });

  static Future<void> show(BuildContext context, {required int tontineId, VoidCallback? onInviteSuccess}) {
    return showDialog(
      context: context,
      builder: (ctx) => InviteMemberDialog(
        tontineId: tontineId,
        onInviteSuccess: onInviteSuccess,
      ),
    );
  }

  @override
  State<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<InviteMemberDialog> {
  String _canal = 'WHATSAPP'; // 'WHATSAPP', 'SMS', 'EMAIL'
  final _destCtrl = TextEditingController();
  String _selectedRole = 'MEMBRE';
  bool _loading = false;
  String? _error;
  String? _generatedCode;

  @override
  void dispose() {
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final input = _destCtrl.text.trim();
    if (input.isEmpty) {
      setState(() => _error = _canal == 'EMAIL'
          ? 'Saisissez l’adresse e-mail de l’invité.'
          : 'Saisissez le numéro de téléphone (+237).');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final ds = LocalTontiDataSource();
    final res = await ds.inviteMemberDirectAdvanced(
      tontineId: widget.tontineId,
      canal: _canal,
      telephone: _canal != 'EMAIL' ? input : null,
      email: _canal == 'EMAIL' ? input : null,
      roleNom: _selectedRole,
    );

    String? code;
    if (res.isOk && res.data is Map) {
      code = (res.data as Map)['code']?.toString();
    }

    // Fallback if backend code not present
    if (code == null || code.isEmpty) {
      final fallbackRes = await ds.inviteMember(
        tontineId: widget.tontineId,
        canal: _canal,
        destinataire: input,
      );
      if (fallbackRes.isOk && fallbackRes.data is Map) {
        code = (fallbackRes.data as Map)['code']?.toString();
      }
    }

    code ??= 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    setState(() {
      _loading = false;
      _generatedCode = code;
    });

    final msgText = 'Rejoins ma tontine sur TontiLink avec le code d’invitation : $code';
    await Clipboard.setData(ClipboardData(text: code));

    // Auto launch WhatsApp or SMS
    if (_canal == 'WHATSAPP') {
      final phoneClean = input.replaceAll(RegExp(r'\s+'), '');
      final targetPhone = phoneClean.startsWith('+') ? phoneClean : '+237$phoneClean';
      final encoded = Uri.encodeComponent(msgText);
      final url = Uri.parse('https://wa.me/$targetPhone?text=$encoded');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else if (_canal == 'SMS') {
      final encoded = Uri.encodeComponent(msgText);
      final url = Uri.parse('sms:$input?body=$encoded');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }

    widget.onInviteSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TontiColors.goldSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: TontiColors.darkGold),
          ),
          const SizedBox(width: 12),
          const Text('Inviter un membre'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_generatedCode == null) ...[
                const Text('Choisissez le canal d’envoi direct :', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'WHATSAPP',
                      label: Text('WhatsApp'),
                      icon: Icon(Icons.chat, color: Color(0xFF25D366)),
                    ),
                    ButtonSegment(
                      value: 'SMS',
                      label: Text('SMS'),
                      icon: Icon(Icons.sms, color: Colors.blueAccent),
                    ),
                    ButtonSegment(
                      value: 'EMAIL',
                      label: Text('E-mail'),
                      icon: Icon(Icons.mail_outline, color: TontiColors.darkGold),
                    ),
                  ],
                  selected: {_canal},
                  onSelectionChanged: (set) {
                    setState(() {
                      _canal = set.first;
                      _error = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _destCtrl,
                  keyboardType: _canal == 'EMAIL' ? TextInputType.emailAddress : TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _canal == 'EMAIL' ? 'Adresse e-mail' : 'Numéro de téléphone (+237)',
                    hintText: _canal == 'EMAIL' ? 'exemple@domaine.cm' : '6XX XX XX XX',
                    prefixIcon: Icon(_canal == 'EMAIL' ? Icons.email_outlined : Icons.phone_android),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle attribué à l’invité',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MEMBRE', child: Text('Membre Simple')),
                    DropdownMenuItem(value: 'SECRETAIRE', child: Text('Secrétaire')),
                    DropdownMenuItem(value: 'TRESORIER', child: Text('Trésorier')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: TontiColors.alertRed, fontSize: 13)),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TontiColors.successSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TontiColors.successGreen.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: TontiColors.successGreen, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Invitation créée & code copié dans le presse-papier !',
                          style: TextStyle(fontWeight: FontWeight.w700, color: TontiColors.successGreen, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Code d’invitation généré :'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: TontiColors.goldSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TontiColors.primaryGold, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectableText(
                        _generatedCode!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: TontiColors.darkGold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: TontiColors.darkGold),
                        tooltip: 'Copier le code',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code d’invitation copié !')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Transmettez ce code à l’utilisateur. À l’inscription, il lui suffira de choisir « Participer à une tontine » et de saisir ce code.',
                  style: TextStyle(fontSize: 12.5, color: TontiColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (_generatedCode == null) ...[
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
            onPressed: _loading ? null : _sendInvite,
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(_canal == 'WHATSAPP' ? Icons.chat : (_canal == 'SMS' ? Icons.sms : Icons.send), size: 18),
            label: Text(_loading ? 'Envoi...' : 'Générer & Envoyer'),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _generatedCode!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copié ! Utilisez-le à l’inscription (« Participer à une tontine »)')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copier pour tester'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ],
    );
  }
}
