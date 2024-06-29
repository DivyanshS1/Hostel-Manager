import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoarderInfoPage extends StatelessWidget {
  final String boarderId;

  const BoarderInfoPage({required this.boarderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosteler Information'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('boarders').doc(boarderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Phone: ${data['phone']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Address: ${data['address']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Room Number: ${data['roomNumber']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Enrollment Date: ${data['enrollmentDate']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Leaving Date: ${data['leavingDate']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Security Deposit: ₹${data['securityDeposit']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Fees to be Paid: ₹${data['feesToBePaid']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Last Fee Paid: ₹${data['lastFeePaid']}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
