// Retain compatibility with the Flutter SDK used by the original project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/post.dart';

/// Reusable by the community feed owner. Visibility decisions belong to US19;
/// pass canShare: false for posts that the user must not export.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.busy = false,
    this.canShare = true,
  });

  final CommunityPost post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final bool busy;
  final bool canShare;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final liked = post.isLikedBy(currentUserId);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    post.author.name.trim().isEmpty
                        ? '?'
                        : post.author.name
                              .trim()
                              .characters
                              .first
                              .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        MaterialLocalizations.of(context)
                            .formatMediumDate(post.createdAt.toLocal()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Text(
                  post.kind.label,
                  style: TextStyle(color: colors.onSecondaryContainer),
                ),
              ),
            ),
            if (post.title != null) ...[
              const SizedBox(height: 14),
              Text(post.title!, style: Theme.of(context).textTheme.titleLarge),
            ],
            if (post.eventDate != null || post.location != null) ...[
              const SizedBox(height: 8),
              if (post.eventDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Event date: ${calendarDate(post.eventDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
              if (post.location != null)
                Text(
                  'Location: ${post.location!}',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
            ],
            if (post.body.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.body, style: const TextStyle(height: 1.5)),
            ],
            if (post.photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final photo in post.photos)
                        SizedBox(
                          width: post.photos.length == 1
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 8) / 2,
                          height: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: colors.surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 32,
                                          color: colors.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            photo,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 14),
            Text(
              '${post.likedUserIds.length} '
              '${post.likedUserIds.length == 1 ? 'like' : 'likes'} · '
              '${post.comments.length} '
              '${post.comments.length == 1 ? 'comment' : 'comments'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            // Wrap supports narrow phones and larger accessibility text sizes.
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Semantics(
                  toggled: liked,
                  child: TextButton.icon(
                    key: ValueKey('like-${post.id}'),
                    onPressed: busy ? null : onLike,
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                    label: Text(liked ? 'Liked' : 'Like'),
                  ),
                ),
                TextButton.icon(
                  key: ValueKey('comments-${post.id}'),
                  onPressed: onComment,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Comment'),
                ),
                if (canShare)
                  TextButton.icon(
                    key: ValueKey('share-${post.id}'),
                    onPressed: busy ? null : onShare,
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Share'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
