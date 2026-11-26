import 'dart:io';

import 'package:flutter/material.dart';
import '../../edit_profile_screen.dart';
import '../../post_history_page.dart';
import '../../login_page.dart';
import '../../create_page.dart';
import '../../features/posts/screens/posts_preview_page.dart';
import '../../features/posts/posts_controller.dart';
import '../../features/posts/data/post_storage.dart';
import '../../features/posts/services/post_sharer.dart';
import '../../features/posts/models/post.dart';
import '../../models/post_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Ananya Sharma";
  String bio = "Learning, planning and sharing little wins.";

  File? profileImage;

  Color primaryGreen = const Color(0xFF075D35);
  Color lightGreen = const Color(0xFFEAF6D8);

  Future<void> openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: name,
          bio: bio,
          profileImage: profileImage,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        name = result['name'];
        bio = result['bio'];
        profileImage = result['profileImage'];
      });
    }
  }

  Widget buildStat(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),

      child: ListTile(
        leading: Icon(icon, color: primaryGreen),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postCount = PostRepository.posts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Row(
          children: [
            Icon(Icons.eco, color: primaryGreen),
            const SizedBox(width: 5),
            Text(
              "LifeLoop",
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
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
            icon: Icon(Icons.login, size: 16, color: primaryGreen),
            label: Text('Log In', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: openEditProfile,
            icon: Icon(
              Icons.settings_outlined,
              color: primaryGreen,
            ),
            tooltip: 'Settings / Edit Profile',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Profile information
            Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: lightGreen,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? Icon(
                    Icons.person,
                    size: 40,
                    color: primaryGreen,
                  )
                      : null,
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: openEditProfile,
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Profile statistics (Real and dynamic based on posts, starting at 0)
            Row(
              children: [
                buildStat("$postCount", "Posts"),
                buildStat("0", "Events"),
                buildStat("0", "Completed"),
              ],
            ),

            const SizedBox(height: 25),

            // Quick actions
            Row(
              children: [
                buildAction(
                  Icons.edit_note,
                  "Share update",
                  lightGreen,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CreatePage()),
                    );
                  },
                ),
                buildAction(
                  Icons.calendar_today,
                  "Create event",
                  lightGreen,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CreatePage()),
                    );
                  },
                ),
                buildAction(
                  Icons.photo_library_outlined,
                  "Post History",
                  lightGreen,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PostHistoryPage()),
                    ).then((_) => setState(() {}));
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Recent posts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent posts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PostHistoryPage()),
                    ).then((_) => setState(() {}));
                  },
                  child: Text(
                    "View all →",
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (PostRepository.posts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "You haven't posted anything yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            else
              ...PostRepository.posts.take(2).map((post) => buildPost(
                    Icons.photo_camera,
                    'Photo Post',
                    post.caption,
                  )),

            const SizedBox(height: 15),

            // Profile menu
            buildMenuItem(Icons.photo_library, "Personal Post History", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostHistoryPage()),
              ).then((_) => setState(() {}));
            }),
            buildMenuItem(Icons.edit, "Edit Profile", openEditProfile),
            buildMenuItem(Icons.login_rounded, "Log In / Switch Account", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 2 for Profile
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
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatePage(),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
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

  Widget buildAction(
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            children: [
              Icon(icon, color: primaryGreen),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPost(
      IconData icon,
      String title,
      String description,
      ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(icon, color: primaryGreen),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),

        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 11),
        ),

        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
