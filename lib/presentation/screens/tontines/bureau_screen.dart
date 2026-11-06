import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../models/tontine_model.dart';

/// Champ d'un formulaire de saisie rapide.
class _Field {
  final String label;
  final TextInputType? type;
  final bool required;
  final String initial;
  const _Field(this.label, {this.type, this.required = true, this.initial = ''});
}

/// Gestion avancée d'une tontine (contrat API) :
/// cycles personnalisés et clôtures, départ de membre avec compensation,
/// compensations de dettes, répartition de la caisse de pénalités et
/// notifications WhatsApp. Les règles métier sont appliquées par le backend :
/// ses messages (HTTP 400 / 403) sont affichés tels quels.
class BureauScreen extends StatefulWidget {
  final TontineModel tontine;
  const BureauScreen({super.key, required this.tontine});

  @override
  State<BureauScreen> createState() => _BureauScreenState();
}

class _BureauScreenState extends State<BureauScreen> {
  final LocalTontiDataSource _ds = LocalTontiDataSource();
  int _reload = 0;
  bool _busy = false;

  int? get _tid => LocalTontiDataSource.numericId(widget.tontine.id);
  int? get _cycleId => _ds.cycleIdFor(_tid);

  bool get _isPresident => _ds.currentUser.isPresident;
  bool get _isBureau => _ds.currentUser.isPresident || _ds.currentUser.isTreasurer;
  // WhatsApp : SECRETAIRE, PRESIDENT ou FONDATEUR uniquement (403 sinon).
  bool get _canNotify => _ds.currentUser.isPresident || _ds.currentUser.isSecretary;

  // ------------------------------------------------------------------
  // Outils communs & Notifications
  // ------------------------------------------------------------------

  void _snack(String msg, {bool ok = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: ok ? TontiColors.successGreen : TontiColors.alertRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  List<Map<String, dynamic>> _asMaps(dynamic d) {
    final dynamic raw = d is List ? d : (d is Map ? (d['results'] ?? d['data'] ?? const []) : const []);
    return raw is List ? raw.whereType<Map<String, dynamic>>().toList() : <Map<String, dynamic>>[];
  }

  String _s(dynamic v) => v == null ? '' : v.toString();

  /// Exécute une action d'écriture et affiche le message du serveur.
  Future<void> _call(
    Future<ApiResponse> Function() action,
    String okMsg, {
    bool showData = false,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r.isOk) _reload++;
    });
    _snack(
      r.isOk ? (r.message ?? okMsg) : (r.message ?? 'Refusé par le serveur (HTTP ${r.statusCode}).'),
      ok: r.isOk,
    );
  }

  /// Lecture / simulation : affiche la réponse du serveur sans rien modifier.
  Future<void> _view(Future<ApiResponse> Function() loader, String title) async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = await loader();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.isOk) {
      _snack(r.message ?? 'Refusé par le serveur (HTTP ${r.statusCode}).', ok: false);
      return;
    }
    await _showFrontendView(title, r.data);
  }

  Future<void> _showFrontendView(String title, dynamic data) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TontiColors.goldSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics_outlined, color: TontiColors.darkGold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TontiTypography.headingMedium),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: _buildFrontendContent(data),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TontiColors.primaryGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool _isHiddenKey(String key) {
    final lower = key.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return lower == 'id' || lower.contains('id');
  }

  Widget _buildFrontendContent(dynamic data, {int depth = 0}) {
    if (data is List) {
      if (data.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in data)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildFrontendContent(item, depth: depth + 1),
            ),
        ],
      );
    } else if (data is Map) {
      return Container(
        margin: EdgeInsets.only(top: depth > 0 ? 6 : 0),
        padding: EdgeInsets.all(depth > 0 ? 12 : 16),
        decoration: BoxDecoration(
          color: depth > 0 ? TontiColors.cardSubtle : TontiColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TontiColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in data.entries)
              if (!_isHiddenKey(entry.key) && entry.value != null && entry.value.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: entry.value is Map || entry.value is List
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatKey(entry.key),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TontiColors.darkGold),
                            ),
                            const SizedBox(height: 4),
                            _buildFrontendContent(entry.value, depth: depth + 1),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatKey(entry.key),
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: depth > 0 ? 12 : 13, color: TontiColors.textSecondary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _formatValue(entry.key, entry.value),
                                textAlign: TextAlign.end,
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: depth > 0 ? 12.5 : 14, color: TontiColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                ),
          ],
        ),
      );
    }
    return Text(data?.toString() ?? '—', style: const TextStyle(fontSize: 13));
  }

  String _formatKey(String key) {
    switch (key.toLowerCase()) {
      case 'id': return 'Identifiant';
      case 'tontine_id': return 'ID Tontine';
      case 'numero': return 'Numéro du cycle';
      case 'datedebut': case 'date_debut': return 'Date de début';
      case 'datefin': case 'date_fin': return 'Date de fin';
      case 'statut': return 'Statut';
      case 'adhesion_id': return 'ID Adhésion';
      case 'dateattendue': case 'date_attendue': return 'Date attendue';
      case 'montantattendu': case 'montant_attendu': return 'Montant attendu';
      case 'montantregle': case 'montant_regle': return 'Montant réglé';
      case 'montant': return 'Montant';
      case 'motif': return 'Motif';
      case 'beneficiaire_nom': case 'membre_nom': return 'Membre';
      default:
        return key.replaceAll('_', ' ').replaceAllMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
    }
  }

  String _formatValue(String key, dynamic val) {
    final s = val.toString();
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('montant') || lowerKey.contains('solde') || lowerKey.contains('prix')) {
      final n = double.tryParse(s);
      if (n != null) return Formatters.formatFCFA(n);
    }
    if (s == 'EN_COURS') return 'En cours';
    if (s == 'REGLEE') return 'Réglée';
    if (s == 'A_VENIR') return 'À venir';
    if (s == 'CLOTURE') return 'Clôturé';
    return s;
  }

  Future<bool> _confirm(String title, String body) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: TontiColors.alertRed, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TontiTypography.headingMedium)),
          ],
        ),
        content: Text(body, style: TontiTypography.bodyMedium),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: TontiColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: TontiColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TontiColors.alertRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return r == true;
  }

  Future<Map<String, String>?> _form(String title, List<_Field> fields) {
    final ctrls = fields.map((f) => TextEditingController(text: f.initial)).toList();
    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TontiTypography.headingMedium),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < fields.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: ctrls[i],
                    keyboardType: fields[i].type,
                    decoration: InputDecoration(
                      labelText: fields[i].label,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: TontiColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: TontiColors.primaryGold, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: TontiColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TontiColors.primaryGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              for (var i = 0; i < fields.length; i++) {
                if (fields[i].required && ctrls[i].text.trim().isEmpty) return;
              }
              Navigator.pop(ctx, {for (var i = 0; i < fields.length; i++) fields[i].label: ctrls[i].text.trim()});
            },
            child: const Text('Valider', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _pick(
    String title,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) label,
  ) {
    if (items.isEmpty) {
      _snack('Aucun élément disponible.', ok: false);
      return Future.value(null);
    }
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TontiTypography.headingMedium),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final i in items)
                    SimpleDialogOption(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      onPressed: () => Navigator.pop(ctx, i),
                      child: Text(label(i), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Widgets de présentation & Composants Design System
  // ------------------------------------------------------------------

  String _formatNotifType(String t) {
    switch (t.toUpperCase()) {
      case 'TOUR_CAGNOTTE': return 'Alerte de tour';
      case 'PENALITE_COTISATON': case 'PENALITE': return 'Avis de pénalité';
      case 'RAPPEL_COTISATION': return 'Rappel de cotisation';
      case 'CONVOCATION_REUNION': return 'Convocation réunion';
      case 'ANNONCE': return 'Annonce officielle';
      default: return t.replaceAll('_', ' ');
    }
  }

  String _formatDeliveryStatus(String s) {
    switch (s.toUpperCase()) {
      case 'LIVRE': case 'ENVOYE': return 'Livré avec succès';
      case 'NON_ENVOYE': return 'En attente d\'envoi';
      case 'ECHEC': return 'Échec d\'envoi';
      default: return s.replaceAll('_', ' ');
    }
  }

  /// Banner d'information responsive et élégante
  Widget _infoBanner(String text, {bool warning = false, String? title, IconData? icon}) {
    final bg = warning ? TontiColors.warningSoft : TontiColors.goldLightest;
    final borderColor = warning ? TontiColors.warningOrange.withOpacity(0.35) : TontiColors.primaryGold.withOpacity(0.35);
    final iconColor = warning ? Colors.orange[800] : TontiColors.darkGold;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: warning ? TontiColors.warningOrange.withOpacity(0.15) : TontiColors.primaryGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? (warning ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: warning ? Colors.orange[900] : TontiColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: warning ? Colors.orange[900] : TontiColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Titre de section stylisé
  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: TontiColors.darkGold),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: TontiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'action moderne (remplace les boutons géants étirés)
  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool danger = false,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TontiColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger ? TontiColors.alertRed.withOpacity(0.3) : TontiColors.border,
          width: 1,
        ),
        boxShadow: [TontiColors.softShadow],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _busy ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: danger ? TontiColors.alertRed.withOpacity(0.04) : TontiColors.primaryGold.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor ?? (danger ? TontiColors.alertSoft : TontiColors.goldLightest),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? (danger ? TontiColors.alertRed : TontiColors.darkGold),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: danger ? TontiColors.alertRed : TontiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: TontiColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: danger ? TontiColors.alertRed.withOpacity(0.7) : TontiColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Carte d'information ou de liste stylisée
  Widget _cardContainer({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
    BorderSide borderSide = const BorderSide(color: TontiColors.border, width: 1),
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: padding,
      decoration: BoxDecoration(
        color: TontiColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(borderSide),
        boxShadow: [TontiColors.softShadow],
      ),
      child: child,
    );
  }

  Widget _smallBtn(String label, VoidCallback onTap, {bool danger = false}) {
    return ElevatedButton(
      onPressed: _busy ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? TontiColors.alertRed : TontiColors.goldSoft,
        foregroundColor: danger ? Colors.white : TontiColors.darkGold,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: danger ? TontiColors.alertRed : TontiColors.primaryGold.withOpacity(0.4),
          ),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
    );
  }

  /// Conteneur central pour encadrer les contenus en responsive
  Widget _buildTabBody(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  /// Liste distante (GET) avec gestion du chargement et des erreurs.
  Widget _remoteList(
    String key,
    Future<ApiResponse> Function() loader,
    Widget Function(Map<String, dynamic>) tile, {
    String empty = 'Aucune donnée.',
  }) {
    return FutureBuilder<ApiResponse>(
      key: ValueKey('$key-$_reload'),
      future: loader(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: TontiColors.primaryGold)),
          );
        }
        final r = snap.data;
        if (r == null || !r.isOk) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(r?.message ?? 'Erreur de chargement.', style: const TextStyle(color: TontiColors.alertRed)),
          );
        }
        final items = _asMaps(r.data);
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TontiColors.cardSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TontiColors.borderSubtle),
            ),
            child: Text(empty, style: const TextStyle(color: TontiColors.textSecondary, fontSize: 13)),
          );
        }
        return Column(children: items.map(tile).toList());
      },
    );
  }

  num _num(dynamic v) => v is num ? v : (num.tryParse(_s(v)) ?? 0);

  // ------------------------------------------------------------------
  // Onglet 1 — Cycles & clôtures (contrat §4.5)
  // ------------------------------------------------------------------

  Widget _cycleTab() {
    final cid = _cycleId;
    final tid = _tid;

    return _buildTabBody([
      // Banner de statut du cycle
      if (cid != null)
        _infoBanner(
          'Un cycle de tontine est actuellement actif (#$cid). Vous pouvez consulter le calendrier, ajuster les échéances ou procéder à sa clôture.',
          title: 'Cycle en cours actif',
          icon: Icons.autorenew_rounded,
        )
      else
        _infoBanner(
          'Aucun cycle en cours pour cette tontine. Démarrez un nouveau cycle pour définir les échéances et les cotisations.',
          title: 'Aucun cycle en cours',
          icon: Icons.pause_circle_outline_rounded,
        ),

      if (!_isPresident)
        _infoBanner(
          'Le démarrage et la clôture des cycles sont réservés au Président / Fondateur.',
          warning: true,
        ),

      _sectionHeader('Gestion du Cycle', icon: Icons.repeat_rounded),

      if (_isPresident && tid != null)
        _actionCard(
          title: 'Démarrer / personnaliser un cycle',
          subtitle: 'Définir la fréquence, la durée, le nombre de tours, les échéances et cotisations',
          icon: Icons.play_arrow_rounded,
          onTap: _startCycle,
        ),

      if (cid != null) ...[
        _actionCard(
          title: 'Consulter le cycle',
          subtitle: 'Afficher les détails de la configuration et la progression du cycle en cours',
          icon: Icons.visibility_outlined,
          onTap: () => _view(() => _ds.fetchCycle(cid), 'Détails du cycle'),
        ),
        _actionCard(
          title: 'Échéances du cycle',
          subtitle: 'Calendrier des dates attendues et montants de cotisation du cycle',
          icon: Icons.event_note_outlined,
          onTap: () => _view(() => _ds.fetchEcheances(cid), 'Échéances du cycle'),
        ),
        if (_isPresident)
          _actionCard(
            title: 'Modifier la date de fin / les échéances',
            subtitle: 'Ajuster les dates d\'échéance ou la date de clôture prévisionnelle',
            icon: Icons.edit_calendar_outlined,
            onTap: () => _editCycle(cid),
          ),
      ],

      if (_isPresident) ...[
        _sectionHeader('Zone de Danger & Operations Irréversibles', icon: Icons.warning_amber_rounded),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TontiColors.alertSoft.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TontiColors.alertRed.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            children: [
              if (cid != null)
                _actionCard(
                  title: 'Clôturer le cycle',
                  subtitle: 'Nécessite que tous les membres actifs aient perçu leur cagnotte',
                  icon: Icons.lock_outline,
                  danger: true,
                  onTap: () async {
                    final ok = await _confirm(
                      'Clôturer le cycle',
                      'La clôture est refusée par le serveur tant qu\'un membre actif n\'a pas bénéficié de sa cagnotte.',
                    );
                    if (ok) await _call(() => _ds.closeCycle(cid), 'Cycle clôturé.');
                  },
                ),
              if (tid != null)
                _actionCard(
                  title: 'Clôturer définitivement la tontine',
                  subtitle: 'Action définitive rendant la tontine inactive',
                  icon: Icons.block,
                  danger: true,
                  onTap: () async {
                    final ok = await _confirm(
                      'Clôturer la tontine',
                      'Action définitive. Elle est rejetée si un cycle en cours compte encore des membres n\'ayant pas bénéficié.',
                    );
                    if (ok) await _call(() => _ds.closeTontine(tid), 'Tontine clôturée.');
                  },
                ),
            ],
          ),
        ),
      ],
    ]);
  }

  Future<void> _startCycle() async {
    final tid = _tid;
    if (tid == null) return;
    final debut = TextEditingController();
    final fin = TextEditingController();
    final montant = TextEditingController();
    final intervalle = TextEditingController();
    final tours = TextEditingController();
    final dates = TextEditingController();
    var frequence = 'MENSUELLE';
    var variable = false;
    final members = widget.tontine.members;
    final parts = {for (final m in members) m.id: TextEditingController(text: '1')};

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Démarrer un cycle', style: TontiTypography.headingMedium),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 460,
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setLocal) => Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: debut,
                  decoration: InputDecoration(
                    labelText: 'Date de début (AAAA-MM-JJ)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fin,
                  decoration: InputDecoration(
                    labelText: 'Date de fin (AAAA-MM-JJ) — facultatif',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: frequence,
                  decoration: InputDecoration(
                    labelText: 'Fréquence',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'HEBDOMADAIRE', child: Text('Hebdomadaire')),
                    DropdownMenuItem(value: 'QUINZOMADAIRE', child: Text('Quinzomadaire')),
                    DropdownMenuItem(value: 'MENSUELLE', child: Text('Mensuelle')),
                    DropdownMenuItem(value: 'PERSONNALISEE', child: Text('Personnalisée')),
                  ],
                  onChanged: (v) => setLocal(() => frequence = v ?? 'MENSUELLE'),
                ),
                if (frequence == 'PERSONNALISEE') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: intervalle,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Intervalle entre tours (jours)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: tours,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nombre de tours — facultatif',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dates,
                        decoration: InputDecoration(
                          labelText: 'Dates d\'échéances (AAAA-MM-JJ)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TontiColors.primaryGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final startStr = debut.text.trim();
                        final startDate = DateTime.tryParse(startStr) ?? DateTime.now();
                        if (debut.text.isEmpty) {
                          debut.text = startDate.toIso8601String().substring(0, 10);
                        }
                        int numTours = int.tryParse(tours.text.trim()) ?? members.length;
                        if (numTours <= 0) numTours = 1;
                        tours.text = numTours.toString();

                        List<String> calculatedDates = [];
                        DateTime currentDate = startDate;

                        for (int i = 0; i < numTours; i++) {
                          calculatedDates.add(currentDate.toIso8601String().substring(0, 10));
                          if (frequence == 'HEBDOMADAIRE') {
                            currentDate = currentDate.add(const Duration(days: 7));
                          } else if (frequence == 'QUINZOMADAIRE') {
                            currentDate = currentDate.add(const Duration(days: 14));
                          } else if (frequence == 'MENSUELLE') {
                            currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
                          } else if (frequence == 'PERSONNALISEE') {
                            final days = int.tryParse(intervalle.text.trim()) ?? 30;
                            currentDate = currentDate.add(Duration(days: days));
                          } else {
                            currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
                          }
                        }
                        setLocal(() {
                          dates.text = calculatedDates.join(', ');
                        });
                      },
                      child: const Text('Auto-calcul', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montant,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Montant de cotisation (FCFA) — facultatif',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: TontiColors.primaryGold,
                  title: const Text('Cotisation variable (parts par membre)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  value: variable,
                  onChanged: (v) => setLocal(() => variable = v),
                ),
                if (variable)
                  for (final m in members)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: parts[m.id],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Parts de ${m.fullName}',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: TontiColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TontiColors.primaryGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Créer le cycle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final dateList = dates.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final body = <String, dynamic>{
      if (debut.text.trim().isNotEmpty) 'dateDebut': debut.text.trim(),
      if (fin.text.trim().isNotEmpty) 'dateFin': fin.text.trim(),
      'frequence': frequence,
      if (frequence == 'PERSONNALISEE' && int.tryParse(intervalle.text.trim()) != null)
        'intervalleJours': int.parse(intervalle.text.trim()),
      if (dateList.isNotEmpty) 'datesEcheances': dateList,
      if (int.tryParse(tours.text.trim()) != null) 'nombreTours': int.parse(tours.text.trim()),
      if (int.tryParse(montant.text.trim()) != null) 'montantCotisation': int.parse(montant.text.trim()),
      if (variable) 'typeCotisation': 'VARIABLE',
      if (variable)
        'partsParMembre': {
          for (final m in members)
            if (LocalTontiDataSource.numericId(m.id) != null)
              '${LocalTontiDataSource.numericId(m.id)}':
                  double.tryParse(parts[m.id]!.text.replaceAll(',', '.')) ?? 1.0,
        },
    };
    await _call(() => _ds.startCycle(tid, body), 'Cycle créé.');
  }

  Future<void> _editCycle(int cycleId) async {
    final v = await _form('Mettre à jour le cycle', const [
      _Field('Nouvelle date de fin (AAAA-MM-JJ)', required: false),
      _Field('Dates d\'échéances (séparées par des virgules)', required: false),
    ]);
    if (v == null) return;
    final fin = v['Nouvelle date de fin (AAAA-MM-JJ)'] ?? '';
    final dates = (v['Dates d\'échéances (séparées par des virgules)'] ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (fin.isEmpty && dates.isEmpty) return;
    await _call(
      () => _ds.updateCycle(cycleId, {
        if (fin.isNotEmpty) 'dateFin': fin,
        if (dates.isNotEmpty) 'datesEcheances': dates,
      }),
      'Cycle mis à jour.',
    );
  }

  // ------------------------------------------------------------------
  // Onglet 2 — Départ d'un membre (contrat §4.5.4)
  // ------------------------------------------------------------------

  Widget _departTab() {
    final tid = _tid;
    final me = _ds.adhesionIdIn(tid);
    final members = widget.tontine.members;

    return _buildTabBody([
      _infoBanner(
        'Un membre qui quitte la tontine en cours de cycle règle une compensation regroupant : ses cotisations futures, ses pénalités impayées et le solde de ses prêts en cours.',
        title: 'Procédure de démission / départ',
        icon: Icons.exit_to_app_rounded,
      ),
      _sectionHeader('Membres de la tontine', icon: Icons.people_outline_rounded),
      if (tid == null || members.isEmpty)
        _cardContainer(child: const Text('Aucun membre chargé.', style: TextStyle(color: TontiColors.textSecondary))),
      for (final m in members)
        Builder(builder: (context) {
          final adh = LocalTontiDataSource.numericId(m.id);
          final allowed = adh != null && (_isBureau || adh == me);
          final isMe = adh == me;

          return _cardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isMe ? TontiColors.goldSoft : TontiColors.surfaceMuted,
                      child: Text(
                        m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : 'M',
                        style: TextStyle(
                          color: isMe ? TontiColors.darkGold : TontiColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                m.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: TontiColors.textPrimary),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: TontiColors.goldSoft,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('VOUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TontiColors.darkGold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.role.name.toUpperCase(),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: TontiColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (allowed) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: TontiColors.divider, height: 1),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _smallBtn(
                        'Simuler le départ',
                        () => _view(() => _ds.simulateDeparture(tid!, adh!), 'Compensation de départ — ${m.fullName}'),
                      ),
                      _smallBtn(
                        'Valider le départ',
                        () => _quit(tid!, adh!, m.fullName),
                        danger: true,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
    ]);
  }

  Future<void> _quit(int tid, int adhesionId, String name) async {
    final v = await _form('Départ de $name', const [
      _Field('Mode de paiement', initial: 'MOBILE_MONEY'),
      _Field('Référence de paiement'),
      _Field('Motif'),
    ]);
    if (v == null) return;
    final ok = await _confirm(
      'Confirmer le départ',
      'La compensation sera payée, les échéances restantes réglées et l\'adhésion passera à « démissionnaire ». Cette action est définitive.',
    );
    if (!ok) return;
    await _call(
      () => _ds.confirmDeparture(
        tid,
        adhesionId,
        modePaiement: v['Mode de paiement'] ?? 'MOBILE_MONEY',
        reference: v['Référence de paiement'] ?? '',
        motif: v['Motif'] ?? '',
      ),
      'Départ validé.',
      showData: true,
    );
  }

  // ------------------------------------------------------------------
  // Onglet 3 — Compensations de dettes (contrat §5.7)
  // ------------------------------------------------------------------

  Widget _compensationsTab() {
    final tid = _tid;
    final dists = _ds.distributions
        .where((d) => LocalTontiDataSource.numericId(d.tontineId) == tid)
        .toList();

    return _buildTabBody([
      _infoBanner(
        'Déduit automatiquement sur la cagnotte brute d\'un bénéficiaire l\'ensemble de ses cotisations impayées, ses pénalités et ses échéances de prêt avant versement du solde net.',
        title: 'Compensation automatique des dettes',
        icon: Icons.account_balance_wallet_outlined,
      ),

      _sectionHeader('Distributions à venir & à compenser', icon: Icons.payments_outlined),

      if (dists.isEmpty)
        _cardContainer(child: const Text('Aucune distribution en attente.', style: TextStyle(color: TontiColors.textSecondary))),

      for (final d in dists)
        Builder(builder: (context) {
          final did = LocalTontiDataSource.numericId(d.id);
          return _cardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${d.beneficiaryName} • Tour ${d.turnNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: TontiColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TontiColors.goldSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.statusLabel.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.darkGold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Montant net versé : ', style: TextStyle(fontSize: 13, color: TontiColors.textSecondary)),
                    Text(
                      Formatters.formatFCFA(d.netAmount),
                      style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold),
                    ),
                  ],
                ),
                if (did != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: TontiColors.divider, height: 1),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _smallBtn('Simuler la compensation', () => _view(() => _ds.simulateCompensation(did), 'Simulation — ${d.beneficiaryName}')),
                      if (_isBureau)
                        _smallBtn('Exécuter la compensation', () async {
                          final ok = await _confirm(
                            'Exécuter la compensation',
                            'Déduire cotisations, pénalités et prêts de ${d.beneficiaryName} puis verser le solde net ?',
                          );
                          if (ok) await _call(() => _ds.executeCompensation(did), 'Compensation exécutée.', showData: true);
                        }),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),

      _sectionHeader('Historique des compensations exécutées', icon: Icons.history_rounded),

      if (tid != null)
        _remoteList(
          'comp',
          () => _ds.fetchCompensations(tontineId: tid),
          (c) => _cardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_s(c['membre_nom'])}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: TontiColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TontiColors.successSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _s(c['statut']),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TontiColors.successGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TontiColors.cardSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol('Brut', Formatters.formatFCFA(_num(c['montantBrut']))),
                      _metricCol('Compensé', Formatters.formatFCFA(_num(c['montantCompense']))),
                      _metricCol('Net Versé', Formatters.formatFCFA(_num(c['montantNetVerse'])), isHighlight: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          empty: 'Aucune compensation enregistrée dans l\'historique.',
        ),
    ]);
  }

  Widget _metricCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: TontiColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isHighlight ? TontiColors.primaryGold : TontiColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Onglet 4 — Répartition de la caisse de pénalités (contrat §5.8)
  // ------------------------------------------------------------------

  Widget _penaltiesTab() {
    final tid = _tid;
    if (tid == null) return _buildTabBody([_infoBanner('Tontine introuvable.', warning: true)]);

    return _buildTabBody([
      _infoBanner(
        'La caisse PENALITES accumulée est redistribuée aux membres les plus assidus selon la formule :\nScore = présences × 10 + cotisations × 15 + votes × 5 − pénalités × 20.',
        title: 'Redistribution de la caisse pénalités',
        icon: Icons.gavel_rounded,
      ),

      if (!_isBureau)
        _infoBanner('La gestion et la redistribution des pénalités sont réservées au Bureau (Président & Trésorier).', warning: true),

      if (_isBureau) ...[
        _sectionHeader('Actions sur les pénalités', icon: Icons.tune_rounded),

        _actionCard(
          title: 'Calculer & Appliquer une pénalité',
          subtitle: 'Appliquer une sanction financière statutaire à un membre (majoration auto si cagnotte perçue)',
          icon: Icons.gavel_outlined,
          onTap: () async {
            final members = widget.tontine.members;
            if (members.isEmpty) return;
            final picked = await _pick(
              'Choisir le membre sanctionné',
              [for (final m in members) {'id': m.id, 'name': m.fullName, 'adh': LocalTontiDataSource.numericId(m.id)}],
              (m) => '${m['name']}',
            );
            if (picked == null) return;
            final adhId = picked['adh'] as int?;
            if (adhId == null) {
              _snack('Adhésion introuvable pour ce membre.', ok: false);
              return;
            }
            final formVal = await _form('Appliquer une pénalité', const [
              _Field('Montant de base (FCFA)', type: TextInputType.number, initial: '2500'),
              _Field('Motif de la sanction', initial: 'Retard de versement à la séance'),
            ]);
            if (formVal == null) return;
            final baseAmt = double.tryParse(formVal['Montant de base (FCFA)'] ?? '') ?? 2500;
            final motif = formVal['Motif de la sanction'] ?? 'Sanction statutaire';

            final calcRes = await _ds.calculatePenalty(tontineId: tid, adhesionId: adhId, montant: baseAmt);
            double finalAmount = baseAmt;
            String previewMsg = 'Appliquer la pénalité de ${Formatters.formatFCFA(baseAmt)} à ${picked['name']} ?';
            if (calcRes.isOk && calcRes.data is Map) {
              final d = calcRes.data as Map;
              final rec = (d['montant_recommande'] as num?)?.toDouble() ?? baseAmt;
              final isAggravated = d['a_deja_bouffe'] == true;
              finalAmount = rec;
              if (isAggravated) {
                previewMsg = '⚠️ Membre ayant déjà perçu sa cagnotte ! Pénalité majorée x2 : ${Formatters.formatFCFA(rec)} pour ${picked['name']}. Continuer ?';
              }
            }

            final confirmOk = await _confirm('Confirmation Pénalité', previewMsg);
            if (!confirmOk) return;

            await _call(
              () => _ds.applyPenalty(
                tontineId: tid,
                adhesionId: adhId,
                montant: finalAmount,
                motif: motif,
              ),
              'Pénalité appliquée avec succès.',
              showData: true,
            );
          },
        ),

        _actionCard(
          title: 'Simuler la répartition',
          subtitle: 'Estimer la répartition des fonds entre les membres ayant le meilleur score d\'assiduité',
          icon: Icons.calculate_outlined,
          onTap: () async {
            final v = await _form('Simulation', const [_Field('Nombre de bénéficiaires (facultatif)', type: TextInputType.number, required: false)]);
            if (v == null) return;
            final n = int.tryParse(v['Nombre de bénéficiaires (facultatif)'] ?? '');
            await _view(() => _ds.simulatePenaltyShare(tid, beneficiaries: n), 'Simulation de répartition');
          },
        ),

        _actionCard(
          title: 'Exécuter la répartition',
          subtitle: 'Distribuer effectivement la caisse PENALITES aux membres bénéficiaires (remise à zéro)',
          icon: Icons.redeem_outlined,
          onTap: () async {
            final v = await _form('Répartition', const [
              _Field('Nombre de bénéficiaires', type: TextInputType.number, initial: '2'),
              _Field('Justificatif', initial: 'Prime annuelle d\'assiduité'),
            ]);
            if (v == null) return;
            final n = int.tryParse(v['Nombre de bénéficiaires'] ?? '');
            if (n == null || n <= 0) {
              _snack('Nombre de bénéficiaires invalide.', ok: false);
              return;
            }
            final ok = await _confirm('Exécuter la répartition', 'La caisse PENALITES sera débitée à 0. Continuer ?');
            if (!ok) return;
            await _call(
              () => _ds.executePenaltyShare(tid, beneficiaries: n, justificatif: v['Justificatif'] ?? ''),
              'Répartition effectuée.',
              showData: true,
            );
          },
        ),
      ],
    ]);
  }

  // ------------------------------------------------------------------
  // Onglet 5 — Notifications WhatsApp (contrat §4.14)
  // ------------------------------------------------------------------

  Widget _whatsappTab() {
    final tid = _tid;
    final cid = _cycleId;
    if (tid == null) return _buildTabBody([_infoBanner('Tontine introuvable.', warning: true)]);

    return _buildTabBody([
      if (!_canNotify)
        _infoBanner(
          'Seuls la Secrétaire, le Président ou le Fondateur peuvent émettre des notifications WhatsApp officielles.',
          warning: true,
        ),

      if (_canNotify) ...[
        _sectionHeader('Diffusion & Notifications', icon: Icons.chat_bubble_outline_rounded),

        if (cid != null)
          _actionCard(
            title: 'Rappels groupés de cotisation',
            subtitle: 'Envoyer un message WhatsApp de relance à tous les membres en retard sur le cycle',
            icon: Icons.notifications_active_outlined,
            onTap: () async {
              final ok = await _confirm('Rappels groupés', 'Envoyer un rappel WhatsApp à tous les membres en retard du cycle ?');
              if (ok) await _call(() => _ds.whatsappCycleReminders(cid), 'Rappels envoyés.', showData: true);
            },
          ),

        if (cid != null)
          _actionCard(
            title: 'Rappel individuel de cotisation',
            subtitle: 'Sélectionner une échéance spécifique et notifier le membre concerné',
            icon: Icons.person_outline_rounded,
            onTap: () async {
              final r = await _ds.fetchEcheances(cid);
              if (!r.isOk) {
                _snack(r.message ?? 'Échéances indisponibles.', ok: false);
                return;
              }
              final e = await _pick(
                'Choisir une échéance',
                _asMaps(r.data),
                (e) => '${_s(e['membre_nom'] ?? e['concerne_nom'])} • '
                    '${_s(e['dateAttendue'] ?? e['date'])} • ${_s(e['montantAttendu'])}',
              );
              final id = e == null ? null : int.tryParse(_s(e['id']));
              if (id != null) await _call(() => _ds.whatsappContributionReminder(id), 'Rappel envoyé.', showData: true);
            },
          ),

        _actionCard(
          title: 'Convoquer à une réunion',
          subtitle: 'Diffuser la date et l\'ordre du jour d\'une réunion par notification WhatsApp',
          icon: Icons.event_available_outlined,
          onTap: () async {
            final r = await _ds.fetchMeetings(tid);
            if (!r.isOk) {
              _snack(r.message ?? 'Réunions indisponibles.', ok: false);
              return;
            }
            final m = await _pick(
              'Choisir une réunion',
              _asMaps(r.data),
              (m) => '${_s(m['date'])} • ${_s(m['lieu'])} • ${_s(m['statut'])}',
            );
            final id = m == null ? null : int.tryParse(_s(m['id']));
            if (id == null) return;
            final v = await _form('Convocation', const [_Field('Note (facultatif)', required: false)]);
            if (v == null) return;
            await _call(() => _ds.whatsappMeetingConvocation(id, note: v['Note (facultatif)']), 'Convocation diffusée.', showData: true);
          },
        ),

        _actionCard(
          title: 'Diffuser une annonce',
          subtitle: 'Envoyer une communication officielle de la tontine aux membres',
          icon: Icons.campaign_outlined,
          onTap: () async {
            final r = await _ds.fetchAnnouncements(tid);
            if (!r.isOk) {
              _snack(r.message ?? 'Annonces indisponibles.', ok: false);
              return;
            }
            final a = await _pick('Choisir une annonce', _asMaps(r.data), (a) => '${_s(a['titre'])} • ${_s(a['date'])}');
            final id = a == null ? null : int.tryParse(_s(a['id']));
            if (id != null) await _call(() => _ds.whatsappAnnouncement(id), 'Annonce diffusée.', showData: true);
          },
        ),

        if (cid != null)
          _actionCard(
            title: 'Alerter le bénéficiaire d\'un tour',
            subtitle: 'Informer le bénéficiaire que sa cagnotte est prête à être perçue',
            icon: Icons.emoji_events_outlined,
            onTap: () async {
              final turns = _ds.turnsFor(tid);
              final t = await _pick(
                'Choisir un tour',
                [for (final t in turns) {'adhesion_id': t.adhesionId, 'rang': t.rank, 'nom': t.memberName}],
                (t) => 'Tour ${t['rang']} • ${t['nom']}',
              );
              final adh = t == null ? null : int.tryParse(_s(t['adhesion_id']));
              if (adh != null) await _call(() => _ds.whatsappTurnAlert(cid, adh), 'Alerte envoyée.', showData: true);
            },
          ),
      ],

      _sectionHeader('Journal des notifications WhatsApp', icon: Icons.history_toggle_off_rounded),

      _remoteList(
        'wa',
        () => _ds.fetchTontineNotifications(tid, canal: 'WHATSAPP'),
        (n) => _cardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${_formatNotifType(_s(n['type']))} • ${_s(n['destinataire_nom'])}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: TontiColors.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TontiColors.successSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDeliveryStatus(_s(n['statutLivraison'])),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TontiColors.successGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TontiColors.cardSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _s(n['contenu']),
                  style: const TextStyle(fontSize: 12.5, color: TontiColors.textPrimary, height: 1.4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _s(n['dateEnvoi']),
                style: const TextStyle(fontSize: 11, color: TontiColors.textMuted),
              ),
            ],
          ),
        ),
        empty: 'Aucune notification WhatsApp enregistrée.',
      ),
    ]);
  }

  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: TontiColors.background,
        appBar: AppBar(
          backgroundColor: TontiColors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          iconTheme: const IconThemeData(color: TontiColors.textPrimary),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestion avancée',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TontiColors.textPrimary),
              ),
              Text(
                widget.tontine.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: TontiColors.textSecondary),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: const BoxDecoration(
                color: TontiColors.white,
                border: Border(bottom: BorderSide(color: TontiColors.border, width: 1)),
              ),
              child: const TabBar(
                isScrollable: true,
                indicatorColor: TontiColors.primaryGold,
                indicatorWeight: 3,
                labelColor: TontiColors.primaryGold,
                unselectedLabelColor: TontiColors.textSecondary,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(icon: Icon(Icons.autorenew_rounded, size: 18), text: 'Cycles'),
                  Tab(icon: Icon(Icons.exit_to_app_rounded, size: 18), text: 'Départs'),
                  Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'Compensations'),
                  Tab(icon: Icon(Icons.gavel_rounded, size: 18), text: 'Pénalités'),
                  Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 18), text: 'WhatsApp'),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _cycleTab(),
                _departTab(),
                _compensationsTab(),
                _penaltiesTab(),
                _whatsappTab(),
              ],
            ),
            if (_busy)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(color: TontiColors.primaryGold, backgroundColor: TontiColors.goldSoft),
              ),
          ],
        ),
      ),
    );
  }
}
