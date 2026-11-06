# Changements — CRUD branché sur la base (API Django)

## Ce qui a été fait
- **Aucune donnée par défaut** : le bloc de données de démonstration (membres, tontines, transactions, caisse, prêts, réunions) a été supprimé de `local_tonti_datasource.dart`. Tout vient de l'API après connexion.
- **Création de tontine** (`createTontine` dans le datasource) : POST `/api/tontines/`, relecture complète, puis garantie que le créateur est **Président** (assignation `PRESIDENT` à sa propre adhésion si le serveur ne l'a pas fait).
- **Assistant de création** : champs vides par défaut, plus de saisie Trésorier / Secrétaire (l'étape 5 devient une simple information : le créateur est Président), validations (nom, cotisation > 0, au moins 2 membres).
- **Cotisations** : le modal ne propose que les membres de la tontine choisie, montant pré-rempli avec la cotisation de la tontine, adhésion réelle du membre (plus de `adhesionId = 1`), relecture après écriture. Même logique pour le paiement espèces en réunion.
- **Validation de cotisation / signature de distribution** : adhésion de l'utilisateur connecté (plus de `2` ni de nom codé), relecture après succès. La signature du tableau de bord appelle maintenant le serveur.
- **Prêts / entraide** : champs vides, validations, relecture depuis `/api/prets/` et `/api/entraide/evenements/` (plus d'insertion locale fictive).
- **Tableau de bord / Cotisations** : graphique, cotisations du mois, fonds, membres, prochaine échéance et bannière calculés depuis les données chargées.
- **Textes par défaut** retirés (profil, barre latérale, réglages, indices de formulaires).
- Code mort (dossiers `features/`, `app/`, `shared/`, `injection_container.dart`, non utilisés et pleins de données fictives) déplacé hors du package, dans `../_archive_code_mort/`.

## Mise à jour — alignement sur API_CONTRACT.md
- **Distributions** : « Exécuter la distribution » (Président/Trésorier) appelle `POST /finances/distributions/<id>/executer/` ; le bénéficiaire a un bouton « Confirmer la réception » (`/confirmer/`). Avant, `confirmer` était appelé à tort à la place du bénéficiaire.
- **Prêts** : lecture de `/api/prets/demandes/` et `/api/prets/` ; actions Approuver/Rejeter (`decider`), Décaisser (`decaisser`, taux saisi), Rembourser (`rembourser`).
- **Entraide** : type `MEDICAL`/`AUTRE`, `dateEvenement` envoyé ; actions Valider/Rejeter, Contribuer, Décaisser l'aide.
- **Cotisations** : `enregistreePar_id`, `saisieDifferee` et `reunion_id` (paiement en réunion) envoyés.
- **Caisse** : mouvements lus via `/finances/caisses/<id>/transactions/` (entrées, sorties, totaux) ; le bouton devient « Rapprochement de caisse » (`/rapprochements/` avec `soldeReel`).
- **Réunions** : planification (`POST /tontines/<id>/reunions/`) ; le badge « prochaine séance » est calculé.
- Non implémentés (aucun écran existant) : votes, annonces, pénalités, projets collectifs, contrôle (validations, litiges), rappels WhatsApp.

## Mise à jour 2 — alignement sur API_RESPONSES_FLUTTER.md (réponses réelles du backend)
- **Création de tontine** : le serveur attribue déjà FONDATEUR + PRESIDENT au créateur (confirmé) : le fallback d'assignation a été retiré ; l'app lit `tontine_id` dans la réponse et active la nouvelle tontine. Valeurs envoyées corrigées : `PRET`, `PROJET_COMMERCIAL`, `QUINZOMADAIRE`, `TIRAGE_SORT`, `ACCORD_MUTUEL`.
- **Lecture des tontines** : `regle` (cotisation, fréquence, mode de distribution), `cycleEnCours` (numéro, `prochaineEcheance`, `montantCollecte` si le backend les ajoute), statuts `CREEE/ACTIVE/SUSPENDUE/CLOTUREE`.
- **Membres** : `adhesion_id`, rôles, statuts d'adhésion ; `totalCotise`, `totalAttendu`, `nombreRetards` lus dès que le backend les expose (§3.2).
- **Distributions** : cycle `PROGRAMMEE → EFFECTUEE → CONFIRMEE` (+ `CONTESTEE`) ; `executer` réservé Fondateur/Trésorier (le message 403 du serveur s'affiche).
- **Prêts** : clés réelles (`montantAccorde`, `soldeRestantDu`, `demandeur_nom`, `demande_id`…), statuts `SOUMISE/EN_ETUDE/APPROUVEE/REJETEE` et `EN_COURS/REMBOURSE/EN_DEFAUT/CLOTURE` ; décaissement depuis la caisse `PRETS`.
- **Entraide** : types réels `MALADIE/DECES/MARIAGE/NAISSANCE/ACCIDENT/AUTRE` (plus de `MEDICAL`), statuts `DECLARE/EN_ATTENTE_VALIDATION/VALIDE/REJETE/CLOTURE`, caisse `SECOURS_ENTRAIDE`.
- **Caisse** : sens des mouvements déduit du `type` (crédits / débits), mouvements échoués ou contre-passés ignorés.
- **Cotisations** : section « Cotisations à valider » (bureau) branchée sur `/valider/`.
- **Nouvel écran « Vie de la tontine »** (bouton dans le détail d'une tontine) : annonces, votes (créer/voter), pénalités (appliquer), projets, validations et litiges de contrôle.

## Mise à jour 3 — application complète de API_RESPONSES_FLUTTER.md
- **Ordre de passage (§1.9)** : nouvelle entité `TurnEntity` ; lecture de `GET /tontines/cycles/<cycle_id>/ordre-passage/` à chaque synchro (cycle = `cycleEnCours.id`). L'onglet « Ordre de passage » du détail d'une tontine affiche les vrais tours (rang, bénéficiaire, collecté / prévu, `statutTour`). Le bureau peut **permuter** deux tours (`/permuter/`, `rang_source` / `rang_cible`) ou **régénérer par tirage au sort** (`POST` avec `methode: TIRAGE_SORT`) ; `PUT` (ordre personnalisé / dates) disponible dans le datasource (`saveTurnOrder`). Le « prochain bénéficiaire » et le rang de chaque membre viennent désormais de cet ordre (plus de membre n°2 choisi arbitrairement).
- **Membres (§1.2)** : `statutCotisation` (A_JOUR / EN_RETARD, calculé sur les échéances échues) remplace la comparaison `totalCotise >= totalAttendu`, qui affichait à tort « En retard » ; `peutCotiser`, `penalitesImpayeesCount` et `penalitesImpayeesMontant` sont lus. Un membre aux pénalités impayées est signalé (badge « Cotisation bloquée ») et sa cotisation est refusée côté app avec un message explicite avant l'appel serveur.
- **Pénalités (§3.5)** : bouton « Régler » (bureau) sur les pénalités `IMPOSEE` → `POST /tontines/<id>/penalites/<id>/payer/` ; le message du serveur est affiché et les membres sont relus (déblocage de `peutCotiser`). Projets : `resultat` affiché en plus du budget.
- **Cotisations (§1.4)** : tous les statuts (`DECLAREE`, `EN_ATTENTE_VALIDATION` → « à valider » ; `VALIDEE` ; `ECHOUEE` ; `ANNULEE`) et modes (`ESPECES`, `MOBILE_MONEY`, `VIREMENT`, `CARTE`) sont mappés. `CARTE` est rattaché à « Virement » (pas de valeur dédiée dans l'enum `PaymentMethod`).
- **Réunions (§1.3)** : le statut vient du serveur (`PLANIFIEE`, `EN_COURS`, `TENUE`, `ANNULEE`) au lieu d'être déduit de la date.
- **Création de tontine (§2)** : `adhesion_id` de la réponse 201 est mémorisé pour le créateur.
- **Erreurs (§4.2)** : `ApiResponse.errorCode` (ex. `UNAUTHORIZED`) et `isPermissionDenied`.
- Entraide : le type `ACCIDENT` est rattaché à « Autre secours » (pas de valeur dédiée dans `AidEventType`).
- Non branché volontairement : `POST /finances/caisses/<id>/operations/` (§3.4) est une **proposition** du contrat, pas une route existante.

## Limites connues
- Code **non compilé** (pas de SDK Flutter ici) : lancer `flutter pub get && flutter analyze`.
- À ajouter côté backend (propositions §3.2-3.4 du document) : `totalCotise/totalAttendu/nombreRetards` par membre, `montantCollecte/prochaineEcheance` dans `cycleEnCours`, et `POST /api/finances/caisses/<id>/operations/` pour les écritures manuelles (pas encore branché côté Flutter).
- Les corps POST des annonces (`titre`, `contenu`) et la montant « remboursé » d'un prêt (`montantAccorde − soldeRestantDu`) sont des hypothèses à confirmer.

## Mise à jour 4 — application de API_CONTRACT.md + API_RESPONSES_FLUTTER.md (nouvelles règles métier)
- **URL de base** : `http://10.173.147.1:8000` (réseau local du contrat) dans `ApiClient`.
- **Nouvel écran « Gestion avancée »** (`bureau_screen.dart`, bouton dans le détail d'une tontine), 5 onglets :
  - **Cycles** : démarrer / personnaliser un cycle (`POST /tontines/<id>/cycles/` : dates, fréquence `PERSONNALISEE`, `intervalleJours`, `datesEcheances`, `nombreTours`, cotisation variable + `partsParMembre`), consulter (`GET /cycles/<id>/`), modifier (`PUT`), échéances (`/cycles/<id>/echeances/`), **clôturer le cycle** et **clôturer la tontine** (le serveur refuse en 400 tant qu'un membre n'a pas bénéficié : son message est affiché).
  - **Départs** : simulation et validation de la compensation de départ (`/membres/<adhesion_id>/depart/simuler/` et `/quitter/`), pour le membre lui-même ou le bureau.
  - **Compensations** : simulation / exécution par distribution (`/finances/compensations/simuler|executer/`) et historique (`GET /finances/compensations/?tontine_id=`).
  - **Pénalités** : simulation et exécution de la répartition de la caisse PENALITES aux membres les plus actifs.
  - **WhatsApp** (Secrétaire / Président / Fondateur) : rappels groupés du cycle, rappel individuel, convocation de réunion, diffusion d'annonce, alerte de tour, et journal `GET /tontines/<id>/notifications/?canal=WHATSAPP`.
- **Distributions** : « Exécuter la distribution » propose la compensation automatique (`compenserDettes: true/false`). Les erreurs de rotation stricte (« ne pas bouffer 2 fois », HTTP 400) s'affichent telles que renvoyées par le serveur.
- **Prêts** : `typeTaux` `FIXE` / `VARIABLE` choisi à la demande et au décaissement, relu dans `GET /prets/` (`LoanEntity.rateType`).
- **Cotisations** : modes directs `MTN_MOMO` / `ORANGE_MONEY` envoyés au backend (§7.1) ; `SEANCE` est lu comme espèces, `ORANGE_MONEY` comme Orange Money.
- Datasource : méthodes ajoutées pour `GET /comptes/notifications/` et `GET /comptes/admin/presidents/` (supervision Super Admin), sans écran dédié pour l'instant.
- Non branchés (aucun écran existant) : vérifications d'identité, assistance, signalements, journal d'audit, présences par WhatsApp, `echeances` hors du sélecteur WhatsApp.
- Code **non compilé** ici (pas de SDK Flutter) : lancer `flutter pub get && flutter analyze`.
