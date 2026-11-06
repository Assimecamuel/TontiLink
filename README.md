# TontiLink - FinTech Africaine & Gestion des Tontines

Application Flutter moderne, élégante, transparente et adaptative pour la gestion des tontines traditionnelles et modernes au Cameroun (Douala, Yaoundé, Bafoussam...).

Conçue sur la base du **Cahier des charges de l'application de tontines** et du **Guide de conception UI/UX (`promt_interface.md`)**.

---

## 🎨 Identité Visuelle & Design System

- **Or principal** : `#C99A2E` (actions majeures, montants cagnottes, branding)
- **Or clair / Or doux** : `#E9C96B` & `#F9F3DF` (accents, cartes actives)
- **Fond général** : `#F8F7F3` (chaleureux, aéré, rassurant)
- **Blanc pur** : `#FFFFFF` (surfaces de cartes et tableaux)
- **Texte principal** : `#202124` (contraste optimal)
- **Texte secondaire** : `#777777`
- **Vert de confirmation** : `#21865B` (opérations confirmées, membres à jour)
- **Rouge d'alerte** : `#D64545` (retards, alertes de trésorerie)
- **Bleu d'information** : `#3478C8` (notices, virements)
- **Bordures** : `#E8E3D8`

---

## 📱 & 💻 Ergonomie Adaptative (Web Desktop & Mobile)

L'application détecte automatiquement la taille de l'écran et adapte l'expérience utilisateur :

| Éléments | Web Desktop (≥ 1024px / Réf. 1440px) | Mobile (< 768px / Réf. 390px) |
| :--- | :--- | :--- |
| **Navigation** | Barre latérale gauche complète fixe avec profils et badges | Barre de navigation inférieure à 5 onglets (Accueil, Tontines, Cotisations, Réunions, Profil) |
| **En-tête** | Titre, fil d'Ariane, barre de recherche globale, badge de rôle actif, raccourci d'ajout | En-tête compact avec cloche de notification et bouton tiroir |
| **Tableaux** | Vue tabulaire avec colonnes détaillées et filtres horizontaux | Cartes compactes avec badges de statut et actions rapides |
| **Formulaires** | Fenêtres modales dimensionnées et formulaires multi-colonnes | Feuilles déroulantes et déroulement vertical plein écran |

---

## 🚀 Fonctionnalités Implémentées

1. **Tableau de Bord FinTech (Dashboard)**
   - 4 Cartes d'indicateurs clés : Cotisations du mois, Fonds disponibles, Tontines actives, Prochaine levée.
   - Bannière en vedette de la prochaine distribution (Tour #7 Mme Jeanne Ngo Bayi, 1 200 000 FCFA).
   - Graphique interactif de l'évolution financière sur 6 mois (collecté vs attendu) avec info-bulles.
   - Raccourcis d'actions rapides et alertes de trésorerie.
   - Tableau traçable des dernières transactions avec badges MTN MoMo, Orange Money, Espèces et Virement.

2. **Mes Tontines & Groupes**
   - Filtrage : Rotatives, Cumulatives, Avec Prêts, Entraide familiale, Projets d'investissement.
   - Cartes complètes avec barre de progression du cycle (ex: Tour 7/12) et prochain bénéficiaire.
   - **Assistant de Création en 6 étapes** (`CreateTontineWizardScreen`) :
     1. Informations générales (nom, visibilité, image)
     2. Modèle de tontine
     3. Règles financières & montants FCFA
     4. Mécanisme d'attribution des tours (ordre fixe, tirage au sort, enchères)
     5. Composition du bureau (Président, Trésorier, Secrétaire)
     6. Règlement intérieur & validation
   - **Détail d'une Tontine** avec onglets : Vue d'ensemble, Membres & Rôles, Historique des cotisations, Calendrier des distributions.

3. **Cotisations & Enregistrement de Paiement**
   - Suivi nominatif des membres à jour et en retard.
   - Formulaire d'enregistrement avec sélection de l'opérateur (MTN MoMo, Orange Money, Espèces, Virement).
   - Mention de sécurité formelle : aucun code PIN n'est demandé.
   - Traitement des espèces en réunion avec statut "À vérifier" avant rapprochement par le trésorier.

4. **Distributions & Sécurité Financière**
   - Ordre de passage et dates programmées.
   - **Double signature obligatoire** : Président + Trésorier avant décaissement des cagnottes.
   - Rapprochement entre cagnotte théorique et fonds réellement disponibles.

5. **Caisse & Comptabilité Rapprochée**
   - **Distinction stricte** : Solde comptable théorique vs Fonds réellement disponibles.
   - Décomposition de la trésorerie : Espèces physiques en coffre, Mobile Money agrégé, Solde Afriland First Bank.
   - Journal des écritures avec pièces justificatives.

6. **Réunions Traditionnelles Présentielles**
   - Module taillé pour les séances physiques de week-end au Cameroun.
   - Feuille d'émargement et de présence en direct.
   - Encaissement rapide des espèces en réunion avec reçu instantané.

7. **Prêts Internes & Entraide Sociale**
   - Suivi des micro-crédits internes avec taux d'intérêt voté (2.0%) et barres d'amortissement.
   - Caisse de secours pour événements de vie (naissances, mariages, deuils).

8. **Simulation des Rôles & Permissions**
   - Sélecteur de rôle interactif dans les paramètres (Président, Trésorier, Secrétaire, Membre Simple) permettant de tester l'adaptation des autorisations de l'interface en direct !

---

## 💻 Comment Lancer le Projet

### Sur Web (Recommandé pour tester le format Desktop 1440px) :
```bash
cd TontiLink
flutter pub get
flutter run -d chrome
```

### Sur Mobile (Android / iOS) :
```bash
cd TontiLink
flutter pub get
flutter run
```


## Architecture (Clean Architecture)

```
lib/
├── main.dart                      # point d'entrée (init DI + runApp)
├── injection_container.dart       # injection de dépendances manuelle (sl)
├── app/                           # MaterialApp + shell de navigation
├── core/                          # thème, utilitaires, contrat UseCase
├── shared/widgets/                # widgets réutilisables (common, navigation, charts)
└── features/<feature>/
    ├── domain/                    # Dart pur : entities, repositories (interfaces), usecases
    ├── data/                      # datasources (mock en mémoire), repositories (implémentations)
    └── presentation/              # controllers (ChangeNotifier), screens, widgets
```

Sens des dépendances : `presentation -> domain <- data`. Le domaine ne dépend ni de Flutter ni de la couche data.
Flux : `Screen -> Controller -> UseCase -> Repository (interface) -> RepositoryImpl -> DataSource`.

Features : `tontines`, `members`, `cotisations`, `distributions`, `caisse`, `prets_entraide`, `reunions`
(avec domain/data/presentation) ; `auth`, `dashboard`, `settings` (présentation uniquement).

Pour brancher une vraie API : remplacer `*LocalDataSourceImpl` par une implémentation distante dans `injection_container.dart`.


## Connexion au backend Django (contrat API)

- URL configurée : `http://10.173.147.1:8000`. Pour un émulateur ou un autre réseau, modifier `lib/core/network/api_client.dart`.
- Le client envoie `Authorization: Bearer <token>` après authentification et décode les réponses standard `{success, data, message}` ainsi que le catalogue non enveloppé de `GET /api/`.
- La connexion utilise `POST /api/comptes/auth/login/`; l'inscription suit `register` puis `register/verify-email`. Un échec réseau ou d'authentification ne connecte plus un compte de démonstration.
- Après connexion, la navigation métier synchronise les endpoints GET configurés dans `lib/data/datasources/local_tonti_datasource.dart`. Les opérations reliées attendent la réponse HTTP et affichent les erreurs réseau/API au lieu d'annoncer un succès local.
- Android déclare la permission INTERNET et autorise HTTP en clair pour ce backend local. Pour une mise en production, utiliser HTTPS et désactiver `usesCleartextTraffic`.

**Prérequis réseau :** le serveur Django doit écouter sur l'interface LAN de l'ordinateur (`0.0.0.0:8000`), le port 8000 doit être autorisé par le pare-feu, et le téléphone/émulateur doit pouvoir joindre `10.173.147.1`.

**Intégration active :** l'écran principal après connexion est la navigation métier. Le jeton reçu au login est joint aux appels protégés; l'application confirme la disponibilité du catalogue Django avant d'indiquer qu'elle est connectée. Les formulaires de création de tontine, cotisation, prêt et entraide ainsi que les signatures et présences attendent une réponse du serveur et affichent les erreurs au lieu de signaler un succès local. Les IDs d'adhésion utilisés par les actions sont recherchés dans les membres synchronisés et ne sont pas remplacés par un ID de démonstration fixe.

Pour Flutter Web, autoriser également l'origine de l'application dans la configuration CORS Django. Les écrans qui ne sont pas encore reliés à un endpoint dédié peuvent toujours afficher leurs données locales de démonstration.
