import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditContactScreen extends StatefulWidget {
  final String? contactId;
  final String? initialName;
  final String? initialPhone;
  final String? initialRelation;

  EditContactScreen({this.contactId, this.initialName, this.initialPhone, this.initialRelation});

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationController;

  bool _saving = false;
  CollectionReference<Map<String, dynamic>>? contactsRef;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _relationController = TextEditingController(text: widget.initialRelation ?? '');

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      contactsRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    if (contactsRef == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final name = _nameController.text.trim();
      final phoneInput = _phoneController.text.trim();
      final relation = _relationController.text.trim();

      String normalizePhone(String phone) {
        if (phone.startsWith('0')) {
          return '+88' + phone;
        } else if (!phone.startsWith('+')) {
          return '+' + phone;
        }
        return phone;
      }

      final normalizedPhone = normalizePhone(phoneInput);
      String? fcmToken;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        fcmToken = userSnapshot.docs.first.data()['fcmToken'];
        print('Found FCM token for $normalizedPhone');
      } else {
        print('No user found for $normalizedPhone');
      }

      final data = {
        'name': name,
        'phone': normalizedPhone,
        'relation': relation,
        'fcmToken': fcmToken,
        'addedAt': FieldValue.serverTimestamp(),
      };

      if (widget.contactId == null) {
        await contactsRef!.add(data);
      } else {
        await contactsRef!.doc(widget.contactId).update(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact saved successfully')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $e')));
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contactId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a name' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a phone number' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _relationController,
                decoration: InputDecoration(
                  labelText: 'Relation (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Contact' : 'Add Contact',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

