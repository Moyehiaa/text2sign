import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:text2sign/const.dart';
import 'package:text2sign/views/home_page.dart';
import 'package:text2sign/views/login_page.dart';

class RegisterPage extends StatefulWidget {
  final String selectedRole;

  const RegisterPage({super.key, required this.selectedRole});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final relatedPersonController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool get isDeaf => widget.selectedRole == "deaf";

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    relatedPersonController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = credential.user;
      if (user == null) {
        throw Exception("User creation failed");
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "role": widget.selectedRole,
        "name": nameController.text.trim(),
        "age": int.parse(ageController.text.trim()),
        "email": emailController.text.trim(),
        "linkedUserEmail": relatedPersonController.text.trim(),
        "linkedUserUid": null,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            selectedRole: widget.selectedRole,
            userName: nameController.text.trim(),
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already in use";
          break;
        case 'invalid-email':
          message = "Invalid email address";
          break;
        case 'weak-password':
          message = "Password is too weak";
          break;
        default:
          message = e.message ?? "Authentication error";
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? "Database error")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Something went wrong")));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    if (!value.contains('@')) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Age is required";
    }
    final age = int.tryParse(value);
    if (age == null || age <= 0) {
      return "Enter a valid age";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm password is required";
    }
    if (value != passwordController.text.trim()) {
      return "Passwords do not match";
    }
    return null;
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isDeaf ? "Deaf Registration" : "Caregiver Registration",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildField(
                controller: nameController,
                label: "Full Name",
                hint: "Enter your name",
                keyboardType: TextInputType.name,
                validator: validateRequired,
              ),
              const SizedBox(height: 20),

              buildField(
                controller: ageController,
                label: "Age",
                hint: "Enter your age",
                keyboardType: TextInputType.number,
                validator: validateAge,
              ),
              const SizedBox(height: 20),

              buildField(
                controller: emailController,
                label: "Email",
                hint: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 20),

              buildField(
                controller: relatedPersonController,
                label: isDeaf ? "Caregiver Email" : "Deaf User Email",
                hint: isDeaf
                    ? "Enter your caregiver email"
                    : "Enter the deaf user's email",
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 20),

              buildField(
                controller: passwordController,
                label: "Password",
                hint: "Enter your password",
                keyboardType: TextInputType.text,
                validator: validatePassword,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              buildField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                hint: "Re-enter your password",
                keyboardType: TextInputType.text,
                validator: validateConfirmPassword,
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LoginPage(selectedRole: widget.selectedRole),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
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





// ///
// rules_version = '2';

// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /{document=**} {
//       allow read, write: if false;
//     }
//   }
// }