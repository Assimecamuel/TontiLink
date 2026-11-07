import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../controllers/auth_controller.dart';

/// Interface volontairement pilotée par les réponses du backend : aucune donnée métier locale.
class BackendDataScreen extends StatefulWidget {
  const BackendDataScreen({super.key});
  @override
  State<BackendDataScreen> createState() => _BackendDataScreenState();
}

class _BackendDataScreenState extends State<BackendDataScreen> {
  final ApiClient api = ApiClient.instance;
  int selected = 0;
  bool loading = false;
  dynamic payload;
  String? error;
  static const sections = <({String label, String path, IconData icon})>[
    (label: 'Accueil API', path: '/api/', icon: Icons.dashboard_outlined),
    (label: 'Mes tontines', path: '/api/tontines/', icon: Icons.groups_outlined),
    (label: 'Cotisations', path: '/api/finances/cotisations/', icon: Icons.payments_outlined),
    (label: 'Caisses', path: '/api/finances/caisses/tontine/1/', icon: Icons.account_balance_wallet_outlined),
    (label: 'Distributions', path: '/api/finances/distributions/', icon: Icons.call_made_outlined),
    (label: 'Réunions', path: '/api/tontines/1/reunions/', icon: Icons.event_outlined),
    (label: 'Prêts', path: '/api/prets/', icon: Icons.account_balance_outlined),
    (label: 'Entraide', path: '/api/entraide/evenements/', icon: Icons.volunteer_activism_outlined),
    (label: 'Projets', path: '/api/projets/', icon: Icons.work_outline),
    (label: 'Contrôle', path: '/api/controle/validations/', icon: Icons.verified_user_outlined),
    (label: 'Litiges', path: '/api/controle/litiges/', icon: Icons.gavel_outlined),
    (label: 'Mon profil', path: '/api/comptes/profile/', icon: Icons.person_outline),
    (label: 'Notifications', path: '/api/comptes/notifications/', icon: Icons.notifications_none),
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    final response = await api.get(sections[selected].path);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.isOk) { payload = response.data ?? response.rawBody; }
      else { payload = null; error = response.message ?? 'Erreur HTTP ${response.statusCode}'; }
    });
  }

  void _logout() {
    AuthController().logout();
  }

  @override
  Widget build(BuildContext context) {
    final section = sections[selected];
    return Scaffold(
      appBar: AppBar(title: const Text('TontiLink'), actions: [IconButton(tooltip: 'Actualiser', onPressed: loading ? null : _load, icon: const Icon(Icons.refresh)), IconButton(tooltip: 'Déconnexion', onPressed: _logout, icon: const Icon(Icons.logout))]),
      body: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(16, 10, 16, 12), color: const Color(0xFFF9F3DF), child: Text('Données en direct depuis l’API Django • ${api.baseUrl}', style: const TextStyle(fontWeight: FontWeight.w600))),
        SizedBox(height: 64, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), itemCount: sections.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, i) => ChoiceChip(label: Text(sections[i].label), avatar: Icon(sections[i].icon, size: 18), selected: selected == i, onSelected: (_) { setState(() { selected = i; payload = null; }); _load(); }))),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(section.label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6), Text(section.path, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          if (loading) const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
          if (!loading && error != null) Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.cloud_off_outlined, size: 36), const SizedBox(height: 8), Text(error!, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), const Text('Aucune donnée de démonstration n’est affichée. Vérifiez que le backend est lancé, que le téléphone est sur le même réseau et que le jeton JWT est valide.'), const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Réessayer')))]))),
          if (!loading && error == null && payload == null) const Text('Le backend a répondu sans contenu.'),
          if (!loading && error == null && payload != null) _renderPayload(payload),
        ]))),
      ]),
    );
  }

  Widget _renderPayload(dynamic value) {
    if (value is List) {
      if (value.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Aucun enregistrement retourné par la base de données.'),
          ),
        );
      }
      return Column(
        children: value
            .map<Widget>(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _renderPayload(item),
                ),
              ),
            )
            .toList(),
      );
    }
    if (value is Map) {
      final entries = value.entries.toList();
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries
                .map<Widget>(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 135,
                          child: Text(
                            _humanize(e.key.toString()),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: (e.value is Map || e.value is List)
                              ? _renderPayload(e.value)
                              : SelectableText(e.value == null ? '—' : e.value.toString()),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return SelectableText(value is String ? _prettyJson(value) : value.toString());
  }

  String _humanize(String key) => key.replaceAll('_', ' ').replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  String _prettyJson(String value) { try { return const JsonEncoder.withIndent('  ').convert(jsonDecode(value)); } catch (_) { return value; } }
}
