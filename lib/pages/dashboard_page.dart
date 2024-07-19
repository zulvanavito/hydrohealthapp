import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrohealth/content/chat.dart';
import 'package:hydrohealth/content/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrohealth/Content/camera.dart';
import 'package:hydrohealth/Content/home.dart';
import 'package:hydrohealth/pages/navigasi_tab.dart';
import 'package:hydrohealth/widgets/navbar.dart';
import 'package:hydrohealth/pages/login_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // ignore: unused_element
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const CircleNavBarPage(
      pages: [
        Home(),
        Chat(),
        Camera(),
        NavigasiTab(),
        Profile(),
      ],
    );
  }
}
