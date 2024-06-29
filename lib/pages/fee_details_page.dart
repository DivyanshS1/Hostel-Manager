import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_owner/components/my_button.dart';
import 'package:hostel_owner/pages/fee_update_page.dart';

class FeeDetailsPage extends StatefulWidget {
  @override
  _FeeDetailsPageState createState() => _FeeDetailsPageState();
}

class _FeeDetailsPageState extends State<FeeDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _showDueBoarders() async {
    if (user == null) return;

    try {
      final DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('boarders')
          .where('lastFeePaidDate', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .where('uid', isEqualTo: user!.uid)
          .get();

      print('Due hostelers count: ${querySnapshot.docs.length}');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Hostelers with Due Fees'),
            content: querySnapshot.docs.isNotEmpty
                ? Container(
              width: double.minPositive,
              child: ListView(
                shrinkWrap: true,
                children: querySnapshot.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text('${data['name']}'),
                    subtitle: Text('Room: ${data['roomNumber']}'),
                  );
                }).toList(),
              ),
            )
                : const Text('No hostelers with due fees'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching due hostelers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching due hostelers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Details'),
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
                  text: "Due Hostelers",
                  onTap: () {
                    _showDueBoarders();
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
                              builder: (context) => FeeUpdatePage(boarder: boarder),
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
