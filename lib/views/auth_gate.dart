import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:text2sign/views/home_page.dart';
import 'package:text2sign/views/onboarding.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> getStartPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Onboarding();
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return const Onboarding();
      }

      final data = doc.data();
      final role = data?['role'] ?? 'deaf';
      final name = data?['name'] ?? "User";

      return HomePage(selectedRole: role, userName: name);
    } catch (e) {
      return const Onboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return const Onboarding();
      },
    );
  }
}
