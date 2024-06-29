import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerName = TextEditingController();
  final TextEditingController _hostelName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _numberOfRooms = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmpassword = TextEditingController();

  void register() async {
    final _authService = AuthService();
    if (_password.text == _confirmpassword.text) {
      try {
        UserCredential userCredential = await _authService.signUpWithEmailPassword(_email.text, _password.text);
        await FirebaseFirestore.instance.collection('hostels').doc(userCredential.user!.uid).set({
          'ownerName': _ownerName.text,
          'hostelName': _hostelName.text,
          'address': _address.text,
          'numberOfRooms': _numberOfRooms.text,
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ownerName.dispose();
    _hostelName.dispose();
    _address.dispose();
    _numberOfRooms.dispose();
    _email.dispose();
    _password.dispose();
    _confirmpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              const Icon(
                Icons.home,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 25,),
              const Text(
                "Lets Register",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25,),
              MyTextfield(controller: _ownerName, hintText: "Owner Name", obscureText: false),
              const SizedBox(height: 25,),
              MyTextfield(controller: _hostelName, hintText: "Hostel Name", obscureText: false),
              const SizedBox(height: 25,),
              MyTextfield(controller: _numberOfRooms, hintText: "Number of Rooms", obscureText: false),
              const SizedBox(height: 25,),
              MyTextfield(controller: _address, hintText: "Hostel Address", obscureText: false),
              const SizedBox(height: 25,),
              MyTextfield(controller: _email, hintText: "E-mail", obscureText: false),
              const SizedBox(height: 25,),
              MyTextfield(controller: _password, hintText: "Password", obscureText: true),
              const SizedBox(height: 25,),
              MyTextfield(controller: _confirmpassword, hintText: "Confirm Password", obscureText: true),
              const SizedBox(height: 25,),
              MyButton(text: "Register", onTap: register),
              const SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already Registered?",
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 4,),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      " Sign in",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }
}
