import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus { ringing, accepted, declined, ended }

CallStatus callStatusFromString(String value) {
  return CallStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => CallStatus.ended,
  );
}

class CallSession {
  final String id;
  final String channelName;
  final String token;
  final String callerId;
  final String callerName;
  final String calleeId;
  final String calleeName;
  final CallStatus status;
  final DateTime createdAt;

  CallSession({
    required this.id,
    required this.channelName,
    required this.token,
    required this.callerId,
    required this.callerName,
    required this.calleeId,
    required this.calleeName,
    required this.status,
    required this.createdAt,
  });

  CallSession copyWith({
    CallStatus? status,
  }) {
    return CallSession(
      id: id,
      channelName: channelName,
      token: token,
      callerId: callerId,
      callerName: callerName,
      calleeId: calleeId,
      calleeName: calleeName,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory CallSession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CallSession(
      id: doc.id,
      channelName: data['channelName'] as String? ?? '',
      token: data['token'] as String? ?? '',
      callerId: data['callerId'] as String? ?? '',
      callerName: data['callerName'] as String? ?? '',
      calleeId: data['calleeId'] as String? ?? '',
      calleeName: data['calleeName'] as String? ?? '',
      status: callStatusFromString(data['status'] as String? ?? ''),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelName': channelName,
      'token': token,
      'callerId': callerId,
      'callerName': callerName,
      'calleeId': calleeId,
      'calleeName': calleeName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
