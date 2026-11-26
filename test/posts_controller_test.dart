import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lifeloops/features/posts/models/post.dart';
import 'package:lifeloops/features/posts/posts_controller.dart';
import 'package:lifeloops/features/posts/services/post_sharer.dart';

import 'support/fakes.dart';

void main() {
  const author = PostAuthor(id: 'aayush', name: 'Aayush');
  late MemoryPostStorage storage;
  late PostsController controller;
  var sequence = 0;

  setUp(() async {
    sequence = 0;
    storage = MemoryPostStorage();
    controller = PostsController(
      storage: storage,
      currentUser: author,
      clock: () => DateTime(2026, 11, 23, 12),
      newId: () => 'id-${++sequence}',
    );
    await controller.load();
  });
  tearDown(() => controller.dispose());

  test(
    'US09 trims content, assigns author and stores newest posts first',
    () async {
      await controller.createPost(kind: PostKind.text, body: '  First post  ');
      await controller.createPost(kind: PostKind.text, body: 'Second post');
      expect(controller.posts.map((post) => post.body), [
        'Second post',
        'First post',
      ]);
      expect(controller.posts.first.author.id, author.id);
      expect(controller.posts.first.id, isNot(controller.posts.last.id));
      expect(
        controller.posts.last.createdAt,
        DateTime(2026, 11, 23, 12).toUtc(),
      );
      expect(storage.writes, 2);
    },
  );

  test('US09 rejects whitespace and overlong posts before saving', () async {
    for (final body in [' \n ', 'x' * 2001]) {
      await expectLater(
        controller.createPost(kind: PostKind.text, body: body),
        throwsA(isA<PostFailure>()),
      );
    }
    expect(storage.writes, 0);
    expect(controller.posts, isEmpty);
  });

  test(
    'character limits count visible emoji rather than UTF-16 code units',
    () async {
      await controller.createPost(kind: PostKind.text, body: '😀' * 2000);
      expect(controller.posts, hasLength(1));
    },
  );

  test('US12 experience needs a title and retains its story', () async {
    await expectLater(
      controller.createPost(kind: PostKind.experience, body: 'My experience'),
      throwsA(isA<PostFailure>()),
    );
    await controller.createPost(
      kind: PostKind.experience,
      title: '  First hike  ',
      body: 'I reached the trail end.',
    );
    expect(controller.posts.single.title, 'First hike');
    expect(controller.posts.single.kind, PostKind.experience);
    expect(controller.posts.single.eventDate, isNull);
  });

  test(
    'US12 event dates stay calendar dates across JSON round trips',
    () async {
      await controller.createPost(
        kind: PostKind.eventRecap,
        title: 'Birthday',
        body: 'We baked a cake.',
        eventDate: DateTime(2026, 11, 22, 23, 30),
        location: 'Park Venue',
        photos: ['https://example.com/cake.jpg'],
      );
      final post = controller.posts.single;
      expect(post.toJson()['eventDate'], '2026-11-22');
      expect(post.location, 'Park Venue');
      expect(post.photos, ['https://example.com/cake.jpg']);
      final restored = CommunityPost.fromJson(post.toJson());
      expect(restored.eventDate, DateTime(2026, 11, 22));
      expect(restored.kind, PostKind.eventRecap);
      expect(restored.location, 'Park Venue');
      expect(restored.photos, ['https://example.com/cake.jpg']);
    },
  );

  test(
    'US12 rejects future dates, overlong location, and overlong title',
    () async {
      await expectLater(
        controller.createPost(
          kind: PostKind.eventRecap,
          title: 'Event',
          body: 'Recap',
          eventDate: DateTime(2026, 11, 24),
        ),
        throwsA(isA<PostFailure>()),
      );
      await expectLater(
        controller.createPost(
          kind: PostKind.experience,
          title: 'x' * 101,
          body: 'Story',
        ),
        throwsA(isA<PostFailure>()),
      );
      await expectLater(
        controller.createPost(
          kind: PostKind.eventRecap,
          title: 'Event',
          body: 'Recap',
          location: 'x' * 101,
        ),
        throwsA(isA<PostFailure>()),
      );
      expect(storage.writes, 0);
    },
  );

  test(
    'US12 supports optional eventDate for eventRecap and optional photos',
    () async {
      await controller.createPost(
        kind: PostKind.eventRecap,
        title: 'Graduation',
        body: 'Graduation party with family.',
        eventDate: null,
        location: 'Main Hall',
      );
      expect(controller.posts.single.eventDate, isNull);
      expect(controller.posts.single.location, 'Main Hall');

      await controller.createPost(
        kind: PostKind.experience,
        title: 'Scuba Diving',
        body: 'Dived off the reef.',
        photos: ['https://example.com/reef.jpg'],
      );
      expect(controller.posts.first.photos, ['https://example.com/reef.jpg']);
      expect(controller.posts.first.kind, PostKind.experience);
    },
  );

  test('older saved posts without new fields load gracefully', () async {
    final legacyJson = jsonEncode({
      'version': 1,
      'posts': [
        {
          'id': 'legacy-1',
          'author': {'id': 'user-1', 'name': 'Legacy User'},
          'kind': 'text',
          'body': 'Old text post',
          'createdAt': '2026-01-01T10:00:00.000Z',
          'likedUserIds': [],
          'comments': [],
        },
      ],
    });
    storage.contents = legacyJson;
    await controller.load();
    expect(controller.posts, hasLength(1));
    final oldPost = controller.posts.single;
    expect(oldPost.kind, PostKind.text);
    expect(oldPost.title, isNull);
    expect(oldPost.eventDate, isNull);
    expect(oldPost.location, isNull);
    expect(oldPost.photos, isEmpty);
  });

  test(
    'US13 duplicate likes are idempotent and unlike removes only this user',
    () async {
      final seeded = CommunityPost(
        id: 'post',
        author: author,
        kind: PostKind.text,
        body: 'Hello',
        createdAt: DateTime.utc(2026),
        likedUserIds: {'someone-else'},
      );
      storage.contents = jsonEncode({
        'version': 1,
        'posts': [seeded.toJson()],
      });
      await controller.load();
      await controller.setLiked('post', true);
      await controller.setLiked('post', true);
      expect(controller.posts.single.likedUserIds, {'someone-else', 'aayush'});
      await controller.setLiked('post', false);
      await controller.setLiked('post', false);
      expect(controller.posts.single.likedUserIds, {'someone-else'});
    },
  );

  test(
    'US14 rejects empty/overlong comments and keeps author and order',
    () async {
      await controller.createPost(kind: PostKind.text, body: 'Hello');
      final id = controller.posts.single.id;
      for (final body in [' \n ', 'x' * 501]) {
        await expectLater(
          controller.addComment(id, body),
          throwsA(isA<PostFailure>()),
        );
      }
      await controller.addComment(id, '  First comment  ');
      await controller.addComment(id, 'Second comment');
      final comments = controller.posts.single.comments;
      expect(comments.map((comment) => comment.body), [
        'First comment',
        'Second comment',
      ]);
      expect(comments.first.author.id, author.id);
      expect(comments.first.id, isNot(comments.last.id));
    },
  );

  test('posts, likes and comments survive creating a new controller', () async {
    await controller.createPost(kind: PostKind.text, body: 'Keep me');
    final id = controller.posts.single.id;
    await controller.setLiked(id, true);
    await controller.addComment(id, 'Keep this too');
    final reopened = PostsController(storage: storage, currentUser: author);
    addTearDown(reopened.dispose);
    await reopened.load();
    expect(reopened.posts.single.body, 'Keep me');
    expect(reopened.posts.single.isLikedBy(author.id), isTrue);
    expect(reopened.posts.single.comments.single.body, 'Keep this too');
  });

  test(
    'overlapping like and comment writes do not lose either change',
    () async {
      await controller.createPost(kind: PostKind.text, body: 'Hello');
      final id = controller.posts.single.id;
      await Future.wait([
        controller.setLiked(id, true),
        controller.addComment(id, 'One'),
        controller.addComment(id, 'Two'),
      ]);
      expect(controller.posts.single.likedUserIds, {'aayush'});
      expect(controller.posts.single.comments.map((comment) => comment.body), [
        'One',
        'Two',
      ]);
    },
  );

  test(
    'failed write leaves saved and visible state intact, then permits retry',
    () async {
      await controller.createPost(kind: PostKind.text, body: 'Hello');
      final before = storage.contents;
      final id = controller.posts.single.id;
      storage.failWrite = true;
      await expectLater(
        controller.setLiked(id, true),
        throwsA(isA<PostFailure>()),
      );
      expect(controller.posts.single.likedUserIds, isEmpty);
      expect(storage.contents, before);
      expect(controller.isSaving, isFalse);
      storage.failWrite = false;
      await controller.setLiked(id, true);
      expect(controller.posts.single.isLikedBy(author.id), isTrue);
    },
  );

  test(
    'corrupted or unsupported saved data blocks writes without erasing it',
    () async {
      for (final contents in ['not json', '{"version":2,"posts":[]}']) {
        storage.contents = contents;
        await controller.load();
        expect(controller.loadError, isNotNull);
        await expectLater(
          controller.createPost(kind: PostKind.text, body: 'Overwrite?'),
          throwsA(isA<PostFailure>()),
        );
        expect(storage.contents, contents);
      }
      storage.contents = null;
      await controller.load();
      expect(controller.isReady, isTrue);
    },
  );

  test('stale post IDs are rejected without writing', () async {
    await expectLater(
      controller.setLiked('missing', true),
      throwsA(isA<PostFailure>()),
    );
    await expectLater(
      controller.addComment('missing', 'Hi'),
      throwsA(isA<PostFailure>()),
    );
    expect(storage.writes, 0);
  });

  test('US15 share text contains content and no fabricated URL or private comments', () async {
    await controller.createPost(
      kind: PostKind.eventRecap,
      title: 'Birthday',
      body: 'A lovely evening.',
      eventDate: DateTime(2026, 11, 22),
    );
    await controller.addComment(
      controller.posts.single.id,
      'This is not exported.',
    );
    final text = buildShareText(controller.posts.single);
    expect(text, contains('Aayush'));
    expect(text, contains('Birthday'));
    expect(text, contains('2026-11-22'));
    expect(text, contains('A lovely evening.'));
    expect(text, isNot(contains('https://')));
    expect(text, isNot(contains('This is not exported.')));
  });
}
