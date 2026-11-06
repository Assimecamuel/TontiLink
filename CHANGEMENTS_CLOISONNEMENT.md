# Changements — rôles, inscription en 2 parcours, cloisonnement (selon API_CONTRACT.md)

## 1. Président automatique + invités membres
- Inscription « Créer ma tontine » → `intention: CREER_TONTINE` : l'utilisateur est Président (rôle réel ensuite relu depuis `/api/tontines/<id>/membres/`).
- Président/Fondateur : onglet Membres de la tontine → panneau « Invitations & utilisateurs » (`InvitationsPanel`) :
  invitation (`POST /api/tontines/<id>/inviter/`, canal EMAIL ou LIEN), liste des invitations (`GET /api/comptes/mes-invites/`),
  utilisateurs visibles (`GET /api/comptes/utilisateurs/`).
- Un invité apparaît comme `MEMBRE` ; le Président change son rôle via l'icône « gérer les droits »
  (`POST /api/tontines/<id>/roles/assign/` avec `replace: true`, id de tontine dynamique).
- Le faux « changement de rôle » local (menu profil) est supprimé : le rôle vient du serveur.

## 2. Inscription en deux parcours
- Écran d'inscription : choix « Créer ma tontine » (formulaire classique) ou « Participer à une tontine » (formulaire + code d'invitation).
- Corps envoyé à `POST /api/comptes/auth/register/` : `intention` (+ `codeInvitation` si REJOINDRE_TONTINE), `langue`.
- Utilisateur déjà connecté : bouton « Rejoindre avec un code » (`POST /api/tontines/rejoindre/`) dans « Mes Tontines ».
- Création de tontine alignée sur le contrat (`cotisation`, `membreMin`, `membreMax`, `dureeCycle`, `categorie`, `modeDistribution: ORDRE_FIXE`…).

## 3. Cloisonnement
- Plus aucune donnée de démonstration : à la connexion/déconnexion/inscription, toutes les données en mémoire sont vidées.
- Synchro dynamique : `GET /api/tontines/` (uniquement mes tontines), puis membres / cotisations / caisses / distributions / réunions
  de CHAQUE tontine (plus de `tontine 1` codée en dur). Le filtrage réel est fait par le backend (403 hors membres).
- Garde-fous d'état vide (tableau de bord, réunions, modal de paiement).

## Fichiers principaux
`lib/data/datasources/local_tonti_datasource.dart`, `lib/data/repositories/auth_repository_impl.dart`,
`lib/presentation/screens/auth/login_screen.dart`, `lib/presentation/screens/tontines/widgets/invitations_panel.dart`,
`lib/presentation/screens/tontines/tontines_screen.dart`, `lib/presentation/screens/shell_navigation_screen.dart`.

## À vérifier au premier lancement
Le code n'a pas pu être compilé (pas de SDK Flutter disponible lors de la modification) : lancer `flutter pub get && flutter analyze`.
Les formes exactes des réponses `GET /api/tontines/` et `GET /api/tontines/<id>/membres/` ne sont pas détaillées dans le contrat ;
le parsing est tolérant (liste directe ou clés `tontines` / `membres` / `results`).
