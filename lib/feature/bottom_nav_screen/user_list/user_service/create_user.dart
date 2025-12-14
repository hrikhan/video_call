import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/app_user.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/call_session.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _callSessions =>
      _firestore.collection('callSessions');

  Future<void> ensureUserDocument(
    User user, {
    String? displayName,
  }) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get();
    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : user.displayName ?? user.email?.split('@').first ?? 'Guest';

    final payload = {
      'email': user.email,
      'displayName': name,
      'isOnline': true,
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (snapshot.exists) {
      await doc.update(payload);
    } else {
      await doc.set({
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updatePresence(String uid, {required bool isOnline}) async {
    if (uid.isEmpty) return;
    await _safeUpdate(uid, {
      'isOnline': isOnline,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppUser>> streamOtherUsers(String uid) {
    return _users.snapshots().map(
      (snapshot) => snapshot.docs
          .map(AppUser.fromDoc)
          .where((user) => user.id != uid)
          .toList(),
    );
  }

  Future<CallSession> startCall({
    required AppUser callee,
    required User caller,
  }) async {
    final doc = _callSessions.doc();
    final callerName = caller.displayName ??
        caller.email?.split('@').first ??
        'Unknown Caller';

    final session = CallSession(
      id: doc.id,
      channelName: AppConstants.channelName,
      token: AppConstants.tempToken,
      callerId: caller.uid,
      callerName: callerName,
      calleeId: callee.id,
      calleeName: callee.displayName,
      status: CallStatus.ringing,
      createdAt: DateTime.now(),
    );

    await doc.set(session.toMap());
    await _safeUpdate(caller.uid, {'activeCallId': doc.id});
    await _safeUpdate(callee.id, {'incomingCallId': doc.id});
    return session;
  }

  Stream<CallSession?> listenForIncomingCall(String uid) {
    return _callSessions
        .where('calleeId', isEqualTo: uid)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CallSession.fromDoc(snapshot.docs.first);
    });
  }

  Stream<CallSession?> watchCall(String callId) {
    return _callSessions.doc(callId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return CallSession.fromDoc(snapshot);
    });
  }

  Future<void> updateCallStatus(String callId, CallStatus status) async {
    await _callSessions.doc(callId).update({'status': status.name});
  }

  Future<void> acceptCall(CallSession session) async {
    await Future.wait([
      _callSessions
          .doc(session.id)
          .update({'status': CallStatus.accepted.name}),
      _safeUpdate(session.calleeId, {
        'incomingCallId': FieldValue.delete(),
        'activeCallId': session.id,
      }),
    ]);
  }

  Future<void> declineCall(CallSession session) async {
    await _callSessions
        .doc(session.id)
        .update({'status': CallStatus.declined.name});
    await clearUserCallState(session);
  }

  Future<void> clearUserCallState(CallSession session) async {
    await Future.wait([
      _safeUpdate(
          session.callerId, {'activeCallId': FieldValue.delete()}),
      _safeUpdate(session.calleeId, {
        'incomingCallId': FieldValue.delete(),
        'activeCallId': FieldValue.delete(),
      }),
    ]);
  }

  Future<void> endCall(CallSession session) async {
    await updateCallStatus(session.id, CallStatus.ended);
    await clearUserCallState(session);
  }

  Future<void> _safeUpdate(String uid, Map<String, dynamic> data) async {
    if (uid.isEmpty) return;
    try {
      await _users.doc(uid).update(data);
    } catch (_) {}
  }
}
