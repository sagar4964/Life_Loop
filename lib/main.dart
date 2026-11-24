// Retain compatibility with the Flutter SDK used by the original project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'features/posts/data/post_storage.dart';
import 'features/posts/models/post.dart';
import 'features/posts/posts_controller.dart';
import 'features/posts/screens/posts_preview_page.dart';
import 'features/posts/services/post_sharer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeLoopApp());
}

/// Runner for Aayush's Sprint 2 stories. Use the signed-in user when integrating.
class LifeLoopApp extends StatefulWidget {
  const LifeLoopApp({super.key, this.controller, this.sharer});
  final PostsController? controller;
  final PostSharer? sharer;

  @override
  State<LifeLoopApp> createState() => _LifeLoopAppState();
}

class _LifeLoopAppState extends State<LifeLoopApp> {
  late final PostsController _controller =
      widget.controller ??
      PostsController(
        storage: const AndroidPostStorage(),
        currentUser: const PostAuthor(id: 'demo-aayush', name: 'Aayush'),
      );

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'LifeLoop',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF146C63)),
      scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F9F8),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
    home: PostsPreviewPage(
      controller: _controller,
      sharer: widget.sharer ?? const AndroidPostSharer(),
    ),
  );
}
