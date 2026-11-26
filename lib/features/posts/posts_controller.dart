import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Characters;

import 'data/post_storage.dart';
import 'models/post.dart';

/// US09 / US12 / US13 / US14 logic, separated from the screens.
/// Single-device prototype; this class does not authenticate users.
class PostsController extends ChangeNotifier {
  PostsController({
    required this.storage,
    required this.currentUser,
    DateTime Function()? clock,
    String Function()? newId,
  }) : _clock = clock ?? DateTime.now,
       _newId = newId ?? _randomId;

  static const maxBodyLength = 2000;
  static const maxTitleLength = 100;
  static const maxLocationLength = 100;
  static const maxCommentLength = 500;
  final PostStorage storage;
  final PostAuthor currentUser;
  final DateTime Function() _clock;
  final String Function() _newId;
  List<CommunityPost> _posts = [];
  Future<void>? _tail;
  bool _disposed = false;
  bool _loaded = false;
  bool isLoading = true;
  bool isSaving = false;
  String? loadError;

  List<CommunityPost> get posts => List.unmodifiable(_posts);
  bool get isReady => _loaded && !isLoading && loadError == null;

  CommunityPost? findPost(String id) {
    for (final post in _posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  Future<void> load() => _serial(() async {
    isLoading = true;
    loadError = null;
    _notify();
    try {
      final contents = await storage.read();
      if (contents == null) {
        _posts = [];
      } else {
        final json = jsonDecode(contents) as Map<String, dynamic>;
        if (json['version'] != 1) {
          throw const FormatException('Unsupported saved-post version.');
        }
        final decoded = (json['posts'] as List)
            .map(
              (value) => CommunityPost.fromJson(value as Map<String, dynamic>),
            )
            .toList();
        if (decoded.map((post) => post.id).toSet().length != decoded.length) {
          throw const FormatException('Duplicate post IDs.');
        }
        decoded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _posts = decoded;
      }
      _loaded = true;
    } catch (_) {
      // Never overwrite unreadable existing data with an empty saved list.
      _loaded = false;
      loadError =
          'Could not load your saved posts. Try again. '
          'Your saved file has not been changed.';
    } finally {
      isLoading = false;
      _notify();
    }
  });

  Future<void> createPost({
    required PostKind kind,
    required String body,
    String? title,
    DateTime? eventDate,
    String? location,
    List<String>? photos,
  }) => _mutate(() {
    final cleanPhotos = (photos ?? [])
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (kind == PostKind.photo) {
      if (body.trim().isEmpty && cleanPhotos.isEmpty) {
        throw const PostFailure(
          'Add a photo or write something for your post.',
        );
      }
    }

    final String cleanBody;
    if (kind == PostKind.photo &&
        cleanPhotos.isNotEmpty &&
        body.trim().isEmpty) {
      cleanBody = '';
    } else {
      final String emptyMsg = switch (kind) {
        PostKind.text => 'Write something for your post.',
        PostKind.photo => 'Write a caption for your post.',
        PostKind.experience => 'Describe your experience.',
        PostKind.eventRecap => 'Write what happened at the event.',
      };
      cleanBody = _text(body, emptyMsg, maxBodyLength);
    }

    final String? cleanTitle = switch (kind) {
      PostKind.experience => _text(title ?? '', 'Add a title.', maxTitleLength),
      PostKind.eventRecap => _text(
        title ?? '',
        'Add an event name.',
        maxTitleLength,
      ),
      PostKind.text || PostKind.photo => null,
    };

    final String? cleanLocation;
    if (location != null && location.trim().isNotEmpty) {
      final loc = location.trim();
      if (Characters(loc).length > maxLocationLength) {
        throw const PostFailure('Location must be 100 characters or fewer.');
      }
      cleanLocation = loc;
    } else {
      cleanLocation = null;
    }

    DateTime? date;
    if (kind == PostKind.eventRecap && eventDate != null) {
      date = DateTime(eventDate.year, eventDate.month, eventDate.day);
      final now = _clock();
      if (date.isAfter(DateTime(now.year, now.month, now.day))) {
        throw const PostFailure('An event recap cannot have a future date.');
      }
    }

    return [
      CommunityPost(
        id: _newId(),
        author: currentUser,
        kind: kind,
        body: cleanBody,
        title: cleanTitle,
        eventDate: date,
        location: cleanLocation,
        photos: cleanPhotos,
        createdAt: _clock().toUtc(),
      ),
      ..._posts,
    ];
  });

  /// Idempotent: repeating 'like' never creates duplicate likes for a user.
  Future<void> setLiked(String postId, bool liked) => _mutate(() {
    final post = _requirePost(postId);
    final likes = {...post.likedUserIds};
    if (liked) {
      likes.add(currentUser.id);
    } else {
      likes.remove(currentUser.id);
    }
    return _replace(post.copyWith(likedUserIds: likes));
  });

  Future<void> addComment(String postId, String body) => _mutate(() {
    final post = _requirePost(postId);
    final cleanBody = _text(body, 'Write a comment first.', maxCommentLength);
    return _replace(
      post.copyWith(
        comments: [
          ...post.comments,
          PostComment(
            id: _newId(),
            author: currentUser,
            body: cleanBody,
            createdAt: _clock().toUtc(),
          ),
        ],
      ),
    );
  });

  Future<void> _mutate(
    List<CommunityPost> Function() change,
  ) => _serial(() async {
    if (!isReady) {
      throw const PostFailure('Load your saved posts before making changes.');
    }
    if (currentUser.id.trim().isEmpty || currentUser.name.trim().isEmpty) {
      throw const PostFailure('A user is required to post, like, or comment.');
    }
    final next = change();
    isSaving = true;
    _notify();
    try {
      await storage.write(
        jsonEncode({
          'version': 1,
          'posts': next.map((post) => post.toJson()).toList(),
        }),
      );
      // Show the change only after the disk write succeeds.
      _posts = next;
    } catch (_) {
      throw const PostFailure('Could not save your change. Please try again.');
    } finally {
      isSaving = false;
      _notify();
    }
  });

  CommunityPost _requirePost(String id) =>
      findPost(id) ??
      (throw const PostFailure('This post is no longer available.'));

  List<CommunityPost> _replace(CommunityPost changed) => [
    for (final post in _posts)
      if (post.id == changed.id) changed else post,
  ];

  // Queue writes to prevent overlapping comments and likes losing each other.
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = (_tail ?? Future<void>.value()).then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  static String _text(String value, String emptyMessage, int maxLength) {
    final clean = value.trim();
    if (clean.isEmpty) throw PostFailure(emptyMessage);
    if (Characters(clean).length > maxLength) {
      throw PostFailure('Use $maxLength characters or fewer.');
    }
    return clean;
  }

  static String _randomId() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(16, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
