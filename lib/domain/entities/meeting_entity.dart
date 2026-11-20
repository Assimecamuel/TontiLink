enum MeetingStatus {
  aVenir,
  enCours,
  cloturee,
}

class AttendanceItemEntity {
  final String memberId;
  final String memberName;
  final bool isPresent;
  final double cashContributed;
  final bool cashReceiptIssued;
  final String note;

  const AttendanceItemEntity({
    required this.memberId,
    required this.memberName,
    this.isPresent = false,
    this.cashContributed = 0,
    this.cashReceiptIssued = false,
    this.note = '',
  });

  AttendanceItemEntity copyWith({
    bool? isPresent,
    double? cashContributed,
    bool? cashReceiptIssued,
    String? note,
  }) {
    return AttendanceItemEntity(
      memberId: memberId,
      memberName: memberName,
      isPresent: isPresent ?? this.isPresent,
      cashContributed: cashContributed ?? this.cashContributed,
      cashReceiptIssued: cashReceiptIssued ?? this.cashReceiptIssued,
      note: note ?? this.note,
    );
  }
}

class MeetingEntity {
  final String id;
  final String tontineId;
  final String tontineName;
  final String title;
  final DateTime dateTime;
  final String location;
  final String hostName;
  final MeetingStatus status;
  final int attendeesCount;
  final int totalExpectedMembers;
  final double totalCashCollected;
  final String minutesSummary;
  final List<AttendanceItemEntity> attendanceList;

  const MeetingEntity({
    required this.id,
    required this.tontineId,
    required this.tontineName,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.hostName,
    required this.status,
    required this.attendeesCount,
    required this.totalExpectedMembers,
    required this.totalCashCollected,
    required this.minutesSummary,
    required this.attendanceList,
  });

  MeetingEntity copyWith({
    String? id,
    String? tontineId,
    String? tontineName,
    String? title,
    DateTime? dateTime,
    String? location,
    String? hostName,
    MeetingStatus? status,
    int? attendeesCount,
    int? totalExpectedMembers,
    double? totalCashCollected,
    String? minutesSummary,
    List<AttendanceItemEntity>? attendanceList,
  }) {
    return MeetingEntity(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      tontineName: tontineName ?? this.tontineName,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      hostName: hostName ?? this.hostName,
      status: status ?? this.status,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      totalExpectedMembers: totalExpectedMembers ?? this.totalExpectedMembers,
      totalCashCollected: totalCashCollected ?? this.totalCashCollected,
      minutesSummary: minutesSummary ?? this.minutesSummary,
      attendanceList: attendanceList ?? this.attendanceList,
    );
  }
}
