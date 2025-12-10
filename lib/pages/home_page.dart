import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // 🔄 Checking login state
          final user = snapshot.data;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle_sharp,
                      size: 100, color: Colors.blue),
                  const SizedBox(height: 25),

                  Text(
                    "Welcome to Authentication App",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =============================
                  // 🔹 USER LOGGED IN → SHOW SERVICE + LOGOUT
                  // =============================
                  if (user != null) ...[
                    _button(
                      context,
                      "Go to Services",
                      Icons.miscellaneous_services,
                      '/service',
                    ),
                    const SizedBox(height: 15),

                    _logoutButton(context),
                  ],

                  // =============================
                  // 🔹 USER NOT LOGGED IN → SHOW LOGIN + SIGNUP
                  // =============================
                  if (user == null) ...[
                    _button(context, "Create Account", Icons.person_add, '/signup'),
                    const SizedBox(height: 15),

                    _button(context, "Login", Icons.login, '/login'),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Reusable Button
  Widget _button(BuildContext context, String text, IconData icon, String route) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        onPressed: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  // Logout Button
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.logout),
        label: const Text("Logout", style: TextStyle(fontSize: 18)),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
      ),
    );
  }
}

