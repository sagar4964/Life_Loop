/// Aayush's post types from US09 and US12.
enum PostKind {
  text('Text post'),
  photo('Photo post'),
  experience('Personal experience'),
  eventRecap('Event recap');

  const PostKind(this.label);
  final String label;
}

class PostAuthor {
  const PostAuthor({required this.id, required this.name});
  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory PostAuthor.fromJson(Map<String, dynamic> json) =>
      PostAuthor(id: json['id'] as String, name: json['name'] as String);
}

class PostComment {
  const PostComment({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
  });
  final String id;
  final PostAuthor author;
  final String body;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'body': body,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    id: json['id'] as String,
    author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
    body: json['body'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class CommunityPost {
  CommunityPost({
    required this.id,
    required this.author,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.title,
    this.eventDate,
    this.location,
    List<String> photos = const [],
    Set<String> likedUserIds = const {},
    List<PostComment> comments = const [],
  }) : photos = List.unmodifiable(photos),
       likedUserIds = Set.unmodifiable(likedUserIds),
       comments = List.unmodifiable(comments);

  final String id;
  final PostAuthor author;
  final PostKind kind;
  final String body;
  final String? title;
  // A calendar date, without a time zone. Do not convert this to UTC.
  final DateTime? eventDate;
  final String? location;
  final List<String> photos;
  final DateTime createdAt;
  final Set<String> likedUserIds;
  final List<PostComment> comments;

  bool isLikedBy(String userId) => likedUserIds.contains(userId);

  CommunityPost copyWith({
    Set<String>? likedUserIds,
    List<PostComment>? comments,
  }) => CommunityPost(
    id: id,
    author: author,
    kind: kind,
    body: body,
    title: title,
    eventDate: eventDate,
    location: location,
    photos: photos,
    createdAt: createdAt,
    likedUserIds: likedUserIds ?? this.likedUserIds,
    comments: comments ?? this.comments,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'kind': kind.name,
    'body': body,
    'title': title,
    'eventDate': eventDate == null ? null : calendarDate(eventDate!),
    'location': location,
    'photos': photos,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'likedUserIds': likedUserIds.toList(),
    'comments': comments.map((comment) => comment.toJson()).toList(),
  };

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    PostKind parsedKind;
    try {
      parsedKind = PostKind.values.byName(json['kind'] as String);
    } catch (_) {
      parsedKind = PostKind.text;
    }

    final rawPhotos = json['photos'] ?? json['photoUrls'] ?? json['imageUrls'];
    final photosList = rawPhotos is List
        ? rawPhotos.map((e) => e.toString()).toList()
        : <String>[];

    return CommunityPost(
      id: json['id'] as String,
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
      kind: parsedKind,
      body: json['body'] as String? ?? '',
      title: json['title'] as String?,
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.tryParse(json['eventDate'] as String),
      location: json['location'] as String?,
      photos: photosList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likedUserIds: Set<String>.from(json['likedUserIds'] as List? ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((value) => PostComment.fromJson(value as Map<String, dynamic>))
          .toList(),
    );
  }
}

String calendarDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

class PostFailure implements Exception {
  const PostFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
