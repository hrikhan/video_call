import 'package:cloud_firestore/cloud_firestore.dart';

class SocialPost {
  SocialPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    this.caption,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final String? caption;

  bool get isVideo => mediaType == 'video';
  bool get isImage => mediaType == 'image';

  factory SocialPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['createdAt'];
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      createdAt = timestamp;
    }

    final url = data['videoUrl'] ?? '';
    final type = (data['mediaType'] as String?) ?? _inferType(url);

    return SocialPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      mediaUrl: url,
      mediaType: type,
      caption: data['caption'],
      createdAt: createdAt,
    );
  }
}

String _inferType(String url) {
  final lower = url.toLowerCase();
  if (lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.mkv') ||
      lower.endsWith('.webm')) {
    return 'video';
  }
  return 'image';
}
