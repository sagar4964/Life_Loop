import 'package:life_loop/features/posts/data/post_storage.dart';
import 'package:life_loop/features/posts/models/post.dart';
import 'package:life_loop/features/posts/services/post_sharer.dart';

class MemoryPostStorage implements PostStorage {
  String? contents;
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;

  @override
  Future<String?> read() async {
    if (failRead) throw StateError('Simulated read failure');
    return contents;
  }

  @override
  Future<void> write(String contents) async {
    if (failWrite) throw StateError('Simulated disk failure');
    writes++;
    this.contents = contents;
  }
}

class RecordingPostSharer implements PostSharer {
  final List<CommunityPost> shared = [];

  @override
  Future<void> share(CommunityPost post) async => shared.add(post);
}
