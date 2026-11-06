/// Contrat de base d'un cas d'utilisation (couche domain).
///
/// [T] est le type retourné, [Params] le type du paramètre d'entrée.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// À utiliser pour les cas d'utilisation qui n'ont pas de paramètre.
class NoParams {
  const NoParams();
}
