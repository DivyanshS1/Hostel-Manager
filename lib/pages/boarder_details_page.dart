import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_owner/components/my_button.dart';
import 'add_new_boarder.dart';
import 'update_boarder_page.dart';
import 'boarder_info_page.dart';

class BoarderDetailsPage extends StatefulWidget {
  @override
  _BoarderDetailsPageState createState() => _BoarderDetailsPageState();
}

class _BoarderDetailsPageState extends State<BoarderDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosteler Details'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  text: "Add New Hosteler",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddNewBoarder()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: "Update Existing Hosteler",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdateBoarderPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: user == null
                ? const Center(child: Text('User not logged in'))
                : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('boarders')
                  .where('uid', isEqualTo: user!.uid)
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
                  itemCount: boarders.length,
                  itemBuilder: (context, index) {
                    final boarder = boarders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        title: Text(
                          '${boarder['name']}',
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Room: ${boarder['roomNumber']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BoarderInfoPage(boarderId: boarder.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
