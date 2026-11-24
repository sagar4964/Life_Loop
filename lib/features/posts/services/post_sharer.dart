import 'package:flutter/services.dart';

import '../data/post_storage.dart';
import '../models/post.dart';

abstract interface class PostSharer {
  Future<void> share(CommunityPost post);
}

/// US15: opens Android's chooser. This does not prove a message was delivered.
class AndroidPostSharer implements PostSharer {
  const AndroidPostSharer();

  @override
  Future<void> share(CommunityPost post) async {
    try {
      await AndroidPostStorage.channel.invokeMethod<void>('sharePost', {
        'text': buildShareText(post),
        'subject': post.title ?? 'A LifeLoop post',
      });
    } on PlatformException {
      throw const PostFailure('Could not open sharing. Please try again.');
    } on MissingPluginException {
      throw const PostFailure('Sharing is available in the Android app.');
    }
  }
}

String buildShareText(CommunityPost post) => [
  '${post.author.name} shared a ${post.kind.label.toLowerCase()} on LifeLoop',
  if (post.title != null) post.title!,
  if (post.eventDate != null) 'Event date: ${calendarDate(post.eventDate!)}',
  if (post.location != null) 'Location: ${post.location}',
  if (post.photos.isNotEmpty) 'Photos: ${post.photos.join(', ')}',
  if (post.body.isNotEmpty) ...['', post.body],
].join('\n');
