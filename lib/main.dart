import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:text2sign/views/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Text2Sign());
}

class Text2Sign extends StatelessWidget {
  const Text2Sign({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
