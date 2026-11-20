import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/member_local_data_source.dart';

class MemberRepositoryImpl implements MemberRepository {
  const MemberRepositoryImpl(this._dataSource);

  final MemberLocalDataSource _dataSource;

  @override
  Future<List<Member>> getMembers() => _dataSource.getMembers();

}
