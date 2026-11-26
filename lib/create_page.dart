import 'package:flutter/material.dart';
import 'view/profile/profile_screen.dart';
import 'features/posts/screens/posts_preview_page.dart';
import 'features/posts/screens/create_post_page.dart';
import 'features/posts/posts_controller.dart';
import 'features/posts/data/post_storage.dart';
import 'features/posts/services/post_sharer.dart';
import 'features/posts/models/post.dart';
import 'models/post_model.dart';
import 'login_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _captionController = TextEditingController();
  bool _hasPhoto = false;
  bool _isPhotoPost = true; // Default choice

  final _postsController = PostsController(
    storage: const AndroidPostStorage(),
    currentUser: const PostAuthor(id: 'u1', name: 'Ananya Sharma'),
  );

  @override
  void dispose() {
    _captionController.dispose();
    _postsController.dispose();
    super.dispose();
  }

  void _publishPhotoPost() {
    if (_captionController.text.trim().isEmpty && !_hasPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo or caption before publishing.')),
      );
      return;
    }

    PostRepository.addPost(_captionController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo post published to your history!')),
    );
    _captionController.clear();
    setState(() {
      _hasPhoto = false;
    });
  }

  void _openTextPostComposer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(controller: _postsController),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isPhotoPost = true; // reset back to photo post view
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B5E20);
    const lime = Color(0xFFE9F7C6);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: lime,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, color: green, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'LifeLoop',
              style: TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.login, size: 16, color: green),
            label: const Text('Log In', style: TextStyle(color: green, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person, color: green),
              label: const Text('Profile', style: TextStyle(color: green, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: lime,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Two clearly labeled choices at the top: Photo Post and Text Post
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Photo Post'),
                    selected: _isPhotoPost,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _isPhotoPost = true);
                      }
                    },
                    selectedColor: lime,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _isPhotoPost ? green : Colors.black87,
                      fontWeight: _isPhotoPost ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Text Post'),
                    selected: !_isPhotoPost,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _isPhotoPost = false);
                        _openTextPostComposer();
                      }
                    },
                    selectedColor: lime,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: !_isPhotoPost ? green : Colors.black87,
                      fontWeight: !_isPhotoPost ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: lime,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    size: 36,
                    color: green,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create Photo Post',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Publish photos with captions to share visual updates with the community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Photo Picker Box
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE6E1D8)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _hasPhoto = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo attached successfully!')),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasPhoto ? Icons.check_circle : Icons.add_a_photo_outlined,
                        size: 48,
                        color: _hasPhoto ? Colors.green : green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _hasPhoto ? 'Photo Attached (Tap to change)' : 'Tap to select photo',
                        style: TextStyle(
                          color: _hasPhoto ? Colors.green.shade700 : green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Caption input
              const Text(
                'Caption',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: green),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share a visual update with the community...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6E1D8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6E1D8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Publish Button
              FilledButton(
                onPressed: _publishPhotoPost,
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  'Publish Post',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 1 for Create
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PostsPreviewPage(
                  controller: PostsController(
                    storage: const AndroidPostStorage(),
                    currentUser: const PostAuthor(id: 'u1', name: 'Ananya Sharma'),
                  ),
                  sharer: const AndroidPostSharer(),
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_outlined),
            activeIcon: Icon(Icons.feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
