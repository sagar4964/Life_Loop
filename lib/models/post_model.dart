class PostItem {
  final String id;
  final String caption;
  final String timeAgo;
  final String date;

  PostItem({
    required this.id,
    required this.caption,
    required this.timeAgo,
    required this.date,
  });
}

class PostRepository {
  // Starts empty as requested ("keep it real he/she havent post")
  static final List<PostItem> _posts = [];

  static List<PostItem> get posts => _posts;

  static void addPost(String caption) {
    _posts.insert(
      0,
      PostItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caption: caption.isEmpty ? 'Visual update from LifeLoop' : caption,
        timeAgo: 'Just now',
        date: 'Today',
      ),
    );
  }

  static void deletePost(String id) {
    _posts.removeWhere((p) => p.id == id);
  }
}
