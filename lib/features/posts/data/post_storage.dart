import 'package:flutter/services.dart';

/// Local persistence boundary. Tests inject in-memory storage.
/// A shared backend needs per-user, atomic server operations; uploading this
/// entire local snapshot is NOT a multi-user database implementation.
abstract interface class PostStorage {
  Future<String?> read();
  Future<void> write(String contents);
}

class AndroidPostStorage implements PostStorage {
  const AndroidPostStorage();
  static const channel = MethodChannel('life_loop/sprint_two');

  @override
  Future<String?> read() => channel.invokeMethod<String>('readPosts');

  @override
  Future<void> write(String contents) =>
      channel.invokeMethod<void>('writePosts', {'contents': contents});
}
