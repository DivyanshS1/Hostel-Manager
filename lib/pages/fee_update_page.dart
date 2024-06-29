import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:hostel_owner/components/my_button.dart';
import 'package:hostel_owner/components/my_textfield.dart';

class FeeUpdatePage extends StatefulWidget {
  final DocumentSnapshot boarder;

  FeeUpdatePage({required this.boarder});

  @override
  _FeeUpdatePageState createState() => _FeeUpdatePageState();
}

class _FeeUpdatePageState extends State<FeeUpdatePage> {
  final _amountPaidNowController = TextEditingController();
  DateTime? _datePaid;
  String _feesToBePaid = '';
  String _lastFeePaid = '';
  String _lastFeePaidDate = '';
  String _boarderName = '';
  String _roomNumber = '';
  String? _boarderId;
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _initializeData();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _ownerId = user?.uid;
    });
  }

  void _initializeData() {
    final data = widget.boarder.data() as Map<String, dynamic>;
    setState(() {
      _boarderId = widget.boarder.id;
      _boarderName = data['name'];
      _roomNumber = data['roomNumber'];
      _feesToBePaid = data['feesToBePaid'].toString();
      _lastFeePaid = data['lastFeePaid'].toString();
      _lastFeePaidDate = data['lastFeePaidDate'] is Timestamp
          ? (data['lastFeePaidDate'] as Timestamp).toDate().toString()
          : data['lastFeePaidDate'] ?? '';
    });
  }

  Future<void> _updateFees() async {
    if (_boarderId == null || _amountPaidNowController.text.isEmpty || _datePaid == null) return;

    double newFeesToBePaid = double.parse(_feesToBePaid) - double.parse(_amountPaidNowController.text);

    await FirebaseFirestore.instance.collection('boarders').doc(_boarderId).update({
      'feesToBePaid': newFeesToBePaid.toString(),
      'lastFeePaid': _amountPaidNowController.text,
      'lastFeePaidDate': _datePaid,
    });

    await FirebaseFirestore.instance.collection('fees').add({
      'boarderId': _boarderId,
      'ownerId': _ownerId,
      'amountPaid': _amountPaidNowController.text,
      'datePaid': _datePaid,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fees updated successfully')));

    setState(() {
      _feesToBePaid = newFeesToBePaid.toString();
      _lastFeePaid = _amountPaidNowController.text;
      _lastFeePaidDate = _datePaid?.toString() ?? '';
      _amountPaidNowController.clear();
      _datePaid = null;
    });
  }

  Future<void> _generateCsv() async {
    if (_boarderId == null) return;

    final feesSnapshot = await FirebaseFirestore.instance
        .collection('fees')
        .where('boarderId', isEqualTo: _boarderId)
        .where('ownerId', isEqualTo: _ownerId)
        .get();

    final rows = [
      ['Name', 'Room Number', 'Amount Paid', 'Date Paid'],
      ...feesSnapshot.docs.map((doc) => [
        _boarderName,
        _roomNumber,
        doc['amountPaid'],
        (doc['datePaid'] as Timestamp).toDate().toString(),
      ])
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/fees_${_boarderName.replaceAll(' ', '_')}.csv';

    final file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV generated: $path')));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datePaid ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _datePaid) {
      setState(() {
        _datePaid = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Fees'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generateCsv,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $_boarderName', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Room Number: $_roomNumber', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              if (_feesToBePaid.isNotEmpty)
                Text('Fees to be Paid: ₹$_feesToBePaid', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Last Fee Paid: ₹$_lastFeePaid', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              if (_lastFeePaidDate.isNotEmpty)
                Text('Last Paid on: ${_lastFeePaidDate.split(' ')[0]}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              MyTextfield(controller: _amountPaidNowController, hintText: 'Amount Paid Now in ₹', obscureText: false),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Date Paid: ${_datePaid?.toLocal().toString().split(' ')[0] ?? 'Select Date'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              MyButton(
                text: 'Update Fees',
                onTap: _updateFees,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
