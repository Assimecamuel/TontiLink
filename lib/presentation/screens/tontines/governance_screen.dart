import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../models/tontine_model.dart';

/// Vie de la tontine : annonces, votes, pénalités, projets, contrôle.
/// Toutes les données viennent de l'API (aucune donnée locale).
class GovernanceScreen extends StatefulWidget {
  final TontineModel tontine;
  const GovernanceScreen({super.key, required this.tontine});

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen> {
  int _reload = 0;

  int? get _tid => LocalTontiDataSource.numericId(widget.tontine.id);

  bool get _isBureau {
    final u = LocalTontiDataSource().currentUser;
    return u.isPresident || u.isTreasurer;
  }

  Future<List<Map<String, dynamic>>> _load(String path) async {
    final res = await ApiClient.instance.get(path);
    if (!res.isOk) throw Exception(res.message ?? 'Erreur ${res.statusCode}');
    final d = res.data;
    final list = d is List ? d : (d is Map ? (d['data'] ?? d['results'] ?? const []) : const []);
    return (list as List).whereType<Map<String, dynamic>>().toList();
  }

  void _toast(bool ok, String okMsg, String? err) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? okMsg : (err ?? 'Refusé par le serveur.')),
      backgroundColor: ok ? TontiColors.successGreen : TontiColors.alertRed,
    ));
    if (ok) setState(() => _reload++);
  }

  Future<Map<String, String>?> _form(String title, List<String> fields, {List<TextInputType>? types}) {
    final ctrls = fields.map((_) => TextEditingController()).toList();
    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < fields.length; i++)
              TextField(
                controller: ctrls[i],
                keyboardType: types?[i],
                decoration: InputDecoration(labelText: fields[i]),
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (ctrls.any((c) => c.text.trim().isEmpty)) return;
              Navigator.pop(ctx, {for (var i = 0; i < fields.length; i++) fields[i]: ctrls[i].text.trim()});
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget _list(String path, Widget Function(Map<String, dynamic>) tile, {Widget? action, String empty = 'Aucune donnée.'}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: ValueKey('$path-$_reload'),
      future: _load(path),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (action != null) Align(alignment: Alignment.centerLeft, child: action),
            if (snap.hasError)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('${snap.error}', style: const TextStyle(color: TontiColors.alertRed)),
              )
            else if (items.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(empty)))
            else
              ...items.map(tile),
          ],
        );
      },
    );
  }

  Widget _card(String title, String subtitle, {Widget? trailing, List<Widget> extra = const []}) => Card(
        margin: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
              if (trailing != null) trailing,
            ]),
            if (subtitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle)),
            ...extra,
          ]),
        ),
      );

  Widget _addBtn(String label, VoidCallback onTap) =>
      OutlinedButton.icon(onPressed: onTap, icon: const Icon(Icons.add, size: 16), label: Text(label));

  @override
  Widget build(BuildContext context) {
    final tid = _tid;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vie de ${widget.tontine.name}'),
          bottom: const TabBar(isScrollable: true, tabs: [
            Tab(text: 'Annonces'),
            Tab(text: 'Votes'),
            Tab(text: 'Pénalités'),
            Tab(text: 'Projets'),
            Tab(text: 'Contrôle'),
          ]),
        ),
        body: tid == null
            ? const Center(child: Text('Tontine introuvable.'))
            : TabBarView(children: [
                // Annonces
                _list(
                  '/api/tontines/$tid/annonces/',
                  (a) => _card('${a['titre'] ?? ''}', '${a['contenu'] ?? ''}',
                      extra: [Padding(padding: const EdgeInsets.only(top: 4), child: Text('${a['date'] ?? ''}', style: const TextStyle(fontSize: 11)))]),
                  empty: 'Aucune annonce.',
                  action: _addBtn('Publier une annonce', () async {
                    final v = await _form('Nouvelle annonce', ['Titre', 'Contenu']);
                    if (v == null) return;
                    final r = await ApiClient.instance.post('/api/tontines/$tid/annonces/', {'titre': v['Titre'], 'contenu': v['Contenu']});
                    _toast(r.isOk, 'Annonce publiée.', r.message);
                  }),
                ),
                // Votes
                _list(
                  '/api/tontines/$tid/votes/',
                  (v) {
                    final options = (v['options'] as List? ?? const []).whereType<Map<String, dynamic>>().toList();
                    return _card('${v['proposition'] ?? ''}', 'Quorum : ${v['quorum'] ?? '-'} % • Résultat : ${v['resultat'] ?? '-'}', extra: [
                      for (final o in options)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () async {
                              final r = await ApiClient.instance.post('/api/tontines/votes/${v['id']}/voter/', {'option_id': o['id']});
                              _toast(r.isOk, 'Vote enregistré.', r.message);
                            },
                            child: Text('Voter : ${o['libelle']}'),
                          ),
                        ),
                    ]);
                  },
                  empty: 'Aucun vote en cours.',
                  action: _addBtn('Lancer un vote', () async {
                    final v = await _form('Nouveau vote', ['Proposition', 'Option 1', 'Option 2', 'Quorum (%)'],
                        types: [TextInputType.text, TextInputType.text, TextInputType.text, TextInputType.number]);
                    if (v == null) return;
                    final r = await ApiClient.instance.post('/api/tontines/$tid/votes/', {
                      'proposition': v['Proposition'],
                      'options': [
                        {'libelle': v['Option 1']},
                        {'libelle': v['Option 2']},
                      ],
                      'quorum': int.tryParse(v['Quorum (%)'] ?? '') ?? 50,
                    });
                    _toast(r.isOk, 'Vote créé.', r.message);
                  }),
                ),
                // Pénalités
                _list(
                  '/api/tontines/$tid/penalites/',
                  (p) => _card('${p['debiteur_nom'] ?? ''} • ${Formatters.formatFCFA(((p['montant'] as num?) ?? 0).toDouble())}',
                      '${p['motif'] ?? ''}\n${p['date'] ?? ''} • ${p['statut'] ?? ''}',
                      // Règlement : POST /penalites/<id>/payer/ (FONDATEUR, PRESIDENT, TRESORIER)
                      trailing: (_isBureau && '${p['statut']}' == 'IMPOSEE')
                          ? TextButton(
                              onPressed: () async {
                                final pid = int.tryParse('${p['id']}');
                                if (pid == null) return;
                                final r = await LocalTontiDataSource().payPenalty(tontineId: tid, penaltyId: pid);
                                _toast(r.isOk, r.message ?? 'Pénalité soldée.', r.message);
                              },
                              child: const Text('Régler'),
                            )
                          : null),
                  empty: 'Aucune pénalité.',
                  action: _isBureau
                      ? _addBtn('Appliquer une pénalité', () async {
                          if (widget.tontine.members.isEmpty) return;
                          final names = widget.tontine.members.map((m) => m.fullName).join(', ');
                          final v = await _form('Pénalité', ['Nom du membre ($names)', 'Montant (FCFA)', 'Motif'],
                              types: [TextInputType.text, TextInputType.number, TextInputType.text]);
                          if (v == null) return;
                          final target = widget.tontine.members
                              .where((m) => m.fullName.toLowerCase() == v.values.first.toLowerCase())
                              .toList();
                          final adh = target.isEmpty ? null : LocalTontiDataSource.numericId(target.first.id);
                          if (adh == null) {
                            _toast(false, '', 'Membre introuvable : saisissez le nom exact.');
                            return;
                          }
                          final r = await ApiClient.instance.post('/api/tontines/$tid/penalites/appliquer/', {
                            'adhesion_id': adh,
                            'montant': int.tryParse(v['Montant (FCFA)'] ?? '') ?? 0,
                            'motif': v['Motif'],
                          });
                          _toast(r.isOk, 'Pénalité appliquée.', r.message);
                        })
                      : null,
                ),
                // Projets
                _list(
                  '/api/projets/?tontine_id=$tid',
                  (p) => _card('${p['objectif'] ?? ''}',
                      'Budget : ${Formatters.formatFCFA(((p['budget'] as num?) ?? 0).toDouble())} • '
                      'Résultat : ${Formatters.formatFCFA(((p['resultat'] as num?) ?? 0).toDouble())} • ${p['statut'] ?? ''}'),
                  empty: 'Aucun projet collectif.',
                ),
                // Contrôle
                ListView(children: [
                  SizedBox(
                    height: 260,
                    child: _list(
                      '/api/controle/validations/?tontine_id=$tid',
                      (v) => _card('${v['typeOperation'] ?? ''} #${v['entiteId'] ?? ''}', 'Niveau ${v['niveau'] ?? ''} • ${v['statut'] ?? ''}'),
                      empty: 'Aucune validation.',
                    ),
                  ),
                  SizedBox(
                    height: 260,
                    child: _list(
                      '/api/controle/litiges/?tontine_id=$tid',
                      (l) => _card('${l['objet'] ?? ''}', '${l['motif'] ?? ''}\n${l['statut'] ?? ''} • ${l['dateOuverture'] ?? ''}'),
                      empty: 'Aucun litige.',
                    ),
                  ),
                ]),
              ]),
      ),
    );
  }
}
