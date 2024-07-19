import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hydrohealth/content/tanaman.dart';
import 'package:hydrohealth/widgets/button_web.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrohealth/pages/login_page.dart';
import 'package:hydrohealth/widgets/costume_button.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Function to launch URL
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://hydrohealth.vercel.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  User? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    final prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber = prefs.getString('phoneNumber');

    setState(() {
      _user = user;
      _nameController.text = user?.displayName ?? '';
      _phoneController.text = savedPhoneNumber ?? user?.phoneNumber ?? '';
      _profileImageUrl = user?.photoURL;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage != null && _user != null) {
      try {
        // Ensure user is authenticated
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw FirebaseAuthException(
            code: 'user-not-authenticated',
            message: 'User is not authenticated',
          );
        }

        final storageRef = FirebaseStorage.instanceFor(
          bucket: 'gs://hydrohealth-project-9cf6c.appspot.com',
        ).ref().child('profile_images').child('${_user!.uid}.jpg');

        await storageRef.putFile(_profileImage!);

        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set({
          'photoUrl': downloadUrl,
          'displayName': _nameController.text,
          'phoneNumber': _phoneController.text,
        }, SetOptions(merge: true));

        await _user?.updatePhotoURL(downloadUrl);

        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 240, 218, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/images/logo.png'))
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _buildEditableItem(
                  'Name', _nameController, CupertinoIcons.person),
              const SizedBox(height: 10),
              _buildEditableItem(
                  'Phone', _phoneController, CupertinoIcons.phone),
              const SizedBox(height: 10),
              itemProfile('Email', _user?.email ?? '', CupertinoIcons.mail),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CostumeButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Tanaman(),
                      ),
                    );
                  },
                  text: 'Tambah Informasi Tanaman',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CostumeButton(
                  onPressed: () {
                    // Save changes to profile
                    _saveProfile();
                  },
                  text: 'Save',
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CostumeButton(
                  onPressed: () => _logout(context), // Updated logout action
                  text: 'Log Out',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child:
                    ButtonWeb(text: "Visit Our Website", onPressed: _launchURL),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableItem(
      String title, TextEditingController controller, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 44, 95, 0).withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
        leading: Icon(iconData),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 44, 95, 0).withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }

  void _saveProfile() async {
    setState(() {
      _user?.updateDisplayName(_nameController.text);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', _phoneController.text);

    await _uploadProfileImage();

    await _user?.reload();
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });

    // Optionally, show a confirmation message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
