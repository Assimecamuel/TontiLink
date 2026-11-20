abstract class Failure {
  final String message;
  const Failure(this.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Action non autorisée pour votre rôle.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau ou connexion indisponible.']);
}
