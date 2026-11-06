enum MeetingStatus {
  aVenir,
  enCours,
  cloturee,
}

class MeetingAttendanceItem {
  final String memberId;
  final String memberName;
  final bool isPresent;
  final double cashContributed;
  final bool cashReceiptIssued;
  final String note;

  const MeetingAttendanceItem({
    required this.memberId,
    required this.memberName,
    this.isPresent = false,
    this.cashContributed = 0,
    this.cashReceiptIssued = false,
    this.note = '',
  });

  MeetingAttendanceItem copyWith({
    bool? isPresent,
    double? cashContributed,
    bool? cashReceiptIssued,
    String? note,
  }) {
    return MeetingAttendanceItem(
      memberId: memberId,
      memberName: memberName,
      isPresent: isPresent ?? this.isPresent,
      cashContributed: cashContributed ?? this.cashContributed,
      cashReceiptIssued: cashReceiptIssued ?? this.cashReceiptIssued,
      note: note ?? this.note,
    );
  }
}

class Meeting {
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
  final List<MeetingAttendanceItem> attendanceList;

  const Meeting({
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
}

