// Retain compatibility with the Flutter SDK used by the original project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../posts_controller.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({
    super.key,
    required this.controller,
    required this.postId,
  });
  final PostsController controller;
  final String postId;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    if (_text.text.trim().isEmpty) {
      setState(() => _error = 'Write a comment first.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.controller.addComment(widget.postId, _text.text);
      if (!mounted) return;
      _text.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } on PostFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not send. Please try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_sending,
    child: Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final post = widget.controller.findPost(widget.postId);
                if (post == null) {
                  return const Center(
                    child: Text('This post is no longer available.'),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            post.author.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (post.title != null) Text(post.title!),
                          const SizedBox(height: 8),
                          Text(post.body),
                          const Divider(height: 32),
                          if (post.comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'No comments yet. Start the conversation.',
                              ),
                            ),
                          for (final comment in post.comments)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.author.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    MaterialLocalizations.of(context)
                                        .formatMediumDate(
                                          comment.createdAt.toLocal(),
                                        ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(comment.body),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const Key('comment-body'),
                            controller: _text,
                            enabled: !_sending,
                            minLines: 1,
                            maxLines: 3,
                            maxLength: PostsController.maxCommentLength,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: 'Write a comment',
                              errorText: _error,
                              errorMaxLines: 3,
                            ),
                          ),
                          FilledButton.icon(
                            key: const Key('send-comment'),
                            onPressed: _sending || widget.controller.isSaving
                                ? null
                                : _send,
                            icon: const Icon(Icons.send_outlined),
                            label: Text(
                              _sending ? 'Sending...' : 'Send comment',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
