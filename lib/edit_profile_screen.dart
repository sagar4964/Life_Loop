
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String bio;
  final File? profileImage;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.bio,
    this.profileImage,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final Color primaryGreen = const Color(0xFF075D35);

  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  File? profileImage;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    bioController = TextEditingController(text: widget.bio);
    emailController = TextEditingController(
      text: "ananya@example.com",
    );
    phoneController = TextEditingController();
    profileImage = widget.profileImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Change Profile Photo
  Future<void> changePhoto() async {

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  // Remove Profile Photo
  void removePhoto() {
    setState(() {
      profileImage = null;
    });
  }

  // Save Profile
  void saveProfile() {

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete the required fields"),
        ),
      );

      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
        .hasMatch(emailController.text.trim())) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address"),
        ),
      );

      return;
    }

    Navigator.pop(context, {
      'name': nameController.text.trim(),
      'bio': bioController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'profileImage': profileImage,
    });
  }

  // Reusable Text Field
  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: primaryGreen,
            ),

            filled: true,
            fillColor: Colors.grey.shade100,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 15),

            // Profile Photo
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green.shade100,

              backgroundImage: profileImage != null
                  ? FileImage(profileImage!)
                  : null,

              child: profileImage == null
                  ? Icon(
                Icons.person,
                size: 60,
                color: primaryGreen,
              )
                  : null,
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: changePhoto,

              icon: Icon(
                Icons.camera_alt,
                color: primaryGreen,
              ),

              label: Text(
                "Change Profile Photo",
                style: TextStyle(color: primaryGreen),
              ),
            ),

            TextButton(
              onPressed: removePhoto,

              child: const Text(
                "Remove Photo",
                style: TextStyle(color: Colors.red),
              ),
            ),

            const SizedBox(height: 20),

            // Personal Information
            buildTextField(
              "Full Name",
              nameController,
              Icons.person_outline,
            ),

            buildTextField(
              "Email Address",
              emailController,
              Icons.email_outlined,
            ),

            buildTextField(
              "Phone Number",
              phoneController,
              Icons.phone_outlined,
            ),

            buildTextField(
              "About Me",
              bioController,
              Icons.info_outline,
            ),

            const SizedBox(height: 10),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
