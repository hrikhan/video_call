import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final bool isOnline;
  final DateTime? lastActive;
  final String? incomingCallId;
  final String? activeCallId;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isOnline,
    this.lastActive,
    this.incomingCallId,
    this.activeCallId,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      isOnline: data['isOnline'] as bool? ?? false,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      incomingCallId: data['incomingCallId'] as String?,
      activeCallId: data['activeCallId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'isOnline': isOnline,
      'lastActive': lastActive,
      if (incomingCallId != null) 'incomingCallId': incomingCallId,
      if (activeCallId != null) 'activeCallId': activeCallId,
    };
  }
}
