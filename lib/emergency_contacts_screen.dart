import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_contact_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference<Map<String, dynamic>>? contactsRef;

  @override
  void initState() {
    super.initState();
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      contactsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts');
    }
  }

  void _deleteContact(String contactId) async {
    if (contactsRef == null) return;

    await contactsRef!.doc(contactId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact deleted successfully')),
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (contactsRef == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Manage Emergency Contacts')),
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Emergency Contacts'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: contactsRef!.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading contacts'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No emergency contacts added yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final contact = docs[index].data();
              final contactId = docs[index].id;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(contact['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(contact['phone'] ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Delete contact',
                  onPressed: () async {
                    final confirmed = await _confirmDelete();
                    if (confirmed == true) {
                      _deleteContact(contactId);
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditContactScreen(
                        contactId: contactId,
                        initialName: contact['name'],
                        initialPhone: contact['phone'],
                        initialRelation: contact['relation'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add, size: 28),
        tooltip: 'Add new contact',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditContactScreen()),
          );
        },
      ),
    );
  }
}
