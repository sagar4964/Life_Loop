import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_loop/features/posts/data/post_storage.dart';
import 'package:life_loop/features/posts/models/post.dart';
import 'package:life_loop/features/posts/services/post_sharer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = AndroidPostStorage();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(AndroidPostStorage.channel, (
      call,
    ) async {
      calls.add(call);
      return call.method == 'readPosts' ? '{"version":1,"posts":[]}' : null;
    });
  });
  tearDown(
    () => messenger.setMockMethodCallHandler(AndroidPostStorage.channel, null),
  );

  test('Dart storage uses the exact Kotlin channel contract', () async {
    expect(await storage.read(), '{"version":1,"posts":[]}');
    await storage.write('content');
    expect(calls.map((call) => call.method), ['readPosts', 'writePosts']);
    expect(calls.last.arguments, {'contents': 'content'});
  });

  test('US15 passes plain text and subject to Android', () async {
    final post = CommunityPost(
      id: '1',
      author: const PostAuthor(id: 'a', name: 'Aayush'),
      kind: PostKind.text,
      body: 'Hello',
      createdAt: DateTime.utc(2026),
    );
    await const AndroidPostSharer().share(post);
    expect(calls.single.method, 'sharePost');
    expect(calls.single.arguments['text'], buildShareText(post));
    expect(calls.single.arguments['subject'], 'A LifeLoop post');
  });

  test('native sharing failure becomes a readable error', () async {
    messenger.setMockMethodCallHandler(AndroidPostStorage.channel, (_) async {
      throw PlatformException(code: 'SHARE_UNAVAILABLE');
    });
    final post = CommunityPost(
      id: '1',
      author: const PostAuthor(id: 'a', name: 'Aayush'),
      kind: PostKind.text,
      body: 'Hello',
      createdAt: DateTime.utc(2026),
    );
    await expectLater(
      const AndroidPostSharer().share(post),
      throwsA(isA<PostFailure>()),
    );
  });
}
