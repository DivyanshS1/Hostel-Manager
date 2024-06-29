import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../components/my_button.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _boarders = {};
  Map<String, bool> _attendance = {};
  String _searchQuery = '';
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchBoarders();
  }

  Future<void> _fetchBoarders() async {
    if (user == null) return;
    final boardersSnapshot = await FirebaseFirestore.instance.collection('boarders').where('uid', isEqualTo: user!.uid).get();
    setState(() {
      _boarders.clear();
      _attendance.clear();
      for (var doc in boardersSnapshot.docs) {
        _boarders[doc.id] = {
          'name': doc['name'],
          'roomNumber': doc['roomNumber']
        };
        _attendance[doc.id] = false;
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (user == null) return;
    final attendanceData = _attendance.entries
        .map((entry) => {
      'boarderId': entry.key,
      'date': _selectedDate,
      'present': entry.value,
      'uid': user!.uid,
    })
        .toList();

    for (var data in attendanceData) {
      await FirebaseFirestore.instance.collection('attendance').add(data);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance saved')));
  }

  Future<void> _generateCsv() async {
    if (user == null) return;
    final attendanceSnapshot = await FirebaseFirestore.instance.collection('attendance').where('uid', isEqualTo: user!.uid).where('date', isEqualTo: _selectedDate).get();
    final rows = [
      ['Boarder Name', 'Room Number', 'Date', 'Present'],
      ...attendanceSnapshot.docs.map((doc) => [
        _boarders[doc['boarderId']]['name'],
        _boarders[doc['boarderId']]['roomNumber'],
        doc['date'].toDate().toString().split(' ')[0],
        doc['present'] ? 'Present' : 'Absent',
      ])
    ];

    final presentCount = attendanceSnapshot.docs.where((doc) => doc['present']).length;
    final absentCount = attendanceSnapshot.docs.length - presentCount;

    rows.addAll([
      [],
      ['Summary'],
      ['Total Present', presentCount.toString()],
      ['Total Absent', absentCount.toString()],
    ]);

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/attendance.csv';

    final file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV generated: $path')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generateCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (date != null && date != _selectedDate) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _boarders.length,
              itemBuilder: (context, index) {
                final boarderId = _boarders.keys.elementAt(index);
                final boarder = _boarders[boarderId];
                final boarderName = boarder['name'];
                final boarderRoomNumber = boarder['roomNumber'];

                if (_searchQuery.isNotEmpty &&
                    !boarderName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                    !boarderRoomNumber.toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink();
                }

                return CheckboxListTile(
                  title: Text('$boarderName (Room: $boarderRoomNumber)'),
                  value: _attendance[boarderId],
                  onChanged: (value) {
                    setState(() {
                      _attendance[boarderId] = value!;
                    });
                  },
                );
              },
            ),
          ),
          MyButton(
            text: "Save Attendance",
            onTap: _saveAttendance,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
