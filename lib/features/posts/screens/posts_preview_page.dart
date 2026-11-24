// Retain compatibility with the Flutter SDK used by the original project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../posts_controller.dart';
import '../services/post_sharer.dart';
import '../widgets/post_card.dart';
import 'comments_page.dart';
import 'create_post_page.dart';

/// A small preview runner, not the team's US08 community home feed.
class PostsPreviewPage extends StatefulWidget {
  const PostsPreviewPage({
    super.key,
    required this.controller,
    required this.sharer,
  });
  final PostsController controller;
  final PostSharer sharer;

  @override
  State<PostsPreviewPage> createState() => _PostsPreviewPageState();
}

class _PostsPreviewPageState extends State<PostsPreviewPage> {
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Future<void> _create() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final published = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePostPage(controller: widget.controller),
      ),
    );
    if (published == true && mounted) _message('Post saved on this device.');
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _like(CommunityPost post) async {
    try {
      await widget.controller.setLiked(
        post.id,
        !post.isLikedBy(widget.controller.currentUser.id),
      );
    } on PostFailure catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _share(CommunityPost post) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await widget.sharer.share(post);
      // The chooser may be cancelled. Do not show a false 'Post shared' message.
    } catch (error) {
      if (mounted) {
        _message(
          error is PostFailure ? error.message : 'Could not open sharing.',
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      return Scaffold(
        appBar: AppBar(title: const Text('LifeLoop')),
        floatingActionButton: controller.isReady
            ? FloatingActionButton.extended(
                key: const Key('new-post'),
                onPressed: controller.isSaving ? null : _create,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('New post'),
              )
            : null,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.loadError != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_outlined, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            controller.loadError!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: controller.load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      itemCount: controller.posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Moments worth sharing',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Device preview · ${controller.currentUser.name}\n'
                                  'Posts, likes and comments are saved on this device.',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (controller.posts.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 48,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Icon(
                                        Icons.auto_stories_outlined,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Start with your first post',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Share a thought, a personal experience, or an event recap.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }
                        final post = controller.posts[index - 1];
                        return PostCard(
                          key: ValueKey(post.id),
                          post: post,
                          currentUserId: controller.currentUser.id,
                          busy: controller.isSaving || _sharing,
                          onLike: () => _like(post),
                          onShare: () => _share(post),
                          onComment: () {
                            // A previous save notice must not cover the reply button.
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => CommentsPage(
                                  controller: controller,
                                  postId: post.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      );
    },
  );
}
