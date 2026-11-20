enum TransactionType {
  cotisation,
  distribution,
  pret,
  remboursement,
  secoursEntraide,
  penalite,
}

enum PaymentMethod {
  mtnMoMo,
  orangeMoney,
  especes,
  virement,
}

enum TransactionStatus {
  confirme,
  enAttente,
  aVerifier,
  echoue,
  annule,
}

class Transaction {
  final String id;
  final String tontineName;
  final String memberName;
  final TransactionType type;
  final double amount;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime date;
  final String reference;
  final String? validatedBy;
  final String note;

  const Transaction({
    required this.id,
    required this.tontineName,
    required this.memberName,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.reference,
    this.validatedBy,
    this.note = '',
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.cotisation:
        return 'Cotisation';
      case TransactionType.distribution:
        return 'Distribution (Tour)';
      case TransactionType.pret:
        return 'Octroi de Prêt';
      case TransactionType.remboursement:
        return 'Remboursement';
      case TransactionType.secoursEntraide:
        return 'Secours Entraide';
      case TransactionType.penalite:
        return 'Pénalité Retard';
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.mtnMoMo:
        return 'MTN MoMo';
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.especes:
        return 'Espèces (En réunion)';
      case PaymentMethod.virement:
        return 'Virement Bancaire';
    }
  }
}

