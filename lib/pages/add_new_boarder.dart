import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_owner/components/my_button.dart';
import 'package:hostel_owner/components/my_textfield.dart';

class AddNewBoarder extends StatefulWidget {
  @override
  _AddBoarderPageState createState() => _AddBoarderPageState();
}

class _AddBoarderPageState extends State<AddNewBoarder> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _enrollmentDateController = TextEditingController();
  final _leavingDateController = TextEditingController();
  final _securityDepositController = TextEditingController();
  final _feesToBePaidController = TextEditingController();
  final _lastFeePaidController = TextEditingController();

  Future<void> _addBoarder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('boarders').add({
        'uid': user.uid,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'roomNumber': _roomNumberController.text,
        'enrollmentDate': _enrollmentDateController.text,
        'leavingDate': _leavingDateController.text,
        'securityDeposit': _securityDepositController.text,
        'feesToBePaid': _feesToBePaidController.text,
        'lastFeePaid': _lastFeePaidController.text,
      });

      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _roomNumberController.clear();
      _enrollmentDateController.clear();
      _leavingDateController.clear();
      _securityDepositController.clear();
      _feesToBePaidController.clear();
      _lastFeePaidController.clear();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Hosteler'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyTextfield(controller: _nameController, hintText: 'Name', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _phoneController, hintText: 'Phone Number', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _addressController, hintText: 'Address', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _roomNumberController, hintText: 'Room Number', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _enrollmentDateController, hintText: 'Enrollment Date', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _leavingDateController, hintText: 'Leaving Date', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _securityDepositController, hintText: 'Security Deposit in ₹', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _feesToBePaidController, hintText: 'Fees to be Paid in ₹', obscureText: false),
              const SizedBox(height: 20),
              MyTextfield(controller: _lastFeePaidController, hintText: 'Last Fee Paid in ₹', obscureText: false),
              const SizedBox(height: 20),
              MyButton(
                text: 'Add Hosteler',
                onTap: _addBoarder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
