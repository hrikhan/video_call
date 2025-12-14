import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';

import 'social_post.dart';

class SocialFeedService {
  SocialFeedService({
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _httpClient = httpClient ?? http.Client();

  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('socialPosts');

  Stream<List<SocialPost>> streamPosts() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(SocialPost.fromDoc).toList());
  }

  Future<String> uploadMedia({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String? mimeType,
    required String resourceType,
  }) async {
    if (file == null && bytes == null) {
      throw ArgumentError('Either file or bytes must be provided');
    }

    final sanitizedName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final publicId = 'social_feed/$sanitizedName';
    final paramsToSign = {
      'public_id': publicId,
      'timestamp': timestamp,
    };
    final signature = _generateSignature(paramsToSign);
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll({
        'public_id': publicId,
        'timestamp': timestamp,
        'api_key': AppConstants.cloudinaryApiKey,
        'signature': signature,
      });

    final filename = sanitizedName.isNotEmpty ? sanitizedName : 'upload.mp4';
    final mediaType = MediaType.parse(mimeType ?? 'video/mp4');
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: filename,
          contentType: mediaType,
        ),
      );
    } else if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      );
    }

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = decoded['secure_url'] as String?;
      if (secureUrl != null && secureUrl.isNotEmpty) {
        return secureUrl;
      }
      throw Exception('Cloudinary upload succeeded but no URL was returned.');
    }

    String message = 'Cloudinary upload failed (${response.statusCode}).';
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final details = error['message'];
        if (details is String && details.isNotEmpty) {
          message = details;
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = '$message ${response.body}';
      }
    }
    throw Exception(message);
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    required String mediaUrl,
    required String mediaType,
    String? caption,
  }) async {
    await _collection.add({
      'authorId': authorId,
      'authorName': authorName,
      'videoUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _generateSignature(Map<String, String> params) {
    final keys = params.keys.toList()..sort();
    final stringToSign = keys.map((key) => '$key=${params[key]}').join('&');
    final bytes = utf8.encode('$stringToSign${AppConstants.cloudinaryApiSecret}');
    return sha1.convert(bytes).toString();
  }
}
