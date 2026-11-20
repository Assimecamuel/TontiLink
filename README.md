# TontiLink – Plateforme de gestion des tontines en Afrique

**TontiLink** est une application multiplateforme développée avec Flutter pour faciliter la gestion des tontines traditionnelles et modernes en Afrique, avec une attention particulière au contexte camerounais.

Elle vise à améliorer la transparence financière, la gestion des membres, le suivi des cotisations, l'organisation des distributions et la gouvernance des groupes.

L'application propose une interface moderne, responsive et intuitive, adaptée aux ordinateurs, tablettes et téléphones mobiles.

---

## Sommaire

- Présentation du projet
- Fonctionnalités principales
- Identité visuelle
- Compatibilité et interface responsive
- Architecture technique
- Technologies utilisées
- Installation et configuration
- Connexion au backend Django
- Compilation et déploiement Web
- Sécurité et bonnes pratiques
- État du développement

---

## 1. Fonctionnalités principales

### 1.1 Tableau de bord

Le tableau de bord centralise les informations financières et opérationnelles :

- Total des cotisations du mois.
- Fonds disponibles.
- Nombre de tontines actives.
- Prochaine distribution.
- Graphique de l'évolution financière sur six mois.
- Historique des dernières transactions.
- Alertes et raccourcis vers les principales fonctionnalités.

### 1.2 Gestion des tontines

Le module de gestion des tontines permet :

- De consulter les tontines existantes.
- De filtrer les groupes selon leur type.
- De consulter les détails et les règles financières.
- De suivre la progression des cycles.
- D'identifier les prochains bénéficiaires.

Un assistant de création en six étapes est également disponible :

1. Informations générales et visibilité.
2. Choix du modèle de tontine.
3. Définition des règles financières.
4. Organisation des tours de distribution.
5. Composition du bureau.
6. Règlement intérieur et validation.

Les détails d'une tontine comprennent notamment les membres, les rôles, l'historique des cotisations et le calendrier des distributions.

### 1.3 Gestion des membres

- Consultation des membres.
- Suivi de leur participation.
- Gestion des informations des adhérents.
- Organisation des rôles et responsabilités.
- Gestion des invitations et des autorisations.

### 1.4 Cotisations et paiements

- Suivi des cotisations individuelles.
- Identification des membres à jour et en retard.
- Enregistrement des paiements.
- Historique des transactions.
- Prise en charge des moyens de paiement suivants dans l'interface :
  - MTN Mobile Money.
  - Orange Money.
  - Espèces.
  - Virement bancaire.

Les opérations en espèces peuvent être soumises à une vérification avant leur rapprochement comptable.

**Sécurité :** l'application ne demande jamais le code PIN personnel Mobile Money de l'utilisateur.

### 1.5 Distributions

- Consultation de l'ordre de passage.
- Programmation des distributions.
- Suivi des bénéficiaires.
- Vérification des fonds disponibles.
- Processus de validation à double signature : président et trésorier avant décaissement.

### 1.6 Caisse et comptabilité

Le module de caisse permet de distinguer :

- Le solde comptable théorique.
- Les fonds réellement disponibles.
- Les espèces physiques.
- Les fonds Mobile Money.
- Les soldes bancaires.

Il comprend également un journal des opérations et le suivi des justificatifs.

### 1.7 Réunions

- Organisation des réunions.
- Gestion des présences.
- Feuille d'émargement.
- Suivi des activités.
- Enregistrement des paiements en espèces pendant les réunions.

### 1.8 Prêts et entraide sociale

- Suivi des prêts internes.
- Consultation des remboursements.
- Suivi des échéances.
- Gestion des aides sociales.
- Suivi des événements familiaux et communautaires.

### 1.9 Gestion des rôles et permissions

L'application prévoit plusieurs profils :

- Président.
- Trésorier.
- Secrétaire.
- Membre.

Les permissions de l'interface s'adaptent au rôle sélectionné.

---

## 2. Identité visuelle et design system

TontiLink utilise une identité visuelle chaleureuse, moderne et professionnelle.

| Élément | Couleur | Code |
|---|---|---|
| Or principal | Or | `#C99A2E` |
| Or clair | Or doux | `#E9C96B` |
| Fond secondaire | Crème | `#F9F3DF` |
| Fond général | Gris chaud | `#F8F7F3` |
| Blanc | Blanc pur | `#FFFFFF` |
| Texte principal | Gris foncé | `#202124` |
| Texte secondaire | Gris | `#777777` |
| Confirmation | Vert | `#21865B` |
| Alerte | Rouge | `#D64545` |
| Information | Bleu | `#3478C8` |
| Bordures | Beige clair | `#E8E3D8` |

---

## 3. Compatibilité et interface responsive

TontiLink adapte automatiquement son interface à la taille de l'écran.

| Élément | Ordinateur | Mobile |
|---|---|---|
| Navigation | Barre latérale | Barre inférieure |
| En-tête | Complet avec recherche | Compact |
| Tableaux | Tableaux détaillés | Cartes compactes |
| Formulaires | Modales et colonnes | Présentation verticale |
| Actions | Boutons et menus | Actions simplifiées |

L'interface est conçue pour offrir une expérience cohérente sur les différentes plateformes.

---

## 4. Architecture technique

Le projet adopte une organisation inspirée de la Clean Architecture afin de séparer les responsabilités et faciliter la maintenance.

```text
lib/
├── main.dart
├── injection_container.dart
│
├── app/
│   ├── app.dart
│   └── shell_navigation_screen.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── i18n/
│   ├── network/
│   ├── theme/
│   ├── usecases/
│   └── utils/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── tontines/
│   ├── members/
│   ├── cotisations/
│   ├── distributions/
│   ├── caisse/
│   ├── prets_entraide/
│   ├── reunions/
│   └── settings/
│
└── presentation/
    ├── controllers/
    ├── screens/
    └── widgets/
```

### Principe de fonctionnement

```text
Screen
   ↓
Controller
   ↓
UseCase
   ↓
Repository Interface
   ↓
Repository Implementation
   ↓
DataSource
```

Les responsabilités sont séparées entre la présentation, la logique métier et l'accès aux données.

---

## 5. Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Flutter | Développement multiplateforme |
| Dart | Langage de programmation |
| Material Design | Interface utilisateur |
| Django | Backend |
| Django REST Framework | API REST |
| HTTP | Communication frontend/backend |
| Git | Gestion des versions |
| GitHub | Hébergement du code source |
| Vercel | Hébergement envisagé pour Flutter Web |

---

## 6. Installation et configuration

### Prérequis

Installer les outils suivants :

- Flutter SDK.
- Dart SDK (inclus avec Flutter).
- Android Studio.
- Git.
- Visual Studio Code (facultatif).

Vérifier l'installation :

```bash
flutter doctor
```

### Récupérer le projet

```bash
git clone https://github.com/Assimecamuel/TontiLink.git
```

Entrer dans le dossier :

```bash
cd TontiLink
```

Installer les dépendances :

```bash
flutter pub get
```

### Lancer l'application sur Chrome

```bash
flutter run -d chrome
```

### Lancer l'application sur Android

```bash
flutter run
```

---

## 7. Connexion au backend Django

Le frontend communique avec un backend Django à travers une API REST.

### Configuration de l'API

Le client HTTP est organisé dans :

```text
lib/core/network/api_client.dart
```

L'adresse actuelle du backend de développement est :

```text
http://10.173.147.1:8000
```

Cette adresse est une configuration locale de développement. Elle doit être adaptée à l'environnement utilisé.

### Authentification

Le processus d'authentification utilise notamment :

```text
POST /api/comptes/auth/login/
```

L'inscription suit les étapes suivantes :

```text
register
register/verify-email
```

Après authentification, le jeton reçu est utilisé dans les requêtes protégées :

```http
Authorization: Bearer <token>
```

Le client prend en charge les réponses standard de l'API :

```json
{
  "success": true,
  "data": {},
  "message": "Operation successful"
}
```

Il prend également en charge le catalogue non enveloppé de `GET /api/`.

### Configuration réseau

Pour le développement local :

- Le serveur Django doit écouter sur `0.0.0.0:8000`.
- Le port 8000 doit être autorisé dans le pare-feu.
- L'appareil Android doit pouvoir accéder au serveur.
- Pour Flutter Web, l'origine du frontend doit être autorisée dans la configuration CORS du backend.

**Important :** l'adresse IP locale ne doit pas être utilisée comme adresse publique de production. En production, utiliser une URL HTTPS accessible publiquement.

---

## 8. Compilation et déploiement Web

### Générer la version Web

```bash
flutter build web --release
```

Les fichiers compilés sont générés dans :

```text
build/web/
```

Ce dossier contient les ressources statiques nécessaires à l'hébergement de l'application Web.

### Déploiement sur Vercel

Le projet peut être préparé pour un hébergement statique sur Vercel à partir de `build/web`.

La configuration de production doit notamment prévoir :

- Une compilation Flutter Web.
- Le dossier de sortie `build/web`.
- Les règles de réécriture nécessaires à la navigation Flutter Web.
- Une URL publique HTTPS pour le backend Django.
- Une configuration CORS adaptée.

Le SDK Flutter n'étant pas fourni par défaut dans l'environnement standard de Vercel, une configuration personnalisée du processus de build est nécessaire.

---

## 9. Sécurité et bonnes pratiques

Pour protéger l'application et les données des utilisateurs :

- Ne jamais publier de mots de passe, clés secrètes ou fichiers `.env`.
- Utiliser HTTPS en production.
- Ne jamais demander les codes PIN Mobile Money.
- Contrôler les permissions selon les rôles.
- Vérifier les opérations financières côté backend.
- Effectuer les validations métier côté serveur.
- Conserver les informations sensibles dans un environnement sécurisé.
- Ne pas considérer les données locales de démonstration comme des données financières réelles.

---

## 10. État du développement

TontiLink est un projet en développement progressif.

L'interface Flutter comprend plusieurs modules de gestion et des données locales de démonstration. Certaines fonctionnalités disposent d'une intégration avec le backend Django, tandis que d'autres nécessitent encore le raccordement à leurs endpoints API dédiés.

Les fonctionnalités visibles dans l'interface ne doivent donc pas toutes être considérées comme des services de production entièrement opérationnels.

---

## 11. Contribution

Les contributions au projet sont les bienvenues.

Pour proposer une amélioration :

1. Forker le dépôt.
2. Créer une branche dédiée.
3. Effectuer les modifications.
4. Tester les changements.
5. Soumettre une Pull Request.

Exemple :

```bash
git checkout -b feature/nom-de-la-fonctionnalite
```

---

## 12. Dépôt GitHub

Code source :

https://github.com/Assimecamuel/TontiLink

---

**TontiLink — Simplifier la gestion des tontines, renforcer la confiance et accompagner la finance communautaire en Afrique.**