class AppStrings {
  static const String appName = 'TontiLink';
  static const String appTagline = 'FinTech des Tontines Traditionnelles et Modernes';
  static const String currency = 'FCFA';
  static const String countryCodeCameroon = '+237';

  // Rôles statutaires selon le Cahier des charges
  static const String rolePresident = 'Président';
  static const String roleTreasurer = 'Trésorier';
  static const String roleSecretary = 'Secrétaire';
  static const String roleAuditor = 'Commissaire aux comptes';
  static const String roleMember = 'Membre';

  // Descriptions des responsabilités statutaires
  static const String rolePresidentDesc =
      'Coordonne le groupe, convoque les assemblées, co-signe les distributions. Seul habilité statutairement à modifier ou attribuer les rôles aux membres.';
  static const String roleTreasurerDesc =
      'Enregistre et vérifie les cotisations, gère la caisse commune, prépare les distributions et effectue le rapprochement bancaire/MoMo.';
  static const String roleSecretaryDesc =
      'Gère le registre des membres, tient la feuille d\'émargement lors des réunions, rédige et publie les procès-verbaux (PV).';
  static const String roleAuditorDesc =
      'Contrôle la régularité des comptes et des pièces justificatives avec un accès d\'audit sans pouvoir de modification directe.';
  static const String roleMemberDesc =
      'Consulte sa situation, cotise, participe aux votes, reçoit sa cagnotte au tour fixé et peut solliciter un prêt ou une entraide.';

  // Avertissements de permissions
  static const String roleEditPresidentOnlyWarning =
      'Habilitation réservée au Président : Conformément à l\'Article 6 du Règlement Intérieur, seul le Président de la tontine peut modifier les rôles et attributions des membres.';
}
