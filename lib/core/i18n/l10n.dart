import 'package:flutter/material.dart';

/// Gestion simple de la langue (FR / EN) sans dépendance externe.
class L10n extends ChangeNotifier {
  static final L10n instance = L10n._();
  L10n._();

  String _code = 'fr';

  String get code => _code;
  bool get isFr => _code == 'fr';

  void setLanguage(String code) {
    if ((code == 'fr' || code == 'en') && code != _code) {
      _code = code;
      notifyListeners();
    }
  }

  String t(String key) {
    final table = isFr ? _fr : _en;
    return table[key] ?? _fr[key] ?? key;
  }

  static const Map<String, String> _fr = {
    // Navigation
    'nav_features': 'Fonctionnalités',
    'nav_how': 'Comment ça marche',
    'nav_payments': 'Paiements',
    'nav_login': 'Connexion',
    'nav_signup': 'Créer un compte',
    'theme_to_dark': 'Passer au thème sombre',
    'theme_to_light': 'Passer au thème clair',
    'lang_label': 'Langue',
    'back': 'Retour',
    'app_title': 'TontiLink - FinTech des Tontines Camerounaises',

    // Hero
    'hero_badge': 'LA TONTINE, VERSION DIGITALE',
    'hero_title_1': 'Votre tontine avance.',
    'hero_title_2': 'Vous aussi.',
    'hero_sub':
        'Cotisations, tours de cagnotte, réunions et caisse commune : TontiLink rassemble toute la vie de votre tontine dans un espace clair, sûr et transparent.',
    'hero_cta_create': 'Créer ma tontine',
    'hero_cta_discover': 'Découvrir la plateforme',
    'hero_tags': 'Présidents · Trésoriers · Membres',
    'preview_title': 'Mon espace TontiLink',
    'preview_kicker': 'UNE VUE CLAIRE SUR L\'ESSENTIEL',
    'preview_hello': 'Bonjour, et bienvenue',
    'preview_sub': 'Votre tontine commence ici.',
    'preview_r1_t': 'Cotisations',
    'preview_r1_s': 'Suivre chaque versement',
    'preview_r2_t': 'Cagnotte & tours',
    'preview_r2_s': 'Un tirage équitable et clair',
    'preview_r3_t': 'Réunions & PV',
    'preview_r3_s': 'Des assemblées bien tenues',
    'preview_foot': 'Tout votre groupe, à portée de main.',
    'preview_tag': 'APERÇU',

    // Stats
    'stat1_v': '100 %',
    'stat1_l': 'Transparence des comptes',
    'stat2_v': '2',
    'stat2_l': 'Opérateurs Mobile Money',
    'stat3_v': '5',
    'stat3_l': 'Rôles statutaires',
    'stat4_v': '24/7',
    'stat4_l': 'Accès à votre espace',

    // Fonctionnalités
    'feat_kicker': 'POURQUOI TONTILINK',
    'feat_title': 'Tout ce qu\'il faut pour une tontine sereine',
    'feat_sub':
        'Fini les carnets perdus et les disputes de chiffres. Chaque cotisation, chaque tour et chaque décision est tracé.',
    'f1_t': 'Cotisations suivies',
    'f1_d':
        'Enregistrez les versements, repérez les retards et relancez en un clic.',
    'f2_t': 'Cagnotte rotative',
    'f2_d':
        'Tirage au sort ou ordre fixé : chacun connaît son tour et le montant à recevoir.',
    'f3_t': 'Rôles statutaires',
    'f3_d':
        'Président, Trésorier, Secrétaire, Commissaire aux comptes : chacun ses droits.',
    'f4_t': 'Réunions & procès-verbaux',
    'f4_d':
        'Convocations, feuille d\'émargement et PV publiés pour tous les membres.',
    'f5_t': 'Prêts & entraide',
    'f5_d':
        'Demandes de prêt et événements de solidarité gérés dans le même espace.',
    'f6_t': 'Caisse & audit',
    'f6_d':
        'Une caisse commune lisible, avec une vue d\'audit sans pouvoir de modification.',

    // Comment ça marche
    'how_kicker': 'EN 3 ÉTAPES',
    'how_title': 'Lancez votre tontine en quelques minutes',
    's1_t': 'Créez votre tontine',
    's1_d':
        'Choisissez le montant, la fréquence et la méthode de distribution.',
    's2_t': 'Invitez vos membres',
    's2_d': 'Ajoutez-les par téléphone et attribuez les rôles du bureau.',
    's3_t': 'Cotisez et recevez',
    's3_d':
        'Les cotisations sont suivies et la cagnotte est remise au bon tour.',

    // Paiements
    'pay_title': 'Pensé pour le Cameroun',
    'pay_sub':
        'Paiements compatibles MTN MoMo et Orange Money, montants en FCFA et rigueur comptable conforme aux normes OHADA.',

    // CTA final
    'cta_title': 'Prêt à lancer votre tontine ?',
    'cta_sub':
        'Rejoignez TontiLink et donnez à votre groupe les outils d\'une gestion moderne.',
    'cta_btn': 'Créer mon compte gratuitement',
    'cta_login': 'J\'ai déjà un compte',
    'footer_rights': '© 2026 TontiLink · Fait pour les tontines du Cameroun',

    // Connexion — panneau gauche
    'brand_tag': 'FinTech des Tontines CM',
    'login_hero_title': 'Chaque tontine mérite de prospérer.',
    'login_hero_sub':
        'Gérez vos cotisations, supervisez les levées de cagnotte rotatives et tenez vos assemblées avec une rigueur comptable conforme aux normes OHADA.',
    'chip1': 'Simple à utiliser',
    'chip2': 'Pensé pour vous',
    'bul1': 'Double signature statutaire Président & Trésorier',
    'bul2': 'Paiements compatibles MTN MoMo & Orange Money',
    'bul3': 'Rôles statutaires stricts selon le Cahier des charges',
    'panel_foot': 'TONTILINK / PLATEFORME DE TONTINES',

    // Connexion — formulaire
    'tab_login': 'Se connecter',
    'tab_signup': 'Créer un compte',
    'reg_choice_title': 'Que souhaitez-vous faire ?',
    'reg_create_title': 'Créer ma tontine',
    'reg_create_desc': 'Je serai automatiquement Président et je pourrai inviter mes membres.',
    'reg_join_title': 'Participer à une tontine',
    'reg_join_desc': 'J’ai reçu un code ou un lien d’invitation par e-mail.',
    'reg_change_choice': 'Changer mon choix',
    'reg_president_note': 'Vous serez automatiquement Président de votre tontine.',
    'f_invite_code': 'Code d’invitation',
    'f_invite_code_hint': 'Ex. INV-123456',
    'invite_code_required': 'Le code d’invitation est obligatoire pour participer à une tontine.',
    'title_login': 'Ravi de vous retrouver.',
    'sub_login':
        'Connectez-vous pour retrouver vos tontines actives et continuer à avancer.',
    'title_signup': 'Créez votre compte membre',
    'sub_signup': 'Rejoignez votre tontine camerounaise en quelques clics.',
    'f_name': 'Nom et prénom',
    'f_name_hint': 'Nom et prénom',
    'f_email': 'Adresse e-mail (facultative)',
    'f_email_hint': 'votre.email@domaine.cm',
    'f_phone': 'Numéro de téléphone (+237)',
    'f_password': 'Mot de passe sécurisé',
    'remember': 'Se souvenir de moi',
    'forgot': 'Mot de passe oublié ?',
    'terms':
        'J\'accepte les conditions d\'utilisation et le respect de la charte de solidarité tontinière.',
    'btn_login': 'Se connecter',
    'btn_signup': 'Valider mon inscription',
    'no_account': 'Pas encore de compte ? S\'inscrire',
    'have_account': 'Déjà un compte ? Se connecter',
    'secure_note': 'Votre espace personnel sécurisé',
    'phone_required':
        'Veuillez saisir votre numéro de téléphone camerounais.',

    // Démo
    'demo_title': 'CONNEXION RAPIDE DÉMO PAR RÔLE',
    'demo_sub':
        'Sélectionnez un profil pour tester les permissions réelles de l\'interface :',
    'demo_president': '👑 Président (Paul)',
    'demo_treasurer': '💰 Trésorière (Jeanne)',
    'demo_secretary': '📝 Secrétaire (Samuel)',
    'demo_member': '👤 Membre (Christian)',
    'connected_as': 'Connecté en tant que',

    // OTP
    'otp_title': 'Vérification par Email',
    'otp_sent': 'Un code à 4 chiffres a été envoyé au',
    'otp_label': 'Code de confirmation',
    'otp_resend_in': 'Renvoyer dans',
    'otp_expired': 'Code expiré',
    'otp_resend': 'Renvoyer le SMS',
    'otp_confirm': 'Confirmer et entrer dans l\'espace tontine',

    // Mot de passe oublié
    'forgot_title': 'Récupération de mot de passe',
    'forgot_text':
        'Entrez votre numéro pour recevoir un lien sécurisé de réinitialisation :',
    'forgot_phone': 'Numéro (+237)',
    'cancel': 'Annuler',
    'forgot_send': 'Envoyer le lien',
    'forgot_done': 'Lien de réinitialisation envoyé par SMS !',

    // Coque (barre latérale, en-tête)
    'space_label': 'VOTRE ESPACE',
    'crumb': 'MON ESPACE',
    'nav_dashboard': 'Tableau de bord',
    'nav_tontines': 'Mes tontines',
    'nav_contrib': 'Cotisations & paiements',
    'nav_distrib': 'Distributions',
    'nav_cash': 'Caisse & comptabilité',
    'nav_loans': 'Prêts & entraide',
    'nav_repayments': 'Remboursements & Dettes',
    'nav_meetings': 'Réunions',
    'nav_settings': 'Paramètres & profil',
    'promo_t': 'Grandir, ensemble.',
    'promo_d': 'Chaque tontine compte. Accompagnez la suivante.',
    'logout': 'Se déconnecter',
    'new_tontine': 'Nouvelle tontine',
    'notif_msg': 'Centre de notifications : toutes les alertes sont à jour.',
    'switch_role': 'Changer de rôle actif',
    'title_create_tontine': 'Créer une tontine',
    'bn_home': 'Accueil',
    'bn_tontines': 'Tontines',
    'bn_contrib': 'Cotisations',
    'bn_meetings': 'Réunions',
    'bn_profile': 'Profil',
    'bn_sec': 'Secrétaire',
    'bn_treas': 'Trésorier',
    'bn_mem': 'Mon Espace',
    'bn_val': 'Validation',
    'bn_cash': 'Caisse',
    'bn_distrib': 'Distributions',
    'bn_pay': 'Cotiser',
    'bn_loans': 'Prêts/Aide',
    'bn_options': 'Options',
    'bn_members': 'Membres',
    'bn_penalties': 'Pénalités',

    'nav_sec_space': 'Espace Secrétaire',
    'nav_sec_meetings': 'Réunions & Présences',
    'nav_sec_members': 'Membres & Rôles',
    'nav_sec_penalties': 'Signalement Pénalités',

    'nav_treas_space': 'Espace Trésorier',
    'nav_treas_validation': 'Validation Cotisations',
    'nav_treas_cash': 'Suivi de Caisse',
    'nav_treas_distrib': 'Distributions',
    'nav_treas_loans': 'Demandes de Prêts',

    'nav_aud_space': 'Espace Audit',
    'nav_aud_cash': 'Audit Caisse',
    'nav_aud_contrib': 'Audit Cotisations',
    'nav_aud_distrib': 'Audit Distributions',

    'nav_mem_space': 'Mon Espace / Situation',
    'nav_mem_pay': 'Cotiser en ligne',
    'nav_mem_tontines': 'Mes Tontines & Inviter',
    'nav_mem_loans': 'Demande Prêt & Aide',
    'nav_mem_meetings': 'Notifications & Réunions',

    // Tableau de bord
    'dash_title': 'Votre quotidien, en un coup d\'œil.',
    'dash_sub': 'Retrouvez l\'essentiel et accédez rapidement à votre gestion.',
    'hello': 'Bonjour',
    'hello_sub': 'Gérez vos tontines et gardez une vue claire sur votre activité.',
    'role_connected': 'Rôle connecté',
    'qa_title': 'Accès rapides',
    'qa_sub': 'L\'essentiel de votre activité',
    'qa1_t': 'Mes tontines',
    'qa1_d': 'Consultez vos cercles, cycles et bénéficiaires.',
    'qa2_t': 'Cotisations',
    'qa2_d': 'Gardez une trace claire de chaque versement.',
    'qa3_t': 'Caisse',
    'qa3_d': 'Suivez la trésorerie et les rapprochements.',
    'qa4_t': 'Réunions',
    'qa4_d': 'Émargement, procès-verbaux et séances.',
  };

  static const Map<String, String> _en = {
    // Navigation
    'nav_features': 'Features',
    'nav_how': 'How it works',
    'nav_payments': 'Payments',
    'nav_login': 'Log in',
    'nav_signup': 'Create account',
    'theme_to_dark': 'Switch to dark theme',
    'theme_to_light': 'Switch to light theme',
    'lang_label': 'Language',
    'back': 'Back',
    'app_title': 'TontiLink - Cameroonian Tontine FinTech',

    // Hero
    'hero_badge': 'THE TONTINE, GOES DIGITAL',
    'hero_title_1': 'Your tontine moves forward.',
    'hero_title_2': 'So do you.',
    'hero_sub':
        'Contributions, payout rounds, meetings and the common fund: TontiLink brings your whole tontine together in one clear, safe and transparent space.',
    'hero_cta_create': 'Create my tontine',
    'hero_cta_discover': 'Discover the platform',
    'hero_tags': 'Presidents · Treasurers · Members',
    'preview_title': 'My TontiLink space',
    'preview_kicker': 'A CLEAR VIEW OF WHAT MATTERS',
    'preview_hello': 'Hello, and welcome',
    'preview_sub': 'Your tontine starts here.',
    'preview_r1_t': 'Contributions',
    'preview_r1_s': 'Track every payment',
    'preview_r2_t': 'Payout & rounds',
    'preview_r2_s': 'A fair and clear draw',
    'preview_r3_t': 'Meetings & minutes',
    'preview_r3_s': 'Well-run assemblies',
    'preview_foot': 'Your whole group, at your fingertips.',
    'preview_tag': 'PREVIEW',

    // Stats
    'stat1_v': '100%',
    'stat1_l': 'Account transparency',
    'stat2_v': '2',
    'stat2_l': 'Mobile Money operators',
    'stat3_v': '5',
    'stat3_l': 'Statutory roles',
    'stat4_v': '24/7',
    'stat4_l': 'Access to your space',

    // Features
    'feat_kicker': 'WHY TONTILINK',
    'feat_title': 'Everything you need for a worry-free tontine',
    'feat_sub':
        'No more lost notebooks or arguments over figures. Every contribution, round and decision is tracked.',
    'f1_t': 'Tracked contributions',
    'f1_d': 'Record payments, spot late ones and send reminders in one click.',
    'f2_t': 'Rotating payout',
    'f2_d':
        'Random draw or fixed order: everyone knows their turn and the amount to receive.',
    'f3_t': 'Statutory roles',
    'f3_d':
        'President, Treasurer, Secretary, Auditor: everyone has their own rights.',
    'f4_t': 'Meetings & minutes',
    'f4_d':
        'Notices, attendance sheets and minutes published for every member.',
    'f5_t': 'Loans & mutual aid',
    'f5_d': 'Loan requests and solidarity events handled in the same space.',
    'f6_t': 'Fund & audit',
    'f6_d':
        'A readable common fund, with an audit view that cannot modify entries.',

    // How it works
    'how_kicker': 'IN 3 STEPS',
    'how_title': 'Launch your tontine in minutes',
    's1_t': 'Create your tontine',
    's1_d': 'Choose the amount, the frequency and the payout method.',
    's2_t': 'Invite your members',
    's2_d': 'Add them by phone number and assign the board roles.',
    's3_t': 'Contribute and receive',
    's3_d': 'Contributions are tracked and the pot goes to the right member.',

    // Payments
    'pay_title': 'Designed for Cameroon',
    'pay_sub':
        'Payments compatible with MTN MoMo and Orange Money, amounts in FCFA and accounting rigor in line with OHADA standards.',

    // Final CTA
    'cta_title': 'Ready to launch your tontine?',
    'cta_sub':
        'Join TontiLink and give your group the tools of modern management.',
    'cta_btn': 'Create my free account',
    'cta_login': 'I already have an account',
    'footer_rights': '© 2026 TontiLink · Made for Cameroonian tontines',

    // Login — left panel
    'brand_tag': 'Tontine FinTech CM',
    'login_hero_title': 'Every tontine deserves to thrive.',
    'login_hero_sub':
        'Manage your contributions, oversee rotating payouts and hold your meetings with accounting rigor in line with OHADA standards.',
    'chip1': 'Easy to use',
    'chip2': 'Made for you',
    'bul1': 'Statutory double signature: President & Treasurer',
    'bul2': 'Payments compatible with MTN MoMo & Orange Money',
    'bul3': 'Strict statutory roles as set by the Bylaws',
    'panel_foot': 'TONTILINK / TONTINE PLATFORM',

    // Login — form
    'tab_login': 'Log in',
    'tab_signup': 'Create account',
    'reg_choice_title': 'What would you like to do?',
    'reg_create_title': 'Create my tontine',
    'reg_create_desc': 'I will automatically be President and can invite my members.',
    'reg_join_title': 'Join a tontine',
    'reg_join_desc': 'I received an invitation code or link by e-mail.',
    'reg_change_choice': 'Change my choice',
    'reg_president_note': 'You will automatically be President of your tontine.',
    'f_invite_code': 'Invitation code',
    'f_invite_code_hint': 'e.g. INV-123456',
    'invite_code_required': 'An invitation code is required to join a tontine.',
    'title_login': 'Great to see you again.',
    'sub_login':
        'Log in to find your active tontines and keep moving forward.',
    'title_signup': 'Create your member account',
    'sub_signup': 'Join your Cameroonian tontine in just a few clicks.',
    'f_name': 'Full name',
    'f_name_hint': 'Full name',
    'f_email': 'Email address (optional)',
    'f_email_hint': 'your.email@domain.cm',
    'f_phone': 'Phone number (+237)',
    'f_password': 'Secure password',
    'remember': 'Remember me',
    'forgot': 'Forgot password?',
    'terms':
        'I accept the terms of use and the tontine solidarity charter.',
    'btn_login': 'Log in',
    'btn_signup': 'Complete my registration',
    'no_account': 'No account yet? Sign up',
    'have_account': 'Already have an account? Log in',
    'secure_note': 'Your secure personal space',
    'phone_required': 'Please enter your Cameroonian phone number.',

    // Demo
    'demo_title': 'QUICK DEMO LOGIN BY ROLE',
    'demo_sub': 'Pick a profile to test the real permissions of the interface:',
    'demo_president': '👑 President (Paul)',
    'demo_treasurer': '💰 Treasurer (Jeanne)',
    'demo_secretary': '📝 Secretary (Samuel)',
    'demo_member': '👤 Member (Christian)',
    'connected_as': 'Logged in as',

    // OTP
    'otp_title': 'SMS OTP verification',
    'otp_sent': 'A 4-digit code has been sent to',
    'otp_label': 'Confirmation code',
    'otp_resend_in': 'Resend in',
    'otp_expired': 'Code expired',
    'otp_resend': 'Resend SMS',
    'otp_confirm': 'Confirm and enter the tontine space',

    // Forgot password
    'forgot_title': 'Password recovery',
    'forgot_text': 'Enter your number to receive a secure reset link:',
    'forgot_phone': 'Number (+237)',
    'cancel': 'Cancel',
    'forgot_send': 'Send link',
    'forgot_done': 'Reset link sent by SMS!',

    // Shell (sidebar, header)
    'space_label': 'YOUR SPACE',
    'crumb': 'MY SPACE',
    'nav_dashboard': 'Dashboard',
    'nav_tontines': 'My tontines',
    'nav_contrib': 'Contributions & payments',
    'nav_distrib': 'Payouts',
    'nav_cash': 'Fund & accounting',
    'nav_loans': 'Loans & mutual aid',
    'nav_meetings': 'Meetings',
    'nav_settings': 'Settings & profile',
    'promo_t': 'Growing together.',
    'promo_d': 'Every tontine counts. Support the next one.',
    'logout': 'Log out',
    'new_tontine': 'New tontine',
    'notif_msg': 'Notification center: all alerts are up to date.',
    'switch_role': 'Change active role',
    'title_create_tontine': 'Create a tontine',
    'bn_home': 'Home',
    'bn_tontines': 'Tontines',
    'bn_contrib': 'Contributions',
    'bn_meetings': 'Meetings',
    'bn_profile': 'Profile',
    'bn_sec': 'Secretary',
    'bn_treas': 'Treasurer',
    'bn_mem': 'My Space',
    'bn_val': 'Validation',
    'bn_cash': 'Fund',
    'bn_distrib': 'Payouts',
    'bn_pay': 'Contribute',
    'bn_loans': 'Loans/Aid',
    'bn_options': 'Options',
    'bn_members': 'Members',
    'bn_penalties': 'Penalties',

    'nav_sec_space': 'Secretary Space',
    'nav_sec_meetings': 'Meetings & Attendance',
    'nav_sec_members': 'Members & Roles',
    'nav_sec_penalties': 'Penalty Reporting',

    'nav_treas_space': 'Treasurer Space',
    'nav_treas_validation': 'Contribution Validation',
    'nav_treas_cash': 'Fund Tracking',
    'nav_treas_distrib': 'Payouts',
    'nav_treas_loans': 'Loan Requests',

    'nav_aud_space': 'Audit Space',
    'nav_aud_cash': 'Fund Audit',
    'nav_aud_contrib': 'Contribution Audit',
    'nav_aud_distrib': 'Payout Audit',

    'nav_mem_space': 'My Space / Overview',
    'nav_mem_pay': 'Pay Online',
    'nav_mem_tontines': 'My Tontines & Invite',
    'nav_mem_loans': 'Loan & Aid Request',
    'nav_mem_meetings': 'Notifications & Meetings',

    // Dashboard
    'dash_title': 'Your day at a glance.',
    'dash_sub': 'Find the essentials and jump straight to your management.',
    'hello': 'Hello',
    'hello_sub': 'Manage your tontines and keep a clear view of your activity.',
    'role_connected': 'Connected role',
    'qa_title': 'Quick access',
    'qa_sub': 'The essentials of your activity',
    'qa1_t': 'My tontines',
    'qa1_d': 'View your circles, cycles and beneficiaries.',
    'qa2_t': 'Contributions',
    'qa2_d': 'Keep a clear record of every payment.',
    'qa3_t': 'Fund',
    'qa3_d': 'Track cash and reconciliations.',
    'qa4_t': 'Meetings',
    'qa4_d': 'Attendance, minutes and sessions.',
  };
}

/// Raccourci de traduction.
String tr(String key) => L10n.instance.t(key);
