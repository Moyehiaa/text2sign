import 'package:flutter/material.dart';
import 'package:text2sign/views/register_page.dart';

class RoleSelection extends StatefulWidget {
  const RoleSelection({super.key});

  @override
  State<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFCD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 29),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Who are you?",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRoleCard(
                  title: "I am Deaf",
                  imagePath: "assets/role_selection/deaf.jpg",
                  roleValue: "deaf",
                ),
                _buildRoleCard(
                  title: "I am a Caregiver",
                  imagePath: "assets/role_selection/person.jpg",
                  roleValue: "caregiver",
                ),
              ],
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterPage(selectedRole: selectedRole!),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  selectedRole == null ? "Select Role First" : "Continue",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String imagePath,
    required String roleValue,
  }) {
    final bool isSelected = selectedRole == roleValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        width: 150,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 35, 250, 214)
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color.fromARGB(255, 36, 182, 255).withOpacity(0.18)
                  : const Color.fromARGB(255, 34, 235, 211).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Image.asset(imagePath, fit: BoxFit.contain)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color.fromARGB(255, 35, 250, 214)
                    : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
