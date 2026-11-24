// Retain compatibility with the Flutter SDK used by the original project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_loop/features/posts/models/post.dart';
import 'package:life_loop/features/posts/posts_controller.dart';
import 'package:life_loop/features/posts/widgets/post_card.dart';
import 'package:life_loop/main.dart';

import 'support/fakes.dart';

void main() {
  late MemoryPostStorage storage;
  late PostsController controller;
  late RecordingPostSharer sharer;

  setUp(() {
    storage = MemoryPostStorage();
    controller = PostsController(
      storage: storage,
      currentUser: const PostAuthor(id: 'aayush', name: 'Aayush'),
    );
    sharer = RecordingPostSharer();
  });
  tearDown(() => controller.dispose());

  Future<void> openApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      LifeLoopApp(controller: controller, sharer: sharer),
    );
    await tester.pumpAndSettle();
  }

  Future<void> publish(WidgetTester tester, String body) async {
    await tester.tap(find.byKey(const Key('new-post')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('post-body')), body);
    await tester.ensureVisible(find.byKey(const Key('publish-post')));
    await tester.tap(find.byKey(const Key('publish-post')));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'create, like, unlike, comment and share through the actual screens',
    (tester) async {
      await openApp(tester);
      expect(find.text('Start with your first post'), findsOneWidget);
      await publish(tester, 'I finished my first hike.');
      final id = controller.posts.single.id;
      expect(find.text('I finished my first hike.'), findsOneWidget);
      await tester.ensureVisible(find.byKey(ValueKey('like-$id')));
      await tester.tap(find.byKey(ValueKey('like-$id')));
      await tester.pumpAndSettle();
      expect(find.text('1 like · 0 comments'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('like-$id')));
      await tester.pumpAndSettle();
      expect(find.text('0 likes · 0 comments'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('comments-$id')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('comment-body')),
        'A great afternoon.',
      );
      await tester.tap(find.byKey(const Key('send-comment')));
      await tester.pumpAndSettle();
      expect(find.text('A great afternoon.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('0 likes · 1 comment'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('share-$id')));
      await tester.pumpAndSettle();
      expect(sharer.shared.single.id, id);
      expect(find.text('Post shared'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty submission stays in composer with an explanation', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byKey(const Key('new-post')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('publish-post')));
    await tester.tap(find.byKey(const Key('publish-post')));
    await tester.pumpAndSettle();
    expect(find.text('Write something for your post.'), findsOneWidget);
    expect(controller.posts, isEmpty);
  });

  for (final kind in [PostKind.experience, PostKind.eventRecap]) {
    testWidgets('${kind.label} form publishes title, story and correct type', (
      tester,
    ) async {
      await openApp(tester);
      await tester.tap(find.byKey(const Key('new-post')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, kind.label));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('post-title')),
        'A memorable day',
      );
      await tester.enterText(
        find.byKey(const Key('post-body')),
        'Here is what happened.',
      );
      await tester.ensureVisible(find.byKey(const Key('publish-post')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('publish-post')));
      await tester.pumpAndSettle();
      final post = controller.posts.single;
      expect(post.kind, kind);
      expect(post.title, 'A memorable day');
      expect(find.text('Create a post'), findsNothing);
    });
  }

  testWidgets(
    'Event recap publishes location and photo, displayed on feed card',
    (tester) async {
      await openApp(tester);
      await tester.tap(find.byKey(const Key('new-post')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ChoiceChip, PostKind.eventRecap.label),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('post-title')),
        'Summer Concert',
      );
      await tester.enterText(
        find.byKey(const Key('post-location')),
        'Central Park',
      );
      await tester.enterText(
        find.byKey(const Key('post-body')),
        'Great music and sunset.',
      );
      await tester.ensureVisible(find.byKey(const Key('photo-url-input')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('photo-url-input')),
        'https://example.com/concert.jpg',
      );
      await tester.tap(find.byKey(const Key('add-photo-button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('publish-post')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('publish-post')));
      await tester.pumpAndSettle();

      final post = controller.posts.single;
      expect(post.kind, PostKind.eventRecap);
      expect(post.title, 'Summer Concert');
      expect(post.location, 'Central Park');
      expect(post.photos, ['https://example.com/concert.jpg']);
      expect(find.text('Summer Concert'), findsOneWidget);
      expect(find.text('Location: Central Park'), findsOneWidget);
    },
  );

  testWidgets('failed save keeps the draft and retry publishes it once', (
    tester,
  ) async {
    await openApp(tester);
    storage.failWrite = true;
    await publish(tester, 'Please keep my draft.');
    expect(controller.posts, isEmpty);
    expect(
      find.text('Could not save your change. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Please keep my draft.'), findsOneWidget);
    storage.failWrite = false;
    await tester.ensureVisible(find.byKey(const Key('publish-post')));
    await tester.tap(find.byKey(const Key('publish-post')));
    await tester.pumpAndSettle();
    expect(controller.posts, hasLength(1));
  });

  testWidgets('failed comment keeps typed text and retry sends it once', (
    tester,
  ) async {
    await openApp(tester);
    await publish(tester, 'My post');
    final id = controller.posts.single.id;
    await tester.ensureVisible(find.byKey(ValueKey('comments-$id')));
    await tester.tap(find.byKey(ValueKey('comments-$id')));
    await tester.pumpAndSettle();
    storage.failWrite = true;
    await tester.enterText(
      find.byKey(const Key('comment-body')),
      'Keep this reply',
    );
    await tester.tap(find.byKey(const Key('send-comment')));
    await tester.pumpAndSettle();
    expect(controller.posts.single.comments, isEmpty);
    expect(find.text('Keep this reply'), findsOneWidget);
    storage.failWrite = false;
    await tester.tap(find.byKey(const Key('send-comment')));
    await tester.pumpAndSettle();
    expect(controller.posts.single.comments, hasLength(1));
  });

  testWidgets('read failure offers retry and does not enable writing', (
    tester,
  ) async {
    storage.failRead = true;
    await openApp(tester);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byKey(const Key('new-post')), findsNothing);
    storage.failRead = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('new-post')), findsOneWidget);
  });

  testWidgets('post card wraps actions at narrow width and large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final post = CommunityPost(
      id: '1',
      author: const PostAuthor(id: 'a', name: 'Aayush Chaulagain'),
      kind: PostKind.eventRecap,
      title: 'A birthday with friends',
      eventDate: DateTime(2026, 11, 22),
      body: 'We baked a cake together.',
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: PostCard(
                post: post,
                currentUserId: 'a',
                onLike: () {},
                onComment: () {},
                onShare: () {},
                canShare: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Share'), findsNothing);
  });
}
