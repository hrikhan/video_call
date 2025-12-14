import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/utils/colors.dart';
import 'package:video_calling_system/app_constants/utils/global_textstyle.dart';
import 'package:video_calling_system/feature/bottom_navbar/controller/social_feed_controller.dart';
import 'package:video_calling_system/feature/bottom_navbar/pages/social_post.dart';
import 'package:video_player/video_player.dart';

class SocialPage extends StatelessWidget {
  SocialPage({super.key});

  final SocialFeedController controller = Get.put(SocialFeedController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutralBg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutralCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olpo Olpoi',
                        style: GlobalTextStyle.heading(
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover today’s picks',
                        style: GlobalTextStyle.body(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Social Feed',
                style: GlobalTextStyle.heading(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: controller.isUploading.value
                      ? null
                      : () => controller.shareMedia(),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    controller.isUploading.value
                        ? 'Uploading...'
                        : 'Share a new photo',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    controller.errorMessage.value,
                    style: GlobalTextStyle.body(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (controller.posts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Share your first photo to start the community feed.',
                    style: GlobalTextStyle.body(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: controller.posts
                    .map(
                      (post) {
                        final isCalling =
                            controller.callingPostId.value == post.id;
                        final isOwnPost =
                            controller.currentUserId == post.authorId;
                        final canCallAuthor =
                            controller.canCallAuthor(post);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeedVideoCard(
                            key: ValueKey(post.id),
                            post: post,
                            time: _relativeTime(post.createdAt),
                            isCalling: isCalling,
                            isOwnPost: isOwnPost,
                            canCallAuthor: canCallAuthor,
                            onCall: () => controller.requestRecipe(post),
                          ),
                        );
                      },
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

String _relativeTime(DateTime time) {
  final now = DateTime.now();
  if (time.isBefore(DateTime(2000))) {
    return 'Just now';
  }
  final diff = now.difference(time);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) return '$weeks week${weeks > 1 ? 's' : ''} ago';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '$months month${months > 1 ? 's' : ''} ago';
  final years = (diff.inDays / 365).floor();
  return '$years year${years > 1 ? 's' : ''} ago';
}

class _FeedVideoCard extends StatefulWidget {
  final SocialPost post;
  final String time;
  final bool isCalling;
  final bool isOwnPost;
  final bool canCallAuthor;
  final VoidCallback onCall;

  const _FeedVideoCard({
    super.key,
    required this.post,
    required this.time,
    required this.isCalling,
    required this.isOwnPost,
    required this.canCallAuthor,
    required this.onCall,
  });

  @override
  State<_FeedVideoCard> createState() => _FeedVideoCardState();
}

class _FeedVideoCardState extends State<_FeedVideoCard> {
  VideoPlayerController? _controller;
  Future<void>? _initFuture;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant _FeedVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.isVideo) {
      if (!oldWidget.post.isVideo ||
          oldWidget.post.mediaUrl != widget.post.mediaUrl) {
        _controller?.dispose();
        _initVideo();
        setState(() {
          _isPlaying = true;
        });
      }
    } else if (oldWidget.post.isVideo) {
      _controller?.dispose();
      _controller = null;
      _initFuture = null;
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initVideo() {
    if (!widget.post.isVideo) return;
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrl));
    _initFuture = _controller!.initialize().then((_) {
      _controller!
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      _isPlaying = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagLabel = widget.post.isVideo ? 'Video' : 'Photo';
    final tagColor = widget.post.isVideo
        ? AppColors.secondary.withOpacity(0.12)
        : AppColors.primary.withOpacity(0.12);
    final tagTextColor =
        widget.post.isVideo ? AppColors.secondary : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: widget.post.isVideo
                ? _buildVideoPlayer()
                : _buildImagePreview(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tagLabel,
                        style: TextStyle(
                          color: tagTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.time,
                      style: GlobalTextStyle.body(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.post.caption?.isNotEmpty == true
                      ? widget.post.caption!
                      : widget.post.isVideo
                          ? 'Shared a new video'
                          : 'Shared a new photo',
                  style: GlobalTextStyle.heading(
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        widget.post.authorName.isNotEmpty
                            ? widget.post.authorName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.authorName,
                            style: GlobalTextStyle.heading(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Post owner',
                            style: GlobalTextStyle.body(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: (widget.isOwnPost ||
                              widget.isCalling ||
                              !widget.canCallAuthor)
                          ? null
                          : widget.onCall,
                      icon: Icon(
                        widget.isCalling
                            ? Icons.hourglass_top
                            : Icons.call_outlined,
                        size: 16,
                      ),
                      label: Text(
                        widget.isOwnPost
                            ? 'Your post'
                            : widget.isCalling
                                ? 'Calling...'
                                : widget.canCallAuthor
                                    ? 'Call'
                                    : 'Not in contacts',
                      ),
                    ),
                  ],
                ),
                if (!widget.canCallAuthor && !widget.isOwnPost)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Add them from the Calls tab to connect.',
                      style: GlobalTextStyle.body(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_initFuture == null || _controller == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Video failed to load'));
        }
        return Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                      _isPlaying = false;
                    } else {
                      _controller!.play();
                      _isPlaying = true;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Muted',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      child: Image.network(
        widget.post.mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Text('Image failed to load')),
        loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
      ),
    );
  }
}
