import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_owner/components/my_button.dart';
import 'package:hostel_owner/components/my_textfield.dart';

class UpdateBoarderPage extends StatefulWidget {
  @override
  _UpdateBoarderPageState createState() => _UpdateBoarderPageState();
}

class _UpdateBoarderPageState extends State<UpdateBoarderPage> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _enrollmentDateController = TextEditingController();
  final _leavingDateController = TextEditingController();
  final _securityDepositController = TextEditingController();
  final _feesToBePaidController = TextEditingController();
  final _lastFeePaidController = TextEditingController();

  DocumentSnapshot? _selectedBoarder;
  String _searchText = '';

  Future<void> _updateBoarder() async {
    if (_selectedBoarder != null) {
      await FirebaseFirestore.instance.collection('boarders').doc(_selectedBoarder!.id).update({
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

      setState(() {
        _selectedBoarder = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Hosteler'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Hostelers',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchText = '';
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedBoarder != null) ...[
                MyTextfield(controller: _nameController, hintText: 'Name', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _phoneController, hintText: 'Phone Number', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _addressController, hintText: 'Address', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _roomNumberController, hintText: 'Room Number', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _enrollmentDateController, hintText: 'Enrollment Date', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _leavingDateController, hintText: 'Leaving Date', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _securityDepositController, hintText: 'Security Deposit in ₹', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _feesToBePaidController, hintText: 'Fees to be Paid in ₹', obscureText: false),
                const SizedBox(height: 15),
                MyTextfield(controller: _lastFeePaidController, hintText: 'Last Fee Paid in ₹', obscureText: false),
                const SizedBox(height: 15),
                MyButton(
                  text: 'Update Hosteler',
                  onTap: _updateBoarder,
                ),
                const SizedBox(height: 16),
              ],
              user == null
                  ? const Center(child: Text('User not logged in'))
                  : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('boarders')
                    .where('uid', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final boarders = snapshot.data!.docs.where((boarder) {
                    final name = boarder['name'].toString().toLowerCase();
                    final roomNumber = boarder['roomNumber'].toString().toLowerCase();
                    return name.contains(_searchText.toLowerCase()) ||
                        roomNumber.contains(_searchText.toLowerCase());
                  }).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: boarders.length,
                    itemBuilder: (context, index) {
                      final boarder = boarders[index];
                      return ListTile(
                        title: Text(boarder['name']),
                        subtitle: Text('Room: ${boarder['roomNumber']}'),
                        onTap: () {
                          setState(() {
                            _selectedBoarder = boarder;
                            _nameController.text = boarder['name'];
                            _phoneController.text = boarder['phone'];
                            _addressController.text = boarder['address'];
                            _roomNumberController.text = boarder['roomNumber'];
                            _enrollmentDateController.text = boarder['enrollmentDate'];
                            _leavingDateController.text = boarder['leavingDate'];
                            _securityDepositController.text = boarder['securityDeposit'];
                            _feesToBePaidController.text = boarder['feesToBePaid'];
                            _lastFeePaidController.text = boarder['lastFeePaid'];
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
