import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:text2sign/const.dart';
import 'package:text2sign/views/chat_tab.dart';
import 'package:text2sign/widgets/aliert_title.dart';
import 'package:text2sign/widgets/stat_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text2sign/views/login_page.dart';

class HomePage extends StatefulWidget {
  final String selectedRole;
  final String userName;

  const HomePage({
    super.key,
    required this.selectedRole,
    required this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PersistentTabController _controller = PersistentTabController();

  bool get isDeaf => widget.selectedRole == "deaf";

  List<PersistentTabConfig> _tabs() {
    return [
      PersistentTabConfig(
        screen: DashboardTab(
          selectedRole: widget.selectedRole,
          userName: widget.userName,
        ),
        item: ItemConfig(
          icon: const Icon(Icons.home_rounded),
          title: "Home",
          activeForegroundColor: Colors.black,
          inactiveForegroundColor: Colors.grey,
        ),
      ),
      PersistentTabConfig(
        screen: AlertsTab(selectedRole: widget.selectedRole),
        item: ItemConfig(
          icon: Icon(
            isDeaf ? Icons.hearing_rounded : Icons.notifications_active_rounded,
          ),
          title: isDeaf ? "Detection" : "Notification",
          activeForegroundColor: Colors.black,
          inactiveForegroundColor: Colors.grey,
        ),
      ),
      PersistentTabConfig(
        screen: ChatTab(
          selectedRole: widget.selectedRole,
          userName: widget.userName,
        ),
        item: ItemConfig(
          icon: const Icon(Icons.chat_bubble_rounded),
          title: "Chat",
          activeForegroundColor: Colors.black,
          inactiveForegroundColor: Colors.grey,
        ),
      ),
      PersistentTabConfig(
        screen: ProfileTab(
          selectedRole: widget.selectedRole,
          userName: widget.userName,
        ),
        item: ItemConfig(
          icon: const Icon(Icons.person_rounded),
          title: "Profile",
          activeForegroundColor: Colors.black,
          inactiveForegroundColor: Colors.grey,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _controller,
      tabs: _tabs(),
      backgroundColor: backgroundColor,
      navBarBuilder: (navBarConfig) => Style8BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final String selectedRole;
  final String userName;

  const DashboardTab({
    super.key,
    required this.selectedRole,
    required this.userName,
  });

  bool get isDeaf => selectedRole == "deaf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, $userName 👋",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isDeaf ? "Deaf User Dashboard" : "Caregiver Dashboard",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            isDeaf ? const _DeafHomeCard() : const _CaregiverHomeCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: isDeaf ? "12" : "8",
                    subtitle: "Alerts Today",
                    icon: isDeaf
                        ? Icons.notifications_active_outlined
                        : Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: isDeaf ? "Listening" : "Online",
                    subtitle: isDeaf ? "Status" : "User Status",
                    icon: isDeaf ? Icons.hearing_rounded : Icons.wifi_tethering,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isDeaf ? "Recent Alerts" : "Live Notifications",
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              4,
              (index) => AlertTile(
                title: isDeaf
                    ? ["Doorbell", "Baby Crying", "Alarm", "Car Horn"][index]
                    : [
                        "Doorbell detected",
                        "Baby crying",
                        "Alarm detected",
                        "Car horn nearby",
                      ][index],
                time: [
                  "Just now",
                  "2 mins ago",
                  "8 mins ago",
                  "20 mins ago",
                ][index],
                icon: [
                  Icons.door_front_door_outlined,
                  Icons.child_care,
                  Icons.alarm,
                  Icons.directions_car,
                ][index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertsTab extends StatelessWidget {
  final String selectedRole;

  const AlertsTab({super.key, required this.selectedRole});

  bool get isDeaf => selectedRole == "deaf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          isDeaf ? "Detection" : "Notification",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isDeaf
                      ? Icons.graphic_eq_rounded
                      : Icons.notifications_active_rounded,
                  size: 48,
                  color: Colors.black,
                ),
                const SizedBox(height: 14),
                Text(
                  isDeaf
                      ? "Sound Detection Running"
                      : "Live Notifications Active",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isDeaf
                      ? "The app is listening for important nearby sounds."
                      : "You are receiving the latest alerts from the deaf user.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final String selectedRole;
  final String userName;

  const ProfileTab({
    super.key,
    required this.selectedRole,
    required this.userName,
  });

  bool get isDeaf => selectedRole == "deaf";

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you really want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage(selectedRole: selectedRole)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFF5FFCD),
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDeaf ? "Deaf User" : "Caregiver",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeafHomeCard extends StatelessWidget {
  const _DeafHomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFF5FFCD),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.hearing_rounded,
              size: 38,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Current Detected Sound",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            "Doorbell",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Confidence: 92%",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text("Detected just now", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _CaregiverHomeCard extends StatelessWidget {
  const _CaregiverHomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFF5FFCD),
                child: Icon(Icons.person_outline, color: Colors.black),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monitoring User",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Last alert: Doorbell",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  "Urgent notifications are enabled",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
