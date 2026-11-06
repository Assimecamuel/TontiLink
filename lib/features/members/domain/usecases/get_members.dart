import '../../../../core/usecases/usecase.dart';
import '../entities/member.dart';
import '../repositories/member_repository.dart';

class GetMembers implements UseCase<List<Member>, NoParams> {
  const GetMembers(this._repository);

  final MemberRepository _repository;

  @override
  Future<List<Member>> call(NoParams params) => _repository.getMembers();
}
