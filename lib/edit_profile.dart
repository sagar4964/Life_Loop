import 'package:flutter/material.dart';

// All interests the user can choose from
const List<String> allInterests = [
  'Traveling',
  'Photography',
  'Music',
  'Fitness',
  'Hiking',
  'Technology',
  'Art',
  'Cooking',
  'Sports',
  'Gaming',
  'Reading',
  'Dancing',
];

// A small box that carries the saved data back to the profile page
class ProfileEdits {
  final String bio;
  final List<String> interests;

  const ProfileEdits({required this.bio, required this.interests});
}

class EditProfileSheet extends StatefulWidget {
  final String currentBio;
  final List<String> currentInterests;

  const EditProfileSheet({
    super.key,
    required this.currentBio,
    required this.currentInterests,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _bioController;
  late List<String> _selected; // temporary copy, only used while editing

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
    _selected = List<String>.from(widget.currentInterests);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selected.add(interest);
      } else {
        _selected.remove(interest);
      }
    });
  }

  void _save() {
    Navigator.pop(
      context,
      ProfileEdits(
        bio: _bioController.text.trim(),
        interests: _selected,
      ),
    );
  }

  void _cancel() {
    Navigator.pop(context); // closes without sending any data back
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B5E20);
    const lime = Color(0xFFE9F7C6);

    return Padding(
      // pushes the sheet up when the keyboard opens
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Bio', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLength: 150,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell people about yourself',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Interests',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: allInterests.map((interest) {
                  final isSelected = _selected.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (value) => _toggleInterest(interest, value),
                    selectedColor: lime,
                    backgroundColor: Colors.white,
                    checkmarkColor: green,
                    labelStyle: TextStyle(
                      color: isSelected ? green : Colors.black87,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? green : Colors.grey.shade300,
                    ),
                    shape: const StadiumBorder(),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}