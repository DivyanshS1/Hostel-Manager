import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/my_button.dart';
import 'attendance_page.dart';
import 'boarder_details_page.dart';
import 'fee_details_page.dart';
import 'owner_details_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Home",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle,
            color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OwnerDetailsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout,
            color: Colors.white,),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyButton(
              text: "Hosteler Details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BoarderDetailsPage()),
                );
              },
            ),
            const SizedBox(height: 30,),
            MyButton(
              text: "Attendance",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendancePage()),
                );
              },
            ),
            const SizedBox(height: 30,),
            MyButton(
              text: "Fee Details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeeDetailsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
