import 'package:flutter/material.dart';
import 'profile_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _captionController = TextEditingController();
  bool _hasPhoto = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _publishPost() {
    if (_captionController.text.trim().isEmpty && !_hasPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo or caption before publishing.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo post published successfully!')),
    );
    _captionController.clear();
    setState(() {
      _hasPhoto = false;
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(
                      fullName: 'Ananya Sharma',
                      username: '@ananya',
                    ),
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
                onPressed: _publishPost,
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
        currentIndex: 0, // 0 for Create
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(
                  fullName: 'Ananya Sharma',
                  username: '@ananya',
                ),
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
            icon: Icon(Icons.add_box_rounded),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
