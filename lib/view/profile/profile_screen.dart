
import 'dart:io';

import 'package:flutter/material.dart';
import '../../edit_profile_screen.dart';

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

  Widget buildMenuItem(IconData icon, String title) {
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
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            onPressed: openEditProfile,
            icon: Icon(
              Icons.settings_outlined,
              color: primaryGreen,
            ),
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

            // Profile statistics
            Row(
              children: [
                buildStat("24", "Posts"),
                buildStat("7", "Events"),
                buildStat("18", "Completed"),
              ],
            ),

            const SizedBox(height: 25),

            // Quick actions
            Row(
              children: [
                buildAction(
                  Icons.edit_note,
                  "Share a progress update",
                  lightGreen,
                ),
                buildAction(
                  Icons.calendar_today,
                  "Create an event",
                  lightGreen,
                ),
                buildAction(
                  Icons.menu_book,
                  "Share what I learned",
                  lightGreen,
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

                Text(
                  "View all →",
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            buildPost(
              Icons.celebration,
              "My birthday recap",
              "Had such a lovely birthday with family and close friends.",
            ),

            buildPost(
              Icons.fitness_center,
              "3 weeks of consistency!",
              "Completed 3 weeks of my routine today.",
            ),

            const SizedBox(height: 15),

            // Profile menu
            buildMenuItem(Icons.grid_view, "My Posts"),
            buildMenuItem(Icons.bookmark_border, "Saved"),
            buildMenuItem(Icons.calendar_month, "My Events"),
          ],
        ),
      ),
    );
  }

  Widget buildAction(
      IconData icon,
      String title,
      Color color,
      ) {
    return Expanded(
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
