// Retain compatibility with the Flutter SDK used by the original project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../posts_controller.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key, required this.controller});
  final PostsController controller;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _location = TextEditingController();
  final _photoUrl = TextEditingController();
  final List<String> _photos = [];
  PostKind _kind = PostKind.text;
  DateTime? _eventDate = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _location.dispose();
    _photoUrl.dispose();
    super.dispose();
  }

  void _addPhoto() {
    final url = _photoUrl.text.trim();
    if (url.isNotEmpty && !_photos.contains(url)) {
      setState(() {
        _photos.add(url);
        _photoUrl.clear();
        _error = null;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _publish() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_kind == PostKind.photo &&
        _photos.isEmpty &&
        _body.text.trim().isEmpty) {
      setState(() => _error = 'Add a photo or write something for your post.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.createPost(
        kind: _kind,
        body: _body.text,
        title: _title.text,
        eventDate: _kind == PostKind.eventRecap ? _eventDate : null,
        location: _kind == PostKind.eventRecap ? _location.text : null,
        photos: _photos,
      );
      if (!mounted) return;
      // Re-enable popping before navigating after a successful save.
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    } on PostFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not publish. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final initial = _eventDate ?? DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (date != null && mounted) setState(() => _eventDate = date);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: const Text('Create a post')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Share a little of your life.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Posting as ${widget.controller.currentUser.name}'),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final kind in PostKind.values)
                        ChoiceChip(
                          key: Key('chip-${kind.name}'),
                          label: Text(kind.label),
                          selected: _kind == kind,
                          onSelected: _saving
                              ? null
                              : (_) => setState(() {
                                  _kind = kind;
                                  _error = null;
                                }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_kind == PostKind.experience ||
                      _kind == PostKind.eventRecap) ...[
                    TextFormField(
                      key: const Key('post-title'),
                      controller: _title,
                      enabled: !_saving,
                      maxLength: PostsController.maxTitleLength,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: _kind == PostKind.experience
                            ? 'Experience title'
                            : 'Event name',
                        hintText: _kind == PostKind.experience
                            ? 'My first pottery class'
                            : 'A birthday with friends',
                      ),
                      validator: (text) => (text ?? '').trim().isEmpty
                          ? (_kind == PostKind.experience
                                ? 'Add a title.'
                                : 'Add an event name.')
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_kind == PostKind.eventRecap) ...[
                    TextFormField(
                      key: const Key('post-location'),
                      controller: _location,
                      enabled: !_saving,
                      maxLength: PostsController.maxLocationLength,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g., Central Park, NY',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('pick-event-date'),
                            onPressed: _saving ? null : _pickDate,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(
                              _eventDate == null
                                  ? 'Select event date (optional)'
                                  : 'Event date: ${calendarDate(_eventDate!)}',
                            ),
                          ),
                        ),
                        if (_eventDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            key: const Key('clear-event-date'),
                            onPressed: _saving
                                ? null
                                : () => setState(() => _eventDate = null),
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear date',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    key: const Key('post-body'),
                    controller: _body,
                    enabled: !_saving,
                    minLines: 4,
                    maxLines: 12,
                    maxLength: PostsController.maxBodyLength,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: switch (_kind) {
                        PostKind.text => 'What would you like to share?',
                        PostKind.photo =>
                          'Write a caption (optional if photo added)',
                        PostKind.experience => 'Tell your story',
                        PostKind.eventRecap => 'What happened at the event?',
                      },
                    ),
                    validator: (text) {
                      final clean = (text ?? '').trim();
                      if (_kind == PostKind.photo && _photos.isNotEmpty) {
                        return null;
                      }
                      if (clean.isEmpty) {
                        return switch (_kind) {
                          PostKind.text => 'Write something for your post.',
                          PostKind.photo => 'Add a photo or write a caption.',
                          PostKind.experience => 'Describe your experience.',
                          PostKind.eventRecap =>
                            'Write what happened at the event.',
                        };
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _kind == PostKind.photo ? 'Photos' : 'Photos (optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('photo-url-input'),
                          controller: _photoUrl,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            hintText: 'Enter photo URL or image path',
                            isDense: true,
                          ),
                          onFieldSubmitted: (_) => _addPhoto(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        key: const Key('add-photo-button'),
                        onPressed: _saving ? null : _addPhoto,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        tooltip: 'Add photo',
                      ),
                    ],
                  ),
                  if (_photos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_photos.length, (index) {
                        final photo = _photos[index];
                        return InputChip(
                          key: Key('remove-photo-$index'),
                          label: Text(
                            photo.length > 25
                                ? '${photo.substring(0, 22)}...'
                                : photo,
                          ),
                          onDeleted: _saving ? null : () => _removePhoto(index),
                        );
                      }),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('publish-post'),
                    onPressed: _saving ? null : _publish,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward),
                    label: Text(_saving ? 'Saving...' : 'Publish post'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
