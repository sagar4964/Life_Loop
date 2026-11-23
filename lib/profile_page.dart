import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'activity_list_page.dart';
import 'login_page.dart';
import 'create_page.dart';

class ProfilePage extends StatefulWidget {
  final String fullName;
  final String username;

  const ProfilePage({
    super.key,
    required this.fullName,
    required this.username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Editable state (changes when the user presses Save)
  String _bio =
      'I love exploring new places, learning new skills, and creating memorable experiences with friends.';
  List<String> _interests = ['Hiking', 'Photography', 'Music', 'Traveling'];

  // Statistics (interactive numbers)
  final int _activitiesCreated = 3;
  final int _activitiesJoined = 5;
  final int _activitiesCompleted = 2;
  final int _ongoingActivities = 1;

  Future<void> _openEditor() async {
    final result = await showModalBottomSheet<ProfileEdits>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFAF7F2),
      builder: (context) => EditProfileSheet(
        currentBio: _bio,
        currentInterests: _interests,
      ),
    );

    if (!mounted) return;

    // result is null when the user pressed Cancel
    if (result != null) {
      setState(() {
        _bio = result.bio;
        _interests = result.interests;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        title: const Text('Log Out', style: TextStyle(color: Color(0xFF1B5E20))),
        content: const Text('Are you sure you want to log out of LifeLoop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B5E20);
    const lime = Color(0xFFE9F7C6);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        title: const Text(
          'LifeLoop Profile',
          style: TextStyle(color: green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: green),
            tooltip: 'Log Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo + name + username
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: lime,
                      child: Icon(Icons.person, size: 48, color: green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.username,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bio
                Text(
                  _bio.isEmpty ? 'Add a bio to tell people about you.' : _bio,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: _bio.isEmpty ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Edit Profile button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openEditor,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      side: const BorderSide(color: green),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Interests
                const Text(
                  'Interests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_interests.isEmpty)
                  Text(
                    'No interests selected yet.',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interests.map((interest) {
                      return Chip(
                        label: Text(interest),
                        backgroundColor: lime,
                        labelStyle: const TextStyle(
                          color: green,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 28),

                // Activity Statistics
                const Text(
                  'Activity Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      icon: Icons.add_circle_outline,
                      value: _activitiesCreated,
                      label: 'Activities Created',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityListPage(
                              categoryTitle: 'Activities Created',
                              count: 3,
                            ),
                          ),
                        );
                      },
                    ),
                    _StatCard(
                      icon: Icons.group_outlined,
                      value: _activitiesJoined,
                      label: 'Activities Joined',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityListPage(
                              categoryTitle: 'Activities Joined',
                              count: 5,
                            ),
                          ),
                        );
                      },
                    ),
                    _StatCard(
                      icon: Icons.check_circle_outline,
                      value: _activitiesCompleted,
                      label: 'Activities Completed',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityListPage(
                              categoryTitle: 'Activities Completed',
                              count: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    _StatCard(
                      icon: Icons.timelapse,
                      value: _ongoingActivities,
                      label: 'Ongoing Activities',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityListPage(
                              categoryTitle: 'Ongoing Activities',
                              count: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 1 for Profile
        onTap: (index) {
          if (index == 0) {
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

// A reusable widget for one clickable statistics card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B5E20);
    const lime = Color(0xFFE9F7C6);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E1D8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: lime,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: green),
                  ),
                  const Spacer(),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                ],
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
